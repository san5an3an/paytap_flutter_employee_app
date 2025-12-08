import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/cm_donut_chart/data/cm_donut_chart_data_model.dart';

/// 도넛 차트 위젯
class CmDonutChart extends StatelessWidget {
  final List<CmDonutChartDataModel> chartData;
  final double height;

  const CmDonutChart({super.key, required this.chartData, this.height = 330});

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('데이터가 없습니다.')),
      );
    }

    // 전체 값 계산
    final totalValue = chartData.fold<double>(
      0,
      (sum, data) => sum + data.value,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GlobalColor.bk08,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          // 도넛 차트
          SizedBox(
            height: height,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0, // 섹션 간 간격 제거
                centerSpaceRadius: ((height) / 4), // 중앙 공간을 조금 작게 조정
                startDegreeOffset: -90, // 12시 방향에서 시작
                sections: _createPieSections(totalValue),
              ),
            ),
          ),
          // 범례
          const SizedBox(height: 15),
          _buildLegend(),
        ],
      ),
    );
  }

  /// 파이 섹션 생성
  List<PieChartSectionData> _createPieSections(double totalValue) {
    final chartRadius = (height) / 5.5; // 차트 높이의 60%를 6으로 나누어 반지름으로 사용

    return List.generate(chartData.length, (index) {
      final data = chartData[index];

      return PieChartSectionData(
        color: data.color,
        value: data.value,
        title: '',
        radius: chartRadius,
        titlePositionPercentageOffset: 0.5,
        borderSide: BorderSide.none,
      );
    });
  }

  /// 범례 위젯 생성
  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: chartData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final isLast = index == chartData.length - 1;
          final percentage =
              (data.value /
                  chartData.fold<double>(0, (sum, item) => sum + item.value)) *
              100;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 15.0),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: data.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(data.label, style: GlobalTextStyle.body01),
                ),
                const SizedBox(width: 10),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: GlobalTextStyle.body01M.copyWith(
                    color: GlobalColor.bk03,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
