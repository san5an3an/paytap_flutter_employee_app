import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paytap_app/common/models/c_option.dart';
import 'package:paytap_app/common/services/payment_service.dart';
import 'package:paytap_app/common/services/pos_service.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/widget/amount_card/data/amount_card_model.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';
import 'package:paytap_app/common/widget/cm_search/data/search_config.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 반품 내역 화면의 상태 모델
class ReturnHistoryState {
  final Map<String, dynamic> searchState;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isInitialized;
  final List originalList;
  final List returnHistoryItemList;
  final SearchConfig searchConfig;
  final List<COption> posList;
  final List<AmountCardModel> amountCardMainList;

  ReturnHistoryState({
    required this.searchState,
    this.isLoading = false,
    this.isInitialLoading = false,
    this.isInitialized = false,
    this.originalList = const [],
    this.returnHistoryItemList = const [],
    SearchConfig? searchConfig,
    this.posList = const [],
    this.amountCardMainList = const [],
  }) : searchConfig =
           searchConfig ??
           SearchConfig(
             list: [
               SearchConfigItem(
                 label: "기간",
                 type: CmSearchType.rangeDayDate,
                 name: "rangeDate",
                 startDateKey: "startDe",
                 endDateKey: "endDe",
               ),
               SearchConfigItem(
                 label: "포스",
                 name: "posNo",
                 type: CmSearchType.pos,
                 options: [],
               ),
             ],
           );

  ReturnHistoryState copyWith({
    Map<String, dynamic>? searchState,
    bool? isLoading,
    bool? isInitialLoading,
    bool? isInitialized,
    List? originalList,
    List? returnHistoryItemList,
    SearchConfig? searchConfig,
    List<COption>? posList,
    List<AmountCardModel>? amountCardMainList,
  }) {
    return ReturnHistoryState(
      searchState: searchState ?? this.searchState,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      originalList: originalList ?? this.originalList,
      returnHistoryItemList:
          returnHistoryItemList ?? this.returnHistoryItemList,
      searchConfig: searchConfig ?? this.searchConfig,
      posList: posList ?? this.posList,
      amountCardMainList: amountCardMainList ?? this.amountCardMainList,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class ReturnHistoryScreenModel extends Notifier<ReturnHistoryState> {
  final storage = FlutterSecureStorage();
  final ScrollController scrollController = ScrollController();

  @override
  ReturnHistoryState build() {
    // dispose 콜백 등록
    ref.onDispose(() {
      scrollController.dispose();
    });

    return ReturnHistoryState(
      searchState: {
        "posNo": "",
        "startDe": DateHelpers.getYYYYMMDDString(DateTime.now()),
        "endDe": DateHelpers.getYYYYMMDDString(DateTime.now()),
        "startNo": 0,
        "recordSize": 10,
      },
      amountCardMainList: [
        AmountCardModel(
          name: 'totalSaleAmt',
          label: '총 매출 금액',
          value: 0,
          icon: 'assets/icons/i_sale.svg',
          color: 'bk01',
        ),
        AmountCardModel(
          name: 'totalRefundAmt',
          label: '총 반품 금액',
          value: 0,
          icon: 'assets/icons/i_equal.svg',
          color: 'systemRed',
        ),
        AmountCardModel(
          name: 'totalActSaleAmt',
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
      await setTopFiltter();
      await getReturnHistory(context);

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
        await getReturnHistory(context);
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
        await resetReturnHistoryList();
        await getReturnHistory(context);
      } catch (e) {
        print('Error during refresh: $e');
      } finally {
        setInitialLoading(false);
      }
    }
  }

  Future<void> setTopFiltter() async {
    await getPosList();
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['posNo'] = '';

    final searchConfig = SearchConfig(
      list: [
        SearchConfigItem(
          label: "기간",
          type: CmSearchType.rangeDayDate,
          name: "rangeDate",
          startDateKey: "startDe",
          endDateKey: "endDe",
        ),
        SearchConfigItem(
          label: "포스",
          name: "posNo",
          type: CmSearchType.pos,
          options: state.posList,
        ),
      ],
    );

    state = state.copyWith(
      searchState: updatedState,
      searchConfig: searchConfig,
    );
  }

  Future<void> getPosList() async {
    String? storeInfo = await storage.read(key: 'storeInfo');
    Map<String, dynamic> storeInfoList = {};
    if (storeInfo != null) {
      storeInfoList = jsonDecode(storeInfo);
    }

    Map<String, dynamic> res = await PosService.getEnvPos({
      "storeUnqcd": storeInfoList['storeInfo']['storeUnqcd'],
    });

    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['posNo'] = res['results'][0]['posNo'];

    final posList = <COption>[COption(title: '전체', value: '')];
    for (var item in res['results']) {
      posList.add(
        COption(
          title:
              '${item['posNo']}${item['posNm'] != "" ? '(${item['posNm']})' : ""}',
          value: item['posNo'],
        ),
      );
    }

    state = state.copyWith(searchState: updatedState, posList: posList);
  }

  //데이터 초기화 하는 함수
  Future<void> resetReturnHistoryList() async {
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
      returnHistoryItemList: [],
      searchState: updatedState,
      amountCardMainList: updatedAmountCardList,
    );
  }

  //데이터 조회 하는 함수
  Future<void> getReturnHistory(BuildContext context) async {
    Map<String, dynamic> data = {...state.searchState};

    Map<String, dynamic> res = await PaymentService.getAppSaleRefund(data);
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }

    if (res['results'].isNotEmpty) {
      final updatedState = Map<String, dynamic>.from(state.searchState);
      updatedState['startNo'] =
          updatedState['startNo'] + updatedState['recordSize'];

      final updatedAmountCardList = state.amountCardMainList.map((item) {
        if (item.name == "totalSaleAmt") {
          return AmountCardModel(
            name: item.name,
            label: item.label,
            value: res['results']['totalSaleAmt'],
            icon: item.icon,
            color: item.color,
          );
        } else if (item.name == "totalRefundAmt") {
          return AmountCardModel(
            name: item.name,
            label: item.label,
            value: res['results']['totalRefundAmt'],
            icon: item.icon,
            color: item.color,
          );
        } else if (item.name == "totalActSaleAmt") {
          return AmountCardModel(
            name: item.name,
            label: item.label,
            value:
                res['results']['totalSaleAmt'] +
                res['results']['totalRefundAmt'],
            icon: item.icon,
            color: item.color,
          );
        }
        return item;
      }).toList();

      final updatedOriginalList = [
        ...state.originalList,
        ...res['results']['refundList'],
      ];

      state = state.copyWith(
        searchState: updatedState,
        originalList: updatedOriginalList,
        returnHistoryItemList: updatedOriginalList,
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

/// ReturnHistoryScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final returnHistoryScreenModelProvider =
    NotifierProvider.autoDispose<ReturnHistoryScreenModel, ReturnHistoryState>(
      ReturnHistoryScreenModel.new,
    );
