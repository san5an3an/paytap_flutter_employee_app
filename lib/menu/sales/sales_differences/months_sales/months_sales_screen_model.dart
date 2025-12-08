import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/models/c_option.dart';
import 'package:paytap_app/common/models/cm_code.dart';
import 'package:paytap_app/common/models/pos.dart';
import 'package:paytap_app/common/services/statistics_service.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/widget/cm_bar_vertical_chart/data/cm_bar_vertical_chart_data_model.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';
import 'package:paytap_app/common/widget/cm_search/data/search_config.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 월별 매출 화면의 상태 모델
class MonthsSalesState {
  final Map<String, dynamic> searchState;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isInitialized;
  final List<Map<String, dynamic>> timeSalesItemList;
  final List<COption> posList;
  final List<Map<String, dynamic>> barChartList;
  final List<Map<String, dynamic>> horizonChartList;
  final List<CmBarVerticalChartDataModel> chartData;
  final SearchConfig searchConfig;

  MonthsSalesState({
    required this.searchState,
    this.isLoading = false,
    this.isInitialLoading = false,
    this.isInitialized = false,
    this.timeSalesItemList = const [],
    this.posList = const [],
    this.barChartList = const [],
    this.horizonChartList = const [],
    this.chartData = const [],
    SearchConfig? searchConfig,
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
                 label: "기간",
                 type: CmSearchType.rangeMonthDate,
                 name: "dateRange",
                 startDateKey: "startMth",
                 endDateKey: "endMth",
               ),
             ],
           );

  MonthsSalesState copyWith({
    Map<String, dynamic>? searchState,
    bool? isLoading,
    bool? isInitialLoading,
    bool? isInitialized,
    List<Map<String, dynamic>>? timeSalesItemList,
    List<COption>? posList,
    List<Map<String, dynamic>>? barChartList,
    List<Map<String, dynamic>>? horizonChartList,
    List<CmBarVerticalChartDataModel>? chartData,
    SearchConfig? searchConfig,
  }) {
    return MonthsSalesState(
      searchState: searchState ?? this.searchState,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      timeSalesItemList: timeSalesItemList ?? this.timeSalesItemList,
      posList: posList ?? this.posList,
      barChartList: barChartList ?? this.barChartList,
      horizonChartList: horizonChartList ?? this.horizonChartList,
      chartData: chartData ?? this.chartData,
      searchConfig: searchConfig ?? this.searchConfig,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class MonthsSalesScreenModel extends Notifier<MonthsSalesState> {
  CmBarVerticalChartConfigModel get chartConfig =>
      CmBarVerticalChartConfigModel(
        mainLabel: '선택 당월',
        subLabel: '기간 평균',
        yAxisUnit: '만원',
      );

  // CmSearch용 posName getter
  String get posName {
    final posNo = state.searchState['posNo'];
    if (posNo == null || posNo.toString().isEmpty) {
      return '전체';
    }

    final pos = Pos.posList.firstWhere((pos) => pos.posNo == posNo);
    final cmCodeList = CmCode.getFindCmcodeList("629");
    final deviceTypeNm = cmCodeList
        .firstWhere((type) => type.code == pos.deviceTypeCode)
        .codeNm;
    return "${pos.posNm} ($deviceTypeNm)";
  }

  @override
  MonthsSalesState build() {
    return MonthsSalesState(
      searchState: {
        'posNo': '',
        'startMth': DateHelpers.getYYYYMMString(DateTime.now()),
        'endMth': DateHelpers.getYYYYMMString(DateTime.now()),
        'targetYear': DateHelpers.getYYYYString(DateTime.now()),
      },
    );
  }

  /// 검색 상태 업데이트
  void updateSearchState(Map<String, dynamic> newState) {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState.addAll(newState);
    state = state.copyWith(searchState: updatedState);
  }

  /// NavSlider에서 날짜 변경 시 호출되는 메서드
  Future<void> onChangeQuery(
    BuildContext context,
    Map<String, dynamic> value,
  ) async {
    await getMonthsSales(context, value['targetYear']);
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
      await getInitMonthsSales(context);
      state = state.copyWith(isInitialized: true);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 새로고침 함수
  Future<void> refreshData(BuildContext context) async {
    if (!state.isInitialLoading) {
      setInitialLoading(true);
      try {
        await getInitMonthsSales(context);
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
    updatedState['startMth'] = DateHelpers.getYYYYMMString(DateTime.now());
    updatedState['endMth'] = DateHelpers.getYYYYMMString(DateTime.now());
    updatedState['targetYear'] = DateHelpers.getYYYYString(DateTime.now());

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
          type: CmSearchType.rangeMonthDate,
          name: "dateRange",
          startDateKey: "startMth",
          endDateKey: "endMth",
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

  // 차트 데이터 세팅 함수
  void setChartData(Map<String, dynamic> res) {
    final int targetYear = DateTime.now().year;
    final period = List<Map<String, dynamic>>.from(
      res['results']['period'] ?? [],
    );
    final target = List<Map<String, dynamic>>.from(
      res['results']['target'] ?? [],
    );

    // saleMth를 Map으로 변환 (yyyyMM → value)
    final periodMap = {
      for (var e in period) e['saleMth'].toString(): e['dcmSaleAmt'],
    };
    final targetMap = {
      for (var e in target) e['saleMth'].toString(): e['dcmSaleAmt'],
    };

    // chartData 설정
    final chartData = <CmBarVerticalChartDataModel>[];
    for (int month = 1; month <= 12; month++) {
      final key = '$targetYear${month.toString().padLeft(2, '0')}';
      final mainValue = targetMap[key] ?? 0;
      final subValue = periodMap[key] ?? 0;
      chartData.add(
        CmBarVerticalChartDataModel(
          title: '$month',
          mainValue: mainValue.toDouble(),
          subValue: subValue.toDouble(),
        ),
      );
    }

    // horizonChartList 설정
    final horizonChartList = <Map<String, dynamic>>[];
    for (int month = 1; month <= 12; month++) {
      final key = '$targetYear${month.toString().padLeft(2, '0')}';
      if (targetMap.containsKey(key)) {
        horizonChartList.add({
          'title': '$month월',
          'value': targetMap[key].toInt(),
        });
      }
    }

    state = state.copyWith(
      chartData: chartData,
      horizonChartList: horizonChartList,
    );
  }

  //데이터 조회 하는 함수
  Future<void> getInitMonthsSales(BuildContext context) async {
    Map<String, dynamic> data = {...state.searchState};
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['targetYear'] = DateHelpers.getYYYYString(DateTime.now());

    data['targetYear'] = DateHelpers.getYYYYString(DateTime.now());
    data['startMth'] = data['startMth'];
    data['endMth'] = data['endMth'];

    state = state.copyWith(searchState: updatedState);

    Map<String, dynamic> res = await StatisticsService.getAppGrowthMonth(data);
    if (res.containsKey('error'))
      return _showErrorDialog(context, res["results"]);

    setChartData(res);
  }

  //데이터 조회 하는 함수
  Future<void> getMonthsSales(BuildContext context, targetYear) async {
    Map<String, dynamic> data = {...state.searchState};
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['targetYear'] = targetYear;

    data['targetYear'] = targetYear;
    data['startMth'] = data['startMth'];
    data['endMth'] = data['endMth'];

    state = state.copyWith(searchState: updatedState);

    Map<String, dynamic> res = await StatisticsService.getAppGrowthMonth(data);
    if (res.containsKey('error'))
      return _showErrorDialog(context, res["results"]);

    setChartData(res);
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

/// MonthsSalesScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final monthsSalesScreenModelProvider =
    NotifierProvider.autoDispose<MonthsSalesScreenModel, MonthsSalesState>(
      MonthsSalesScreenModel.new,
    );
