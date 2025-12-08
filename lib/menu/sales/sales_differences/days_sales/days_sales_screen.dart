import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/cm_bar_horizon_chart/cm_bar_horizon_chart.dart';
import 'package:paytap_app/common/widget/cm_bar_vertical_chart/cm_bar_vertical_chart.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/nav_slider/nav_slider.dart';
import 'package:paytap_app/menu/sales/sales_differences/days_sales/days_sales_screen_model.dart';

class DaysSalesScreen extends ConsumerStatefulWidget {
  const DaysSalesScreen({super.key});

  @override
  ConsumerState<DaysSalesScreen> createState() => _DaysSalesScreenState();
}

class _DaysSalesScreenState extends ConsumerState<DaysSalesScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화 (한 번만 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(daysSalesScreenModelProvider.notifier);
      final state = ref.read(daysSalesScreenModelProvider);
      if (!state.isInitialized && !state.isLoading) {
        vm.initializeData(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(daysSalesScreenModelProvider);
    final vm = ref.read(daysSalesScreenModelProvider.notifier);

    return Layout(
      title: '요일별 매출 변화',
      isDisplayBottomNavigationBar: false,
      children: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CmSearch(
                searchConfig: state.searchConfig,
                searchState: state.searchState,
                searchSetState: (newState) {
                  vm.updateSearchState(newState);
                  vm.refreshData(context);
                },
              ),
              const SizedBox(height: 10),
              CmBarVerticalChart(
                chartData: state.chartData,
                config: vm.chartConfig,
                height: 300,
              ),
              const SizedBox(height: 20),
              NavSlider(
                type: 'week',
                startDeName: 'targetStartDe',
                startDe: state.searchState['targetStartDe'],
                endDeName: 'targetEndDe',
                endDe: state.searchState['targetEndDe'],
                onChange: (value) => vm.onChangeQuery(context, value),
              ),
              const SizedBox(height: 10),
              Text(
                '*시간별 매출 동향의 데이터는 영업일이 아닌 시간을 기준으로 하기 때문에 합계에 차이가 발생할 수 있습니다.',
                style: GlobalTextStyle.small01.copyWith(
                  color: GlobalColor.bk03,
                ),
              ),
              const SizedBox(height: 20),
              if (state.isInitialLoading)
                const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!state.isInitialLoading)
                CmBarHorizonChart(chartList: state.horizonChartList),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
