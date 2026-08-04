import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'debug_log.dart';

/// Cryptographic utilities for Hoymiles BLE protocol.
///
/// Two encryption layers:
/// - V0 (AES-128-CBC): Used for initial APPInfoData pairing (cmd 0xA301)
/// - V1 (AES-128-GCM): Used for all subsequent commands after encRand extraction
///
/// Key differences:
/// - V0 uses big-endian packing for IV derivation
/// - V1 uses little-endian packing for nonce/AAD derivation
class HoymilesCryptoUtils {
  static const String _salt = "Hoymiles@#123456";

  /// Compute SHA256(SHA256(SHA256(data)))
  static Uint8List tripleSha256(Uint8List data) {
    var h = sha256.convert(data).bytes;
    h = sha256.convert(h).bytes;
    h = sha256.convert(h).bytes;
    return Uint8List.fromList(h);
  }

  // ==========================================================================
  // V0: AES-128-CBC (initial pairing)
  // ==========================================================================

  /// Derive AES-128-CBC key for V0 pairing from device serial number.
  static Uint8List _deriveV0Key(String serialNumber) {
    final material = Uint8List.fromList(
      serialNumber.codeUnits + _salt.codeUnits,
    );
    return tripleSha256(material).sublist(0, 16);
  }

  /// Derive AES-128-CBC IV for V0 pairing.
  /// Uses big-endian packing: pack(">HH", cmd, tid) + sn.encode("ascii")
  static Uint8List _deriveV0Iv(String serialNumber, int cmd, int tid) {
    final builder = BytesBuilder();
    // Big-endian: cmd (2 bytes) + tid (2 bytes)
    builder.addByte((cmd >> 8) & 0xFF);
    builder.addByte(cmd & 0xFF);
    builder.addByte((tid >> 8) & 0xFF);
    builder.addByte(tid & 0xFF);
    builder.add(serialNumber.codeUnits);
    return tripleSha256(Uint8List.fromList(builder.toBytes())).sublist(16, 32);
  }

  /// Encrypt with V0 AES-128-CBC + PKCS7 padding.
  static Future<Uint8List> encryptV0(
    Uint8List plaintext,
    String serialNumber,
    int cmd,
    int tid,
  ) async {
    final key = _deriveV0Key(serialNumber);
    final iv = _deriveV0Iv(serialNumber, cmd, tid);

    DebugLog.crypto('V0 key: ${_toHex(key)}', level: LogLevel.verbose);
    DebugLog.crypto('V0 iv: ${_toHex(iv)}', level: LogLevel.verbose);
    DebugLog.crypto('V0 plaintext (${plaintext.length} bytes): ${_toHex(plaintext)}', level: LogLevel.verbose);

    // AES-CBC encrypt with PKCS7 padding (handled by the library)
    final algorithm = crypto.AesCbc.with128bits(
      macAlgorithm: crypto.MacAlgorithm.empty,
      paddingAlgorithm: crypto.PaddingAlgorithm.pkcs7,
    );
    final secretKey = await algorithm.newSecretKeyFromBytes(key);
    final secretBox = await algorithm.encrypt(
      plaintext,
      secretKey: secretKey,
      nonce: iv,
    );
    return Uint8List.fromList(secretBox.cipherText);
  }

  /// Decrypt with V0 AES-128-CBC + PKCS7 unpadding.
  static Future<Uint8List> decryptV0(
    Uint8List ciphertext,
    String serialNumber,
    int cmd,
    int tid,
  ) async {
    final key = _deriveV0Key(serialNumber);
    final iv = _deriveV0Iv(serialNumber, cmd, tid);

    // AES-CBC decrypt with PKCS7 unpadding (handled by the library)
    final algorithm = crypto.AesCbc.with128bits(
      macAlgorithm: crypto.MacAlgorithm.empty,
      paddingAlgorithm: crypto.PaddingAlgorithm.pkcs7,
    );
    final secretKey = await algorithm.newSecretKeyFromBytes(key);

    final secretBox = crypto.SecretBox(
      ciphertext,
      nonce: iv,
      mac: crypto.Mac.empty,
    );

    final decrypted = await algorithm.decrypt(secretBox, secretKey: secretKey);
    return Uint8List.fromList(decrypted);
  }

