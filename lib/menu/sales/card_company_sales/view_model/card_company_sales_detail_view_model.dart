import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/services/statistics_service.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/query_state.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 카드사별 매출 상세 화면의 상태 모델
class CardCompanySalesDetailState {
  final QueryState queryState;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isInitialized;
  final List originalList;
  final List itemList;
  final int startNo;
  final int recordSize;
  final String? payCorpNm;

  CardCompanySalesDetailState({
    QueryState? queryState,
    this.isLoading = false,
    this.isInitialLoading = false,
    this.isInitialized = false,
    this.originalList = const [],
    this.itemList = const [],
    this.startNo = 0,
    this.recordSize = 10,
    this.payCorpNm,
  }) : queryState =
           queryState ??
           QueryState({'startDe': DateTime.now(), 'endDe': DateTime.now()});

  CardCompanySalesDetailState copyWith({
    QueryState? queryState,
    bool? isLoading,
    bool? isInitialLoading,
    bool? isInitialized,
    List? originalList,
    List? itemList,
    int? startNo,
    int? recordSize,
    String? payCorpNm,
  }) {
    return CardCompanySalesDetailState(
      queryState: queryState ?? this.queryState,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      originalList: originalList ?? this.originalList,
      itemList: itemList ?? this.itemList,
      startNo: startNo ?? this.startNo,
      recordSize: recordSize ?? this.recordSize,
      payCorpNm: payCorpNm ?? this.payCorpNm,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class CardCompanySalesDetailViewModel
    extends Notifier<CardCompanySalesDetailState> {
  final ScrollController scrollController = ScrollController();

  @override
  CardCompanySalesDetailState build() {
    // dispose 콜백 등록
    ref.onDispose(() {
      scrollController.dispose();
    });

    return CardCompanySalesDetailState();
  }

  void setInitialData(Map<String, dynamic>? arguments) {
    print("arguments: $arguments");
    QueryState? updatedQueryState;
    String? payCorpNm;

    if (arguments != null) {
      payCorpNm = arguments['payCorpNm'];
      final queryMap = Map<String, dynamic>.from(
        state.queryState.getAllQuery(),
      );
      updatedQueryState = QueryState(queryMap);
      updatedQueryState.onChangeQuery('payCorpCode', arguments['payCorpCode']);
      updatedQueryState.onChangeQuery('startDe', arguments['startDe']);
      updatedQueryState.onChangeQuery('endDe', arguments['endDe']);
    }

    state = state.copyWith(
      queryState: updatedQueryState ?? state.queryState,
      payCorpNm: payCorpNm,
    );
  }

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// 초기 로딩 상태 설정
  void setInitialLoading(bool loading) {
    state = state.copyWith(isInitialLoading: loading);
  }

  /// 초기 데이터 로딩 함수
  Future<void> initializeData(BuildContext context) async {
    if (state.isInitialized) return;

    setLoading(true);
    try {
      await getCardCompanySalesDetail(context);

      state = state.copyWith(isInitialized: true);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 추가 데이터 로딩 함수
  Future<void> loadMoreData(BuildContext context) async {
    if (!state.isLoading) {
      setLoading(true);
      try {
        await getCardCompanySalesDetail(context);
      } catch (e) {
        print('Error loading more data: $e');
      } finally {
        setLoading(false);
      }
    }
  }

  /// 새로고침 함수
  Future<void> refreshData(BuildContext context) async {
    if (!state.isInitialLoading) {
      setInitialLoading(true);
      try {
        await resetCardCompanySalesDetailList();
        await getCardCompanySalesDetail(context);
      } catch (e) {
        print('Error during refresh: $e');
      } finally {
        setInitialLoading(false);
      }
    }
  }

  //데이터 초기화 하는 함수
  Future<void> resetCardCompanySalesDetailList() async {
    state = state.copyWith(originalList: [], itemList: [], startNo: 0);
  }

  //데이터 조회 하는 함수
  Future<void> getCardCompanySalesDetail(BuildContext context) async {
    Map<String, dynamic> data = {...state.queryState.getAllQuery()};
    data['startNo'] = state.startNo;
    data['recordSize'] = state.recordSize;

    Map<String, dynamic> res = await StatisticsService.getAppSaleCardDetail(
      data,
    );

    if (res.containsKey('error'))
      return _showErrorDialog(context, res["results"]);
    if (res['results'].length > 0) {
      final updatedOriginalList = [...state.originalList, ...res['results']];
      final convertData = convertPaymentHistoryItemData(updatedOriginalList);

      state = state.copyWith(
        startNo: state.startNo + state.recordSize,
        originalList: updatedOriginalList,
        itemList: convertData,
      );
    }
  }

  List<Map<String, dynamic>> convertPaymentHistoryItemData(List<dynamic> list) {
    Map<String, List<Map<String, dynamic>>> groupedBySaleDe =
        CommonHelpers.grouyByList(list, 'saleDe');

    // 결과 출력
    List<Map<String, dynamic>> resultList = [];
    groupedBySaleDe.forEach((saleDe, sales) {
      final updatedSales = sales.map((sale) {
        final saleMap = Map<String, dynamic>.from(sale);
        saleMap['payCorpNm'] = state.payCorpNm;
        return saleMap;
      }).toList();

      Map<String, dynamic> totalData = {
        'saleDe': saleDe,
        'child': updatedSales,
      };

      resultList.add(totalData);
    });

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

/// CardCompanySalesDetailViewModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final cardCompanySalesDetailViewModelProvider =
    NotifierProvider.autoDispose<
      CardCompanySalesDetailViewModel,
      CardCompanySalesDetailState
    >(CardCompanySalesDetailViewModel.new);
