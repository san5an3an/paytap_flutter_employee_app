import 'package:paytap_app/common/models/device_storage.dart';
import 'package:paytap_app/common/services/Common/http_service.dart';

class AlarmHistoryService {
  HttpService httpService = HttpService();
  // 알림 내역 조회
  Future<Map<String, dynamic>> getAlarmHistoryList({
    required Map<String, dynamic> data,
  }) async {
    final Map<String, dynamic> res = await httpService.get(
      '/push-notification/alarm/store',
      data,
    );
    return res;
  }

  // 디바이스 정보 가져오기
  Future getDeviceInfo() async {
    // JSON 파일을 로드

    final deviceInfoStorage = await DeviceStorage.read("deviceInfo");
    return deviceInfoStorage;
  }
}
