import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:protobuf/protobuf.dart';

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

  HoymilesConnectionState _connectionState = HoymilesConnectionState.offline;
  bool _isDisposed = false;

  // Constants
  static const Duration keepAliveDuration = Duration(seconds: 10);
  static const Duration requestTimeout = Duration(seconds: 10);

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
      debugPrint('[HoymilesTcp] Cannot connect: already disposed');
      return false;
    }

    if (isConnected) {
      debugPrint('[HoymilesTcp] Already connected');
      return true;
    }

    try {
      debugPrint('[HoymilesTcp] Connecting to $host:$port...');
      _connectionState = HoymilesConnectionState.connecting;

      _socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );

      debugPrint('[HoymilesTcp] Connected successfully');
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
      debugPrint('[HoymilesTcp] Connection error: $e');
      _connectionState = HoymilesConnectionState.error;
      // Reconnection will be handled by service layer
      return false;
    }
  }

  /// Disconnect from the DTU device
  Future<void> disconnect() async {
    debugPrint('[HoymilesTcp] Disconnecting...');

    _stopKeepAliveTimer();

    // Complete all pending requests with null (connection lost)
    for (final pending in _pendingRequests.values) {
      if (!pending.completer.isCompleted) {
        pending.completer.complete(null);
      }
    }
    _pendingRequests.clear();

    await _socketSubscription?.cancel();
    _socketSubscription = null;

    await _socket?.close();
    _socket = null;

    _connectionState = HoymilesConnectionState.offline;

    debugPrint('[HoymilesTcp] Disconnected');
  }

  /// Send a request and wait for response using sequence number matching
  ///
  /// Returns the parsed response or null on timeout/error
  Future<Map<String, dynamic>?> sendRequest(
    GeneratedMessage request,
    List<int> command,
  ) async {
    if (!isConnected) {
      debugPrint('[HoymilesTcp] Cannot send: not connected');
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
      await _socket!.flush();

      debugPrint('[HoymilesTcp] Sent request with sequence: $sequence');

      // Wait for response with timeout
      try {
        final result = await completer.future.timeout(
          requestTimeout,
          onTimeout: () {
            debugPrint('[HoymilesTcp] Request $sequence timed out');
            _pendingRequests.remove(sequence);
            return null;
          },
        );
        return result;
      } finally {
        _pendingRequests.remove(sequence);
      }
    } catch (e) {
      debugPrint('[HoymilesTcp] Send error: $e');
      _handleError(e);
      return null;
    }
  }

  /// Handle incoming data from socket
  void _handleIncomingData(Uint8List data) {
    if (_isDisposed) return;

    debugPrint('[HoymilesTcp] Received ${data.length} bytes');

    try {
      // Parse response to extract sequence number
      final parsed = protocol.parseResponse(data);
      if (parsed == null) {
        debugPrint('[HoymilesTcp] Failed to parse response');
        return;
      }

      final sequence = parsed['sequence'] as int;
      debugPrint('[HoymilesTcp] Received response for sequence: $sequence');

      // Find matching pending request
      var pending = _pendingRequests[sequence];
      if (pending == null) {
        // Find matching pending request
        _pendingRequests[sequence] = _pendingRequests[sequence-1]!;
        pending = _pendingRequests[sequence];
        if (pending == null) {
          debugPrint('[HoymilesTcp] No pending request for sequence $sequence (may have timed out)');
          return;
        }
      }

      // Complete the completer with parsed data
      if (!pending.completer.isCompleted) {
        pending.completer.complete(parsed);
      }
    } catch (e) {
      debugPrint('[HoymilesTcp] Error processing data: $e');
    }
  }

  /// Handle socket errors
  void _handleError(Object error) {
    debugPrint('[HoymilesTcp] Socket error: $error');
    _connectionState = HoymilesConnectionState.error;
    // Reconnection will be handled by service layer
  }

  /// Handle socket disconnect
  void _handleDisconnect() {
    debugPrint('[HoymilesTcp] Socket disconnected');
    _connectionState = HoymilesConnectionState.offline;
    // Reconnection will be handled by service layer
  }

  /// Start keep-alive timer
  void _startKeepAliveTimer() {
    _stopKeepAliveTimer();
    _keepAliveTimer = Timer.periodic(keepAliveDuration, (_) {
      if (isConnected) {
        try {
          // Send null byte to maintain connection
          _socket!.add([0x00]);
          _socket!.flush();
          debugPrint('[HoymilesTcp] Sent keep-alive');
        } catch (e) {
          debugPrint('[HoymilesTcp] Keep-alive error: $e');
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
    debugPrint('[HoymilesTcp] Disposing connection');
    _isDisposed = true;
    await disconnect();
  }
}
