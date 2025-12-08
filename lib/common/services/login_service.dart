import 'package:paytap_app/common/services/Common/http_service.dart';

class LoginService {
  static final LoginService _instance = LoginService._internal();
  static final HttpService _httpService = HttpService();
  static const String serverName = "/login";
  // private 생성자
  LoginService._internal();

  // 싱글톤 인스턴스 반환
  static LoginService get instance => _instance;

  // 모바일 로그인 API
  static Future<Map<String, dynamic>> postAppInitial(
    Map<String, dynamic> data,
  ) async {
    final res = await _httpService.post('$serverName/app/initial', data);
    return res;
  }

  // 모바일 자동 로그인 API
  static Future<Map<String, dynamic>> postAppAuto(
    Map<String, dynamic> data,
  ) async {
    final res = await _httpService.post('$serverName/app/auto', data);
    return res;
  }
}
