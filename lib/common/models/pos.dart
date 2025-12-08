import 'package:paytap_app/common/models/session.dart';
import 'package:paytap_app/common/services/Common/http_service.dart';

class PosItem {
  final String posNo;
  final String posNm;
  final String confrmAt;
  final String mainPosEnvCode;
  final String deviceTypeCode;

  PosItem({
    required this.posNo,
    required this.posNm,
    required this.confrmAt,
    required this.mainPosEnvCode,
    required this.deviceTypeCode,
  });

  factory PosItem.fromJson(Map<String, dynamic> json) {
    return PosItem(
      posNo: json['posNo'],
      posNm: json['posNm'],
      confrmAt: json['confrmAt'],
      mainPosEnvCode: json['mainPosEnvCode'],
      deviceTypeCode: json['deviceTypeCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posNo': posNo,
      'posNm': posNm,
      'confrmAt': confrmAt,
      'mainPosEnvCode': mainPosEnvCode,
      'deviceTypeCode': deviceTypeCode,
    };
  }
}

class Pos {
  static HttpService httpService = HttpService();
  static List<PosItem> _posList = [];

  static List<PosItem> get posList => _posList;

  static Future<void> getPosList() async {
    final res = await httpService.get("/pos/env/pos", {
      "storeUnqcd": Session.storeUnqcd,
    });
    if (res.containsKey('error')) return print(res["error"]);
    _posList = (res["results"] as List<dynamic>)
        .map((e) => PosItem.fromJson(e))
        .toList();
    print(_posList);
  }

  // 초기화
  static Future<void> initialize() async {
    await getPosList();
  }
}
