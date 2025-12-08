import 'package:paytap_app/common/services/Common/http_service.dart';

class CommonService {
  static final CommonService _instance = CommonService._internal();
  static final HttpService _httpService = HttpService();
  static const String serverName = "/common";
  // private 생성자
  CommonService._internal();

  // 싱글톤 인스턴스 반환
  static CommonService get instance => _instance;

  static Future<Map<String, dynamic>> getCommonCodePublic(
    Map<String, dynamic> data,
  ) async {
    final res = await _httpService.get('$serverName/code/public', data);
    return res;
  }
}
