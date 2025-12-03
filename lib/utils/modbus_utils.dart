import 'dart:typed_data';

/// Utility functions for Modbus protocol operations
class ModbusUtils {
  /// Calculate Modbus CRC16 from ASCII hex string
  ///
  /// Takes a hex string (e.g., "010300280004") and returns the CRC as hex string
  static String modbusCRC16(String hexString) {
    final bytes = hexToBytes(hexString);
    int crc = 0xFFFF;

    for (var byte in bytes) {
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x0001) != 0) {
          crc >>= 1;
          crc ^= 0xA001;
        } else {
          crc >>= 1;
        }
      }
    }

    // Return CRC in little-endian format as hex string
    final crcLow = crc & 0xFF;
    final crcHigh = (crc >> 8) & 0xFF;
    return bytesToHex([crcLow, crcHigh]);
  }

  /// Convert hex string to byte list
  ///
  /// Example: "A5001045" -> [0xA5, 0x00, 0x10, 0x45]
  static List<int> hexToBytes(String hex) {
    final result = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      final byteStr = hex.substring(i, i + 2);
      result.add(int.parse(byteStr, radix: 16));
    }
    return result;
  }

  /// Convert byte list to hex string
  ///
  /// Example: [0xA5, 0x00, 0x10, 0x45] -> "A5001045"
  static String bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join();
  }

  /// Convert integer to hex string with specified length
  ///
  /// Example: lengthToHexString(40, 4) -> "0028"
  static String lengthToHexString(int value, int length) {
    return value.toRadixString(16).padLeft(length, '0').toUpperCase();
  }

  /// Convert integer to decimal string with specified length
  ///
  /// Example: lengthToString(2, 2) -> "02"
  static String lengthToString(int value, int length) {
    return value.toString().padLeft(length, '0');
  }

  /// Parse 16-bit unsigned integer from register bytes (big-endian)
  static int parseUint16(List<int> data, int offset) {
    if (offset + 1 >= data.length) return 0;
    return (data[offset] << 8) | data[offset + 1];
  }

  /// Parse 32-bit unsigned integer from register bytes (big-endian)
  static int parseUint32(List<int> data, int offset) {
    if (offset + 3 >= data.length) return 0;
    return (data[offset] << 24) |
           (data[offset + 1] << 16) |
           (data[offset + 2] << 8) |
           data[offset + 3];
  }

  /// Parse float from register bytes (16-bit scaled value)
  /// Divides by 10 to get decimal value
  static double parseFloat(List<int> data, int offset, {int scale = 10}) {
    final value = parseUint16(data, offset);
    return value / scale;
  }

  /// Swap two consecutive 16-bit words in a 32-bit value
  /// Used for Deye-specific byte ordering
  static void swapWords(Uint8List buffer, int offset) {
    if (offset + 3 >= buffer.length) return;

    final temp0 = buffer[offset];
    final temp1 = buffer[offset + 1];

    buffer[offset] = buffer[offset + 2];
    buffer[offset + 1] = buffer[offset + 3];
    buffer[offset + 2] = temp0;
    buffer[offset + 3] = temp1;
  }

  /// Build 16-bit register value for writing
  static List<int> buildUint16(int value) {
    return [(value >> 8) & 0xFF, value & 0xFF];
  }
}
