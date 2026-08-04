import 'dart:async';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide LogLevel;
import 'package:mutex/mutex.dart';
import 'package:protobuf/protobuf.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/models/devices/manufacturers/hoymiles/protobuf/AppGetHistPower.pb.dart';
import 'package:the_solar_app/services/devices/bluetooth_device_service.dart';
import 'package:the_solar_app/services/devices/hoymiles/hoymiles_command_helper.dart';
import 'package:the_solar_app/services/devices/hoymiles/hoymiles_protocol.dart';
import 'package:the_solar_app/utils/hoymiles_crypto_utils.dart';
import 'package:the_solar_app/utils/debug_log.dart';
import 'package:uuid/uuid.dart';

import '../../../models/devices/manufacturers/hoymiles/hoymiles_bluetooth_device.dart';

/// Hoymiles HMS-WB Bluetooth Low Energy service.
///
/// Implements the full BLE protocol:
/// 1. V0 pairing (AES-128-CBC) to extract encRand
/// 2. CommCmd handshake (login + PIN + time-sync)
/// 3. V1 encrypted (AES-128-GCM) data fetching
///
/// The BLE protocol uses the same frame format and protobuf messages
/// as the WiFi TCP protocol, but adds encryption layers on top.
class HoymilesBluetoothService extends BluetoothDeviceService {
  late HoymilesBluetoothDevice _hoymilesDevice;

  final HoymilesProtocol _protocol = HoymilesProtocol();

  // BLE communication state
  final _responseBuffer = BytesBuilder();
  Completer<Uint8List>? _responseCompleter;
  final _sendMutex = Mutex();
  StreamSubscription<List<int>>? _notifySubscription;

  // Protocol state
  int _tid = 0;
  String _bleId = '';
  bool _handshakeComplete = false;

  // CommCmd action codes
  static const int _actionLogin = 64;
  static const int _actionPin = 82;
  static const int _actionTimeSync = 104;

  /// BLE protocol uses local timezone offset (seconds) instead of the
  /// WiFi protocol's hardcoded 28800 (CST). The hiflow-ble reference
  /// uses 3600 (CET) — we use the device's actual timezone offset.
  int get _bleOffset => DateTime.now().timeZoneOffset.inSeconds;

  // Command codes
  static const int _cmdAppInfo = 0xA301;
  static const int _cmdRealDataNew = 0xA311;
  static const int _cmdCommCmd = 0xA318;
  static const int _cmdCommStatus = 0xA319;
  static const int _cmdCommand = 0xA305;
  static const int _cmdGetConfig   = 0xA309;
  static const int _cmdSetConfig   = 0xA310;
  static const int _cmdNetworkInfo = 0xA314;
  static const int _cmdHistPower   = 0xA315;
  static const int _cmdHistED      = 0xA316;

  HoymilesBluetoothService(
    HoymilesBluetoothDevice device,
    BluetoothDevice bluetoothDevice,
  ) : super(
    updateTime: const Duration(seconds: 31),
    bluetoothDevice: bluetoothDevice,
    baseDevice: device,
    serviceUuid: HOYMILES_BLE_SERVICE_UUID,
    writeCharacteristicUuid: HOYMILES_BLE_TX_UUID,
    writeCharacteristicUuidShort: HOYMILES_BLE_TX_UUID_SHORT,
    notifyCharacteristicUuid: HOYMILES_BLE_RX_UUID,
    notifyCharacteristicUuidShort: HOYMILES_BLE_RX_UUID_SHORT,
  ) {
    _hoymilesDevice = device;
    // Reuse persisted bleId or generate a new one
    _bleId = device.bleId ?? _generateBleId();
  }

  /// Generate a BLE identity string using the same algorithm as the S-Miles app.
  ///
  /// Replicates `com.hoymiles.utils.BleIdUtil.b()`:
  /// 1. raw = str(currentTimeMillis) + str(randomUUID)
  /// 2. md5 = MD5(raw.encode("utf-8")) → 32 hex chars
  /// 3. digits = [int(c, 16) % 10 for c in md5]  → map hex to 0-9
  /// 4. Apply column-first permutation of 30 slots (6 rows × 5 cols)
  /// 5. Take first 18 digits → parse as integer (drops leading zeros)
  String _generateBleId() {
    final seed = '${DateTime.now().millisecondsSinceEpoch}${const Uuid().v4()}';
    final md5Hash = md5.convert(seed.codeUnits).toString();

    // Map hex chars to digits 0-9
    final digits = md5Hash.split('').map((c) => int.parse(c, radix: 16) % 10).toList();

    // Column-first permutation: 6 rows × 5 columns, read column by column
    // Indices: [0,5,10,15,20,25, 1,6,11,16,21,26, 2,7,12,17,22,27, 3,8,13,18,23,28, 4,9,14,19,24,29]
    const perm = [
      0, 5, 10, 15, 20, 25,
      1, 6, 11, 16, 21, 26,
      2, 7, 12, 17, 22, 27,
      3, 8, 13, 18, 23, 28,
      4, 9, 14, 19, 24, 29,
    ];
    final permuted = perm.map((i) => digits[i]).toList();

    // Take first 18 digits and parse as integer (removes leading zeros)
    final numStr = permuted.sublist(0, 18).join();
    return BigInt.parse(numStr).toString();
  }

