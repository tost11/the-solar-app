import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:protobuf/protobuf.dart';

/// Hoymiles protocol constants and utilities
class HoymilesProtocol {
  // Protocol constants
  static const int DTU_PORT = 10081;
  static const List<int> CMD_HEADER = [0x48, 0x4D]; // "HM"

  // Command bytes (from Python reference)
  static const List<int> CMD_REAL_RES_DTO = [0xa3, 0x11];
  static const List<int> CMD_GET_CONFIG = [0xa3, 0x09];
  static const List<int> CMD_NETWORK_INFO_RES = [0xa3, 0x14];
  static const List<int> CMD_HB_RES_DTO = [0xa3, 0x02];
  static const List<int> CMD_APP_INFO_DATA_RES_DTO = [0xa3, 0x01];
  static const List<int> CMD_COMMAND_RES_DTO = [0xa3, 0x05];

  // Offset constant
  static const int OFFSET = 28800;

  int _sequence = 0;

  /// Get next sequence number
  int getNextSequence() {
    _sequence = (_sequence + 1) & 0xFFFF;
    return _sequence;
  }

  /// Reflect bits in a byte (reverse bit order)
  int _reflectByte(int value) {
    int reflected = 0;
    for (int i = 0; i < 8; i++) {
      if ((value & (1 << i)) != 0) {
        reflected |= (1 << (7 - i));
      }
    }
    return reflected;
  }

  /// Reflect bits in a 16-bit value (reverse bit order)
  int _reflectShort(int value) {
    int reflected = 0;
    for (int i = 0; i < 16; i++) {
      if ((value & (1 << i)) != 0) {
        reflected |= (1 << (15 - i));
      }
    }
    return reflected;
  }

  /// Calculate CRC16 using polynomial 0x18005, reversed, init 0xFFFF, xorOut 0x0000
  /// This matches the Python crcmod configuration: mkCrcFun(0x18005, rev=True, initCrc=0xFFFF, xorOut=0x0000)
  int calculateCrc16(List<int> data) {
    int crc = 0xFFFF;
    const int poly = 0x8005; // Normal (not reversed) polynomial for MSB-first processing

    for (final byte in data) {
      // Reflect input byte
      int reflected = _reflectByte(byte);
      crc ^= (reflected << 8);

      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = (crc << 1) ^ poly;
        } else {
          crc = crc << 1;
        }
      }
    }

    // Reflect output CRC and apply xorOut (0x0000, so no change)
    return _reflectShort(crc & 0xFFFF);
  }

  /// Generate message to send to DTU
  ///
  /// Message structure:
  /// - Header: "HM" (2 bytes)
  /// - Command: command bytes (2 bytes)
  /// - Sequence: uint16 (2 bytes)
  /// - CRC16: of protobuf data (2 bytes)
  /// - Length: of message (2 bytes)
  /// - Protobuf data: serialized message
  Uint8List generateMessage(
    List<int> command,
    GeneratedMessage request,
  ) {
    final sequence = getNextSequence();
    final protobufData = request.writeToBuffer();

    // Calculate CRC16 of protobuf data
    final crc16 = calculateCrc16(protobufData);

    // Calculate message length (protobuf data + 10 bytes overhead)
    final length = protobufData.length + 10;

    // Build message
    final builder = BytesBuilder();

    // Header: "HM"
    builder.add(CMD_HEADER);

    // Command: 2 bytes
    builder.add(command);

    // Sequence: uint16 big-endian
    builder.addByte((sequence >> 8) & 0xFF);
    builder.addByte(sequence & 0xFF);

    // CRC16: uint16 big-endian
    builder.addByte((crc16 >> 8) & 0xFF);
    builder.addByte(crc16 & 0xFF);

    // Length: uint16 big-endian
    builder.addByte((length >> 8) & 0xFF);
    builder.addByte(length & 0xFF);

    // Protobuf data
    builder.add(protobufData);

    final message = builder.toBytes();

    debugPrint('[Hoymiles] Generated message: ${message.length} bytes');
    debugPrint('[Hoymiles] Header: ${_bytesToHex(message.sublist(0, 2))}');
    debugPrint('[Hoymiles] Command: ${_bytesToHex(message.sublist(2, 4))}');
    debugPrint('[Hoymiles] Sequence: $sequence (${_bytesToHex(message.sublist(4, 6))})');
    debugPrint('[Hoymiles] CRC16: $crc16 (${_bytesToHex(message.sublist(6, 8))})');
    debugPrint('[Hoymiles] Length: $length (${_bytesToHex(message.sublist(8, 10))})');

    return message;
  }

  /// Parse response from DTU
  ///
  /// Response structure:
  /// - Header: "HM" (2 bytes)
  /// - Tag/Command: (2 bytes)
  /// - Sequence: uint16 (2 bytes)
  /// - CRC16: of protobuf data (2 bytes)
  /// - Length: of full message (2 bytes)
  /// - Protobuf data: serialized response
  Map<String, dynamic>? parseResponse(Uint8List buffer) {
    try {
      if (buffer.length < 10) {
        debugPrint('[Hoymiles] Buffer too short: ${buffer.length} bytes');
        return null;
      }

      // Parse header
      final header = buffer.sublist(0, 2);
      if (header[0] != CMD_HEADER[0] || header[1] != CMD_HEADER[1]) {
        debugPrint('[Hoymiles] Invalid header: ${_bytesToHex(header)}');
        return null;
      }

      // Parse command tag
      final tag = buffer.sublist(2, 4);

      // Parse sequence
      final sequence = (buffer[4] << 8) | buffer[5];

      // Parse CRC16
      final crc16Target = (buffer[6] << 8) | buffer[7];

      // Parse length
      final length = (buffer[8] << 8) | buffer[9];

      debugPrint('[Hoymiles] Parsing response:');
      debugPrint('[Hoymiles]   Sequence: $sequence');
      debugPrint('[Hoymiles]   CRC16: $crc16Target');
      debugPrint('[Hoymiles]   Length: $length');
      debugPrint('[Hoymiles]   Buffer length: ${buffer.length}');

      // Validate buffer length
      if (buffer.length < length) {
        debugPrint('[Hoymiles] Buffer incomplete: expected $length, got ${buffer.length}');
        return null;
      }

      // Extract protobuf data
      final protobufData = buffer.sublist(10, length);

      // Validate CRC16
      final crc16Calculated = calculateCrc16(protobufData);
      if (crc16Calculated != crc16Target) {
        debugPrint('[Hoymiles] CRC16 mismatch: expected $crc16Target, got $crc16Calculated');
        return null;
      }

      debugPrint('[Hoymiles] Response parsed successfully, protobuf data: ${protobufData.length} bytes');

      return {
        'tag': tag,
        'sequence': sequence,
        'data': protobufData,
      };
    } catch (e) {
      debugPrint('[Hoymiles] Error parsing response: $e');
      return null;
    }
  }

  /// Convert bytes to hex string for debugging
  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }
}
