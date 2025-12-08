import 'package:paytap_app/common/services/Common/http_service.dart';

class NoticeDetailModalService {
  final HttpService _httpService = HttpService();

  Future<Map<String, dynamic>> getNoticeDetailList(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '/board/notice/detail',
      data,
    );
    return res;
  }
}
