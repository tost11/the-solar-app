import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

import '../../../utils/debug_log.dart';
import 'hoymiles_protocol.dart';

/// Connection state tracking
enum HoymilesConnectionState {
  offline,
  connected,
  connecting,
  error,
}

/// Pending request context for tracking request metadata
class PendingRequest {
  final Completer<Map<String, dynamic>?> completer;
  final DateTime sentAt;
  final List<int> commandTag;

  PendingRequest({
    required this.completer,
    required this.sentAt,
    required this.commandTag,
  });
}

/// Persistent TCP connection handler for Hoymiles DTU devices
///
/// This class maintains a single persistent socket connection and uses sequence numbers
/// to match responses to requests. Implements keep-alive mechanism and automatic
/// reconnection logic.
class HoymilesTcpConnection {
  final String host;
  final int port;
  final HoymilesProtocol protocol;

  Socket? _socket;
  StreamSubscription<Uint8List>? _socketSubscription;
  Timer? _keepAliveTimer;

  // Pending requests map: sequence number -> request context
  final Map<int, PendingRequest> _pendingRequests = {};

  // Receive buffer for accumulating fragmented TCP data
  final BytesBuilder _receiveBuffer = BytesBuilder();

  HoymilesConnectionState _connectionState = HoymilesConnectionState.offline;
  bool _isDisposed = false;

  // Constants
  static const Duration keepAliveDuration = Duration(seconds: 10);
  static const Duration requestTimeout = Duration(seconds: 10);
  static const Duration historyRequestTimeout = Duration(seconds: 20);

  HoymilesTcpConnection({
    required this.host,
    required this.port,
    required this.protocol,
  });

  /// Get current connection state
  HoymilesConnectionState get connectionState => _connectionState;

  /// Check if connection is alive by checking socket status
  bool get isConnected =>
      _socket != null &&
      _connectionState == HoymilesConnectionState.connected;

