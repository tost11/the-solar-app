import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:mutex/mutex.dart';
import '../../../utils/modbus_utils.dart';

/// Standalone Modbus TCP connection for Deye Sun inverters
///
/// Implements custom Deye frame protocol wrapping standard Modbus commands.
/// Does NOT extend BaseDeviceService - designed to work alongside HTTP service.
///
/// Note: Reconnection is handled by BaseDeviceService, not this class.
class DeyeSunModbusConnection {
  static const int DEFAULT_PORT = 8899;
  static const int COMMAND_TIMEOUT_MS = 5000;
  static const int READ_BUFFER_LENGTH = 200;
  static const int MAX_COMMAND_RETRIES = 4; // Total attempts = 5 (initial + 4 retries)
  static const List<int> RETRY_DELAYS_MS = [250, 500, 1000, 2000]; // Exponential backoff delays

  // Modbus function codes
  static const int MODBUS_READ_HOLDING = 0x03;
  static const int MODBUS_WRITE_MULTIPLE = 0x10;

  // Connection state
  Socket? _socket;
  String? _ipAddress;
  int _port = DEFAULT_PORT;
  String? _serialNumber;
  bool _isConnecting = false;
  bool _isDisposed = false;

  // Timeouts and timers
  Timer? _commandTimeoutTimer;
  DateTime? _lastSuccessfulRead;
  bool _resetRedBytesNewCommand = false;

  // Response handling
  final Uint8List _readBuffer = Uint8List(READ_BUFFER_LENGTH);
  int _readBytes = 0;
  Completer<List<int>?>? _responseCompleter;

  DeyeSunModbusConnection();

  final Mutex _commandMutex = Mutex();

  /// Check if currently connected to the inverter
  bool get isConnected => _socket != null;

  /// Check if connection is healthy (recent successful read)
  bool get isHealthy {
    if (_lastSuccessfulRead == null) return false;
    final diff = DateTime.now().difference(_lastSuccessfulRead!);
    return diff.inMilliseconds < 30000; // Consider healthy if read within 30s
  }

  /// Connect to Deye Sun inverter via Modbus TCP
  Future<bool> connect(String ipAddress, int port, String serialNumber) async {
    if (_isDisposed) {
      debugPrint('[DeyeModbus] Cannot connect - connection disposed');
      return false;
    }

    _ipAddress = ipAddress;
    _port = port;
    _serialNumber = serialNumber;

    return await _connectSocket();
  }

  /// Internal socket connection method
  Future<bool> _connectSocket() async {
    if (_isConnecting || _socket != null) {
      return _socket != null;
    }

    _isConnecting = true;

    try {
      debugPrint('[DeyeModbus] Connecting to $_ipAddress:$_port...');

      _socket = await Socket.connect(
        _ipAddress!,
        _port,
        timeout: const Duration(seconds: 5),
      );

      _socket!.listen(
        _onDataReceived,
        onError: _onSocketError,
        onDone: _onSocketDone,
        cancelOnError: false,
      );

      _isConnecting = false;
      // No timer cancellation needed - BaseDeviceService handles reconnection

      debugPrint('[DeyeModbus] Connected successfully');
      return true;
    } catch (e) {
      debugPrint('[DeyeModbus] Connection failed: $e');
      _socket = null;
      _isConnecting = false;
      // No reconnection scheduling - BaseDeviceService handles it
      return false;
    }
  }

  /// Disconnect from the inverter
  Future<void> disconnect() async {
    // No reconnection timer to cancel - BaseDeviceService handles reconnection
    _cancelCommandTimeout();

    if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
      _responseCompleter!.complete(null);
    }
    _responseCompleter = null;

    try {
      await _socket?.close();
    } catch (e) {
      debugPrint('[DeyeModbus] Error closing socket: $e');
    }

