import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paytap_app/common/models/cm_code.dart';
import 'package:paytap_app/common/services/statistics_service.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';
import 'package:paytap_app/common/widget/cm_search/data/search_config.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 카드사별 매출 화면의 상태 모델
class CardCompanySalesState {
  final Map<String, dynamic> searchState;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isInitialized;
  final List originalList;
  final List<Map<String, dynamic>> dealHistoryItemList;
  final SearchConfig searchConfig;

  CardCompanySalesState({
    required this.searchState,
    this.isLoading = false,
    this.isInitialLoading = false,
    this.isInitialized = false,
    this.originalList = const [],
    this.dealHistoryItemList = const [],
    SearchConfig? searchConfig,
  }) : searchConfig =
           searchConfig ??
           SearchConfig(
             list: [
               SearchConfigItem(
                 label: "기간",
                 type: CmSearchType.rangeDayDate,
                 name: "dateRange",
                 startDateKey: "startDe",
                 endDateKey: "endDe",
               ),
               SearchConfigItem(
                 label: "포스",
                 type: CmSearchType.pos,
                 name: "posNo",
               ),
             ],
           );

  CardCompanySalesState copyWith({
    Map<String, dynamic>? searchState,
    bool? isLoading,
    bool? isInitialLoading,
    bool? isInitialized,
    List? originalList,
    List<Map<String, dynamic>>? dealHistoryItemList,
    SearchConfig? searchConfig,
  }) {
    return CardCompanySalesState(
      searchState: searchState ?? this.searchState,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      originalList: originalList ?? this.originalList,
      dealHistoryItemList: dealHistoryItemList ?? this.dealHistoryItemList,
      searchConfig: searchConfig ?? this.searchConfig,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class CardCompanySalesScreenModel extends Notifier<CardCompanySalesState> {
  final storage = FlutterSecureStorage();
  final ScrollController scrollController = ScrollController();

  @override
  CardCompanySalesState build() {
    // dispose 콜백 등록
    ref.onDispose(() {
      scrollController.dispose();
    });

    return CardCompanySalesState(
      searchState: {
        'startDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
        'endDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
        'posNo': '',
        'startNo': 0,
        'recordSize': 10,
      },
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

  /// 검색 상태 업데이트
  void updateSearchState(Map<String, dynamic> newState) {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState.addAll(newState);
    state = state.copyWith(searchState: updatedState);
  }

  /// 초기 데이터 로딩 함수
  Future<void> initializeData(BuildContext context) async {
    if (state.isInitialized) return;

    setLoading(true);
    try {
      await getDealHistory(context);

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
        await getDealHistory(context);
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
        await resetDealHistoryList();
        await getDealHistory(context);
      } catch (e) {
        print('Error during refresh: $e');
      } finally {
        setInitialLoading(false);
      }
    }
  }

  //데이터 초기화 하는 함수
  Future<void> resetDealHistoryList() async {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['startNo'] = 0;
    updatedState['recordSize'] = 10;

    state = state.copyWith(
      originalList: [],
      dealHistoryItemList: [],
      searchState: updatedState,
    );
  }

  //데이터 조회 하는 함수
  Future<void> getDealHistory(BuildContext context) async {
    Map<String, dynamic> data = {...state.searchState};

    Map<String, dynamic> res = await StatisticsService.getAppSaleCard(data);
    if (res.containsKey('error'))
      return _showErrorDialog(context, res["results"]);
    if (res['results'].length > 0) {
      final updatedState = Map<String, dynamic>.from(state.searchState);
      updatedState['startNo'] =
          updatedState['startNo'] + updatedState['recordSize'];

      final updatedOriginalList = [...state.originalList, ...res['results']];
      final dealHistoryItemList = getConvertItemData(updatedOriginalList);

      state = state.copyWith(
        searchState: updatedState,
        originalList: updatedOriginalList,
        dealHistoryItemList: dealHistoryItemList,
      );
    }
  }

  List<Map<String, dynamic>> getConvertItemData(List<dynamic> list) {
    Map<String, dynamic> query = {...state.searchState};
    List<CmCodeItem> payCorpCodeList = CmCode.getFindCmcodeList('623');
    List<Map<String, dynamic>> resultList = [];
    for (var item in list) {
      final itemMap = Map<String, dynamic>.from(item);
      for (var payCorp in payCorpCodeList) {
        if (itemMap['payCorpCode'] == payCorp.code) {
          itemMap['payCorpNm'] = payCorp.codeNm;
        }
      }
      itemMap['startDe'] = query['startDe'];
      itemMap['endDe'] = query['endDe'];
      resultList.add(itemMap);
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

/// CardCompanySalesScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final cardCompanySalesScreenModelProvider =
    NotifierProvider.autoDispose<
      CardCompanySalesScreenModel,
      CardCompanySalesState
    >(CardCompanySalesScreenModel.new);
