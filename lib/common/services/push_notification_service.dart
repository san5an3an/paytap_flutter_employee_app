import 'package:paytap_app/common/services/Common/http_service.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  static final HttpService _httpService = HttpService();
  static const String serverName = "/push-notification";
  // private 생성자
  PushNotificationService._internal();

  // 싱글톤 인스턴스 반환
  static PushNotificationService get instance => _instance;

  //앱 버전 조회회
  static Future<Map<String, dynamic>> getAppVer(
    Map<String, dynamic> data,
  ) async {
    final res = await _httpService.get('$serverName/app/ver', data);
    return res;
  }

  //디바이스 알람 상태 조회
  static Future<Map<String, dynamic>> getDevice(
    Map<String, dynamic> data,
  ) async {
    final res = await _httpService.get('$serverName/device', data);
    return res;
  }

  //디바이스 알람 상태 수정
  static Future<Map<String, dynamic>> patchDevice(
    Map<String, dynamic> data,
  ) async {
    final res = await _httpService.patch('$serverName/device', data);
    return res;
  }

  //디바이스 토큰 저장
  static Future<Map<String, dynamic>> saveDevice(
    Map<String, dynamic> data,
  ) async {
    final res = await _httpService.post('$serverName/device', data);
    return res;
  }
}
