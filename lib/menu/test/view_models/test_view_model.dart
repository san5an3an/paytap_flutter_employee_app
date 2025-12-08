import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/widget/cm_bar_vertical_chart/data/cm_bar_vertical_chart_data_model.dart';
import 'package:paytap_app/common/widget/cm_donut_chart/data/cm_donut_chart_data_model.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';
import 'package:paytap_app/common/widget/cm_search/data/search_config.dart';
import 'package:paytap_app/common/widget/cm_segmented_button/data/segmented_button_data.dart';

/// 테스트 화면의 상태 모델
class TestState {
  final String selectedValue;
  final String errorText;
  final Map<String, dynamic> searchState;
  final SearchConfig searchConfig;
  final List<CmBarVerticalChartDataModel> chartData;
  final CmBarVerticalChartConfigModel chartConfig;
  final List<CmDonutChartDataModel> donutChartData;

  TestState({
    this.selectedValue = 'sales',
    this.errorText = 'default',
    Map<String, dynamic>? searchState,
    SearchConfig? searchConfig,
    this.chartData = const [],
    CmBarVerticalChartConfigModel? chartConfig,
    this.donutChartData = const [],
  }) : searchState =
           searchState ??
           const {
             "posNo": "",
             "approvalType": "",
             "date": "20250715",
             "monthDate": "202507",
             "startDate": "20250715",
             "endDate": "20250715",
             "startMonth": "202507",
             "endMonth": "202507",
           },
       searchConfig =
           searchConfig ??
           SearchConfig(
             list: [
               SearchConfigItem(
                 label: "포스",
                 name: "posNo",
                 type: CmSearchType.pos,
                 options: [],
               ),
               SearchConfigItem(
                 label: "정산 구분",
                 name: "approvalType",
                 type: CmSearchType.approvalType,
                 options: [],
               ),
               SearchConfigItem(
                 label: "날짜일",
                 name: "date",
                 type: CmSearchType.dayDate,
               ),
               SearchConfigItem(
                 label: "날짜범위일",
                 startDateKey: "startDate",
                 endDateKey: "endDate",
                 type: CmSearchType.rangeDayDate,
               ),
               SearchConfigItem(
                 label: "날짜월",
                 name: "monthDate",
                 type: CmSearchType.monthDate,
               ),
               SearchConfigItem(
                 label: "날짜범위월",
                 startDateKey: "startMonth",
                 endDateKey: "endMonth",
                 type: CmSearchType.rangeMonthDate,
               ),
             ],
           ),
       chartConfig =
           chartConfig ??
           CmBarVerticalChartConfigModel(
             mainLabel: '선택당일',
             subLabel: '기간평균',
             yAxisUnit: '만원',
           );

  TestState copyWith({
    String? selectedValue,
    String? errorText,
    Map<String, dynamic>? searchState,
    SearchConfig? searchConfig,
    List<CmBarVerticalChartDataModel>? chartData,
    CmBarVerticalChartConfigModel? chartConfig,
    List<CmDonutChartDataModel>? donutChartData,
  }) {
    return TestState(
      selectedValue: selectedValue ?? this.selectedValue,
      errorText: errorText ?? this.errorText,
      searchState: searchState ?? this.searchState,
      searchConfig: searchConfig ?? this.searchConfig,
      chartData: chartData ?? this.chartData,
      chartConfig: chartConfig ?? this.chartConfig,
      donutChartData: donutChartData ?? this.donutChartData,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class TestViewModel extends Notifier<TestState> {
  // 세그먼트 버튼 옵션 (상수)
  final List<SegmentedButtonOption> options = [
    const SegmentedButtonOption(title: '매출', value: 'sales'),
    const SegmentedButtonOption(title: '상품', value: 'product'),
    const SegmentedButtonOption(title: '테스트', value: 'test'),
  ];

  @override
  TestState build() {
    return TestState(
      chartData: [
        CmBarVerticalChartDataModel(
          title: '3',
          mainValue: 200000,
          subValue: 270000,
        ),
        CmBarVerticalChartDataModel(
          title: '6',
          mainValue: 7900000,
          subValue: 400000,
        ),
        CmBarVerticalChartDataModel(
          title: '9',
          mainValue: 580000,
          subValue: 120000,
        ),
        CmBarVerticalChartDataModel(
          title: '12',
          mainValue: 28000,
          subValue: 40000,
        ),
        CmBarVerticalChartDataModel(
          title: '15',
          mainValue: 950000,
          subValue: 700000,
        ),
        CmBarVerticalChartDataModel(title: '18', mainValue: 610, subValue: 390),
        CmBarVerticalChartDataModel(title: '21', mainValue: 60, subValue: 10),
        CmBarVerticalChartDataModel(title: '24', mainValue: 540, subValue: 320),
      ],
      donutChartData: [
        CmDonutChartDataModel(
          label: '크렌베리 치즈 케이크',
          value: 45.0,
          color: GlobalColor.brand01, // 파란색
        ),
        CmDonutChartDataModel(
          label: '초콜릿 케이크',
          value: 25.0,
          color: GlobalColor.brand03, // 회색
        ),
        CmDonutChartDataModel(
          label: '티라미수',
          value: 15.0,
          color: GlobalColor.systemGreen, // 진한 파란색
        ),
        CmDonutChartDataModel(
          label: '마카롱',
          value: 10.0,
          color: GlobalColor.brand04, // 티얼
        ),
        CmDonutChartDataModel(
          label: '티케이크',
          value: 5.0,
          color: GlobalColor.bk03, // 연한 파란색
        ),
      ],
    );
  }

  void setErrorText(String errorText) {
    state = state.copyWith(errorText: errorText);
  }

  /// 세그먼트 버튼 탭 메서드
  void onSegmentedButtonTap(String name, String value) {
    state = state.copyWith(selectedValue: value);
  }

  /// 차트 데이터 업데이트 함수
  void updateChartData(List<CmBarVerticalChartDataModel> newData) {
    state = state.copyWith(chartData: newData);
  }

  /// 차트 설정 업데이트 함수
  void updateChartConfig(CmBarVerticalChartConfigModel newConfig) {
    state = state.copyWith(chartConfig: newConfig);
  }

  /// 도넛 차트 데이터 업데이트 함수
  void updateDonutChartData(List<CmDonutChartDataModel> newData) {
    state = state.copyWith(donutChartData: newData);
  }

  void setSearchState(Map<String, dynamic> newState) {
    state = state.copyWith(searchState: newState);
    print(newState);
  }
}

/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final testViewModelProvider =
    NotifierProvider.autoDispose<TestViewModel, TestState>(TestViewModel.new);
