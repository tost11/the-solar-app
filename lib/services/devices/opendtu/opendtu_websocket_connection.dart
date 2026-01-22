import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// WebSocket connection handler for OpenDTU devices
///
/// Manages persistent WebSocket connection to OpenDTU's /livedata endpoint
/// following the same pattern as DeyeSunModbusConnection for consistency.
class OpenDtuWebSocketConnection {
  // Connection constants
  static const int RECONNECT_DELAY_MS = 15000; // 15 seconds
  static const int HEALTH_THRESHOLD_MS = 30000; // 30 seconds
  static const int CONNECTION_TIMEOUT_MS = 5000; // 5 seconds

  // Callback for parsed data
  final Function(Map<String, dynamic>)? onDataReceived;

  // Connection state
  WebSocket? _webSocket;
  bool _isConnecting = false;
  bool _isDisposed = false;
  DateTime? _lastSuccessfulRead;

  // Connection parameters
  String? _ipAddress;
  int? _port;
  Map<String, String>? _authHeaders;

  // Reconnection timer
  Timer? _reconnectTimer;

  // Persistent inverter data map (serial -> inverter data)
  final Map<String, Map<String, dynamic>> _invertersMap = {};

  // Stream subscription
  StreamSubscription? _messageSubscription;

  /// Constructor with optional callback
  OpenDtuWebSocketConnection({this.onDataReceived});

  /// Connect to OpenDTU WebSocket endpoint
  ///
  /// Returns true if connection successful, false otherwise
  Future<bool> connect(
    String ipAddress,
    int port,
    Map<String, String>? authHeaders,
  ) async {
    if (_isDisposed) {
      debugPrint('[OpenDTU-WS] Cannot connect: connection disposed');
      return false;
    }

    if (_isConnecting) {
      debugPrint('[OpenDTU-WS] Connection attempt already in progress');
      return false;
    }

    // Store connection parameters for reconnection
    _ipAddress = ipAddress;
    _port = port;
    _authHeaders = authHeaders;

    _isConnecting = true;

    try {
      await _connectWebSocket();
      _isConnecting = false;

      // Cancel any pending reconnect timer on successful connection
      _reconnectTimer?.cancel();
      _reconnectTimer = null;

      return true;
    } catch (e) {
      _isConnecting = false;
      debugPrint('[OpenDTU-WS] Connection failed: $e');
      _scheduleReconnect();
      return false;
    }
  }

  /// Internal method to establish WebSocket connection
  Future<void> _connectWebSocket() async {
    if (_ipAddress == null || _port == null) {
      throw Exception('Connection parameters not set');
    }

    debugPrint('[OpenDTU-WS] Connecting to ws://$_ipAddress:$_port/livedata');

    // Build WebSocket URL
    final wsUrl = 'ws://$_ipAddress:$_port/livedata';

    // Add authentication to URL if provided
    Uri wsUri;
    if (_authHeaders != null && _authHeaders!.containsKey('Authorization')) {
      // Extract basic auth credentials from Authorization header
      final authHeader = _authHeaders!['Authorization']!;
      if (authHeader.startsWith('Basic ')) {
        final base64Creds = authHeader.substring(6);
        final credentials = utf8.decode(base64.decode(base64Creds));
        final parts = credentials.split(':');
        if (parts.length == 2) {
          wsUri = Uri.parse('ws://${parts[0]}:${parts[1]}@$_ipAddress:$_port/livedata');
        } else {
          wsUri = Uri.parse(wsUrl);
        }
      } else {
        wsUri = Uri.parse(wsUrl);
      }
    } else {
      wsUri = Uri.parse(wsUrl);
    }

    // Connect with timeout
    _webSocket = await WebSocket.connect(
      wsUri.toString(),
    ).timeout(
      const Duration(milliseconds: CONNECTION_TIMEOUT_MS),
      onTimeout: () {
        throw TimeoutException('WebSocket connection timeout');
      },
    );

    debugPrint('[OpenDTU-WS] Connected successfully');

    // Register listeners
    _messageSubscription = _webSocket!.listen(
      _onMessageReceived,
      onError: _onWebSocketError,
      onDone: _onWebSocketDone,
      cancelOnError: false,
    );
  }

