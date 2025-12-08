import 'package:paytap_app/common/models/device_storage.dart';
import 'package:paytap_app/common/services/Common/http_service.dart';

class ProfileService {
  final HttpService httpService = HttpService();

  Future getLoginInfo() async {
    // JSON 파일을 로드
    final loginInfoStorage = await DeviceStorage.read("loginInfo");

    return loginInfoStorage;
  }

  // 매장정보 조회
  Future<Map<String, dynamic>> getStoreInfo(data) async {
    final Map<String, dynamic> res = await httpService.get('/store/info', data);

    return res;
  }

  // APP 로그아웃
  Future<Map<String, dynamic>> postLogout(data) async {
    final Map<String, dynamic> res = await httpService.patch(
      '/login/app/logout',
      {},
    );

    await DeviceStorage.delete("loginInfo");

    return res;
  }
}
