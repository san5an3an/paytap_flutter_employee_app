import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paytap_app/common/services/payment_service.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/widget/amount_card/data/amount_card_model.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';
import 'package:paytap_app/common/widget/cm_search/data/search_config.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 영수증 내역 화면의 상태 모델
class ReceiptHistoryState {
  final Map<String, dynamic> searchState;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isInitialized;
  final List originalList;
  final List<Map<String, dynamic>> receiptHistoryItemList;
  final SearchConfig searchConfig;
  final List<AmountCardModel> amountCardList;

  ReceiptHistoryState({
    required this.searchState,
    this.isLoading = false,
    this.isInitialLoading = false,
    this.isInitialized = false,
    this.originalList = const [],
    this.receiptHistoryItemList = const [],
    SearchConfig? searchConfig,
    this.amountCardList = const [],
  }) : searchConfig =
           searchConfig ??
           SearchConfig(
             list: [
               SearchConfigItem(
                 label: "조회 기간",
                 type: CmSearchType.rangeDayDate,
                 startDateKey: "startDe",
                 endDateKey: "endDe",
               ),
               SearchConfigItem(
                 label: "포스",
                 name: "posNo",
                 type: CmSearchType.pos,
               ),
             ],
           );

  ReceiptHistoryState copyWith({
    Map<String, dynamic>? searchState,
    bool? isLoading,
    bool? isInitialLoading,
    bool? isInitialized,
    List? originalList,
    List<Map<String, dynamic>>? receiptHistoryItemList,
    SearchConfig? searchConfig,
    List<AmountCardModel>? amountCardList,
  }) {
    return ReceiptHistoryState(
      searchState: searchState ?? this.searchState,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      originalList: originalList ?? this.originalList,
      receiptHistoryItemList:
          receiptHistoryItemList ?? this.receiptHistoryItemList,
      searchConfig: searchConfig ?? this.searchConfig,
      amountCardList: amountCardList ?? this.amountCardList,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class ReceiptHistoryScreenModel extends Notifier<ReceiptHistoryState> {
  final storage = FlutterSecureStorage();
  final ScrollController scrollController = ScrollController();

  @override
  ReceiptHistoryState build() {
    // dispose 콜백 등록
    ref.onDispose(() {
      scrollController.dispose();
    });

    return ReceiptHistoryState(
      searchState: {
        "startDe": DateHelpers.getYYYYMMDDString(DateTime.now()),
        "endDe": DateHelpers.getYYYYMMDDString(DateTime.now()),
        "posNo": "",
        "startNo": 0,
        "recordSize": 10,
      },
      amountCardList: [
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

  /// 초기 데이터 로드
  Future<void> initializeData(BuildContext context, args) async {
    if (state.isInitialized || state.isLoading) return;

    Map<String, dynamic> updatedState = Map<String, dynamic>.from(
      state.searchState,
    );
    if (args != null) {
      if (args['type'] == "week") {
        // 오늘 날짜 기준의 해당 주의 시작일(월요일)과 끝일(일요일)
        Map<String, DateTime> weekRange = DateHelpers.getWeekStartEnd(
          DateTime.now(),
        );
        updatedState['startDe'] = DateHelpers.getYYYYMMDDString(
          weekRange['start']!,
        );
        updatedState['endDe'] = DateHelpers.getYYYYMMDDString(
          weekRange['end']!,
        );
      } else if (args['type'] == "month") {
        // 오늘 날짜의 해당 월의 1일과 마지막일
        Map<String, DateTime> monthRange = DateHelpers.getMonthStartEnd(
          DateTime.now(),
        );
        updatedState['startDe'] = DateHelpers.getYYYYMMDDString(
          monthRange['start']!,
        );
        updatedState['endDe'] = DateHelpers.getYYYYMMDDString(
          monthRange['end']!,
        );
      }
    }

    state = state.copyWith(searchState: updatedState);
    setLoading(true);
    try {
      await getReceiptHistory(context);

      state = state.copyWith(isInitialized: true);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 추가 데이터 로드
  Future<void> loadMoreData(BuildContext context) async {
    if (state.isLoading) return;

    setLoading(true);
    try {
      await getReceiptHistory(context);
    } catch (e) {
      print('Error loading more data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 새로고침
  Future<void> refreshData(BuildContext context) async {
    if (state.isInitialLoading) return;

    setInitialLoading(true);
    try {
      await resetReceiptHistoryList();
      await getReceiptHistory(context);
    } catch (e) {
      print('Error during reset and reload: $e');
    } finally {
      setInitialLoading(false);
    }
  }

  //데이터 초기화 하는 함수
  Future<void> resetReceiptHistoryList() async {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['startNo'] = 0;
    updatedState['recordSize'] = 10;

    final updatedAmountCardList = state.amountCardList.map((item) {
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
      receiptHistoryItemList: [],
      searchState: updatedState,
      amountCardList: updatedAmountCardList,
    );
  }

  //데이터 조회 하는 함수
  Future<void> getReceiptHistory(context) async {
    Map<String, dynamic> data = {...state.searchState};

    Map<String, dynamic> res = await PaymentService.getAppSaleReceipt(data);
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }

    if (res['results'].isNotEmpty) {
      final updatedState = Map<String, dynamic>.from(state.searchState);
      updatedState['startNo'] =
          updatedState['startNo'] + updatedState['recordSize'];

      final updatedAmountCardList = state.amountCardList.map((item) {
        final totalStats = res['results']['totalStats'];
        if (item.name == "totSaleAmt") {
          return AmountCardModel(
            name: item.name,
            label: item.label,
            value: totalStats['totalSaleAmt'] ?? 0,
            icon: item.icon,
            color: item.color,
          );
        } else if (item.name == "totDcAmt") {
          return AmountCardModel(
            name: item.name,
            label: item.label,
            value: totalStats['totalDcAmt'] ?? 0,
            icon: item.icon,
            color: item.color,
          );
        } else if (item.name == "totDcmSaleAmt") {
          return AmountCardModel(
            name: item.name,
            label: item.label,
            value: totalStats['totalDcmSaleAmt'] ?? 0,
            icon: item.icon,
            color: item.color,
          );
        }
        return item;
      }).toList();

      final receiptList = List<Map<String, dynamic>>.from(
        res['results']['receiptList'],
      );
      for (var item in receiptList) {
        item['apprDate'] = item['apprDt'].substring(0, 8);
      }

      final updatedOriginalList = [...state.originalList, ...receiptList];
      final convertData = convertReceiptHistoryItemData(updatedOriginalList);

      state = state.copyWith(
        searchState: updatedState,
        originalList: updatedOriginalList,
        receiptHistoryItemList: convertData,
        amountCardList: updatedAmountCardList,
      );
    }
  }

  List<Map<String, dynamic>> convertReceiptHistoryItemData(List<dynamic> list) {
    Map<String, List<Map<String, dynamic>>> groupedBySaleDe =
        CommonHelpers.grouyByList(list, 'apprDate');
    // 결과 출력
    List<Map<String, dynamic>> resultList = [];
    groupedBySaleDe.forEach((apprDate, sales) {
      Map<String, dynamic> totalData = {'apprDate': apprDate, 'child': sales};

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

/// ReceiptHistoryScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final receiptHistoryScreenModelProvider =
    NotifierProvider.autoDispose<
      ReceiptHistoryScreenModel,
      ReceiptHistoryState
    >(ReceiptHistoryScreenModel.new);
