import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/services/statistics_service.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 상품 상세 화면의 상태 모델
class GoodsDetailState {
  final List<dynamic> orderList;
  final Map<String, dynamic> goodsDetail;
  final List optInfoList;
  final double optTotalPrice;
  final bool isLoading;
  final bool isInitialized;

  const GoodsDetailState({
    this.orderList = const [],
    this.goodsDetail = const {},
    this.optInfoList = const [],
    this.optTotalPrice = 0.0,
    this.isLoading = false,
    this.isInitialized = false,
  });

  GoodsDetailState copyWith({
    List<dynamic>? orderList,
    Map<String, dynamic>? goodsDetail,
    List? optInfoList,
    double? optTotalPrice,
    bool? isLoading,
    bool? isInitialized,
  }) {
    return GoodsDetailState(
      orderList: orderList ?? this.orderList,
      goodsDetail: goodsDetail ?? this.goodsDetail,
      optInfoList: optInfoList ?? this.optInfoList,
      optTotalPrice: optTotalPrice ?? this.optTotalPrice,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class GoodsDetailScreenModel extends Notifier<GoodsDetailState> {
  @override
  GoodsDetailState build() {
    return const GoodsDetailState();
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
      await getGoodsSalesDetail(context, arguments);
      state = state.copyWith(isInitialized: true);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setLoading(false);
    }
  }

  //데이터 조회 하는 함수
  Future<void> getGoodsSalesDetail(context, data) async {
    Map<String, dynamic> res = await StatisticsService.getAppRankGoodsDetail(
      data,
    );
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }

    final goodsDetail = res['results']['goodsDetail'];
    final optInfoList = convertOptInfoList(res['results']['optInfo']);

    state = state.copyWith(goodsDetail: goodsDetail, optInfoList: optInfoList);
  }

  List<Map<String, dynamic>> convertOptInfoList(list) {
    double optTotalPrice = 0.0;
    for (var item in list) {
      optTotalPrice += item['dcmSalePrice'];
    }
    Map<String, List<Map<String, dynamic>>> groupedByOptGrpNm =
        CommonHelpers.grouyByList(list, 'optGrpNm');

    // 결과 출력
    List<Map<String, dynamic>> resultList = [];
    groupedByOptGrpNm.forEach((groupNm, groupItem) {
      Map<String, dynamic> totalData = {'groupNm': groupNm, 'child': groupItem};

      resultList.add(totalData);
    });

    state = state.copyWith(optTotalPrice: optTotalPrice);
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

/// GoodsDetailScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final goodsDetailScreenModelProvider =
    NotifierProvider.autoDispose<GoodsDetailScreenModel, GoodsDetailState>(
      GoodsDetailScreenModel.new,
    );
