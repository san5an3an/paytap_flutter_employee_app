import 'package:flutter/material.dart';

/// 도넛 차트 데이터 모델
class CmDonutChartDataModel {
  final String label;
  final double value;
  final Color color;

  CmDonutChartDataModel({
    required this.label,
    required this.value,
    required this.color,
  });
}