    _socket = null;
    _lastSuccessfulRead = null;
  }

  /// Dispose of the connection (permanent shutdown)
  Future<void> dispose() async {
    _isDisposed = true;
    await disconnect();
  }

  /// Read holding registers from the inverter
  ///
  /// Returns list of 16-bit register values, or null on failure
  Future<List<int>?> readRegisters(int startRegister, int count) async {
    if (!isConnected) {
      debugPrint('[DeyeModbus] Cannot read - not connected');
      return null;
    }

    // Build Modbus read command (function 0x03)
    final modbusFrame = _buildReadModbusFrame(startRegister, count);
    final deyeFrame = _buildDeyeFrame(modbusFrame);

    final result = await _executeCommand(deyeFrame, 'DeyeModbus Read');

    if (result != null) {
      _lastSuccessfulRead = DateTime.now();
    }

    return result;
  }

  /// Write value to a register
  ///
  /// Returns true on success, false on failure
  Future<bool> writeRegister(int register, int value) async {
    if (!isConnected) {
      debugPrint('[DeyeModbus] Cannot write - not connected');
      return false;
    }

    // Build Modbus write command (function 0x10)
    final modbusFrame = _buildWriteModbusFrame(register, [value]);
    final deyeFrame = _buildDeyeFrame(modbusFrame);

    final result = await _executeCommand(deyeFrame, 'DeyeModbus Write');

    return result != null;
  }

  /// Execute a Modbus command with retry logic and exponential backoff
  ///
  /// Returns the raw response data, or null on failure
  /// Disconnects socket if all retries are exhausted
  Future<List<int>?> _executeCommand(
    List<int> deyeFrame,
    String commandName,
  ) async {
    // Check if another command is already in progress (prevent concurrent execution)
    if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
      debugPrint('[$commandName] Another command is in progress, aborting');
      return null;
    }

    int attempt = 0;

    while (attempt <= MAX_COMMAND_RETRIES) {
      if (!isConnected) {
        debugPrint('[$commandName] Not connected (attempt ${attempt + 1})');
        return null;
      }

      List<int>? result;

      await _commandMutex.protect(() async {
        _responseCompleter = Completer<List<int>?>();
        _readBytes = 0;

        try {
          _socket!.add(deyeFrame);
          _startCommandTimeout();

          result = await _responseCompleter!.future;
        } catch (e) {
          debugPrint('[$commandName] Error on attempt ${attempt + 1}: $e');
        } finally {
          _cancelCommandTimeout();
          _responseCompleter = null; // Clean up completer
        }
      });

      if (result != null) {
        return result;
      }

      attempt++;
      if (attempt <= MAX_COMMAND_RETRIES) {
        // Get delay for this retry attempt (exponential backoff)
        final delayMs = RETRY_DELAYS_MS[attempt - 1];
        debugPrint('[$commandName] Retry attempt $attempt after ${delayMs}ms delay');
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    // All retries exhausted - disconnect to trigger reconnection via BaseDeviceService
    debugPrint('[$commandName] All ${MAX_COMMAND_RETRIES + 1} attempts failed, disconnecting socket');
    await disconnect();

    return null;
  }

  /// Build Modbus read holding registers frame
  List<int> _buildReadModbusFrame(int startRegister, int count) {
    final startHex = ModbusUtils.lengthToHexString(startRegister, 4);
    final countHex = ModbusUtils.lengthToHexString(count, 4);
    final businessField = '0103$startHex$countHex';
    final crc = ModbusUtils.modbusCRC16(businessField);
    return ModbusUtils.hexToBytes(businessField + crc);
  }

  /// Build Modbus write multiple registers frame
  List<int> _buildWriteModbusFrame(int register, List<int> values) {
    final registerHex = ModbusUtils.lengthToHexString(register, 4);
    final countHex = ModbusUtils.lengthToHexString(values.length, 4);
    final byteCount = values.length * 2;
    final byteCountHex = ModbusUtils.lengthToString(byteCount, 2);

    // Build value bytes
    final valueBytes = <int>[];
    for (var value in values) {
      valueBytes.addAll(ModbusUtils.buildUint16(value));
    }
    final valueHex = ModbusUtils.bytesToHex(valueBytes);

    final businessField = '0110$registerHex$countHex$byteCountHex$valueHex';
    final crc = ModbusUtils.modbusCRC16(businessField);
    return ModbusUtils.hexToBytes(businessField + crc);
  }

  /// Build custom Deye frame wrapping Modbus command
  List<int> _buildDeyeFrame(List<int> modbusFrame) {
    // Parse serial number to hex bytes
    final serialNum = int.parse(_serialNumber!);
    final serialHex = serialNum.toRadixString(16).padLeft(8, '0').toUpperCase();

    // Byte swap serial number (reverse byte order)
    final serialBytes = [
      serialHex.substring(6, 8),
      serialHex.substring(4, 6),
      serialHex.substring(2, 4),
      serialHex.substring(0, 2),
    ].join();

    // Calculate frame length (control code to end of modbus frame)
    final frameLength = 13 + modbusFrame.length + 2; // +2 for checksum and end byte
    final lengthHex = ModbusUtils.lengthToHexString(frameLength, 4);
    // Swap bytes for little-endian
    final lengthBytes = lengthHex.substring(2, 4) + lengthHex.substring(0, 2);

    // Build frame components
    final start = 'A5';
    final controlCode = '1045';
    final serialFill = '0000';
    final dataField = '020000000000000000000000000000';

    // Combine all parts except checksum and end byte
    final frameBeforeChecksum =
        start + lengthBytes + controlCode + serialFill + serialBytes + dataField;
    final frameBytes = ModbusUtils.hexToBytes(frameBeforeChecksum);
    frameBytes.addAll(modbusFrame);

    // Calculate checksum (sum of all bytes after start byte)
    int checksum = 0;
    for (int i = 1; i < frameBytes.length; i++) {
      checksum += frameBytes[i];
    }
    checksum &= 0xFF;

    // Add checksum and end byte
    frameBytes.add(checksum);
    frameBytes.add(0x15);

    return frameBytes;
  }

  /// Handle incoming socket data
  void _onDataReceived(List<int> data) {
    if (_readBytes + data.length > READ_BUFFER_LENGTH) {
      debugPrint('[DeyeModbus] Read buffer overflow - resetting');
      _readBytes = 0;
      if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
        _responseCompleter!.complete(null);
      }
      return;
    }

    _readBuffer.setRange(_readBytes, _readBytes + data.length, data);
    _readBytes += data.length;

    _processReceivedData();
  }

  /// Process received data and extract response
  void _processReceivedData() {
    if (_responseCompleter == null || _responseCompleter!.isCompleted) {
      return;
    }

    // Check minimum frame size
    if (_readBytes < 29) {
      return; // Not enough data yet
    }

    // Validate frame start and end bytes
    if (_readBuffer[0] != 0xA5) {
      debugPrint('[DeyeModbus] Invalid start byte: ${_readBuffer[0].toRadixString(16)}');
      _readBytes = 0;
      _responseCompleter!.complete(null);
      return;
    }

    if (_readBuffer[_readBytes - 1] != 0x15) {
      return; // End byte not received yet
    }

    // Extract and validate Modbus frame
    final modbusStart = 25;
    final modbusEnd = _readBytes - 4; // Exclude checksum (1 byte) and end byte (1 byte) and frame checksum (2 bytes)

    if (modbusEnd <= modbusStart) {
      debugPrint('[DeyeModbus] Invalid frame length');
      _readBytes = 0;
      _responseCompleter!.complete(null);
      return;
    }

    final modbusFrame = _readBuffer.sublist(modbusStart, modbusEnd + 2); // Include CRC
    final functionCode = modbusFrame[1];

    if (functionCode == MODBUS_READ_HOLDING) {
      _handleReadResponse(modbusFrame);
    } else if (functionCode == MODBUS_WRITE_MULTIPLE) {
      _handleWriteResponse(modbusFrame);
    } else {
      debugPrint('[DeyeModbus] Unknown function code: $functionCode');
      _readBytes = 0;
      _responseCompleter!.complete(null);
    }
  }

  /// Handle read registers response
  void _handleReadResponse(Uint8List modbusFrame) {
    // Verify CRC
    final frameWithoutCrc = modbusFrame.sublist(0, modbusFrame.length - 2);
    final receivedCrc = ModbusUtils.bytesToHex(modbusFrame.sublist(modbusFrame.length - 2));
    final calculatedCrc = ModbusUtils.modbusCRC16(ModbusUtils.bytesToHex(frameWithoutCrc));

    if (receivedCrc != calculatedCrc) {
      debugPrint('[DeyeModbus] Read CRC mismatch: got $receivedCrc, expected $calculatedCrc');
      _readBytes = 0;
      _responseCompleter!.complete(null);
      return;
    }

    // Parse register data
    final byteCount = modbusFrame[2];
    final registerData = modbusFrame.sublist(3, 3 + byteCount);

    // Convert bytes to 16-bit register values
    final registers = <int>[];
    for (int i = 0; i < registerData.length; i += 2) {
      final value = (registerData[i] << 8) | registerData[i + 1];
      registers.add(value);
    }

    debugPrint('[DeyeModbus] Read ${registers.length} registers successfully');
    _readBytes = 0;
    _responseCompleter!.complete(registers);
  }

  /// Handle write registers response
  void _handleWriteResponse(Uint8List modbusFrame) {
    // Verify CRC
    final frameWithoutCrc = modbusFrame.sublist(0, modbusFrame.length - 2);
    final receivedCrc = ModbusUtils.bytesToHex(modbusFrame.sublist(modbusFrame.length - 2));
    final calculatedCrc = ModbusUtils.modbusCRC16(ModbusUtils.bytesToHex(frameWithoutCrc));

    if (receivedCrc != calculatedCrc) {
      debugPrint('[DeyeModbus] Write CRC mismatch: got $receivedCrc, expected $calculatedCrc');
      _readBytes = 0;
      _responseCompleter!.complete(null);
      return;
    }

    debugPrint('[DeyeModbus] Write successful');
    _readBytes = 0;
    _responseCompleter!.complete([1]); // Success indicator
  }

  /// Handle socket errors
  void _onSocketError(error) {
    debugPrint('[DeyeModbus] Socket error: $error');
    _socket = null;
    // No reconnection scheduling - BaseDeviceService detects via isConnected/isHealthy

    if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
      _responseCompleter!.complete(null);
    }
  }

  /// Handle socket disconnection
  void _onSocketDone() {
    debugPrint('[DeyeModbus] Socket disconnected');
    _socket = null;
    // No reconnection scheduling - BaseDeviceService detects via isConnected/isHealthy

    if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
      _responseCompleter!.complete(null);
    }
  }

  /// Start command timeout timer
  void _startCommandTimeout() {
    _cancelCommandTimeout();
    _commandTimeoutTimer = Timer(Duration(milliseconds: COMMAND_TIMEOUT_MS), () {
      debugPrint('[DeyeModbus] Command timeout');
      if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
        _responseCompleter!.complete(null);
      }
    });
  }

  /// Cancel command timeout timer
  void _cancelCommandTimeout() {
    _commandTimeoutTimer?.cancel();
    _commandTimeoutTimer = null;
  }
}
