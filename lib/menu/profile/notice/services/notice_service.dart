import 'package:paytap_app/common/services/Common/http_service.dart';

class NoticeService {
  final HttpService _httpService = HttpService();

  Future<Map<String, dynamic>> getNoticeList(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '/board/notice',
      data,
    );
    return res;
  }
}
