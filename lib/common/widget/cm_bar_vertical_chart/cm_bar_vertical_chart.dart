import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/cm_bar_vertical_chart/data/cm_bar_vertical_chart_data_model.dart';

/// 막대 차트 위젯
class CmBarVerticalChart extends StatelessWidget {
  final List<CmBarVerticalChartDataModel> chartData;
  final CmBarVerticalChartConfigModel config;
  final double? height;

  const CmBarVerticalChart({
    super.key,
    required this.chartData,
    required this.config,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('데이터가 없습니다.')),
      );
    }

    // 최대값과 최소값 계산
    final maxValue = _calculateMaxValue();
    final minValue = _calculateMinValue();
    final maxY = _roundToMoneyUnit(maxValue);
    final unitLabel = _getMoneyUnitLabel(maxValue);

    return Column(
      children: [
        // Y축 단위 라벨
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 50, // leftTitles의 reservedSize와 동일하게 설정
              child: Text(
                '($unitLabel)',
                style: GlobalTextStyle.small02.copyWith(
                  color: GlobalColor.bk02,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              minY: minValue < 0 ? -maxY : 0, // 음수가 있을 때만 음수 범위 설정
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < chartData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            chartData[value.toInt()].title,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    interval: maxY / 4, // 기본 간격
                    getTitlesWidget: (value, meta) {
                      // 음수가 없으면 0부터 시작
                      if (minValue >= 0 && value < 0) return const Text('');

                      // 0, 1/4, 2/4, 3/4, 4/4 위치에만 라벨 표시
                      double step = maxY / 4;
                      double remainder = value % step;

                      // 정확한 위치에만 라벨 표시
                      if (remainder.abs() > step / 10) return const Text('');

                      return Text(
                        _formatYAxisValue(value.toInt()),
                        style: GlobalTextStyle.small02.copyWith(
                          color: GlobalColor.bk03,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: _createBarGroups(),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 범례
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: GlobalColor.brand01,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  config.mainLabel,
                  style: GlobalTextStyle.small01.copyWith(
                    color: GlobalColor.bk02,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: GlobalColor.bk04,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  config.subLabel,
                  style: GlobalTextStyle.small01.copyWith(
                    color: GlobalColor.bk02,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// 최대값 계산
  double _calculateMaxValue() {
    double maxValue = 0;
    for (final data in chartData) {
      if (data.mainValue > maxValue) maxValue = data.mainValue;
      if (data.subValue > maxValue) maxValue = data.subValue;
    }
    return maxValue;
  }

  /// 최소값 계산
  double _calculateMinValue() {
    double minValue = 0;
    for (final data in chartData) {
      if (data.mainValue < minValue) minValue = data.mainValue;
      if (data.subValue < minValue) minValue = data.subValue;
    }
    return minValue;
  }

  /// 돈 단위로 반올림 (만원 단위만 사용)
  double _roundToMoneyUnit(double value) {
    // 절댓값으로 처리
    double absValue = value.abs();

    if (absValue <= 100) return 100;
    if (absValue <= 500) return 500;
    if (absValue <= 1000) return 1000;
    if (absValue <= 5000) return 5000;
    if (absValue <= 10000) return 10000;
    if (absValue <= 50000) return 50000;
    if (absValue <= 100000) return 100000;
    if (absValue <= 500000) return 500000;
    if (absValue <= 1000000) return 1000000;
    if (absValue <= 5000000) return 5000000;
    if (absValue <= 10000000) return 10000000;
    if (absValue <= 50000000) return 50000000;
    return ((absValue / 100000000).ceil() * 100000000); // 억 단위
  }

  /// 돈 단위 라벨 반환 (만원만 사용)
  String _getMoneyUnitLabel(double value) {
    return '만원';
  }

  /// Y축 값을 만원 단위로 표시
  String _formatYAxisValue(int value) {
    return '${(value / 10000).toInt()}';
  }

  /// 막대 그룹 생성
  List<BarChartGroupData> _createBarGroups() {
    return List.generate(chartData.length, (index) {
      final data = chartData[index];
      return BarChartGroupData(
        x: index,
        groupVertically: false,
        barRods: [
          BarChartRodData(
            toY: data.mainValue,
            color: GlobalColor.brand01,
            width: 15,
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: data.subValue,
            color: GlobalColor.bk04,
            width: 15,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    });
  }
}
