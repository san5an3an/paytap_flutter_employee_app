import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/services/payment_service.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 주문 취소 내역 상세 화면의 상태 모델
class CancelHistDetailState {
  final List<dynamic> cancelHistDetailList;
  final String title;
  final bool isLoading;
  final bool isInitialized;
  final Map<String, dynamic> totalCancelList;

  const CancelHistDetailState({
    this.cancelHistDetailList = const [],
    this.title = '',
    this.isLoading = false,
    this.isInitialized = false,
    Map<String, dynamic>? totalCancelList,
  }) : totalCancelList =
           totalCancelList ??
           const {
             'orderPrice': 0,
             'totDcAmt': 0,
             'vatMinusPrice': 0,
             'totVatPrice': 0,
           };

  CancelHistDetailState copyWith({
    List<dynamic>? cancelHistDetailList,
    String? title,
    bool? isLoading,
    bool? isInitialized,
    Map<String, dynamic>? totalCancelList,
  }) {
    return CancelHistDetailState(
      cancelHistDetailList: cancelHistDetailList ?? this.cancelHistDetailList,
      title: title ?? this.title,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      totalCancelList: totalCancelList ?? this.totalCancelList,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class CancelHistDetailScreenModel extends Notifier<CancelHistDetailState> {
  @override
  CancelHistDetailState build() {
    return const CancelHistDetailState();
  }

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// 금액을 문자열로 변환하는 메서드
  String getFormattedPrice(String key) {
    return CommonHelpers.stringParsePrice(state.totalCancelList[key].toInt());
  }

  /// 초기 데이터 로드
  Future<void> initializeData(
    BuildContext context,
    Map<String, dynamic> arguments,
  ) async {
    if (state.isInitialized) return;
    final title = '${arguments['posNo']}-${arguments['orderNo']}';
    setLoading(true);
    try {
      await getCancelHistDetail(context, arguments);
      state = state.copyWith(isInitialized: true, title: title);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 데이터 조회 함수
  Future<void> getCancelHistDetail(context, data) async {
    Map<String, dynamic> res = await PaymentService.getAppSaleOrderCancelDetail(
      {
        "posNo": data["posNo"],
        "saleDe": data["saleDe"],
        "orderNo": data["orderNo"],
      },
    );
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }

    // 데이터가 null이거나 빈 배열인 경우 처리
    if (res['results'] == null || res['results'].isEmpty) {
      state = state.copyWith(cancelHistDetailList: []);
      return;
    }

    final totalCancelList = Map<String, dynamic>.from(state.totalCancelList);
    for (var item in res['results']) {
      totalCancelList['orderPrice'] =
          (totalCancelList['orderPrice'] as num) +
          _safeParseDouble(item['salePrice']);
      totalCancelList['totDcAmt'] =
          (totalCancelList['totDcAmt'] as num) +
          _safeParseDouble(item['dcPrice']);
      totalCancelList['vatMinusPrice'] =
          (totalCancelList['vatMinusPrice'] as num) +
          _safeParseDouble(item['dcmSalePrice']) -
          _safeParseDouble(item['vatPrice']);
      totalCancelList['totVatPrice'] =
          (totalCancelList['totVatPrice'] as num) +
          _safeParseDouble(item['vatPrice']);

      if (item['optItems'] != null) {
        for (var optItem in item['optItems']) {
          totalCancelList['orderPrice'] =
              (totalCancelList['orderPrice'] as num) +
              _safeParseDouble(optItem['salePrice']);
          totalCancelList['totDcAmt'] =
              (totalCancelList['totDcAmt'] as num) +
              _safeParseDouble(optItem['dcPrice']);
          totalCancelList['vatMinusPrice'] =
              (totalCancelList['vatMinusPrice'] as num) +
              _safeParseDouble(optItem['dcmSalePrice']) -
              _safeParseDouble(optItem['vatPrice']);
          totalCancelList['totVatPrice'] =
              (totalCancelList['totVatPrice'] as num) +
              _safeParseDouble(optItem['vatPrice']);
        }
      }
    }

    state = state.copyWith(
      cancelHistDetailList: res['results'],
      totalCancelList: totalCancelList,
    );
  }

  /// 안전한 double 파싱 메서드
  double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
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

/// CancelHistDetailScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final cancelHistDetailScreenModelProvider =
    NotifierProvider.autoDispose<
      CancelHistDetailScreenModel,
      CancelHistDetailState
    >(CancelHistDetailScreenModel.new);