  /// Handle incoming WebSocket messages
  void _onMessageReceived(dynamic message) {
    try {
      if (message is String) {
        final data = jsonDecode(message) as Map<String, dynamic>;
        _lastSuccessfulRead = DateTime.now();

        //debugPrint('[OpenDTU-WS] Received data update');

        // Parse the data immediately and invoke callback
        final parsedData = _parseInverterData(data);
        if (parsedData != null && onDataReceived != null) {
          onDataReceived!(parsedData);
        }
      }
    } catch (e) {
      debugPrint('[OpenDTU-WS] Error parsing message: $e');
    }
  }

  /// Parse inverter data from WebSocket message
  /// Maintains persistent map of inverters by serial number
  Map<String, dynamic>? _parseInverterData(Map<String, dynamic> messageData) {
    try {
      // Extract inverters array from WebSocket message
      final inverters = messageData['inverters'] as List?;
      if (inverters != null && inverters.isNotEmpty) {
        // Iterate through all inverters in this message
        for (var inverterRaw in inverters) {
          final inverter = inverterRaw as Map<String, dynamic>;

          // Extract serial number as unique key
          final serial = inverter['serial'] as String?;
          if (serial == null) continue;

          // Parse this inverter's complete data
          final inverterData = <String, dynamic>{};

          // Basic info
          inverterData['serial'] = serial;
          inverterData['name'] = inverter['name'];
          inverterData['reachable'] = inverter['reachable'] ?? false;
          inverterData['producing'] = inverter['producing'] ?? false;
          inverterData['limit_relative'] = inverter['limit_relative'];
          inverterData['limit_absolute'] = inverter['limit_absolute'];
          inverterData['manufacturer'] = inverter['manufacturer'];

          // AC data (first phase)
          final ac = inverter['AC'] as Map<String, dynamic>?;
          if (ac != null && ac.containsKey('0')) {
            final ac0 = ac['0'] as Map<String, dynamic>;
            inverterData['ac_power'] = _extractValue(ac0, 'Power');
            inverterData['ac_voltage'] = _extractValue(ac0, 'Voltage');
            inverterData['ac_current'] = _extractValue(ac0, 'Current');
            inverterData['ac_frequency'] = _extractValue(ac0, 'Frequency');
            inverterData['ac_power_factor'] = _extractValue(ac0, 'PowerFactor');
            inverterData['ac_reactive_power'] = _extractValue(ac0, 'ReactivePower');
          }

          // DC data (all strings)
          final dc = inverter['DC'] as Map<String, dynamic>?;
          if (dc != null) {
            final dcStrings = <Map<String, dynamic>>[];
            for (var entry in dc.entries) {
              final stringData = entry.value as Map<String, dynamic>;
              // Try both 'Name' (PascalCase) and 'name' (lowercase) for compatibility
              final stringName = _extractValue(stringData, 'Name') ??
                                 _extractValue(stringData, 'name') ??
                                 'String ${entry.key}';
              dcStrings.add({
                'name': stringName,
                'power': _extractValue(stringData, 'Power'),
                'voltage': _extractValue(stringData, 'Voltage'),
                'current': _extractValue(stringData, 'Current'),
                'yield_day': _extractValue(stringData, 'YieldDay'),
                'yield_total': _extractValue(stringData, 'YieldTotal'),
                'irradiation': _extractValue(stringData, 'Irradiation'),
              });
            }
            inverterData['dc_strings'] = dcStrings;
          }

          // Inverter data
          final inv = inverter['INV'] as Map<String, dynamic>?;
          if (inv != null && inv.containsKey('0')) {
            final inv0 = inv['0'] as Map<String, dynamic>;
            inverterData['dc_power'] = _extractValue(inv0, 'Power DC');
            inverterData['yield_day'] = _extractValue(inv0, 'YieldDay');
            inverterData['yield_total'] = _extractValue(inv0, 'YieldTotal');
            inverterData['temperature'] = _extractValue(inv0, 'Temperature');
            inverterData['efficiency'] = _extractValue(inv0, 'Efficiency');
          }

          // Update or insert into persistent map
          _invertersMap[serial] = inverterData;
        }
      }

      // Build result with persistent inverter map + current total/hints
      final result = <String, dynamic>{};

      // Add all inverters (persistent map with all known inverters)
      result['inverters'] = _invertersMap;

      // Total data from current message
      final total = messageData['total'] as Map<String, dynamic>?;
      if (total != null) {
        result['total'] = total; // Keep raw structure with {v, u, d}
      }

      // Hints/warnings from current message
      final hints = messageData['hints'] as Map<String, dynamic>?;
      if (hints != null) {
        result['hints'] = hints;
      }

      return result;
    } catch (e) {
      debugPrint('[OpenDTU-WS] Error parsing inverter data: $e');
      return null;
    }
  }

