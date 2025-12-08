import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:paytap_app/app/app_config.dart';

class HttpService {
  final storage = FlutterSecureStorage();
  static String _userId = "";
  static String _accessTkn = "";
  HttpService();

  // 초기화
  static Future<void> initialize(String userId, String accessTkn) async {
    _userId = userId;
    _accessTkn = accessTkn;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, [
    Map<String, dynamic> data = const {},
    Map<String, dynamic> header = const {},
  ]) async {
    Map<String, String> httpHeader = {'Content-Type': 'application/json'};
    // params 모든 값을 문자열로 변환
    Map<String, String> stringParams = {};
    Uri url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

    httpHeader["GP-AUTH-ID"] = _userId;
    httpHeader["GP-AUTH-TOKEN"] = _accessTkn;

    //param 변환
    data.forEach((key, value) {
      stringParams[key] = value.toString(); // 값을 문자열로 변환
    });
    final queryString = Uri(queryParameters: stringParams).query;

    if (queryString != "") {
      url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint?$queryString');
    }

    final response = await http.get(url, headers: httpHeader);
    if (response.statusCode == 200 || response.statusCode == 201) {
      var decodedResponse = utf8.decode(response.bodyBytes);
      print('=====================================================');
      print('Query: $data');
      print('URL : $endpoint');
      print('DATA : ${jsonDecode(decodedResponse)}');
      print('=====================================================');

      return jsonDecode(decodedResponse); // 응답 본문을 반환
    } else {
      return {
        "error": {"code": "통신오류"},
        "results": "잠시후 다시 시도해 주세요.",
        "status": "8999999",
      };
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    Map<String, String> httpHeader = {'Content-Type': 'application/json'};

    httpHeader["GP-AUTH-ID"] = _userId;
    httpHeader["GP-AUTH-TOKEN"] = _accessTkn;

    print('=====================================================');
    print('QUERY : ${jsonEncode(data)}');
    print('=====================================================');

    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
      headers: httpHeader,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var decodedResponse = utf8.decode(response.bodyBytes);
      print('=====================================================');
      print('URL : $endpoint');
      print('DATA : ${jsonDecode(decodedResponse)}');
      print('=====================================================');
      return jsonDecode(decodedResponse); // 응답 본문을 반환
    } else {
      return {
        "error": {"code": "통신오류"},
        "results": "잠시후 다시 시도해 주세요.",
        "status": "8999999",
      };
    }
  }

  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    Map<String, String> httpHeader = {'Content-Type': 'application/json'};

    httpHeader["GP-AUTH-ID"] = _userId;
    httpHeader["GP-AUTH-TOKEN"] = _accessTkn;

    final response = await http.patch(
      Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
      headers: httpHeader,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('=====================================================');
      print('QUERY : ${jsonEncode(data)}');
      print('=====================================================');

      var decodedResponse = utf8.decode(response.bodyBytes);
      print('=====================================================');
      print('URL : $endpoint');
      print('DATA : ${jsonDecode(decodedResponse)}');
      print('=====================================================');
      return jsonDecode(decodedResponse); // 응답 본문을 반환
    } else {
      return {
        "error": {"code": "통신오류"},
        "results": "잠시후 다시 시도해 주세요.",
        "status": "8999999",
      };
    }
  }
}
