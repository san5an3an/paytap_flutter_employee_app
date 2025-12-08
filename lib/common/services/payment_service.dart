import 'package:paytap_app/common/services/Common/http_service.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  static final HttpService _httpService = HttpService();
  static const String serverName = "/payment";
  // private 생성자
  PaymentService._internal();

  // 싱글톤 인스턴스 반환
  static PaymentService get instance => _instance;

  // APP 영수 목록 조회
  static Future<Map<String, dynamic>> getAppSaleReceipt(
    Map<String, dynamic> data,
  ) async {
    final res = await _httpService.get('$serverName/app/sale/receipt', data);
    return res;
  }

  // APP 당일 매출 종합 조회
  static Future<Map<String, dynamic>> getAppSaleTotal(
    Map<String, dynamic> data,
  ) async {
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/total',
      data,
    );
    return res;
  }

  // APP 영수 정보 상세 조회
  static Future<Map<String, dynamic>> getAppSaleReceiptDetail(
    Map<String, dynamic> data,
  ) async {
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/receipt/detail',
      data,
    );
    return res;
  }

  static Future<Map<String, dynamic>> getAppSale(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale',
      data,
    );
    return res;
  }

  static Future<Map<String, dynamic>> getAppSaleRefund(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/refund',
      data,
    );
    return res;
  }

  // 카드 승인 내역역
  static Future<Map<String, dynamic>> getAppSaleCard(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/card',
      data,
    );
    return res;
  }

  static Future<Map<String, dynamic>> getAppSaleCash(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/cash',
      data,
    );
    return res;
  }

  // 간편 승인
  static Future<Map<String, dynamic>> getAppSaleEasyPay(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/easypay',
      data,
    );
    return res;
  }

  // 정산 내역역
  static Future<Map<String, dynamic>> getAppSaleAccount(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/account',
      data,
    );
    return res;
  }

  static Future<Map<String, dynamic>> getAppSaleManual(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/manual',
      data,
    );
    return res;
  }

  // 주문 취소 목록 조회
  static Future<Map<String, dynamic>> getAppSaleOrderCancel(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/order/cancel',
      data,
    );
    return res;
  }

  // 주문 취소 상세 조회
  static Future<Map<String, dynamic>> getAppSaleOrderCancelDetail(data) async {
    // JSON 파일을 로드
    final Map<String, dynamic> res = await _httpService.get(
      '$serverName/app/sale/order/cancel/detail',
      data,
    );
    return res;
  }
}
