import 'package:paytap_app/common/models/cm_code.dart';
import 'package:paytap_app/common/models/pos.dart';
import 'package:paytap_app/common/services/Common/http_service.dart';
import 'package:paytap_app/common/utils/crypto_helper.dart';

class Session {
  static HttpService httpService = HttpService();
  static Map<String, dynamic> _storeInfo = {};
  static String _accessTkn = "";
  static String _userId = "";
  static String _storeNm = "";
  static String _goodsFlag = "";
  static String _roleCode = "";
  static String _storeUnqcd = "";

  static Map<String, dynamic> get storeInfo => _storeInfo;
  static String get userId => _userId;
  static String get storeNm => _storeNm;
  static String get goodsFlag => _goodsFlag;
  static String get roleCode => _roleCode;
  static String get storeUnqcd => _storeUnqcd;
  static String get accessTkn => _accessTkn;

  // 초기화
  static Future<void> initialize(
    String encryptUserInfo,
    String accessTkn,
  ) async {
    final decryptedData = CryptoHelper.decryptJson(encryptUserInfo);
    print("decryptedData: $decryptedData");
    _storeInfo = decryptedData["storeInfo"];
    _userId = decryptedData["storeInfo"]['userId'];
    _storeNm = decryptedData["storeInfo"]['storeNm'];
    _goodsFlag = decryptedData["storeInfo"]['goodsFlag'];
    _roleCode = decryptedData["storeInfo"]['roleCode'];
    _storeUnqcd = decryptedData["storeInfo"]['storeUnqcd'];
    _accessTkn = accessTkn;
    await HttpService.initialize(_userId, _accessTkn);
    //공통 코드 초기화
    await CmCode.initialize();
    //POS 초기화
    await Pos.initialize();
  }
}
