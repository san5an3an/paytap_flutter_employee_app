import 'package:paytap_app/common/services/Common/http_service.dart';

class StatisticsService {
  static final StatisticsService _instance = StatisticsService._internal();
  static final HttpService _httpService = HttpService();
  static const String serverName = "/statistics";
  // private 생성자
  StatisticsService._internal();

  // 싱글톤 인스턴스 반환
  static StatisticsService get instance => _instance;

  // 홈 화면 매출 조회
  static Future<Map<String, dynamic>> getAppSaleHome(
    Map<String, dynamic> data,
  ) async {
    final res = await _httpService.get('$serverName/app/sale/home', data);
    return res;
  }

  // APP 카드사별매출
  static Future<Map<String, dynamic>> getAppSaleCard(
    Map<String, dynamic> data,
  ) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/card',
      data,
    );
    return res;
  }

  // APP 카드사별매출상세
  static Future<Map<String, dynamic>> getAppSaleCardDetail(
    Map<String, dynamic> data,
  ) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/card/detail',
      data,
    );
    return res;
  }

  static Future<Map<String, dynamic>> getAppSaleDiscount(
    Map<String, dynamic> data,
  ) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/discount',
      data,
    );
    return res;
  }

  static Future<Map<String, dynamic>> getAppRankGoods(
    Map<String, dynamic> data,
  ) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/rank/goods',
      data,
    );
    return res;
  }

  static Future<Map<String, dynamic>> getAppRankGoodsDetail(
    Map<String, dynamic> data,
  ) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/rank/goods/detail',
      data,
    );
    return res;
  }

  static Future<Map<String, dynamic>> getAppGrowthDay(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/growth/day',
      data,
    );
    return res;
  }

  static Future<Map<String, dynamic>> getAppGrowthMonth(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/growth/month',
      data,
    );
    return res;
  }

  static Future<Map<String, dynamic>> getAppGrowthTime(
    Map<String, dynamic> data,
  ) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/growth/time',
      data,
    );
    return res;
  }

  static Future<Map<String, dynamic>> getAppSaleDaily(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/daily',
      data,
    );
    return res;
  }

  static Future<Map<String, dynamic>> getAppSaleMonthly(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/monthly',
      data,
    );
    return res;
  }
}
