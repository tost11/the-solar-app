import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:protobuf/protobuf.dart';
import '../../../utils/debug_log.dart';

/// Hoymiles protocol constants and utilities
class HoymilesProtocol {
  // Protocol constants
  static const int DTU_PORT = 10081;
  static const List<int> CMD_HEADER = [0x48, 0x4D]; // "HM"

  // Command bytes (from Python reference)
  static const List<int> CMD_REAL_RES_DTO = [0xa3, 0x11];
  static const List<int> CMD_GET_CONFIG = [0xa3, 0x09];
  static const List<int> CMD_SET_CONFIG = [0xa3, 0x10];
  static const List<int> CMD_NETWORK_INFO_RES = [0xa3, 0x14];
  static const List<int> CMD_HB_RES_DTO = [0xa3, 0x02];
  static const List<int> CMD_APP_INFO_DATA_RES_DTO = [0xa3, 0x01];
  static const List<int> CMD_COMMAND_RES_DTO = [0xa3, 0x05];
  static const List<int> CMD_APP_GET_HIST_POWER_RES = [0xa3, 0x15];
  static const List<int> CMD_APP_GET_HIST_ED_RES = [0xa3, 0x16];

  // Offset constant
  static const int OFFSET = 28800;

  int _sequence = 0;

  /// Get next sequence number
  int getNextSequence() {
    //increased by two because some times response is one number above to find an handle that increse by +1
    _sequence = (_sequence + 2) & 0xFFFF;
    return _sequence;
  }

  /// CRC16 lookup table for Modbus (polynomial 0xA001, reflected)
  static final List<int> _crcTable = _buildCrcTable();

  static List<int> _buildCrcTable() {
    final table = List<int>.filled(256, 0);
    for (int byte = 0; byte < 256; byte++) {
      int c = byte;
      for (int i = 0; i < 8; i++) {
        c = (c & 1) != 0 ? (c >> 1) ^ 0xA001 : c >> 1;
      }
      table[byte] = c;
    }
    return table;
  }

  /// Calculate CRC16-Modbus: poly 0xA001 (reflected), init 0xFFFF, no final XOR.
  /// Matches the Python hiflow-ble implementation exactly.
  int calculateCrc16(List<int> data) {
    int crc = 0xFFFF;
    for (final b in data) {
      crc = (crc >> 8) ^ _crcTable[(crc ^ b) & 0xFF];
    }
    return crc & 0xFFFF;
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

    DebugLog.device('[Hoymiles] Generated message: ${message.length} bytes', level: LogLevel.verbose);
    DebugLog.device('[Hoymiles] Header: ${_bytesToHex(message.sublist(0, 2))}', level: LogLevel.verbose);
    DebugLog.device('[Hoymiles] Command: ${_bytesToHex(message.sublist(2, 4))}', level: LogLevel.verbose);
    DebugLog.device('[Hoymiles] Sequence: $sequence (${_bytesToHex(message.sublist(4, 6))})', level: LogLevel.verbose);
    DebugLog.device('[Hoymiles] CRC16: $crc16 (${_bytesToHex(message.sublist(6, 8))})', level: LogLevel.verbose);
    DebugLog.device('[Hoymiles] Length: $length (${_bytesToHex(message.sublist(8, 10))})', level: LogLevel.verbose);

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
        DebugLog.device('[Hoymiles] Buffer too short: ${buffer.length} bytes', level: LogLevel.error);
        return null;
      }

      // Parse header
      final header = buffer.sublist(0, 2);
      if (header[0] != CMD_HEADER[0] || header[1] != CMD_HEADER[1]) {
        DebugLog.device('[Hoymiles] Invalid header: ${_bytesToHex(header)}', level: LogLevel.error);
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

      DebugLog.device('[Hoymiles] Parsing response:', level: LogLevel.verbose);
      DebugLog.device('[Hoymiles]   Sequence: $sequence', level: LogLevel.verbose);
      DebugLog.device('[Hoymiles]   CRC16: $crc16Target', level: LogLevel.verbose);
      DebugLog.device('[Hoymiles]   Length: $length', level: LogLevel.verbose);
      DebugLog.device('[Hoymiles]   Buffer length: ${buffer.length}', level: LogLevel.verbose);

      // Validate buffer length
      if (buffer.length < length) {
        DebugLog.device('[Hoymiles] Buffer incomplete: expected $length, got ${buffer.length}', level: LogLevel.error);
        return null;
      }

      // Extract protobuf data
      final protobufData = buffer.sublist(10, length);

      // Validate CRC16
      final crc16Calculated = calculateCrc16(protobufData);
      if (crc16Calculated != crc16Target) {
        DebugLog.device('[Hoymiles] CRC16 mismatch: expected $crc16Target, got $crc16Calculated', level: LogLevel.error);
        return null;
      }

      DebugLog.device('[Hoymiles] Response parsed successfully, protobuf data: ${protobufData.length} bytes', level: LogLevel.debug);

      return {
        'tag': tag,
        'sequence': sequence,
        'data': protobufData,
      };
    } catch (e) {
      DebugLog.device('[Hoymiles] Error parsing response: $e', level: LogLevel.error);
      return null;
    }
  }

  /// Convert bytes to hex string for debugging
  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }
}
