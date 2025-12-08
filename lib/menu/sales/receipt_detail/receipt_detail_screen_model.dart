import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/services/payment_service.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 영수증 상세 화면의 상태 모델
class ReceiptDetailState {
  final List<dynamic> orderList;
  final Map<String, dynamic> receiptInfo;
  final Map<String, dynamic> totalReceiptOrderList;
  final List receiptOrderList;
  final List receiptPaymentList;
  final bool isLoading;
  final bool isInitialized;

  const ReceiptDetailState({
    this.orderList = const [],
    this.receiptInfo = const {},
    this.totalReceiptOrderList = const {},
    this.receiptOrderList = const [],
    this.receiptPaymentList = const [],
    this.isLoading = false,
    this.isInitialized = false,
  });

  ReceiptDetailState copyWith({
    List<dynamic>? orderList,
    Map<String, dynamic>? receiptInfo,
    Map<String, dynamic>? totalReceiptOrderList,
    List? receiptOrderList,
    List? receiptPaymentList,
    bool? isLoading,
    bool? isInitialized,
  }) {
    return ReceiptDetailState(
      orderList: orderList ?? this.orderList,
      receiptInfo: receiptInfo ?? this.receiptInfo,
      totalReceiptOrderList:
          totalReceiptOrderList ?? this.totalReceiptOrderList,
      receiptOrderList: receiptOrderList ?? this.receiptOrderList,
      receiptPaymentList: receiptPaymentList ?? this.receiptPaymentList,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class ReceiptDetailScreenModel extends Notifier<ReceiptDetailState> {
  @override
  ReceiptDetailState build() {
    return const ReceiptDetailState();
  }

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// 초기 데이터 로드
  Future<void> initializeData(
    BuildContext context,
    Map<String, dynamic> arguments,
  ) async {
    if (state.isInitialized) return;

    setLoading(true);
    try {
      await getDealHistoryDetail(context, arguments);
      state = state.copyWith(isInitialized: true);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setLoading(false);
    }
  }

  //데이터 조회 하는 함수
  Future<void> getDealHistoryDetail(context, data) async {
    Map<String, dynamic> res = await PaymentService.getAppSaleReceiptDetail({
      "posNo": data["posNo"],
      "saleDe": data["saleDe"],
      "recptUnqno": data["recptUnqno"],
    });
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }

    final receiptInfo = res['results']['appReceiptInfo'];
    final receiptOrderList = res['results']['appReceiptOrderList'];
    final receiptPaymentList = res['results']['appReceiptPaymentList'];
    final totalReceiptOrderList = convertTotalOrderList(receiptOrderList);

    state = state.copyWith(
      receiptInfo: receiptInfo,
      receiptOrderList: receiptOrderList,
      receiptPaymentList: receiptPaymentList,
      totalReceiptOrderList: totalReceiptOrderList,
    );
  }

  Map<String, dynamic> convertTotalOrderList(List list) {
    Map<String, dynamic> resultList = {
      "totalSalePrice": 0,
      "totalDcmSalePrice": 0,
      "totalDcPrice": 0,
      "totalVatPrice": 0,
      "totalSupplyPrice": 0,
    };
    for (var item in list) {
      resultList['totalSalePrice'] =
          (resultList['totalSalePrice'] as num) + (item['salePrice'] ?? 0);
      resultList['totalDcmSalePrice'] =
          (resultList['totalDcmSalePrice'] as num) +
          (item['dcmSalePrice'] ?? 0);
      resultList['totalDcPrice'] =
          (resultList['totalDcPrice'] as num) + (item['dcPrice'] ?? 0);
      resultList['totalSupplyPrice'] =
          (resultList['totalSupplyPrice'] as num) + (item['supplyPrice'] ?? 0);
      resultList['totalVatPrice'] =
          (resultList['totalVatPrice'] as num) + (item['vatPrice'] ?? 0);
    }

    return resultList;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: '오류',
          content: message,
          confirmBtnLabel: '확인',
        );
      },
    );
  }
}

/// ReceiptDetailScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final receiptDetailScreenModelProvider =
    NotifierProvider.autoDispose<ReceiptDetailScreenModel, ReceiptDetailState>(
      ReceiptDetailScreenModel.new,
    );
