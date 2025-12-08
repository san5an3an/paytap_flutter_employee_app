import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paytap_app/common/models/c_option.dart';
import 'package:paytap_app/common/models/pos.dart';
import 'package:paytap_app/common/services/payment_service.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/widget/amount_card/data/amount_card_model.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';
import 'package:paytap_app/common/widget/cm_search/data/search_config.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 주문 취소 내역 화면의 상태 모델
class CancelHistState {
  final Map<String, dynamic> searchState;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isInitialized;
  final List<Map<String, dynamic>> cancelHistItemList;
  final SearchConfig searchConfig;
  final List<COption> posList;
  final List<AmountCardModel> amountCardList;

  CancelHistState({
    required this.searchState,
    this.isLoading = false,
    this.isInitialLoading = false,
    this.isInitialized = false,
    this.cancelHistItemList = const [],
    SearchConfig? searchConfig,
    this.posList = const [],
    this.amountCardList = const [],
  }) : searchConfig = searchConfig ?? SearchConfig(list: []);

  CancelHistState copyWith({
    Map<String, dynamic>? searchState,
    bool? isLoading,
    bool? isInitialLoading,
    bool? isInitialized,
    List<Map<String, dynamic>>? cancelHistItemList,
    SearchConfig? searchConfig,
    List<COption>? posList,
    List<AmountCardModel>? amountCardList,
  }) {
    return CancelHistState(
      searchState: searchState ?? this.searchState,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      cancelHistItemList: cancelHistItemList ?? this.cancelHistItemList,
      searchConfig: searchConfig ?? this.searchConfig,
      posList: posList ?? this.posList,
      amountCardList: amountCardList ?? this.amountCardList,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class CancelHistScreenModel extends Notifier<CancelHistState> {
  final storage = FlutterSecureStorage();
  final ScrollController scrollController = ScrollController();

  @override
  CancelHistState build() {
    // dispose 콜백 등록
    ref.onDispose(() {
      scrollController.dispose();
    });

    return CancelHistState(
      searchState: {
        'startDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
        'endDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
        'posNo': '',
        'startNo': 0,
        'recordSize': 10,
      },
      amountCardList: [
        AmountCardModel(
          name: 'totalSaleAmt',
          label: '주문 취소 건수',
          value: 0,
          icon: 'assets/icons/i_productCancel.svg',
          color: 'bk01',
        ),
      ],
    );
  }

  /// 현재 주문 취소 내역 Model 가져오기
  /// MVVM 패턴 - View를 통한 Model 접근
  CancelHistState get currentModel => state;

  /// 검색 상태 업데이트
  void updateSearchState(Map<String, dynamic> newState) {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState.addAll(newState);
    state = state.copyWith(searchState: updatedState);
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
      await getCancelHist(context);

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
        await getCancelHist(context);
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
        await resetCancelHistList();
        await getCancelHist(context);
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
          label: "포스",
          type: CmSearchType.pos,
          name: "posNo",
          options: state.posList,
        ),
        SearchConfigItem(
          label: "기간",
          type: CmSearchType.rangeDayDate,
          name: "dateRange",
          startDateKey: "startDe",
          endDateKey: "endDe",
        ),
      ],
    );

    state = state.copyWith(
      searchState: updatedState,
      searchConfig: searchConfig,
    );
  }

  Future<void> getPosList() async {
    final posList = <COption>[COption(title: '전체', value: '')];
    for (var item in Pos.posList) {
      posList.add(
        COption(
          title: '${item.posNo}${item.posNm != "" ? '(${item.posNm})' : ""}',
          value: item.posNo,
        ),
      );
    }
    state = state.copyWith(posList: posList);
  }

  //데이터 초기화 하는 함수
  Future<void> resetCancelHistList() async {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['startNo'] = 0;
    state = state.copyWith(cancelHistItemList: [], searchState: updatedState);
  }

  //데이터 조회 하는 함수
  Future<void> getCancelHist(BuildContext context) async {
    Map<String, dynamic> data = {...state.searchState};

    Map<String, dynamic> res = await PaymentService.getAppSaleOrderCancel(data);
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }

    // API 응답 데이터 처리
    List<dynamic> results = res['results'] ?? [];

    // orderDt의 년월일을 기준으로 그룹화
    Map<String, List<dynamic>> groupedData = {};

    for (var item in results) {
      String orderDt = item['orderDt'] ?? '';
      if (orderDt.length >= 8) {
        // orderDt에서 년월일 추출 (YYYYMMDD 형식)
        String saleDe = orderDt.substring(0, 8);

        if (!groupedData.containsKey(saleDe)) {
          groupedData[saleDe] = [];
        }
        groupedData[saleDe]!.add(item);
      }
    }

    // 기존 데이터와 새로운 데이터를 병합
    final updatedList = List<Map<String, dynamic>>.from(
      state.cancelHistItemList,
    );
    groupedData.forEach((saleDe, childItems) {
      // 기존 리스트에서 같은 saleDe가 있는지 확인
      int existingIndex = updatedList.indexWhere(
        (item) => item['saleDe'] == saleDe,
      );

      if (existingIndex != -1) {
        // 기존 항목이 있으면 child에 추가
        updatedList[existingIndex]['child'].addAll(childItems);
      } else {
        // 기존 항목이 없으면 새로 추가
        updatedList.add({'saleDe': saleDe, 'child': childItems});
      }
    });

    // 날짜순으로 정렬 (과거 날짜가 먼저)
    updatedList.sort((a, b) => a['saleDe'].compareTo(b['saleDe']));
    print(updatedList);

    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['startNo'] =
        updatedState['startNo'] + updatedState['recordSize'];

    state = state.copyWith(
      cancelHistItemList: updatedList,
      searchState: updatedState,
    );
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

/// CancelHistScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
/// Notifier + NotifierProvider.autoDispose로 auto-dispose 자동 적용
final cancelHistScreenModelProvider =
    NotifierProvider.autoDispose<CancelHistScreenModel, CancelHistState>(
      CancelHistScreenModel.new,
    );
