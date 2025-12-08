import 'package:paytap_app/common/services/Common/http_service.dart';

class PwdChangeService {
  final HttpService httpService = HttpService();

  // 비밀번호 변경
  Future<Map<String, dynamic>> patchChangePw(data) async {
    final Map<String, dynamic> res = await httpService.patch(
      '/auth/account/change-pw',
      data,
    );

    return res;
  }
}