  // ==========================================================================
  // V1: AES-128-GCM (post-pairing commands)
  // ==========================================================================

  /// Derive AES-128-GCM key from encRand.
  static Uint8List _deriveV1Key(Uint8List encRand) {
    return tripleSha256(encRand).sublist(0, 16);
  }

  /// Derive 12-byte AES-GCM nonce from encRand.
  /// Uses little-endian packing: pack("<HH", cmd, tid) + encRand
  static Uint8List _deriveV1Nonce(Uint8List encRand, int cmd, int tid) {
    final builder = BytesBuilder();
    // Little-endian: cmd (2 bytes) + tid (2 bytes)
    builder.addByte(cmd & 0xFF);
    builder.addByte((cmd >> 8) & 0xFF);
    builder.addByte(tid & 0xFF);
    builder.addByte((tid >> 8) & 0xFF);
    builder.add(encRand);
    return tripleSha256(Uint8List.fromList(builder.toBytes())).sublist(20, 32);
  }

  /// Derive AAD for V1 encryption.
  /// Uses little-endian packing: pack("<HH", cmd, tid)
  static Uint8List _deriveV1Aad(int cmd, int tid) {
    return Uint8List.fromList([
      cmd & 0xFF,
      (cmd >> 8) & 0xFF,
      tid & 0xFF,
      (tid >> 8) & 0xFF,
    ]);
  }

  /// Encrypt with V1 AES-128-GCM.
  /// Returns ciphertext + 16-byte GCM tag.
  static Future<Uint8List> encryptV1(
    Uint8List plaintext,
    Uint8List encRand,
    int cmd,
    int tid,
  ) async {
    final key = _deriveV1Key(encRand);
    final nonce = _deriveV1Nonce(encRand, cmd, tid);
    final aad = _deriveV1Aad(cmd, tid);

    final algorithm = crypto.AesGcm.with128bits();
    final secretKey = await algorithm.newSecretKeyFromBytes(key);
    final secretBox = await algorithm.encrypt(
      plaintext,
      secretKey: secretKey,
      nonce: nonce,
      aad: aad,
    );

    // Return ciphertext + tag (16 bytes)
    final result = BytesBuilder();
    result.add(secretBox.cipherText);
    result.add(secretBox.mac.bytes);
    return Uint8List.fromList(result.toBytes());
  }

  /// Decrypt with V1 AES-128-GCM.
  /// Input is ciphertext + 16-byte GCM tag.
  static Future<Uint8List> decryptV1(
    Uint8List ciphertextWithTag,
    Uint8List encRand,
    int cmd,
    int tid,
  ) async {
    final key = _deriveV1Key(encRand);
    final nonce = _deriveV1Nonce(encRand, cmd, tid);
    final aad = _deriveV1Aad(cmd, tid);

    // Split ciphertext and tag
    final ciphertext = ciphertextWithTag.sublist(0, ciphertextWithTag.length - 16);
    final tag = ciphertextWithTag.sublist(ciphertextWithTag.length - 16);

    final algorithm = crypto.AesGcm.with128bits();
    final secretKey = await algorithm.newSecretKeyFromBytes(key);

    final secretBox = crypto.SecretBox(
      ciphertext,
      nonce: nonce,
      mac: crypto.Mac(tag),
    );

    final decrypted = await algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
      aad: aad,
    );
    return Uint8List.fromList(decrypted);
  }

  // ==========================================================================
  // PKCS7 Padding helpers
  // ==========================================================================

  static Uint8List _pkcs7Pad(Uint8List data, int blockSize) {
    final padLength = blockSize - (data.length % blockSize);
    final padded = Uint8List(data.length + padLength);
    padded.setAll(0, data);
    for (int i = data.length; i < padded.length; i++) {
      padded[i] = padLength;
    }
    return padded;
  }

  static Uint8List _pkcs7Unpad(Uint8List data) {
    if (data.isEmpty) return data;
    final padLength = data.last;
    if (padLength > 16 || padLength == 0) return data;
    // Validate padding
    for (int i = data.length - padLength; i < data.length; i++) {
      if (data[i] != padLength) return data; // Invalid padding, return as-is
    }
    return data.sublist(0, data.length - padLength);
  }

  /// Debug helper: bytes to hex string
  static String _toHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
