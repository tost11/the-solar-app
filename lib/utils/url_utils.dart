/// Utility class for URL manipulation and port handling
class UrlUtils {
  /// Get default port for protocol
  /// - http: 80
  /// - https: 443
  static String getDefaultPort(String protocol) {
    switch (protocol.toLowerCase()) {
      case 'http':
        return '80';
      case 'https':
        return '443';
      default:
        return '80';
    }
  }

  /// Check if port is standard for given protocol
  static bool isStandardPort(String protocol, String port) {
    final defaultPort = getDefaultPort(protocol);
    return port == defaultPort;
  }

  /// Extract port from host string and return port
  /// If no port in host, return default port for protocol
  ///
  /// Examples:
  /// - "example.com:8080" + "https" -> "8080"
  /// - "example.com" + "https" -> "443"
  /// - "192.168.1.1:9090" + "http" -> "9090"
  static String extractAndInitializePort(String? host, String protocol) {
    if (host == null || host.isEmpty) {
      return getDefaultPort(protocol);
    }

    // Check if host contains port
    if (host.contains(':')) {
      final parts = host.split(':');
      if (parts.length == 2) {
        final portStr = parts[1].trim();
        // Validate it's a number
        if (int.tryParse(portStr) != null) {
          return portStr;
        }
      }
    }

    // No port found, return default
    return getDefaultPort(protocol);
  }

  /// Extract host without port from host string
  ///
  /// Examples:
  /// - "example.com:8080" -> "example.com"
  /// - "example.com" -> "example.com"
  /// - "192.168.1.1:9090" -> "192.168.1.1"
  static String extractHostWithoutPort(String host) {
    if (host.contains(':')) {
      return host.split(':').first.trim();
    }
    return host.trim();
  }

  /// Build complete URL from components
  /// Only includes port in URL if it's non-standard
  ///
  /// Examples:
  /// - ("example.com", "https", "443") -> "https://example.com"
  /// - ("example.com", "https", "8443") -> "https://example.com:8443"
  /// - ("192.168.1.1", "http", "8080") -> "http://192.168.1.1:8080"
  static String buildUrl(String host, String protocol, String port) {
    if (host.isEmpty) return '';

    final cleanHost = extractHostWithoutPort(host);

    // Only include port if non-standard
    if (isStandardPort(protocol, port)) {
      return '$protocol://$cleanHost';
    } else {
      return '$protocol://$cleanHost:$port';
    }
  }

  /// Validate port number
  /// Valid range: 1-65535
  static bool isValidPort(String port) {
    if (port.isEmpty) return false;
    final num = int.tryParse(port);
    return num != null && num >= 1 && num <= 65535;
  }
}
