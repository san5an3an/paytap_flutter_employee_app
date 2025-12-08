import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceStorage {
  static final DeviceStorage _instance = DeviceStorage._internal();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // private 생성자
  DeviceStorage._internal() {
    _initialize();
  }

  // 싱글톤 인스턴스 반환
  factory DeviceStorage() {
    return _instance;
  }

  void _initialize() async {
    // 초기화 로직
  }

  // 데이터 저장 메서드
  static Future<void> write(String key, Map<String, dynamic> value) async {
    await _instance._storage.write(key: key, value: jsonEncode(value));
  }

  // 데이터 읽기 메서드
  static Future<Map<String, dynamic>?> read(String key) async {
    final data = await _instance._storage.read(key: key);
    if (data == null) {
      return null;
    }
    return jsonDecode(data);
  }

  // 데이터 삭제 메서드
  static Future<void> delete(String key) async {
    await _instance._storage.delete(key: key);
  }

  // 모든 데이터 삭제 메서드
  static Future<void> deleteAll() async {
    await _instance._storage.deleteAll();
  }

  // 모든 키 조회 메서드
  static Future<List<String>> getAllKeys() async {
    return await _instance._storage.readAll().then((map) => map.keys.toList());
  }
}
