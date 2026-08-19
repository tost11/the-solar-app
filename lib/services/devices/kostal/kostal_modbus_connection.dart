import 'dart:async';
import '../../../utils/debug_log.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:mutex/mutex.dart';

/// Standalone Modbus TCP connection for Kostal solar inverters
///
/// Implements standard Modbus TCP protocol (RFC 1001) for communication
/// with Kostal Plenticore and other compatible inverters.
///
/// Key Features:
/// - Standard Modbus TCP (no custom framing)
/// - Unit ID support (typically 71 for Kostal)
/// - Mutex-protected command execution
/// - Command timeout handling
/// - Health monitoring via last successful read timestamp
///
/// Note: Reconnection is handled by BaseDeviceService, not this class.
class KostalModbusConnection {
  static const int DEFAULT_PORT = 1502;
  static const int COMMAND_TIMEOUT_MS = 5000;
  static const int READ_BUFFER_LENGTH = 512;

  // Modbus function codes
  static const int MODBUS_READ_HOLDING = 0x03;
  static const int MODBUS_WRITE_SINGLE = 0x06;
  static const int MODBUS_WRITE_MULTIPLE = 0x10;

  // Connection state
  Socket? _socket;
  String? _ipAddress;
  int _port = DEFAULT_PORT;
  bool _isConnecting = false;
  bool _isDisposed = false;

  // Timeouts and timers
  Timer? _commandTimeoutTimer;
  DateTime? _lastSuccessfulRead;

  // Response handling
  final Uint8List _readBuffer = Uint8List(READ_BUFFER_LENGTH);
  int _readBytes = 0;
  Completer<Uint8List?>? _responseCompleter;
  int _transactionId = 0;

  KostalModbusConnection();

  final Mutex _commandMutex = Mutex();

  /// Check if currently connected to the inverter
  bool get isConnected => _socket != null;

  /// Check if connection is healthy (recent successful read)
  bool get isHealthy {
    if (_lastSuccessfulRead == null) return false;
    final diff = DateTime.now().difference(_lastSuccessfulRead!);
    return diff.inMilliseconds < 30000; // Consider healthy if read within 30s
  }

  /// Connect to Kostal inverter via Modbus TCP
  Future<bool> connect(String ipAddress, int port) async {
    if (_isDisposed) {
      DebugLog.device('[KostalModbus] Cannot connect - connection disposed', level: LogLevel.warning);
      return false;
    }

    _ipAddress = ipAddress;
    _port = port;

    return await _connectSocket();
  }

  /// Internal socket connection method
  Future<bool> _connectSocket() async {
    if (_isConnecting || _socket != null) {
      return _socket != null;
    }

    _isConnecting = true;

    try {
      DebugLog.device('[KostalModbus] Connecting to $_ipAddress:$_port...', level: LogLevel.debug);

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

      DebugLog.device('[KostalModbus] Connected successfully', level: LogLevel.debug);
      return true;
    } catch (e) {
      DebugLog.device('[KostalModbus] Connection failed: $e', level: LogLevel.error);
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
      DebugLog.device('[KostalModbus] Error closing socket: $e', level: LogLevel.error);
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
  Future<List<int>?> readRegisters(int startRegister, int count, int unitId) async {
    if (!isConnected) {
      DebugLog.device('[KostalModbus] Cannot read - not connected', level: LogLevel.warning);
      return null;
    }

    if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
      DebugLog.device('[KostalModbus] Cannot read - previous command still pending', level: LogLevel.warning);
      return null;
    }

    // Build Modbus TCP frame
    final frame = _buildReadFrame(startRegister, count, unitId);

    List<int>? ret;

    await _commandMutex.protect(() async {
      _responseCompleter = Completer<Uint8List?>();
      _readBytes = 0;

      try {
        _socket!.add(frame);
        _startCommandTimeout();

        final result = await _responseCompleter!.future;

        if (result != null) {
          ret = _parseReadResponse(result);
          if (ret != null) {
            _lastSuccessfulRead = DateTime.now();
          }
        }
      } catch (e) {
        DebugLog.device('[KostalModbus] Read error: $e', level: LogLevel.error);
      } finally {
        _cancelCommandTimeout();
      }
    });

    return ret;
  }

  /// Write value to a single register
  ///
  /// Returns true on success, false on failure
  Future<bool> writeRegister(int register, int value, int unitId) async {
    if (!isConnected) {
      DebugLog.device('[KostalModbus] Cannot write - not connected', level: LogLevel.warning);
      return false;
    }

    if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
      DebugLog.device('[KostalModbus] Cannot write - previous command still pending', level: LogLevel.warning);
      return false;
    }

    // Build Modbus TCP frame for single register write
    final frame = _buildWriteSingleFrame(register, value, unitId);

    var ret = false;

    await _commandMutex.protect(() async {
      _responseCompleter = Completer<Uint8List?>();
      _readBytes = 0;

      try {
        _socket!.add(frame);
        _startCommandTimeout();

        final result = await _responseCompleter!.future;

        if (result != null) {
          ret = _parseWriteResponse(result);
        }
      } catch (e) {
        DebugLog.device('[KostalModbus] Write error: $e', level: LogLevel.error);
      } finally {
        _cancelCommandTimeout();
      }
    });

    return ret;
  }

