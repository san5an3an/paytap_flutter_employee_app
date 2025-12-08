import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paytap_app/common/models/pos.dart';
import 'package:paytap_app/common/services/payment_service.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';
import 'package:paytap_app/common/widget/cm_search/data/search_config.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 간편결제 내역 화면의 상태 모델
class EasyApprovalHistoryState {
  final Map<String, dynamic> searchState;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isInitialized;
  final List originalList;
  final List<Map<String, dynamic>> easyApprovalHistoryItemList;
  final SearchConfig searchConfig;

  EasyApprovalHistoryState({
    required this.searchState,
    this.isLoading = false,
    this.isInitialLoading = false,
    this.isInitialized = false,
    this.originalList = const [],
    this.easyApprovalHistoryItemList = const [],
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

  EasyApprovalHistoryState copyWith({
    Map<String, dynamic>? searchState,
    bool? isLoading,
    bool? isInitialLoading,
    bool? isInitialized,
    List? originalList,
    List<Map<String, dynamic>>? easyApprovalHistoryItemList,
    SearchConfig? searchConfig,
  }) {
    return EasyApprovalHistoryState(
      searchState: searchState ?? this.searchState,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      originalList: originalList ?? this.originalList,
      easyApprovalHistoryItemList:
          easyApprovalHistoryItemList ?? this.easyApprovalHistoryItemList,
      searchConfig: searchConfig ?? this.searchConfig,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class EasyApprovalHistoryScreenModel
    extends Notifier<EasyApprovalHistoryState> {
  final storage = FlutterSecureStorage();
  final ScrollController scrollController = ScrollController();

  // 선택된 POS 이름
  String get posName {
    final posNo = state.searchState['posNo'] ?? '';
    if (posNo.isEmpty) return '전체';

    // POS 목록에서 해당 POS 이름 찾기
    final posList = Pos.posList;
    final selectedPos = posList.firstWhere(
      (pos) => pos.posNo == posNo,
      orElse: () => PosItem(
        posNo: '',
        posNm: '전체',
        confrmAt: '',
        mainPosEnvCode: '',
        deviceTypeCode: '',
      ),
    );

    return selectedPos.posNm;
  }

  @override
  EasyApprovalHistoryState build() {
    // dispose 콜백 등록
    ref.onDispose(() {
      scrollController.dispose();
    });

    return EasyApprovalHistoryState(
      searchState: {
        'startDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
        'endDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
        'posNo': '',
        'startNo': 0,
        'recordSize': 10,
      },
    );
  }

  /// 초기화 메서드
  Future<void> initialize(BuildContext context) async {
    if (!state.isInitialized) {
      await Pos.initialize();
      state = state.copyWith(isInitialized: true);
    }
  }

  /// 데이터 초기화 및 첫 로드
  Future<void> initializeData(BuildContext context) async {
    await initialize(context);
    await getEasyApprovalHistory(context);
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
  void updateSearchState(Map<String, dynamic> newState, BuildContext context) {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState.addAll(newState);
    state = state.copyWith(searchState: updatedState);
    getEasyApprovalHistory(context);
  }

  /// 데이터 초기화
  Future<void> resetEasyApprovalHistoryList() async {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['startNo'] = 0;

    state = state.copyWith(
      originalList: [],
      easyApprovalHistoryItemList: [],
      searchState: updatedState,
    );
  }

  /// 데이터 조회
  Future<void> getEasyApprovalHistory(BuildContext context) async {
    Map<String, dynamic> data = {...state.searchState};
    data['startNo'] = state.searchState['startNo'];
    data['recordSize'] = state.searchState['recordSize'];

    Map<String, dynamic> res = await PaymentService.getAppSaleEasyPay(data);

    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }

    if (res['results'].length > 0) {
      final updatedState = Map<String, dynamic>.from(state.searchState);
      updatedState['startNo'] =
          updatedState['startNo'] + updatedState['recordSize'];

      final updatedOriginalList = [...state.originalList, ...res['results']];
      final convertData = convertEasyApprovalHistoryItemData(
        updatedOriginalList,
      );

      state = state.copyWith(
        searchState: updatedState,
        originalList: updatedOriginalList,
        easyApprovalHistoryItemList: convertData,
      );
    }
  }

  /// 데이터 새로고침
  Future<void> refreshData(BuildContext context) async {
    setInitialLoading(true);
    try {
      await resetEasyApprovalHistoryList();
      await getEasyApprovalHistory(context);
    } finally {
      setInitialLoading(false);
    }
  }

  List<Map<String, dynamic>> convertEasyApprovalHistoryItemData(
    List<dynamic> list,
  ) {
    Map<String, List<Map<String, dynamic>>> groupedBySaleDe = {};

    // 날짜별로 그룹화
    for (var item in list) {
      String saleDe = item['saleDe'] ?? '';
      if (!groupedBySaleDe.containsKey(saleDe)) {
        groupedBySaleDe[saleDe] = [];
      }
      groupedBySaleDe[saleDe]!.add(Map<String, dynamic>.from(item));
    }

    // 결과 리스트 생성
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

/// Provider 정의
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final easyApprovalHistoryScreenModelProvider =
    NotifierProvider.autoDispose<
      EasyApprovalHistoryScreenModel,
      EasyApprovalHistoryState
    >(EasyApprovalHistoryScreenModel.new);
