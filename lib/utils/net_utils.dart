import 'dart:io' show Platform, NetworkInterface, InternetAddressType;
import 'package:flutter/foundation.dart';

/// Simple model for network interface information
class NetworkInterfaceInfo {
  final String name;
  final String ipAddress;
  final String displayName;
  final bool isPublic;

  NetworkInterfaceInfo({
    required this.name,
    required this.ipAddress,
    required this.displayName,
    required this.isPublic,
  });
}

/// Network utility functions for interface detection and validation
class NetUtils {
  /// Check if an IP address is in a private network range (RFC1918)
  ///
  /// Returns true if IP is in one of these ranges:
  /// - 10.0.0.0/8 (10.0.0.0 - 10.255.255.255)
  /// - 172.16.0.0/12 (172.16.0.0 - 172.31.255.255)
  /// - 192.168.0.0/16 (192.168.0.0 - 192.168.255.255)
  static bool isPrivateIP(String ipAddress,bool onlyRealLocal) {
    final parts = ipAddress.split('.');
    if (parts.length != 4) return false;

    try {
      final octet1 = int.parse(parts[0]);
      final octet2 = int.parse(parts[1]);

      //TODO add ui to enable this is more likely to be docker net or something else
      // Check 10.0.0.0/8 range
      if (onlyRealLocal == false && octet1 == 10) {
        return true;
      }

      // Check 172.16.0.0/12 range (172.16.0.0 - 172.31.255.255)
      if (onlyRealLocal && octet1 == 172 && octet2 >= 16 && octet2 <= 31) {
        return true;
      }

      // Check 192.168.0.0/16 range
      if (octet1 == 192 && octet2 == 168) {
        return true;
      }

      return false;
    } catch (e) {
      return false; // Invalid IP format
    }
  }

  /// Get all local IP addresses from WiFi and Ethernet interfaces
  ///
  /// Returns list of IP addresses from active WiFi/Ethernet interfaces
  /// Excludes loopback, mobile, VPN, and other interface types
  /// Only returns private IP addresses (filters out public IPs)
  ///
  /// Returns empty list if only mobile data is available
  static Future<List<String>> getLocalNetworkIPs() async {
    // Use getNetworkInterfaceList() as the single source of truth
    final interfaces = await getNetworkInterfaceList();

    // Extract and return just the private IP addresses
    return interfaces
        .where((interface) => !interface.isPublic)
        .map((interface) => interface.ipAddress)
        .toList();
  }

  /// Extract unique C-class subnets from list of IP addresses
  ///
  /// Returns list of subnet prefixes (e.g., ["192.168.1", "192.168.50"])
  /// Only returns private IP subnets
  ///
  /// Requires ipToCSubnet function from lan_scanner package
  static List<String> extractUniqueSubnets(List<String> ipAddresses, String Function(String) ipToCSubnet) {
    final Set<String> subnets = {};

    for (final ip in ipAddresses) {
      if (isPrivateIP(ip,false)) {
        final subnet = ipToCSubnet(ip);
        subnets.add(subnet);
      }
    }

    return subnets.toList();
  }

  /// Get list of available network interfaces with metadata
  ///
  /// Returns list of NetworkInterfaceInfo objects for WiFi and Ethernet interfaces
  /// Includes interface name, IP address, display name, and type (WiFi/Ethernet)
  static Future<List<NetworkInterfaceInfo>> getNetworkInterfaceList() async {
    final List<NetworkInterfaceInfo> interfaces = [];

    try {
      final networkInterfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (final interface in networkInterfaces) {
        final name = interface.name.toLowerCase();

        // Detect interface type (same logic as getLocalNetworkIPs)
        final isWiFi = name.contains('wlan') ||
                       name.contains('wifi') ||
                       (Platform.isMacOS && name == 'en0') ||
                       name.startsWith('wlp');

        final isEthernet = name.contains('eth') ||
                           name.startsWith('enp') ||
                           name.startsWith('em') ||
                           (Platform.isMacOS && name == 'en1') ||
                           name.contains('eno');

        bool isUnknownButLocal = false;
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            if (NetUtils.isPrivateIP(addr.address, true)) {
              isUnknownButLocal = true;
            }
          }
        }

        //if (isWiFi || isEthernet || isUnknownButLocal) {
          for (final addr in interface.addresses) {
            if (addr.type == InternetAddressType.IPv4) {
              final typeLabel = isWiFi ? 'WiFi' : (isEthernet ? 'Ethernet' : 'Network');
              //final isPrivate = NetUtils.isPrivateIP(addr.address, false);
              interfaces.add(NetworkInterfaceInfo(
                name: interface.name,
                ipAddress: addr.address,
                displayName: '$typeLabel (${interface.name}) - ${addr.address}',
                isPublic: !(isWiFi || isEthernet || isUnknownButLocal),
              ));
            }
          }
        }
      //}
    } catch (e) {
      debugPrint('Error getting network interfaces: $e');
    }

    return interfaces;
  }
}
