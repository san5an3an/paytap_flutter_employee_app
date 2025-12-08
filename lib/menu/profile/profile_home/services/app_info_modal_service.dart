import 'package:paytap_app/common/services/Common/http_service.dart';

class AppInfoModalService {
  final HttpService _httpService = HttpService();

  Future<Map<String, dynamic>> getAppVer(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '/push-notification/app/ver',
      data,
    );
    return res;
  }
}
