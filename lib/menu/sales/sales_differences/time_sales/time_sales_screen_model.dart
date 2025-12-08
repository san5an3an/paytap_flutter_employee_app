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

/// 시간대별 매출 화면의 상태 모델
class TimeSalesState {
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

  TimeSalesState({
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
                 type: CmSearchType.rangeDayDate,
                 name: "dateRange",
                 startDateKey: "startDe",
                 endDateKey: "endDe",
               ),
             ],
           );

  TimeSalesState copyWith({
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
    return TimeSalesState(
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
class TimeSalesScreenModel extends Notifier<TimeSalesState> {
  CmBarVerticalChartConfigModel get chartConfig =>
      CmBarVerticalChartConfigModel(
        mainLabel: '선택 당일',
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
  TimeSalesState build() {
    return TimeSalesState(
      searchState: {
        'posNo': '',
        'startDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
        'endDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
        'targetDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
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
    await getTimeSales(context, value['targetDe']);
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
      await getInitTimeSales(context);
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
        await getInitTimeSales(context);
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
    updatedState['startDe'] = DateHelpers.getYYYYMMDDString(DateTime.now());
    updatedState['endDe'] = DateHelpers.getYYYYMMDDString(DateTime.now());
    updatedState['targetDe'] = DateHelpers.getYYYYMMDDString(DateTime.now());

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

  // 차트 데이터 세팅 함수
  void setChartData(Map<String, dynamic> res) {
    final period = List<Map<String, dynamic>>.from(
      res['results']['period'] ?? [],
    );
    final target = List<Map<String, dynamic>>.from(
      res['results']['target'] ?? [],
    );

    // 3, 6, 9, ... 24 구간 기본 리스트
    final List<String> defaultSlots = [
      '3',
      '6',
      '9',
      '12',
      '15',
      '18',
      '21',
      '24',
    ];

    // Map으로 변환(빠른 조회용)
    final periodMap = {
      for (var e in period) e['salesTimeSlot'].toString(): e['dcmSaleAmt'],
    };
    final targetMap = {
      for (var e in target) e['salesTimeSlot'].toString(): e['dcmSaleAmt'],
    };

    // chartData 설정
    final chartData = defaultSlots.map((slot) {
      final mainValue = targetMap[slot] ?? 0;
      final subValue = periodMap[slot] ?? 0;
      return CmBarVerticalChartDataModel(
        title: slot,
        mainValue: mainValue.toDouble(),
        subValue: subValue.toDouble(),
      );
    }).toList();

    // barChartList: 기존 로직 유지
    final barChartList = target
        .map(
          (e) => {
            'title':
                '${int.parse(e['salesTimeSlot'].toString())} ~ ${int.parse(e['salesTimeSlot'].toString()) + 2}',
            'value': e['dcmSaleAmt'].toInt() ?? 0,
          },
        )
        .toList();

    // horizonChartList 설정
    final horizonChartList = target
        .map(
          (e) => {
            'title':
                '${int.parse(e['salesTimeSlot'].toString())} ~ ${int.parse(e['salesTimeSlot'].toString()) + 2}',
            'value': e['dcmSaleAmt'].toInt() ?? 0,
          },
        )
        .toList();

    state = state.copyWith(
      chartData: chartData,
      barChartList: barChartList,
      horizonChartList: horizonChartList,
    );
  }

  //데이터 조회 하는 함수
  Future<void> getInitTimeSales(BuildContext context) async {
    Map<String, dynamic> data = {...state.searchState};
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['targetDe'] = data['startDe'];
    data['targetDe'] = data['startDe'];
    data['startDe'] = data['startDe'];
    data['endDe'] = data['endDe'];

    state = state.copyWith(searchState: updatedState);

    Map<String, dynamic> res = await StatisticsService.getAppGrowthTime(data);
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }
    setChartData(res);
  }

  //데이터 조회 하는 함수
  Future<void> getTimeSales(BuildContext context, targetDe) async {
    Map<String, dynamic> data = {...state.searchState};
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['targetDe'] = targetDe;
    data['targetDe'] = targetDe;
    data['startDe'] = data['startDe'];
    data['endDe'] = data['endDe'];

    state = state.copyWith(searchState: updatedState);

    Map<String, dynamic> res = await StatisticsService.getAppGrowthTime(data);
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }
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

/// TimeSalesScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final timeSalesScreenModelProvider =
    NotifierProvider.autoDispose<TimeSalesScreenModel, TimeSalesState>(
      TimeSalesScreenModel.new,
    );
