import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class CmBarHorizonChart extends StatefulWidget {
  final List<Map<String, dynamic>> chartList;

  const CmBarHorizonChart({super.key, required this.chartList});

  @override
  State<CmBarHorizonChart> createState() => _CmBarHorizonChartState();
}

class _CmBarHorizonChartState extends State<CmBarHorizonChart> {
  // 애니메이션이 시작되었는지 여부를 저장하는 상태 변수
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    // 위젯이 초기화된 후에 애니메이션을 트리거합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _animate = true;
      });
    });
  }

  @override
  void didUpdateWidget(covariant CmBarHorizonChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chartList != widget.chartList) {
      setState(() {
        _animate = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _animate = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chartList.isEmpty) {
      return const SizedBox.shrink(); // 아무것도 안 보임
    }
    return SizedBox(width: double.infinity, child: getBarItem(context));
  }

  Widget getBarItem(BuildContext context) {
    int maxValue = getMaxValue(widget.chartList);
    return Column(children: [...barItem(widget.chartList, maxValue, context)]);
  }

  int getMaxValue(List<Map<String, dynamic>> chartList) {
    int maxValue = chartList[0]['value'];
    for (var el in chartList) {
      if (maxValue <= el['value']) {
        maxValue = el['value'];
      }
    }
    return maxValue;
  }

  List<Widget> barItem(
    List<Map<String, dynamic>> chartList,
    int maxValue,
    BuildContext context,
  ) {
    // 화면 크기 또는 최대값에 대한 비율을 설정합니다.
    double maxWidth = MediaQuery.of(context).size.width;
    return chartList.asMap().entries.map((el) {
      int index = el.key;
      Map<String, dynamic> item = el.value;
      double containerWidth = item['value'] > 0
          ? (item['value'] / maxValue) * maxWidth
          : 0; // 비율 계산

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['title'],
                style: GlobalTextStyle.small01.copyWith(
                  color: GlobalColor.bk01,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                CommonHelpers.stringParsePrice(item['value']),
                style: GlobalTextStyle.small01.copyWith(
                  color: item['value'] < 0
                      ? GlobalColor.systemRed
                      : GlobalColor.bk03,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: GlobalColor.bk06,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: _animate ? containerWidth : 0, // 애니메이션 시작 시 너비 설정
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: GlobalColor.brand01,
                ),
              ),
            ],
          ),
          if (index != chartList.length - 1) const SizedBox(height: 20),
        ],
      );
    }).toList();
  }
}
