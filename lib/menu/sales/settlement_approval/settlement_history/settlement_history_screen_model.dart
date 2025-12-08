import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/models/c_option.dart';
import 'package:paytap_app/common/models/device_storage.dart';
import 'package:paytap_app/common/services/common_service.dart';
import 'package:paytap_app/common/services/payment_service.dart';
import 'package:paytap_app/common/services/pos_service.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/widget/amount_title/amount_title.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';
import 'package:paytap_app/common/widget/cm_search/data/search_config.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:paytap_app/menu/sales/settlement_approval/settlement_history/widgets/amount_trace.dart';

/// 정산 내역 화면의 상태 모델
class SettlementHistoryState {
  final Map<String, dynamic> searchState;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isInitialized;
  final List originalList;
  final List commonCodeList;
  final bool isMiddleSettlement;
  final List<COption> posList;
  final List<Map<String, dynamic>> historyList;
  final SearchConfig searchConfig;
  final Map<String, dynamic> storeInfoList;

  SettlementHistoryState({
    required this.searchState,
    this.isLoading = false,
    this.isInitialLoading = false,
    this.isInitialized = false,
    this.originalList = const [],
    this.commonCodeList = const [],
    this.isMiddleSettlement = false,
    this.posList = const [],
    this.historyList = const [],
    SearchConfig? searchConfig,
    this.storeInfoList = const {},
  }) : searchConfig =
           searchConfig ??
           SearchConfig(
             list: [
               SearchConfigItem(
                 label: "포스",
                 type: CmSearchType.pos,
                 name: "posNo",
                 options: [],
               ),
               SearchConfigItem(
                 label: "시작일",
                 type: CmSearchType.rangeDayDate,
                 name: "startDe",
                 startDateKey: "startDe",
                 endDateKey: "endDe",
               ),
             ],
           );