  /// Handle WebSocket errors
  void _onWebSocketError(dynamic error) {
    debugPrint('[OpenDTU-WS] Socket error: $error');
    _webSocket = null;
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _scheduleReconnect();
  }

  /// Handle WebSocket connection closure
  void _onWebSocketDone() {
    debugPrint('[OpenDTU-WS] Socket closed');
    _webSocket = null;
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _scheduleReconnect();
  }

  /// Schedule automatic reconnection
  void _scheduleReconnect() {
    if (_isDisposed) {
      debugPrint('[OpenDTU-WS] Not scheduling reconnect: connection disposed');
      return;
    }

    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      debugPrint('[OpenDTU-WS] Reconnect already scheduled');
      return;
    }

    if (_ipAddress == null || _port == null) {
      debugPrint('[OpenDTU-WS] Cannot schedule reconnect: missing connection parameters');
      return;
    }

    debugPrint('[OpenDTU-WS] Scheduling reconnect in ${RECONNECT_DELAY_MS}ms');

    _reconnectTimer = Timer(
      const Duration(milliseconds: RECONNECT_DELAY_MS),
      () async {
        if (!_isDisposed) {
          debugPrint('[OpenDTU-WS] Attempting reconnection...');
          await connect(_ipAddress!, _port!, _authHeaders);
        }
      },
    );
  }

  /// Disconnect from WebSocket (allows reconnection)
  Future<void> disconnect() async {
    debugPrint('[OpenDTU-WS] Disconnecting...');

    // Cancel reconnect timer
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    // Cancel message subscription
    await _messageSubscription?.cancel();
    _messageSubscription = null;

    // Close WebSocket
    try {
      await _webSocket?.close();
    } catch (e) {
      debugPrint('[OpenDTU-WS] Error closing socket: $e');
    }
    _webSocket = null;

    // Clear state
    _isConnecting = false;
    _lastSuccessfulRead = null;
    _invertersMap.clear();
  }

  /// Permanently dispose connection (prevents reconnection)
  void dispose() {
    debugPrint('[OpenDTU-WS] Disposing connection...');
    _isDisposed = true;
    disconnect();
    _invertersMap.clear();
  }

  /// Check if WebSocket is currently connected
  bool get isConnected {
    return _webSocket != null;
  }

  /// Check if connection is healthy (receiving recent data)
  bool get isHealthy {
    if (_lastSuccessfulRead == null) return false;

    final now = DateTime.now();
    final elapsed = now.difference(_lastSuccessfulRead!).inMilliseconds;

    return elapsed < HEALTH_THRESHOLD_MS;
  }

  /// Parse raw livedata response (from HTTP or WebSocket)
  ///
  /// Public method to allow parsing of HTTP-fetched data using same logic as WebSocket
  /// Returns transformed data structure with inverters as map
  Map<String, dynamic>? parseRawLiveData(Map<String, dynamic> rawData) {
    return _parseInverterData(rawData);
  }

  /// Extract value from OpenDTU data structure
  dynamic _extractValue(Map<String, dynamic> obj, String key) {
    if (!obj.containsKey(key)) return null;

    final data = obj[key];

    // Handle OpenDTU's {v: value, u: unit, d: decimals} structure
    if (data is Map<String, dynamic>) {
      if (data.containsKey('v')) {
        return data['v'];
      }
      // If it's a Map but doesn't have 'v', return null to avoid type errors
      return null;
    }

    // Return primitive values directly
    return data;
  }
}
