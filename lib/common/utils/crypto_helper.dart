import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';
import 'package:pointycastle/api.dart';
import 'package:archive/archive.dart';
import 'package:paytap_app/app/app_config.dart';

class CryptoHelper {
  /// 암호화된 데이터 복호화
  static Map<String, dynamic> decryptJson(String base64Encrypted) {
    // 토큰이 없는 경우
    if (base64Encrypted.isEmpty) return {};

    try {
      // 1. Base64 URL‑safe → 표준 Base64 변환 및 패딩 추가
      final base64 = base64Encrypted.replaceAll('-', '+').replaceAll('_', '/');
      final padded = base64 + '=' * ((4 - (base64.length % 4)) % 4);
      final binary = base64Decode(padded);

      // 2. IV (앞 16바이트)와 암호문 분리
      final iv = binary.sublist(0, 16);
      final encrypted = binary.sublist(16);

      // 3. AES‑192 CBC 복호화
      final key = utf8.encode(AppConfig.loginDecryptKey);

      // CBC 모드로 복호화
      final aes = AESEngine();
      final cbc = CBCBlockCipher(aes);
      final params = ParametersWithIV(
        KeyParameter(Uint8List.fromList(key)),
        Uint8List.fromList(iv),
      );
      cbc.init(false, params);

      // 블록 단위로 복호화
      final decrypted = _processCBCBlocks(cbc, encrypted);

      // 5. 압축 해제 (zlib inflate)
      final decoder = ZLibDecoder();
      final inflated = decoder.decodeBytes(Uint8List.fromList(decrypted));
      final result = utf8.decode(inflated);

      return jsonDecode(result);
    } catch (e) {
      print('복호화 에러: $e');
      return {};
    }
  }

  static String decrypt(String encryptedData, String key, String iv) {
    try {
      final keyBytes = Uint8List.fromList(utf8.encode(key));
      final ivBytes = Uint8List.fromList(utf8.encode(iv));
      final encryptedBytes = base64.decode(encryptedData);

      final cipher = _createCipher(false, keyBytes, ivBytes);
      final decryptedBytes = _processBlocks(cipher, encryptedBytes);

      return utf8.decode(decryptedBytes);
    } catch (e) {
      print('복호화 중 오류 발생: $e');
      return '';
    }
  }

  static String encrypt(String data, String key, String iv) {
    try {
      final keyBytes = Uint8List.fromList(utf8.encode(key));
      final ivBytes = Uint8List.fromList(utf8.encode(iv));
      final dataBytes = utf8.encode(data);

      final cipher = _createCipher(true, keyBytes, ivBytes);
      final encryptedBytes = _processBlocks(cipher, dataBytes);

      return base64.encode(encryptedBytes);
    } catch (e) {
      print('암호화 중 오류 발생: $e');
      return '';
    }
  }

  static PaddedBlockCipherImpl _createCipher(
    bool forEncryption,
    Uint8List key,
    Uint8List iv,
  ) {
    final aes = AESEngine();
    final cbc = CBCBlockCipher(aes);
    final cipher = PaddedBlockCipherImpl(PKCS7Padding(), cbc);
    final params =
        PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
          ParametersWithIV(KeyParameter(key), iv),
          null,
        );
    cipher.init(forEncryption, params);
    return cipher;
  }

  static List<int> _processBlocks(
    PaddedBlockCipherImpl cipher,
    List<int> data,
  ) {
    final result = <int>[];
    final blockSize = cipher.blockSize;

    for (var i = 0; i < data.length; i += blockSize) {
      final end = (i + blockSize < data.length) ? i + blockSize : data.length;
      final block = Uint8List.fromList(data.sublist(i, end));
      final processed = cipher.process(block);
      result.addAll(processed);
    }

    return result;
  }

  static List<int> _processCBCBlocks(CBCBlockCipher cipher, List<int> data) {
    final result = <int>[];
    final blockSize = cipher.blockSize;

    for (var i = 0; i < data.length; i += blockSize) {
      final end = (i + blockSize < data.length) ? i + blockSize : data.length;
      final block = Uint8List.fromList(data.sublist(i, end));

      // 마지막 블록이 아닌 경우에만 처리
      if (block.length == blockSize) {
        final processed = cipher.process(block);
        result.addAll(processed);
      }
    }

    return result;
  }
}
