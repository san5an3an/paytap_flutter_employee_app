import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/widget/cm_bar_vertical_chart/cm_bar_vertical_chart.dart';
import 'package:paytap_app/common/widget/cm_donut_chart/cm_donut_chart.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/cm_segmented_button/cm_segmented_button.dart';
import 'package:paytap_app/common/widget/input/input_v2.dart';

import 'view_models/test_view_model.dart';

/// 테스트 화면
/// ConsumerWidget을 사용하여 Riverpod 상태 관리를 구현
class TestScreen extends ConsumerWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State 참조
    final state = ref.watch(testViewModelProvider);
    final vm = ref.read(testViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('테스트 화면'),
        backgroundColor: Colors.blue,
        foregroundColor: GlobalColor.systemBackGround,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 세그먼트 버튼 추가
              CmSegmentedButton(
                name: 'sales_type',
                value: state.selectedValue,
                options: vm.options,
                onTap: vm.onSegmentedButtonTap,
              ),
              const SizedBox(height: 20),
              Text('현재 선택된 값: ${state.selectedValue}'),
              const SizedBox(height: 20),
              CmSearch(
                searchConfig: state.searchConfig,
                searchState: state.searchState,
                searchSetState: vm.setSearchState,
              ),
              const SizedBox(height: 20),
              // 차트 위젯 추가
              CmBarVerticalChart(
                chartData: state.chartData,
                config: state.chartConfig,
                height: 300,
              ),
              const SizedBox(height: 30),

              CmDonutChart(chartData: state.donutChartData, height: 190),
              const SizedBox(height: 30),
              InputV2(
                name: 'test',
                value: '',
                labelText: '라벨 텍스트',
                leftIcon: Center(
                  child: SvgPicture.asset('assets/icons/key-square 1.svg'),
                ),
                onChange: (name, value) {
                  print('onChange $value $name');
                  if (value.length < 3) {
                    vm.setErrorText('3자 이상 입력해주세요.');
                  } else {
                    vm.setErrorText('');
                  }
                },
                isObscureText: true,
                isClearIcon: true,
                errorText: state.errorText,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