  /// Connect to the DTU device
  Future<bool> connect() async {
    if (_isDisposed) {
      DebugLog.device('[HoymilesTcp] Cannot connect: already disposed', level: LogLevel.warning);
      return false;
    }

    if (isConnected) {
      DebugLog.device('[HoymilesTcp] Already connected', level: LogLevel.debug);
      return true;
    }

    try {
      DebugLog.device('[HoymilesTcp] Connecting to $host:$port...', level: LogLevel.debug);
      _connectionState = HoymilesConnectionState.connecting;

      _socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );

      DebugLog.device('[HoymilesTcp] Connected successfully', level: LogLevel.debug);
      _connectionState = HoymilesConnectionState.connected;

      // Listen to incoming data
      _socketSubscription = _socket!.listen(
        _handleIncomingData,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );

      // Start keep-alive timer
      _startKeepAliveTimer();

      return true;
    } catch (e) {
      DebugLog.device('[HoymilesTcp] Connection error: $e', level: LogLevel.error);
      _connectionState = HoymilesConnectionState.error;
      // Reconnection will be handled by service layer
      return false;
    }
  }

  /// Disconnect from the DTU device
  Future<void> disconnect() async {
    DebugLog.device('[HoymilesTcp] Disconnecting...', level: LogLevel.debug);

    _stopKeepAliveTimer();

    // Complete all pending requests with null (connection lost)
    for (final pending in _pendingRequests.values) {
      if (!pending.completer.isCompleted) {
        pending.completer.complete(null);
      }
    }
    _pendingRequests.clear();
    _receiveBuffer.clear();

    await _socketSubscription?.cancel();
    _socketSubscription = null;

    await _socket?.close();
    _socket = null;

    _connectionState = HoymilesConnectionState.offline;

    DebugLog.device('[HoymilesTcp] Disconnected', level: LogLevel.debug);
  }

  /// Send a request and wait for response using sequence number matching
  ///
  /// Returns the parsed response or null on timeout/error.
  /// Use [timeout] to override the default 10s timeout (e.g. for history requests).
  Future<Map<String, dynamic>?> sendRequest(
    GeneratedMessage request,
    List<int> command, {
    Duration? timeout,
  }) async {
    if (!isConnected) {
      DebugLog.device('[HoymilesTcp] Cannot send: not connected', level: LogLevel.warning);
      return null;
    }

    try {
      // Generate message (protocol increments sequence number automatically)
      final message = protocol.generateMessage(command, request);

      // Extract sequence number from generated message (bytes 4-5)
      final sequence = (message[4] << 8) | message[5];

      // Create completer for this request
      final completer = Completer<Map<String, dynamic>?>();
      _pendingRequests[sequence] = PendingRequest(
        completer: completer,
        sentAt: DateTime.now(),
        commandTag: command,
      );

      // Send message
      _socket!.add(message);

      DebugLog.device('[HoymilesTcp] Sent request with sequence: $sequence', level: LogLevel.verbose);

      // Wait for response with timeout
      try {
        final effectiveTimeout = timeout ?? requestTimeout;
        final result = await completer.future.timeout(
          effectiveTimeout,
          onTimeout: () {
            DebugLog.device('[HoymilesTcp] Request $sequence timed out after ${effectiveTimeout.inSeconds}s', level: LogLevel.warning);
            _pendingRequests.remove(sequence);
            return null;
          },
        );
        return result;
      } finally {
        _pendingRequests.remove(sequence);
      }
    } catch (e) {
      DebugLog.device('[HoymilesTcp] Send error: $e', level: LogLevel.error);
      _handleError(e);
      return null;
    }
  }

  /// Handle incoming data from socket
  ///
  /// TCP does not guarantee message boundaries — data may arrive fragmented
  /// across multiple callbacks or multiple messages may be concatenated in a
  /// single callback.  We accumulate into [_receiveBuffer] and extract complete
  /// Hoymiles protocol frames (10-byte header + protobuf payload).
  void _handleIncomingData(Uint8List data) {
    if (_isDisposed) return;

    DebugLog.device('[HoymilesTcp] Received ${data.length} bytes', level: LogLevel.verbose);

    _receiveBuffer.add(data);

    // Try to extract complete messages from the buffer
    _processBuffer();
  }

  /// Repeatedly try to extract complete messages from [_receiveBuffer].
  void _processBuffer() {
    while (true) {
      final buffer = Uint8List.fromList(_receiveBuffer.toBytes());
      if (buffer.isEmpty) return;

      // Skip leading null bytes (keep-alive echoes from DTU)
      int offset = 0;
      while (offset < buffer.length && buffer[offset] == 0x00) {
        offset++;
      }
      if (offset > 0) {
        _receiveBuffer.clear();
        if (offset < buffer.length) {
          _receiveBuffer.add(buffer.sublist(offset));
        }
        // Loop again with cleaned buffer
        continue;
      }

      // Need at least 10 bytes for the HM header
      if (buffer.length < 10) return;

      // Validate "HM" magic header
      if (buffer[0] != 0x48 || buffer[1] != 0x4D) {
        // Invalid header byte — discard one byte and try again
        DebugLog.device('[HoymilesTcp] Invalid header byte 0x${buffer[0].toRadixString(16)}, discarding', level: LogLevel.warning);
        _receiveBuffer.clear();
        _receiveBuffer.add(buffer.sublist(1));
        continue;
      }

      // Read expected total message length from header bytes 8-9 (big-endian)
      final expectedLength = (buffer[8] << 8) | buffer[9];

      // Sanity check: length should be at least 10 (header size)
      if (expectedLength < 10) {
        DebugLog.device('[HoymilesTcp] Invalid message length: $expectedLength, discarding frame', level: LogLevel.warning);
        _receiveBuffer.clear();
        _receiveBuffer.add(buffer.sublist(2));
        continue;
      }

      // Do we have the complete message yet?
      if (buffer.length < expectedLength) {
        DebugLog.device('[HoymilesTcp] Waiting for more data: have ${buffer.length}/$expectedLength bytes', level: LogLevel.verbose);
        return; // Wait for more data to arrive
      }

      // Extract the complete message
      final messageBytes = Uint8List.fromList(buffer.sublist(0, expectedLength));

      // Remove processed message from buffer
      _receiveBuffer.clear();
      if (buffer.length > expectedLength) {
        _receiveBuffer.add(buffer.sublist(expectedLength));
      }

      // Parse and dispatch the complete message
      _parseAndDispatch(messageBytes);
    }
  }

  /// Parse a complete message and dispatch to the matching pending request.
  void _parseAndDispatch(Uint8List messageBytes) {
    try {
      final parsed = protocol.parseResponse(messageBytes);
      if (parsed == null) {
        DebugLog.device('[HoymilesTcp] Failed to parse complete message (${messageBytes.length} bytes)', level: LogLevel.error);
        return;
      }

      final sequence = parsed['sequence'] as int;
      DebugLog.device('[HoymilesTcp] Received response for sequence: $sequence', level: LogLevel.verbose);

      // Find matching pending request
      var pending = _pendingRequests[sequence];
      if (pending == null) {
        // DTU sometimes responds with sequence+1; try sequence-1
        pending = _pendingRequests[sequence - 1];
        if (pending != null) {
          // Move to correct key
          _pendingRequests[sequence] = pending;
          _pendingRequests.remove(sequence - 1);
        }
      }

      if (pending == null) {
        DebugLog.device('[HoymilesTcp] No pending request for sequence $sequence (may have timed out)', level: LogLevel.warning);
        return;
      }

      // Complete the completer with parsed data
      if (!pending.completer.isCompleted) {
        pending.completer.complete(parsed);
      }
    } catch (e) {
      DebugLog.device('[HoymilesTcp] Error processing message: $e', level: LogLevel.error);
    }
  }

  /// Handle socket errors
  void _handleError(Object error) {
    DebugLog.device('[HoymilesTcp] Socket error: $error', level: LogLevel.error);
    _connectionState = HoymilesConnectionState.error;
    // Reconnection will be handled by service layer
  }

  /// Handle socket disconnect
  void _handleDisconnect() {
    DebugLog.device('[HoymilesTcp] Socket disconnected', level: LogLevel.error);
    _connectionState = HoymilesConnectionState.offline;
    // Reconnection will be handled by service layer
  }

  /// Start keep-alive timer
  void _startKeepAliveTimer() {
    _stopKeepAliveTimer();
    _keepAliveTimer = Timer.periodic(keepAliveDuration, (_) {
      if (isConnected && _pendingRequests.isEmpty) {
        try {
          // Send null byte to maintain connection
          _socket!.add([0x00]);
          DebugLog.device('[HoymilesTcp] Sent keep-alive', level: LogLevel.verbose);
        } catch (e) {
          DebugLog.device('[HoymilesTcp] Keep-alive error: $e', level: LogLevel.error);
        }
      }
    });
  }

  /// Stop keep-alive timer
  void _stopKeepAliveTimer() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  /// Dispose resources
  Future<void> dispose() async {
    DebugLog.device('[HoymilesTcp] Disposing connection', level: LogLevel.debug);
    _isDisposed = true;
    await disconnect();
  }
}
