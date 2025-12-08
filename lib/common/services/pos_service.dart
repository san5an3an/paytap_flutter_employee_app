import 'package:paytap_app/common/services/Common/http_service.dart';

class PosService {
  static final PosService _instance = PosService._internal();
  static final HttpService _httpService = HttpService();
  static const String serverName = "/pos";
  // private 생성자
  PosService._internal();

  // 싱글톤 인스턴스 반환
  static PosService get instance => _instance;

  // 홈 화면 매출 조회
  static Future<Map<String, dynamic>> getEnvPos(
    Map<String, dynamic> data,
  ) async {
    final res = await _httpService.get('$serverName/env/pos', data);
    return res;
  }

  static Future<Map<String, dynamic>> getEnvTabStore(data) async {
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/env/tab/store',
      data,
    );
    return res;
  }
}