  /// Build Modbus TCP frame for reading holding registers
  Uint8List _buildReadFrame(int startRegister, int count, int unitId) {
    _transactionId = (_transactionId + 1) & 0xFFFF; // Increment and wrap at 16 bits

    final frame = ByteData(12);

    // MBAP Header
    frame.setUint16(0, _transactionId, Endian.big); // Transaction ID
    frame.setUint16(2, 0, Endian.big);               // Protocol ID (0 for Modbus)
    frame.setUint16(4, 6, Endian.big);               // Length (6 bytes PDU)

    // PDU
    frame.setUint8(6, unitId);                       // Unit ID
    frame.setUint8(7, MODBUS_READ_HOLDING);         // Function code
    frame.setUint16(8, startRegister, Endian.big);  // Start address
    frame.setUint16(10, count, Endian.big);         // Quantity

    return frame.buffer.asUint8List();
  }

  /// Build Modbus TCP frame for writing single register
  Uint8List _buildWriteSingleFrame(int register, int value, int unitId) {
    _transactionId = (_transactionId + 1) & 0xFFFF;

    final frame = ByteData(12);

    // MBAP Header
    frame.setUint16(0, _transactionId, Endian.big);
    frame.setUint16(2, 0, Endian.big);
    frame.setUint16(4, 6, Endian.big);

    // PDU
    frame.setUint8(6, unitId);
    frame.setUint8(7, MODBUS_WRITE_SINGLE);
    frame.setUint16(8, register, Endian.big);
    frame.setUint16(10, value, Endian.big);

    return frame.buffer.asUint8List();
  }

  /// Parse read registers response
  List<int>? _parseReadResponse(Uint8List data) {
    if (data.length < 9) {
      DebugLog.device('[KostalModbus] Response too short: ${data.length} bytes', level: LogLevel.error);
      return null;
    }

    final byteData = ByteData.view(data.buffer);

    // Parse MBAP header
    final protocolId = byteData.getUint16(2, Endian.big);
    final functionCode = byteData.getUint8(7);

    if (protocolId != 0) {
      DebugLog.device('[KostalModbus] Invalid protocol ID: $protocolId', level: LogLevel.error);
      return null;
    }

    if (functionCode == MODBUS_READ_HOLDING) {
      final byteCount = byteData.getUint8(8);

      if (data.length < 9 + byteCount) {
        DebugLog.device('[KostalModbus] Incomplete response', level: LogLevel.error);
        return null;
      }

      // Parse registers
      final registers = <int>[];
      for (int i = 0; i < byteCount; i += 2) {
        final value = byteData.getUint16(9 + i, Endian.big);
        registers.add(value);
      }

      //debugPrint('[KostalModbus] Read ${registers.length} registers successfully');
      return registers;
    } else if (functionCode >= 0x80) {
      // Error response
      final exceptionCode = byteData.getUint8(8);
      DebugLog.device('[KostalModbus] Modbus exception: $exceptionCode', level: LogLevel.error);
      return null;
    } else {
      DebugLog.device('[KostalModbus] Unexpected function code: $functionCode', level: LogLevel.error);
      return null;
    }
  }