  SettlementHistoryState copyWith({
    Map<String, dynamic>? searchState,
    bool? isLoading,
    bool? isInitialLoading,
    bool? isInitialized,
    List? originalList,
    List? commonCodeList,
    bool? isMiddleSettlement,
    List<COption>? posList,
    List<Map<String, dynamic>>? historyList,
    SearchConfig? searchConfig,
    Map<String, dynamic>? storeInfoList,
  }) {
    return SettlementHistoryState(
      searchState: searchState ?? this.searchState,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      originalList: originalList ?? this.originalList,
      commonCodeList: commonCodeList ?? this.commonCodeList,
      isMiddleSettlement: isMiddleSettlement ?? this.isMiddleSettlement,
      posList: posList ?? this.posList,
      historyList: historyList ?? this.historyList,
      searchConfig: searchConfig ?? this.searchConfig,
      storeInfoList: storeInfoList ?? this.storeInfoList,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class SettlementHistoryScreenModel extends Notifier<SettlementHistoryState> {
  final ScrollController scrollController = ScrollController();

  @override
  SettlementHistoryState build() {
    // dispose 콜백 등록
    ref.onDispose(() {
      scrollController.dispose();
    });
    return SettlementHistoryState(
      searchState: {
        'startDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
        'endDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
        'posNo': '',
        'startNo': 0,
        'recordSize': 10,
      },
    );
  }

  /// 검색 상태 업데이트
  void updateSearchState(Map<String, dynamic> newState, BuildContext context) {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState.addAll(newState);
    state = state.copyWith(searchState: updatedState);
    getHistoryData(context);
  }

  /// 정산 내역 화면 초기화 메서드
  Future<void> initializeSettlementHistory(BuildContext context) async {
    if (!state.isInitialized) {
      state = state.copyWith(isInitialized: true);
      await getInitHistory(context);
    }
  }

  /// 초기 데이터 로드
  Future<void> getInitHistory(BuildContext context) async {
    state = state.copyWith(isLoading: true);

    try {
      await getCommonCode(context);
      await setTopFiltter();
      await getHistoryData(context);
    } catch (e) {
      print('Error loading more data: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 추가 데이터 로드
  Future<void> getHistory(BuildContext context) async {
    state = state.copyWith(isLoading: true);

    try {
      await getHistoryData(context);
    } catch (e) {
      print('Error loading more data: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 새로고침 처리
  Future<void> setRefresh(BuildContext context) async {
    if (!state.isInitialLoading) {
      state = state.copyWith(isInitialLoading: true);

      try {
        await resetHistoryList();
        await getHistory(context);
      } catch (e) {
        print('Error during reset and reload: $e');
      } finally {
        state = state.copyWith(isInitialLoading: false);
      }
    }
  }

  /// 정산 내역 아이템 위젯 생성
  Widget getHistoryItem(Map<String, dynamic> item) {
    List<dynamic> data = item['child'];

    return Column(
      children: [
        AmountTitle(saleDe: item['saleDe']),
        const SizedBox(height: 20),
        ...data.map((i) => AmountTrace(list: i['child'])),
      ],
    );
  }

  Future<void> setTopFiltter() async {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['posNo'] = '';

    state = state.copyWith(searchState: updatedState);
  }

  Future<void> getCommonCode(context) async {
    final res = await CommonService.getCommonCodePublic({});
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }
    Map<String, dynamic>? storeInfo = await DeviceStorage.read('storeInfo');

    final envRes = await PosService.getEnvTabStore({
      "storeUnqcd": storeInfo?["storeUnqcd"] ?? "",
      "tabCode": "6090001",
      "posNo": "00",
    });
    if (envRes.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }

    final isMiddleSettlement =
        envRes['results'].firstWhere(
              (item) => item['envCode'] == "0048",
            )['useYn'] ==
            "Y"
        ? true
        : false;

    state = state.copyWith(
      commonCodeList: res['results'],
      isMiddleSettlement: isMiddleSettlement,
      storeInfoList: storeInfo ?? {},
    );
  }

  //데이터 초기화 하는 함수
  Future<void> resetHistoryList() async {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['startNo'] = 0;

    state = state.copyWith(
      historyList: [],
      originalList: [],
      searchState: updatedState,
    );
  }

  //데이터 조회 하는 함수
  Future<void> getHistoryData(context) async {
    Map<String, dynamic> data = {...state.searchState};

    Map<String, dynamic> res = await PaymentService.getAppSaleAccount(data);
    if (res.containsKey('error'))
      return _showErrorDialog(context, res["results"]);

    if (res['results'].length > 0) {
      final updatedState = Map<String, dynamic>.from(state.searchState);
      updatedState['startNo'] =
          updatedState['startNo'] + updatedState['recordSize'];

      final updatedOriginalList = [...state.originalList, ...res['results']];
      final convertData = convertHistoryItemData(updatedOriginalList);

      state = state.copyWith(
        searchState: updatedState,
        originalList: updatedOriginalList,
        historyList: convertData,
      );
    }
  }

  List<Map<String, dynamic>> convertHistoryItemData(List<dynamic> list) {
    // 1. 날짜별로 그룹화
    Map<String, List<Map<String, dynamic>>> groupedBySaleDe =
        CommonHelpers.grouyByList(list, 'saleDe');

    List<Map<String, dynamic>> resultList = [];

    // 2. 각 날짜별로 처리
    groupedBySaleDe.forEach((saleDe, sales) {
      Map<String, dynamic> totalData = {'saleDe': saleDe, 'child': []};

      // 3. 포스별로 그룹화
      Map<String, List<Map<String, dynamic>>> groupedByPosNo =
          CommonHelpers.grouyByList(sales, 'posNo');

      // 4. 각 포스별로 처리
      groupedByPosNo.forEach((posNo, groupItem) {
        Map<String, dynamic> resultItem = _createPosResultItem(
          posNo,
          groupItem,
        );
        _processPosItems(resultItem, groupItem);
        _calculatePosTotals(resultItem);

        Map<String, dynamic> groupData = {'posNo': posNo, 'child': resultItem};

        totalData['child'].add(groupData);
      });

      resultList.add(totalData);
    });

    return resultList;
  }

  /// 포스별 결과 아이템 생성
  Map<String, dynamic> _createPosResultItem(
    String posNo,
    List<Map<String, dynamic>> groupItem,
  ) {
    // 디바이스 타입 코드명 조회
    Map<String, dynamic> foundItem = state.commonCodeList.firstWhere(
      (item) => item["code"] == groupItem[0]['deviceTypeCode'],
      orElse: () => {"codeNm": ""},
    );
    String codeName = foundItem["codeNm"] ?? "";

    return {
      'title': '$posNo ($codeName)',
      'date': '',
      'saleAmt': 0,
      'dcAmt': 0,
      'dcmSaleAmt': 0,
      'child': [],
    };
  }

  /// 포스별 아이템 처리
  void _processPosItems(
    Map<String, dynamic> resultItem,
    List<Map<String, dynamic>> groupItem,
  ) {
    String startDe = '';
    String endDe = '';

    for (var item in groupItem) {
      switch (item['closeFlag']) {
        case "1": // 개점
          resultItem['child'].add(_createOpenItem(item));
          startDe = getformatDate(item['openDt']);
          break;
        case "2": // 정산
          resultItem['child'].add(_createSettlementItem(item));
          break;
        case "3": // 일마감
          resultItem['child'].add(_createCloseItem(item));
          endDe = ' - ${getformatDate(item['closeDt'])}';
          break;
        case "4": // 마감 정산 (해당 차수 마감 삭제)
          _removeCloseItem(resultItem, item['regiSeq']);
          endDe = "";
          break;
      }
    }

    resultItem['date'] = startDe + endDe;
  }

  /// 개점 아이템 생성
  Map<String, dynamic> _createOpenItem(Map<String, dynamic> item) {
    return {
      'title': '개점',
      'color': 'systemGreen',
      'icon': 'assets/icons/i_open.svg',
      'child': [
        {'title': '준비금', 'value': item['posReadyAmt']},
      ],
      "saleAmt": item['saleAmt'],
      "dcAmt": item['dcAmt'],
      "dcmSaleAmt": item['dcmSaleAmt'],
      "regiSeq": item['regiSeq'],
      "closeFlag": item['closeFlag'],
    };
  }

  /// 정산 아이템 생성
  Map<String, dynamic> _createSettlementItem(Map<String, dynamic> item) {
    return {
      'title': '${item['regiSeq']}차정산',
      'color': 'systemOrange',
      'icon': 'assets/icons/i_adjustment.svg',
      'child': [
        {'title': '준비금', 'value': item['posReadyAmt']},
        {'title': '현금매출', 'value': item['cashAmt']},
        {'title': '현금시재', 'value': item['remCashAmt']},
        {'title': '과부족', 'value': item['lossCashAmt']},
      ],
      "saleAmt": item['saleAmt'],
      "dcAmt": item['dcAmt'],
      "dcmSaleAmt": item['dcmSaleAmt'],
      "regiSeq": item['regiSeq'],
      "closeFlag": item['closeFlag'],
    };
  }

  /// 일마감 아이템 생성
  Map<String, dynamic> _createCloseItem(Map<String, dynamic> item) {
    return {
      'title': '일마감',
      'color': 'systemRed',
      'icon': 'assets/icons/i_close.svg',
      'child': [
        {'title': '준비금', 'value': item['posReadyAmt']},
        {'title': '현금매출', 'value': item['cashAmt']},
        {'title': '현금시재', 'value': item['remCashAmt']},
        {'title': '과부족', 'value': item['lossCashAmt']},
      ],
      "saleAmt": item['saleAmt'],
      "dcAmt": item['dcAmt'],
      "dcmSaleAmt": item['dcmSaleAmt'],
      "regiSeq": item['regiSeq'],
      "closeFlag": item['closeFlag'],
    };
  }

  /// 마감 정산 시 해당 차수 마감 삭제
  void _removeCloseItem(Map<String, dynamic> resultItem, String regiSeq) {
    resultItem['child'].removeWhere(
      (el) => el['regiSeq'] == regiSeq && el['closeFlag'] == "3",
    );
  }

  /// 포스별 합계 계산
  void _calculatePosTotals(Map<String, dynamic> resultItem) {
    for (var item in resultItem['child']) {
      resultItem['saleAmt'] += item['saleAmt'];
      resultItem['dcAmt'] += item['dcAmt'];
      resultItem['dcmSaleAmt'] += item['dcmSaleAmt'];

      // 일마감인 경우 해당 값으로 덮어쓰기
      if (item['closeFlag'] == "3") {
        resultItem['saleAmt'] = item['saleAmt'];
        resultItem['dcAmt'] = item['dcAmt'];
        resultItem['dcmSaleAmt'] = item['dcmSaleAmt'];
      }
    }
  }

  String getformatDate(String date) {
    String month = date.substring(4, 6); // 월
    String day = date.substring(6, 8); // 일
    int hour24 = int.parse(date.substring(8, 10)); // 24시간제 시간
    String minute = date.substring(10, 12); // 분

    // 오전/오후 구분 및 12시간제로 변환
    String period = hour24 >= 12 ? "오후" : "오전";
    int hour12 = hour24 > 12 ? hour24 - 12 : (hour24 == 0 ? 12 : hour24);

    // 최종 문자열 생성
    String formattedDate =
        "$month/$day $period ${hour12.toString().padLeft(2, '0')}:$minute";

    return formattedDate;
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
final settlementHistoryScreenModelProvider =
    NotifierProvider.autoDispose<
      SettlementHistoryScreenModel,
      SettlementHistoryState
    >(SettlementHistoryScreenModel.new);
