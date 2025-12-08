import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paytap_app/common/services/payment_service.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';
import 'package:paytap_app/common/widget/cm_search/data/search_config.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 일별 매출 상세 화면의 상태 모델
class DailySalesDetailState {
  final Map<String, dynamic> searchState;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isInitialized;
  final List originalList;
  final List<Map<String, dynamic>> dailySalesDetailItemList;
  final SearchConfig searchConfig;
  final List<Map<String, dynamic>> totalSaleList;
  final List<Map<String, dynamic>> totalReturnSaleList;

  DailySalesDetailState({
    required this.searchState,
    this.isLoading = false,
    this.isInitialLoading = false,
    this.isInitialized = false,
    this.originalList = const [],
    this.dailySalesDetailItemList = const [],
    SearchConfig? searchConfig,
    this.totalSaleList = const [],
    this.totalReturnSaleList = const [],
  }) : searchConfig =
           searchConfig ??
           SearchConfig(
             list: [
               SearchConfigItem(
                 label: "날짜일",
                 name: "saleDe",
                 type: CmSearchType.dayDate,
               ),
               SearchConfigItem(
                 label: "포스",
                 name: "posNo",
                 type: CmSearchType.pos,
                 options: [],
               ),
             ],
           );

  DailySalesDetailState copyWith({
    Map<String, dynamic>? searchState,
    bool? isLoading,
    bool? isInitialLoading,
    bool? isInitialized,
    List? originalList,
    List<Map<String, dynamic>>? dailySalesDetailItemList,
    SearchConfig? searchConfig,
    List<Map<String, dynamic>>? totalSaleList,
    List<Map<String, dynamic>>? totalReturnSaleList,
  }) {
    return DailySalesDetailState(
      searchState: searchState ?? this.searchState,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      originalList: originalList ?? this.originalList,
      dailySalesDetailItemList:
          dailySalesDetailItemList ?? this.dailySalesDetailItemList,
      searchConfig: searchConfig ?? this.searchConfig,
      totalSaleList: totalSaleList ?? this.totalSaleList,
      totalReturnSaleList: totalReturnSaleList ?? this.totalReturnSaleList,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class DailySalesDetailScreenModel extends Notifier<DailySalesDetailState> {
  final storage = FlutterSecureStorage();
  final ScrollController scrollController = ScrollController();

  @override
  DailySalesDetailState build() {
    // dispose 콜백 등록
    ref.onDispose(() {
      scrollController.dispose();
    });

    return DailySalesDetailState(
      searchState: {
        "posNo": "",
        "saleDe": DateHelpers.getYYYYMMDDString(DateTime.now()),
        "startNo": 0,
        "recordSize": 10,
      },
      totalSaleList: [
        {
          "title": '총 판매 금액',
          "value": 0,
          "icon": 'assets/icons/i_sale.svg',
          "color": "bk01",
        },
        {
          "title": '총 할인 금액',
          "value": 0,
          "icon": 'assets/icons/i_discount.svg',
          "color": "bk03",
        },
        {
          "title": '실 매출 금액',
          "value": 0,
          "icon": 'assets/icons/i_saleTotal.svg',
          "color": "brand01",
        },
        {
          "title": '총 판매 건수',
          "value": 0,
          "icon": 'assets/icons/i_equal.svg',
          "color": "bk01",
        },
      ],
      totalReturnSaleList: [
        {
          "title": '총 판매 금액',
          "value": 0,
          "icon": 'assets/icons/i_sale.svg',
          "color": "bk01",
        },
        {
          "title": '총 할인 금액',
          "value": 0,
          "icon": 'assets/icons/i_discount.svg',
          "color": "bk03",
        },
        {
          "title": '실 매출 금액',
          "value": 0,
          "icon": 'assets/icons/i_saleTotal.svg',
          "color": "brand01",
        },
        {
          "title": '총 반품 건수',
          "value": 0,
          "icon": 'assets/icons/i_equal.svg',
          "color": "systemRed",
        },
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

  //데이터 초기화 하는 함수
  Future<void> resetDailySalesDetailList() async {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['startNo'] = 0;
    updatedState['recordSize'] = 10;

    final updatedTotalSaleList = state.totalSaleList.map((item) {
      return Map<String, dynamic>.from(item)..['value'] = 0;
    }).toList();

    final updatedTotalReturnSaleList = state.totalReturnSaleList.map((item) {
      return Map<String, dynamic>.from(item)..['value'] = 0;
    }).toList();

    state = state.copyWith(
      originalList: [],
      dailySalesDetailItemList: [],
      searchState: updatedState,
      totalSaleList: updatedTotalSaleList,
      totalReturnSaleList: updatedTotalReturnSaleList,
    );
  }

  /// 초기 데이터 로드
  Future<void> initializeData(BuildContext context) async {
    if (state.isInitialized) return;

    setLoading(true);
    try {
      await getDailySalesDetail(context);

      state = state.copyWith(isInitialized: true);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 추가 데이터 로드
  Future<void> loadMoreData(BuildContext context) async {
    if (!state.isLoading) {
      setLoading(true);
      try {
        await getDailySalesDetail(context);
      } catch (e) {
        print('Error loading more data: $e');
      } finally {
        setLoading(false);
      }
    }
  }

  /// 새로고침
  Future<void> refreshData(BuildContext context) async {
    if (!state.isInitialLoading) {
      setInitialLoading(true);
      try {
        await resetDailySalesDetailList();
        await getDailySalesDetail(context);
      } catch (e) {
        print('Error during reset and reload: $e');
      } finally {
        setInitialLoading(false);
      }
    }
  }

  //데이터 조회 하는 함수
  Future<void> getDailySalesDetail(BuildContext context) async {
    Map<String, dynamic> data = {...state.searchState};

    Map<String, dynamic> res = await PaymentService.getAppSaleTotal(data);
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }
    if (res['results'].length > 0) {
      final updatedTotalSaleList = List<Map<String, dynamic>>.from(
        state.totalSaleList,
      );
      final updatedTotalReturnSaleList = List<Map<String, dynamic>>.from(
        state.totalReturnSaleList,
      );

      for (var item in res['results']['appTodayTotalSales']) {
        if (item['saleYn'] == "Y") {
          final saleAmtItem = updatedTotalSaleList.firstWhere(
            (i) => i['title'] == "총 판매 금액",
          );
          saleAmtItem['value'] = item['saleAmt'];
          final dcAmtItem = updatedTotalSaleList.firstWhere(
            (i) => i['title'] == "총 할인 금액",
          );
          dcAmtItem['value'] = item['dcAmt'];
          final dcmSaleAmtItem = updatedTotalSaleList.firstWhere(
            (i) => i['title'] == "실 매출 금액",
          );
          dcmSaleAmtItem['value'] = item['dcmSaleAmt'];
          final saleCntItem = updatedTotalSaleList.firstWhere(
            (i) => i['title'] == "총 판매 건수",
          );
          saleCntItem['value'] = item['saleCnt'];
        }
        if (item['saleYn'] == "N") {
          final saleAmtItem = updatedTotalReturnSaleList.firstWhere(
            (i) => i['title'] == "총 판매 금액",
          );
          saleAmtItem['value'] = item['saleAmt'];
          final dcAmtItem = updatedTotalReturnSaleList.firstWhere(
            (i) => i['title'] == "총 할인 금액",
          );
          dcAmtItem['value'] = item['dcAmt'];
          final dcmSaleAmtItem = updatedTotalReturnSaleList.firstWhere(
            (i) => i['title'] == "실 매출 금액",
          );
          dcmSaleAmtItem['value'] = item['dcmSaleAmt'];
          final saleCntItem = updatedTotalReturnSaleList.firstWhere(
            (i) => i['title'] == "총 반품 건수",
          );
          saleCntItem['value'] = item['saleCnt'];
        }
      }

      final updatedState = Map<String, dynamic>.from(state.searchState);
      updatedState['startNo'] =
          updatedState['startNo'] + updatedState['recordSize'];

      final updatedOriginalList = [
        ...state.originalList,
        ...res['results']['appTodayTotalReceipts'],
      ];
      final convertData = convertDealHistoryItemData(updatedOriginalList);

      state = state.copyWith(
        searchState: updatedState,
        originalList: updatedOriginalList,
        dailySalesDetailItemList: convertData,
        totalSaleList: updatedTotalSaleList,
        totalReturnSaleList: updatedTotalReturnSaleList,
      );
    }
  }

  List<Map<String, dynamic>> convertDealHistoryItemData(List<dynamic> list) {
    Map<String, List<Map<String, dynamic>>> groupedBySaleDe =
        CommonHelpers.grouyByList(list, 'saleDe');
    // 결과 출력
    List<Map<String, dynamic>> resultList = [];
    groupedBySaleDe.forEach((saleDe, sales) {
      Map<String, dynamic> totalData = {'saleDe': saleDe, 'child': sales};

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

/// DailySalesDetailScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final dailySalesDetailScreenModelProvider =
    NotifierProvider.autoDispose<
      DailySalesDetailScreenModel,
      DailySalesDetailState
    >(DailySalesDetailScreenModel.new);