  /// Parse write register response
  bool _parseWriteResponse(Uint8List data) {
    if (data.length < 12) {
      //debugPrint('[KostalModbus] Write response too short: ${data.length} bytes');
      return false;
    }

    final byteData = ByteData.view(data.buffer);
    final functionCode = byteData.getUint8(7);

    if (functionCode == MODBUS_WRITE_SINGLE) {
      DebugLog.device('[KostalModbus] Write successful', level: LogLevel.debug);
      return true;
    } else if (functionCode >= 0x80) {
      final exceptionCode = byteData.getUint8(8);
      DebugLog.device('[KostalModbus] Write exception: $exceptionCode', level: LogLevel.error);
      return false;
    }

    return false;
  }

  /// Handle incoming socket data
  void _onDataReceived(List<int> data) {
    if (_readBytes + data.length > READ_BUFFER_LENGTH) {
      DebugLog.device('[KostalModbus] Read buffer overflow - resetting', level: LogLevel.warning);
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

    // Check minimum frame size (MBAP header + function code)
    if (_readBytes < 8) {
      return; // Not enough data yet
    }

    // Parse MBAP header to get expected length
    final byteData = ByteData.view(_readBuffer.buffer);
    final length = byteData.getUint16(4, Endian.big);

    // Check if we have the complete frame
    final expectedLength = 6 + length; // MBAP header (6) + PDU (length)
    if (_readBytes < expectedLength) {
      return; // Wait for more data
    }

    // Extract complete frame
    final frame = Uint8List.fromList(_readBuffer.sublist(0, expectedLength));
    _readBytes = 0;

    // Complete the response
    _responseCompleter!.complete(frame);
  }

  /// Handle socket errors
  void _onSocketError(error) {
    DebugLog.device('[KostalModbus] Socket error: $error', level: LogLevel.error);
    _socket = null;
    // No reconnection scheduling - BaseDeviceService detects via isConnected/isHealthy

    if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
      _responseCompleter!.complete(null);
    }
  }

  /// Handle socket disconnection
  void _onSocketDone() {
    DebugLog.device('[KostalModbus] Socket disconnected', level: LogLevel.error);
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
      DebugLog.device('[KostalModbus] Command timeout', level: LogLevel.warning);
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

  // ===== Data Type Parsing Utilities =====

  /// Parse 32-bit float from two registers
  /// Kostal uses big endian byte order with little endian word order
  static double parseFloat(List<int> registers, int offset) {
    if (offset + 1 >= registers.length) return 0.0;

    final reg1 = registers[offset];     // High word (first register)
    final reg2 = registers[offset + 1]; // Low word (second register)

    // Word order: Little endian (low word first)
    // Byte order: Big endian within each word (high byte first)
    final bytes = Uint8List(4);
    bytes[0] = (reg2 >> 8) & 0xFF;  // High byte of low word
    bytes[1] = reg2 & 0xFF;         // Low byte of low word
    bytes[2] = (reg1 >> 8) & 0xFF;  // High byte of high word
    bytes[3] = reg1 & 0xFF;         // Low byte of high word

    // Interpret as big endian float
    return ByteData.view(bytes.buffer).getFloat32(0, Endian.big);
  }

  /// Parse 16-bit unsigned integer from single register
  static int parseUint16(List<int> registers, int offset) {
    if (offset >= registers.length) return 0;
    return registers[offset];
  }

  /// Parse 32-bit unsigned integer from two registers
  /// Kostal uses little endian word order
  static int parseUint32(List<int> registers, int offset) {
    if (offset + 1 >= registers.length) return 0;

    final low = registers[offset];
    final high = registers[offset + 1];
    return (high << 16) | low;
  }

  /// Parse 16-bit signed integer from single register
  static int parseInt16(List<int> registers, int offset) {
    if (offset >= registers.length) return 0;

    final value = registers[offset];
    // Convert to signed
    return value > 32767 ? value - 65536 : value;
  }

  /// Parse 8-character string from 8 registers
  static String parseString8(List<int> registers, int offset) {
    if (offset + 7 >= registers.length) return '';

    final bytes = <int>[];
    for (int i = 0; i < 8; i++) {
      final reg = registers[offset + i];
      bytes.add((reg >> 8) & 0xFF);  // High byte
      bytes.add(reg & 0xFF);          // Low byte
    }

    // Convert to string, removing null terminators
    return String.fromCharCodes(bytes.where((b) => b != 0));
  }
}
