import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paytap_app/common/services/statistics_service.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/widget/amount_card/data/amount_card_model.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';
import 'package:paytap_app/common/widget/cm_search/data/search_config.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 월별 매출 집계 화면의 상태 모델
class MonthlyTotalSalesState {
  final Map<String, dynamic> searchState;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isInitialized;
  final List originalList;
  final List itemList;
  final SearchConfig searchConfig;
  final List<AmountCardModel> amountCardMainList;

  MonthlyTotalSalesState({
    required this.searchState,
    this.isLoading = false,
    this.isInitialLoading = false,
    this.isInitialized = false,
    this.originalList = const [],
    this.itemList = const [],
    SearchConfig? searchConfig,
    this.amountCardMainList = const [],
  }) : searchConfig =
           searchConfig ??
           SearchConfig(
             list: [
               SearchConfigItem(
                 label: "기간",
                 type: CmSearchType.rangeMonthDate,
                 name: "rangeDate",
                 startDateKey: "startMth",
                 endDateKey: "endMth",
               ),
               SearchConfigItem(
                 label: "포스",
                 name: "posNo",
                 type: CmSearchType.pos,
                 options: [],
               ),
             ],
           );

  MonthlyTotalSalesState copyWith({
    Map<String, dynamic>? searchState,
    bool? isLoading,
    bool? isInitialLoading,
    bool? isInitialized,
    List? originalList,
    List? itemList,
    SearchConfig? searchConfig,
    List<AmountCardModel>? amountCardMainList,
  }) {
    return MonthlyTotalSalesState(
      searchState: searchState ?? this.searchState,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      originalList: originalList ?? this.originalList,
      itemList: itemList ?? this.itemList,
      searchConfig: searchConfig ?? this.searchConfig,
      amountCardMainList: amountCardMainList ?? this.amountCardMainList,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class MonthlyTotalSalesScreenModel extends Notifier<MonthlyTotalSalesState> {
  final storage = FlutterSecureStorage();
  final ScrollController scrollController = ScrollController();

  @override
  MonthlyTotalSalesState build() {
    // dispose 콜백 등록
    ref.onDispose(() {
      scrollController.dispose();
    });

    return MonthlyTotalSalesState(
      searchState: {
        "posNo": "",
        "startMth": DateHelpers.getYYYYMMString(DateTime.now()),
        "endMth": DateHelpers.getYYYYMMString(DateTime.now()),
        "startNo": 0,
        "recordSize": 10,
      },
      amountCardMainList: [
        AmountCardModel(
          name: 'totSaleAmt',
          label: '총 매출 금액',
          value: 0,
          icon: 'assets/icons/i_sale.svg',
          color: 'bk01',
        ),
        AmountCardModel(
          name: 'totDcAmt',
          label: '총 할인 금액',
          value: 0,
          icon: 'assets/icons/i_discount.svg',
          color: 'bk03',
        ),
        AmountCardModel(
          name: 'totDcmSaleAmt',
          label: '실 매출 금액',
          value: 0,
          icon: 'assets/icons/i_saleTotal.svg',
          color: 'brand01',
        ),
      ],
    );
  }

  void setSearchState(Map<String, dynamic> newState, BuildContext context) {
    state = state.copyWith(searchState: newState);
    print(newState);
    refreshData(context);
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
      await getMonthlyTotalSales(context);

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
        await getMonthlyTotalSales(context);
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
        await resetMonthlyTotalSalesList();
        await getMonthlyTotalSales(context);
      } catch (e) {
        print('Error during refresh: $e');
      } finally {
        setInitialLoading(false);
      }
    }
  }

  //데이터 초기화 하는 함수
  Future<void> resetMonthlyTotalSalesList() async {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['startNo'] = 0;
    updatedState['recordSize'] = 10;

    final updatedAmountCardList = state.amountCardMainList.map((item) {
      return AmountCardModel(
        name: item.name,
        label: item.label,
        value: 0,
        icon: item.icon,
        color: item.color,
      );
    }).toList();

    state = state.copyWith(
      originalList: [],
      itemList: [],
      searchState: updatedState,
      amountCardMainList: updatedAmountCardList,
    );
  }

  //데이터 조회 하는 함수
  Future<void> getMonthlyTotalSales(BuildContext context) async {
    Map<String, dynamic> data = {...state.searchState};

    Map<String, dynamic> res = await StatisticsService.getAppSaleMonthly(data);
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }

    if (res['results'].isNotEmpty) {
      final updatedState = Map<String, dynamic>.from(state.searchState);
      updatedState['startNo'] =
          updatedState['startNo'] + updatedState['recordSize'];

      final updatedAmountCardList = state.amountCardMainList.map((item) {
        return AmountCardModel(
          name: item.name,
          label: item.label,
          value: res['results']['totalStats'][item.name] ?? 0,
          icon: item.icon,
          color: item.color,
        );
      }).toList();

      final updatedOriginalList = [
        ...state.originalList,
        ...res['results']['statsList'],
      ];

      state = state.copyWith(
        searchState: updatedState,
        originalList: updatedOriginalList,
        itemList: updatedOriginalList,
        amountCardMainList: updatedAmountCardList,
      );
    }
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

/// MonthlyTotalSalesScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final monthlyTotalSalesScreenModelProvider =
    NotifierProvider.autoDispose<
      MonthlyTotalSalesScreenModel,
      MonthlyTotalSalesState
    >(MonthlyTotalSalesScreenModel.new);