  int _nextTid() {
    _tid = (_tid + 1) & 0xFFFF;
    return _tid;
  }

  // ==========================================================================
  // BluetoothDeviceService overrides
  // ==========================================================================

  @override
  bool validateCharacteristics() {
    return writeCharacteristic != null && notifyCharacteristic != null;
  }

  @override
  bool isConnected() {
    return super.isConnected() && _handshakeComplete;
  }

  @override
  Future<void> setupCharacteristics() async {
    // Subscribe to stream FIRST, then enable notifications
    // (ensures we don't miss any responses)
    _notifySubscription = notifyCharacteristic!.onValueReceived.listen(_onNotification);
    await notifyCharacteristic!.setNotifyValue(true);
    DebugLog.device('[HoymilesBLE] Notifications enabled on RX characteristic', level: LogLevel.debug);
  }

  @override
  Future<void> onDeviceConnected() async {
    // Small delay to let BLE stack settle
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> internalDisconnect() async {
    // Reset handshake state to prevent isConnected() from returning true
    // with a stale session after a failed reconnect handshake
    _handshakeComplete = false;

    // Cancel pending response completer so _sendMutex is released immediately
    // (avoids up to 10s deadlock if disconnect is called during _sendAndReceive)
    if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
      _responseCompleter!.completeError(Exception('Disconnected'));
    }
    _responseCompleter = null;
    _responseBuffer.clear();

    // Cancel notification subscription to prevent ghost listeners
    // from the global FBP broadcast stream
    await _notifySubscription?.cancel();
    _notifySubscription = null;

    await super.internalDisconnect();
  }

  @override
  Future<bool> internalConnect() async {
    // First do normal BLE connection (connect, discover services, setup chars)
    final connected = await super.internalConnect();
    if (!connected) return false;

    // Now do Hoymiles-specific handshake
    try {
      await _performHandshake();
      return true;
    } catch (e) {
      DebugLog.device('[HoymilesBLE] Handshake failed: $e', level: LogLevel.error);
      rethrow;
    }
  }

  @override
  Future<void> internalFetchData() async {
    final realData = await _fetchRealDataNew();
    if (realData != null) {
      device.data["data"] = realData;
      device.emitData(realData);
    } else {
      throw Exception('Failed to fetch data from Hoymiles BLE device');
    }
  }

  @override
  Future<bool> internalInitializeDevice() async {
    final result = await _fetchRealDataNew();
    if (result != null) {
      device.data["data"] = result;
      device.emitData(result);
    } else {
      throw Exception('Failed to fetch initial data from Hoymiles BLE device');
    }
    return false;
  }

  // ==========================================================================
  // Notification handling (frame buffering with length-based completion)
  // ==========================================================================

  /// V0 commands (no GCM tag appended to frame).
  /// Includes both request (0xA3xx) and response (0xA2xx) variants.
  static const Set<int> _v0Commands = {0xA301, 0xA201};

