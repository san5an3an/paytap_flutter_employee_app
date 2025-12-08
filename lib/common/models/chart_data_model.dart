/// 차트 데이터 모델
class ChartDataModel {
  final String title;
  final double mainValue;
  final double subValue;

  ChartDataModel({
    required this.title,
    required this.mainValue,
    required this.subValue,
  });
}

/// 차트 설정 모델
class ChartConfigModel {
  final String mainLabel;
  final String subLabel;
  final String yAxisUnit;

  ChartConfigModel({
    required this.mainLabel,
    required this.subLabel,
    this.yAxisUnit = "만원",
  });
}
