/// 차트 데이터 모델
class CmBarVerticalChartDataModel {
  final String title;
  final double mainValue;
  final double subValue;

  CmBarVerticalChartDataModel({
    required this.title,
    required this.mainValue,
    required this.subValue,
  });
}

/// 차트 설정 모델
class CmBarVerticalChartConfigModel {
  final String mainLabel;
  final String subLabel;
  final String yAxisUnit;

  CmBarVerticalChartConfigModel({
    required this.mainLabel,
    required this.subLabel,
    this.yAxisUnit = "만원",
  });
}
