import 'package:flutter/material.dart';

/// 세그먼트 버튼 옵션 데이터 모델
class SegmentedButtonOption {
  final String title;
  final String value;

  const SegmentedButtonOption({
    required this.title,
    required this.value,
  });
}

/// 세그먼트 버튼 설정 데이터 모델
class SegmentedButtonData {
  final String name;
  final String value;
  final VoidCallback? onTap;
  final List<SegmentedButtonOption> options;
  final Function(String)? onValueChanged;

  const SegmentedButtonData({
    required this.name,
    required this.value,
    this.onTap,
    required this.options,
    this.onValueChanged,
  });
}
