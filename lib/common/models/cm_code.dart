import 'package:paytap_app/common/services/Common/http_service.dart';

class CmCodeItem {
  final String codeGrp;
  final String code;
  final String codeNm;
  final String codeCntnts;

  CmCodeItem({
    required this.codeGrp,
    required this.code,
    required this.codeNm,
    required this.codeCntnts,
  });

  factory CmCodeItem.fromJson(Map<String, dynamic> json) {
    return CmCodeItem(
      codeGrp: json['codeGrp'],
      code: json['code'],
      codeNm: json['codeNm'],
      codeCntnts: json['codeCntnts'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codeGrp': codeGrp,
      'code': code,
      'codeNm': codeNm,
      'codeCntnts': codeCntnts,
    };
  }
}

class CmCode {
  static HttpService httpService = HttpService();
  static List<CmCodeItem> _cmcodeList = [];
  static List<CmCodeItem> get cmcodeList => _cmcodeList;

  static Future<void> getCmcodeList() async {
    final res = await httpService.get("/common/code/public");
    if (res.containsKey('error')) return print(res["error"]);
    _cmcodeList = (res["results"] as List<dynamic>)
        .map((e) => CmCodeItem.fromJson(e))
        .toList();
    print(_cmcodeList);
  }

  // 초기화
  static Future<void> initialize() async {
    await getCmcodeList();
  }

  static List<CmCodeItem> getFindCmcodeList(String codeGrp) {
    return _cmcodeList.where((item) => item.codeGrp == codeGrp).toList();
  }
}