  void _onNotification(List<int> data) {
    DebugLog.device('[HoymilesBLE] RX notification: ${data.length} bytes', level: LogLevel.verbose);
    _responseBuffer.add(data);

    final assembled = _responseBuffer.toBytes();

    // Need at least 10 bytes for the header
    if (assembled.length < 10) return;

    // Validate magic "HM"
    if (assembled[0] != 0x48 || assembled[1] != 0x4D) {
      DebugLog.device('[HoymilesBLE] Invalid magic in buffer, clearing', level: LogLevel.warning);
      _responseBuffer.clear();
      return;
    }

    // Parse command and length from header
    final cmd = (assembled[2] << 8) | assembled[3];
    final length = (assembled[8] << 8) | assembled[9];

    // Determine expected total frame size:
    // V0 frames: just the length field value (header + ciphertext)
    // V1 frames: length + 16 (extra GCM auth tag)
    final isV0 = _v0Commands.contains(cmd);
    final expectedSize = isV0 ? length : length + 16;

    if (assembled.length >= expectedSize) {
      // TODO: Investigate TID handling — the device firmware responds with
      // tid+1 relative to what we send. The hiflow-ble Python reference does
      // NOT validate TID at all, relying on the mutex to ensure only one
      // request is in-flight. We follow the same approach here. If we ever
      // need multi-request pipelining, TID matching (with +1 offset) would
      // need to be added.

      // Frame complete — signal the waiter
      final completeFrame = Uint8List.fromList(assembled.sublist(0, expectedSize));
      if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
        _responseCompleter!.complete(completeFrame);
      }
    }
  }

  /// Send frame and wait for response via notifications.
  /// Protected by mutex to prevent concurrent sends.
  Future<Uint8List> _sendAndReceive(Uint8List frame, {Duration timeout = const Duration(seconds: 10)}) async {
    await _sendMutex.acquire();
    try {
      // Reset buffer
      _responseBuffer.clear();
      _responseCompleter = Completer<Uint8List>();

      // Write to TX characteristic (with response for reliability)
      // Use explicit 5s timeout to avoid holding _sendMutex for the full
      // FBP default (15s) if the device drops during write.
      await writeCharacteristic!.write(frame.toList(), withoutResponse: false, timeout: 5);

      // Wait for response (length-based detection will signal when frame is complete)
      try {
        final response = await _responseCompleter!.future.timeout(timeout);
        return response;
      } on TimeoutException {
        final buffered = _responseBuffer.toBytes();
        if (buffered.isNotEmpty) {
          DebugLog.device('[HoymilesBLE] Timeout but got ${buffered.length} bytes partial data', level: LogLevel.warning);
          return Uint8List.fromList(buffered);
        }
        throw TimeoutException('No response from device', timeout);
      }
    } finally {
      _sendMutex.release();
    }
  }

  // ==========================================================================
  // Handshake flow
  // ==========================================================================

  Future<void> _performHandshake() async {
    final serial = _hoymilesDevice.inverterSerial;

    // Step 1: V0 Pairing to get encRand (skip if already have it)
    if (_hoymilesDevice.encRand == null || _hoymilesDevice.encRand!.isEmpty) {
      DebugLog.device('[HoymilesBLE] Step 1: V0 Pairing (extracting encRand)...', level: LogLevel.debug);
      final encRand = await _extractEncRand(serial);
      _hoymilesDevice.encRand = _bytesToHex(encRand);
      DebugLog.device('[HoymilesBLE] Got encRand: ${_hoymilesDevice.encRand}', level: LogLevel.debug);
    } else {
      DebugLog.device('[HoymilesBLE] Using stored encRand: ${_hoymilesDevice.encRand}', level: LogLevel.debug);
    }

    // Step 2: CommCmd handshake (always needed per session)
    DebugLog.device('[HoymilesBLE] Step 2: CommCmd Handshake...', level: LogLevel.debug);
    await Future.delayed(const Duration(seconds: 1)); // Device transition time

    final encRand = _hexToBytes(_hoymilesDevice.encRand!);

    // Action 64: Login with bleId
    DebugLog.device('[HoymilesBLE] Action 64 (login): bleId=$_bleId', level: LogLevel.debug);
    final loginSts = await _commCmdSend(encRand, _actionLogin, _bleId);

    if (loginSts == 3) {
      // Need PIN - use stored authPassword or fallback to default
      var pin = _hoymilesDevice.authPassword;
      if (pin == null || pin.isEmpty) {
        pin = HOYMILES_BLE_DEFAULT_PIN;
      }

      DebugLog.device('[HoymilesBLE] Action 82 (PIN): submitting...', level: LogLevel.debug);
      final pinSts = await _commCmdSend(encRand, _actionPin, pin);
      if (pinSts != 0) {
        throw Exception('BLE PIN rejected (status=$pinSts). Check PIN in device settings.');
      }
      DebugLog.device('[HoymilesBLE] PIN accepted, bleId whitelisted', level: LogLevel.debug);
      // Persist bleId — it's now whitelisted on the device
      _hoymilesDevice.bleId = _bleId;
    } else if (loginSts == 1) {
      DebugLog.device('[HoymilesBLE] bleId already whitelisted, skipping PIN', level: LogLevel.debug);
      // Persist bleId if not yet stored
      _hoymilesDevice.bleId ??= _bleId;
    } else if (loginSts != 0) {
      DebugLog.device('[HoymilesBLE] Unexpected login status: $loginSts', level: LogLevel.warning);
    }

    // Action 104: Time sync (with carriage return like hiflow-ble)
    final tzOffset = DateTime.now().timeZoneOffset.inSeconds;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeData = '$now,$tzOffset\r';
    DebugLog.device('[HoymilesBLE] Action 104 (time-sync): $timeData', level: LogLevel.debug);
    await _commCmdSend(encRand, _actionTimeSync, timeData);

    DebugLog.device('[HoymilesBLE] Handshake complete!', level: LogLevel.debug);
    _handshakeComplete = true;
  }

  // ==========================================================================
  // Step 1: V0 Pairing - extract encRand
  // ==========================================================================

  Future<Uint8List> _extractEncRand(String serial) async {
    final tid = _nextTid();

    // Build APPInfoDataResDTO request protobuf
    final plaintext = _buildAppInfoRequest();
    DebugLog.device('[HoymilesBLE] V0 plaintext (${plaintext.length} bytes): ${_bytesToHex(plaintext)}', level: LogLevel.verbose);
    DebugLog.device('[HoymilesBLE] Serial for key derivation: "$serial" (${serial.length} chars)', level: LogLevel.verbose);

    // Encrypt with V0 AES-CBC
    final ciphertext = await HoymilesCryptoUtils.encryptV0(plaintext, serial, _cmdAppInfo, tid);
    DebugLog.device('[HoymilesBLE] V0 ciphertext (${ciphertext.length} bytes): ${_bytesToHex(ciphertext)}', level: LogLevel.verbose);

    // Build frame: HM + cmd + tid + crc + length + ciphertext
    final frame = _buildFrame(_cmdAppInfo, tid, ciphertext, includesTag: false);
    DebugLog.device('[HoymilesBLE] V0 frame (${frame.length} bytes): ${_bytesToHex(frame)}', level: LogLevel.verbose);

    DebugLog.device('[HoymilesBLE] Sending APPInfoData (tid=$tid, ${frame.length} bytes)', level: LogLevel.verbose);
    final response = await _sendAndReceive(frame);
    DebugLog.device('[HoymilesBLE] Got V0 response: ${response.length} bytes', level: LogLevel.verbose);

    // Parse frame header
    final respCmd = (response[2] << 8) | response[3];
    final respTid = (response[4] << 8) | response[5];
    final respLength = (response[8] << 8) | response[9];

    // Extract and decrypt ciphertext
    final respCiphertext = response.sublist(10, respLength);
    final respPlaintext = await HoymilesCryptoUtils.decryptV0(respCiphertext, serial, respCmd, respTid);

    DebugLog.device('[HoymilesBLE] Decrypted V0 response: ${respPlaintext.length} bytes', level: LogLevel.verbose);

    // Parse protobuf to find encRand (field 2 → nested → field 27, 16 bytes)
    final encRand = _findEncRandInProtobuf(respPlaintext);
    if (encRand == null || encRand.length != 16) {
      throw Exception('Could not find encRand in APPInfoData response');
    }

    return encRand;
  }

  // ==========================================================================
  // Step 2: CommCmd handshake
  // ==========================================================================

  /// Send a CommCmd and poll for status. Returns sts value.
  ///
  /// Protocol (from hiflow-ble reference):
  /// 1. Send CommCmdResDTO (0xA318) with action + data
  /// 2. Poll CommCmdStatusResDTO (0xA319) in a loop until sts != 0 (in-progress)
  ///
  /// sts semantics per action:
  ///   action=64: 0=in-progress, 1=OK (whitelisted), 3=PIN-needed
  ///   action=82: 0=SUCCESS (PIN accepted), 1=wrong PIN
  ///   action=104: 0=OK
  Future<int> _commCmdSend(Uint8List encRand, int action, String data) async {
    // Step 1: Send command (CMD_COMM_CMD = 0xA318)
    final tid = _nextTid();
    final plaintext = _buildCommCmdResRequest(action, data);
    final ctWithTag = await HoymilesCryptoUtils.encryptV1(plaintext, encRand, _cmdCommCmd, tid);

    // Split ciphertext and tag for frame building
    final ciphertext = ctWithTag.sublist(0, ctWithTag.length - 16);
    final tag = ctWithTag.sublist(ctWithTag.length - 16);
    final frame = _buildFrameWithTag(_cmdCommCmd, tid, ciphertext, tag);

    DebugLog.device('[HoymilesBLE] Sending CommCmd (action=$action, tid=$tid)', level: LogLevel.verbose);
    final response = await _sendAndReceive(frame);

    // Decrypt response (ACK from device)
    try {
      await _decryptV1Response(response, encRand);
    } catch (e) {
      DebugLog.device('[HoymilesBLE] Failed to decrypt CommCmd ACK: $e', level: LogLevel.error);
      // If no ACK at all, device may be dormant or encRand stale
      return -1;
    }

    // Step 2: Poll for status (CMD_COMM_STATUS = 0xA319) with retry loop
    // action=64/104: poll up to 5 times with 1s delay
    // action=82 (PIN): poll up to 8 times with 1s delay
    final maxPolls = action == _actionPin ? 8 : 5;

    for (int poll = 0; poll < maxPolls; poll++) {
      await Future.delayed(const Duration(seconds: 1));

      final tid2 = _nextTid();
      final pollPlaintext = _buildCommCmdStatusRequest(action);
      final pollCtWithTag = await HoymilesCryptoUtils.encryptV1(pollPlaintext, encRand, _cmdCommStatus, tid2);

      final pollCiphertext = pollCtWithTag.sublist(0, pollCtWithTag.length - 16);
      final pollTag = pollCtWithTag.sublist(pollCtWithTag.length - 16);
      final pollFrame = _buildFrameWithTag(_cmdCommStatus, tid2, pollCiphertext, pollTag);

      DebugLog.device('[HoymilesBLE] Polling status (action=$action, attempt=${poll + 1}/$maxPolls, tid=$tid2)', level: LogLevel.verbose);
      final pollResponse = await _sendAndReceive(pollFrame);

      // Decrypt poll response
      Uint8List pollPlaintextResp;
      try {
        pollPlaintextResp = await _decryptV1Response(pollResponse, encRand);
      } catch (e) {
        DebugLog.device('[HoymilesBLE] Failed to decrypt poll response: $e', level: LogLevel.error);
        continue;
      }

      // Parse protobuf: field 3=action, field 11=sts
      final fields = _decodeProtobuf(pollPlaintextResp);
      int sts = _getFieldInt(fields, 11, defaultVal: -1);

      DebugLog.device('[HoymilesBLE] CommCmd poll: sts=$sts (fields: ${fields.keys.toList()})', level: LogLevel.verbose);

      // For action=64: sts=0 means "in-progress" → keep polling
      if (action == _actionLogin && sts == 0) {
        continue;
      }

      // For any action: sts != -1 means we got a definitive answer
      if (sts != -1) {
        return sts;
      }

      // If sts field missing but we got a response, try alternative fields
      // Field 3=action confirms which action this is about
      // In proto3, sts=0 not serialized → if we got a valid response, assume 0
      if (fields.isNotEmpty && sts == -1) {
        // For action=82/104: missing sts field likely means sts=0 (success)
        if (action != _actionLogin) {
          DebugLog.device('[HoymilesBLE] No sts field in response, assuming success for action=$action', level: LogLevel.warning);
          return 0;
        }
      }
    }

    DebugLog.device('[HoymilesBLE] CommCmd polling exhausted for action=$action', level: LogLevel.warning);
    return -1;
  }

  // ==========================================================================
  // Step 3: Fetch RealDataNew
  // ==========================================================================

  Future<Map<String, dynamic>?> _fetchRealDataNew() async {
    final request = HoymilesCommandHelper.buildRealDataNewRequest(offset: _bleOffset);
    final responseBytes = await _sendProtobufCommand(_cmdRealDataNew, request);
    return HoymilesCommandHelper.parseRealDataNewResponse(responseBytes);
  }

  // ==========================================================================
  // Public command methods (shared protobuf logic via HoymilesCommandHelper)
  // ==========================================================================

  /// Send a protobuf command over BLE with V1 encryption.
  /// Returns decrypted response plaintext bytes.
  Future<Uint8List> _sendProtobufCommand(int cmd, GeneratedMessage request) async {
    final encRandHex = _hoymilesDevice.encRand;
    if (encRandHex == null || encRandHex.isEmpty) {
      throw Exception('Not paired - encRand not available');
    }
    final encRand = _hexToBytes(encRandHex);
    final tid = _nextTid();

    final plaintext = Uint8List.fromList(request.writeToBuffer());
    final ctWithTag = await HoymilesCryptoUtils.encryptV1(plaintext, encRand, cmd, tid);

    final ciphertext = ctWithTag.sublist(0, ctWithTag.length - 16);
    final tag = ctWithTag.sublist(ctWithTag.length - 16);
    final frame = _buildFrameWithTag(cmd, tid, ciphertext, tag);

    final response = await _sendAndReceive(frame);
    return await _decryptV1Response(response, encRand);
  }

  /// Get real-time data (public, for sendCommand use)
  Future<Map<String, dynamic>?> getRealDataNew() => _fetchRealDataNew();

  /// Get network information
  Future<Map<String, dynamic>?> getNetworkInfo() async {
    final request = HoymilesCommandHelper.buildNetworkInfoRequest(offset: _bleOffset);
    final responseBytes = await _sendProtobufCommand(_cmdNetworkInfo, request);
    return HoymilesCommandHelper.parseNetworkInfoResponse(responseBytes);
  }

  /// Get device information (formatted flat map from current config).
  Future<Map<String, dynamic>?> getDeviceInformation() async {
    final config = await getConfig();
    if (config == null) {
      throw Exception("Konnte Konfiguration nicht laden");
    }
    return HoymilesCommandHelper.extractDeviceInformation(config);
  }

  /// Get device configuration
  Future<Map<String, dynamic>?> getConfig() async {
    final request = HoymilesCommandHelper.buildGetConfigRequest(offset: _bleOffset);
    final responseBytes = await _sendProtobufCommand(_cmdGetConfig, request);
    return HoymilesCommandHelper.parseGetConfigResponse(responseBytes);
  }

  /// Set power limit (0-100%)
  Future<void> setPowerLimit(int limitPercent) async {
    final request = HoymilesCommandHelper.buildSetPowerLimitRequest(limitPercent);
    final responseBytes = await _sendProtobufCommand(_cmdCommand, request);
    HoymilesCommandHelper.validateCommandResponse(responseBytes);
    DebugLog.device('[HoymilesBLE] Power limit set to $limitPercent%', level: LogLevel.debug);
  }

  /// Reboot the DTU. The BLE link drops during restart.
  Future<void> restartDtu() async {
    final request = HoymilesCommandHelper.buildRestartDtuRequest();
    final responseBytes = await _sendProtobufCommand(_cmdCommand, request);
    HoymilesCommandHelper.validateCommandResponse(responseBytes);
    DebugLog.device('[HoymilesBLE] DTU restart command sent', level: LogLevel.debug);
  }

  /// Reboot a specific inverter.
  Future<void> rebootInverter(String inverterSerial) async {
    final request = HoymilesCommandHelper.buildRebootInverterRequest(inverterSerial);
    final responseBytes = await _sendProtobufCommand(_cmdCommand, request);
    HoymilesCommandHelper.validateCommandResponse(responseBytes);
    DebugLog.device('[HoymilesBLE] Inverter reboot command sent ($inverterSerial)', level: LogLevel.debug);
  }

  /// Turn on (re-enable output of) a specific inverter.
  Future<void> turnOnInverter(String inverterSerial) async {
    final request = HoymilesCommandHelper.buildTurnOnInverterRequest(inverterSerial);
    final responseBytes = await _sendProtobufCommand(_cmdCommand, request);
    HoymilesCommandHelper.validateCommandResponse(responseBytes);
    DebugLog.device('[HoymilesBLE] Inverter turn-on command sent ($inverterSerial)', level: LogLevel.debug);
  }

  /// Turn off (shut down output of) a specific inverter.
  Future<void> turnOffInverter(String inverterSerial) async {
    final request = HoymilesCommandHelper.buildTurnOffInverterRequest(inverterSerial);
    final responseBytes = await _sendProtobufCommand(_cmdCommand, request);
    HoymilesCommandHelper.validateCommandResponse(responseBytes);
    DebugLog.device('[HoymilesBLE] Inverter turn-off command sent ($inverterSerial)', level: LogLevel.debug);
  }

  /// Fetch the intraday historical power curve (paged, merged across pages).
  Future<Map<String, dynamic>?> getHistPower() async {
    // Page 0
    final firstBytes = await _sendProtobufCommand(
      _cmdHistPower,
      HoymilesCommandHelper.buildGetHistPowerRequest(cp: 0, offset: _bleOffset),
    );
    final combined = AppGetHistPowerReqDTO.fromBuffer(firstBytes);
    final initialAbsoluteStart = combined.absoluteStart;
    final totalPages = combined.ap;

    // Remaining pages 1..ap-1
    for (var cp = 1; cp < totalPages; cp++) {
      try {
        final pageBytes = await _sendProtobufCommand(
          _cmdHistPower,
          HoymilesCommandHelper.buildGetHistPowerRequest(cp: cp, offset: _bleOffset),
        );
        combined.mergeFromBuffer(pageBytes);
      } catch (e) {
        DebugLog.device('[HoymilesBLE] Failed to fetch hist power page $cp: $e', level: LogLevel.warning);
      }
    }
    combined.absoluteStart = initialAbsoluteStart;

    return HoymilesCommandHelper.buildHistPowerResult(combined);
  }

  /// Fetch the historical daily-energy list.
  Future<Map<String, dynamic>?> getHistEnergy() async {
    final responseBytes = await _sendProtobufCommand(
      _cmdHistED,
      HoymilesCommandHelper.buildGetHistEDRequest(offset: _bleOffset),
    );
    return HoymilesCommandHelper.parseHistEDResponse(responseBytes);
  }

  /// Set WiFi configuration (read-modify-write)
  Future<void> setWifiConfig(String ssid, String password) async {
    // 1. Get current config
    final getConfigRequest = HoymilesCommandHelper.buildGetConfigRequest(offset: _bleOffset);
    final currentConfigBytes = await _sendProtobufCommand(_cmdGetConfig, getConfigRequest);
    final currentConfig = HoymilesCommandHelper.parseGetConfigProto(currentConfigBytes);

    // 2. Build SetConfig with new WiFi credentials
    final setConfigRequest = HoymilesCommandHelper.buildSetWifiConfigRequest(currentConfig, ssid, password);

    // 3. Send SetConfig
    final responseBytes = await _sendProtobufCommand(_cmdSetConfig, setConfigRequest);
    HoymilesCommandHelper.validateSetConfigResponse(responseBytes);
    DebugLog.device('[HoymilesBLE] WiFi config set successfully', level: LogLevel.debug);
  }

  // ==========================================================================
  // Frame building helpers
  // ==========================================================================

  /// Build frame without GCM tag (V0 frames).
  Uint8List _buildFrame(int cmd, int tid, Uint8List ciphertext, {required bool includesTag}) {
    final crc = _protocol.calculateCrc16(ciphertext.toList());
    final length = ciphertext.length + 10;

    DebugLog.device('[HoymilesBLE] Frame: cmd=0x${cmd.toRadixString(16)}, tid=$tid, crc=0x${crc.toRadixString(16)}, length=$length', level: LogLevel.verbose);

    final builder = BytesBuilder();
    builder.add([0x48, 0x4D]); // "HM"
    builder.addByte((cmd >> 8) & 0xFF);
    builder.addByte(cmd & 0xFF);
    builder.addByte((tid >> 8) & 0xFF);
    builder.addByte(tid & 0xFF);
    builder.addByte((crc >> 8) & 0xFF);
    builder.addByte(crc & 0xFF);
    builder.addByte((length >> 8) & 0xFF);
    builder.addByte(length & 0xFF);
    builder.add(ciphertext);
    return Uint8List.fromList(builder.toBytes());
  }

  /// Build frame with separate GCM tag (V1 frames).
  /// CRC is computed over ciphertext only (not tag).
  /// Length = len(ciphertext) + 10.
  Uint8List _buildFrameWithTag(int cmd, int tid, Uint8List ciphertext, Uint8List tag) {
    final crc = _protocol.calculateCrc16(ciphertext.toList());
    final length = ciphertext.length + 10;

    final builder = BytesBuilder();
    builder.add([0x48, 0x4D]); // "HM"
    builder.addByte((cmd >> 8) & 0xFF);
    builder.addByte(cmd & 0xFF);
    builder.addByte((tid >> 8) & 0xFF);
    builder.addByte(tid & 0xFF);
    builder.addByte((crc >> 8) & 0xFF);
    builder.addByte(crc & 0xFF);
    builder.addByte((length >> 8) & 0xFF);
    builder.addByte(length & 0xFF);
    builder.add(ciphertext);
    builder.add(tag); // 16-byte GCM tag appended after frame
    return Uint8List.fromList(builder.toBytes());
  }

  /// Decrypt a V1 response frame. Returns decrypted plaintext.
  Future<Uint8List> _decryptV1Response(Uint8List response, Uint8List encRand) async {
    if (response.length < 10) {
      throw Exception('Response too short: ${response.length} bytes');
    }

    final respCmd = (response[2] << 8) | response[3];
    final respTid = (response[4] << 8) | response[5];
    final respLength = (response[8] << 8) | response[9];

    // Ciphertext is from offset 10 to respLength
    final ciphertext = response.sublist(10, respLength);
    // GCM tag is the 16 bytes after the ciphertext
    final tag = response.sublist(respLength, respLength + 16);

    // Combine ciphertext + tag for decryption
    final ctWithTag = Uint8List(ciphertext.length + tag.length);
    ctWithTag.setAll(0, ciphertext);
    ctWithTag.setAll(ciphertext.length, tag);

    return await HoymilesCryptoUtils.decryptV1(ctWithTag, encRand, respCmd, respTid);
  }

  // ==========================================================================
  // Protobuf builders (minimal, matching Python script)
  // ==========================================================================

  /// Build APPInfoDataResDTO request protobuf.
  Uint8List _buildAppInfoRequest() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeStr = _formatTimeStr();

    final builder = BytesBuilder();
    builder.add(_encodeFieldBytes(1, Uint8List.fromList(timeStr.codeUnits))); // time_ymd_hms
    builder.add(_encodeFieldVarint(4, _bleOffset));                           // offset
    builder.add(_encodeFieldVarint(5, now));                                   // time
    return Uint8List.fromList(builder.toBytes());
  }

  /// Build CommCmdResDTO for sending commands (0xA318).
  /// Wire encoding: field 1=time, 2=action, 5=tid, 6=data
  Uint8List _buildCommCmdResRequest(int action, String data) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final builder = BytesBuilder();
    builder.add(_encodeFieldVarint(1, now));                // time
    builder.add(_encodeFieldVarint(2, action));            // action
    builder.add(_encodeFieldVarint(5, now));               // tid
    if (data.isNotEmpty) {
      builder.add(_encodeFieldBytes(6, Uint8List.fromList(data.codeUnits))); // data
    }
    return Uint8List.fromList(builder.toBytes());
  }

  /// Build CommCmdStatusResDTO for polling status (0xA319).
  /// Wire encoding: field 1=time, 2=action, 4=tid (NOT field 5, NO data field)
  Uint8List _buildCommCmdStatusRequest(int action) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final builder = BytesBuilder();
    builder.add(_encodeFieldVarint(1, now));                // time
    builder.add(_encodeFieldVarint(2, action));            // action
    builder.add(_encodeFieldVarint(4, now));               // tid (field 4!)
    return Uint8List.fromList(builder.toBytes());
  }

  // ==========================================================================
  // Minimal protobuf encoder/decoder
  // ==========================================================================

  Uint8List _encodeVarint(int value) {
    final result = <int>[];
    while (value > 0x7F) {
      result.add((value & 0x7F) | 0x80);
      value >>= 7;
    }
    result.add(value & 0x7F);
    return Uint8List.fromList(result);
  }

  Uint8List _encodeFieldVarint(int fieldNum, int value) {
    final tag = (fieldNum << 3) | 0; // wire type 0 = varint
    final builder = BytesBuilder();
    builder.add(_encodeVarint(tag));
    builder.add(_encodeVarint(value));
    return Uint8List.fromList(builder.toBytes());
  }

  Uint8List _encodeFieldBytes(int fieldNum, Uint8List value) {
    final tag = (fieldNum << 3) | 2; // wire type 2 = length-delimited
    final builder = BytesBuilder();
    builder.add(_encodeVarint(tag));
    builder.add(_encodeVarint(value.length));
    builder.add(value);
    return Uint8List.fromList(builder.toBytes());
  }

  /// Decode protobuf wire format into {fieldNum: [values]}.
  Map<int, List<dynamic>> _decodeProtobuf(Uint8List data) {
    final fields = <int, List<dynamic>>{};
    int pos = 0;

    while (pos < data.length) {
      final tagResult = _decodeVarint(data, pos);
      final tag = tagResult.$1;
      pos = tagResult.$2;

      final fieldNum = tag >> 3;
      final wireType = tag & 0x07;

      dynamic value;
      if (wireType == 0) {
        // Varint
        final result = _decodeVarint(data, pos);
        value = result.$1;
        pos = result.$2;
      } else if (wireType == 2) {
        // Length-delimited
        final lenResult = _decodeVarint(data, pos);
        final length = lenResult.$1;
        pos = lenResult.$2;
        value = data.sublist(pos, pos + length);
        pos += length;
      } else if (wireType == 5) {
        // 32-bit fixed
        value = data.buffer.asByteData().getUint32(pos, Endian.little);
        pos += 4;
      } else if (wireType == 1) {
        // 64-bit fixed
        value = data.buffer.asByteData().getUint64(pos, Endian.little);
        pos += 8;
      } else {
        break; // Unknown wire type
      }

      fields.putIfAbsent(fieldNum, () => []);
      fields[fieldNum]!.add(value);
    }

    return fields;
  }

  (int, int) _decodeVarint(Uint8List data, int pos) {
    int value = 0;
    int shift = 0;
    while (pos < data.length) {
      final b = data[pos];
      pos++;
      value |= (b & 0x7F) << shift;
      shift += 7;
      if ((b & 0x80) == 0) break;
    }
    return (value, pos);
  }

  int _getFieldInt(Map<int, List<dynamic>> fields, int num, {int defaultVal = 0}) {
    final values = fields[num];
    if (values == null || values.isEmpty) return defaultVal;
    return values[0] as int;
  }

  // ==========================================================================
  // encRand extraction from protobuf
  // ==========================================================================

  /// Find encRand (16-byte value at field 27) in nested protobuf structure.
  Uint8List? _findEncRandInProtobuf(Uint8List data) {
    final fields = _decodeProtobuf(data);

    // Direct field 27
    final direct = _checkField27(fields);
    if (direct != null) return direct;

    // Check field 2 (dtu_info nested message)
    if (fields.containsKey(2)) {
      for (final nested in fields[2]!) {
        if (nested is Uint8List) {
          try {
            final nestedFields = _decodeProtobuf(nested);
            final result = _checkField27(nestedFields);
            if (result != null) return result;
          } catch (_) {}
        }
      }
    }

    // Recursive search all bytes fields
    return _searchNestedEncRand(fields, 0);
  }

  Uint8List? _checkField27(Map<int, List<dynamic>> fields) {
    if (fields.containsKey(27)) {
      final val = fields[27]![0];
      if (val is Uint8List && val.length == 16) return val;
    }
    return null;
  }

  Uint8List? _searchNestedEncRand(Map<int, List<dynamic>> fields, int depth) {
    if (depth > 5) return null;

    final direct = _checkField27(fields);
    if (direct != null) return direct;

    for (final values in fields.values) {
      for (final val in values) {
        if (val is Uint8List && val.length > 4) {
          try {
            final nested = _decodeProtobuf(val);
            final result = _searchNestedEncRand(nested, depth + 1);
            if (result != null) return result;
          } catch (_) {}
        }
      }
    }
    return null;
  }

  // ==========================================================================
  // Utility helpers
  // ==========================================================================

  String _formatTimeStr() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Uint8List _hexToBytes(String hex) {
    final bytes = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  @override
  void dispose() {
    _notifySubscription?.cancel();
    _notifySubscription = null;
    _handshakeComplete = false;
    super.dispose();
  }
}
