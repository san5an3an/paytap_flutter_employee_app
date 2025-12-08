import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

import 'data/segmented_button_data.dart';

/// 커스텀 세그먼트 버튼 위젯
/// 이미지와 같은 스타일의 세그먼트 버튼을 구현합니다.
class CmSegmentedButton extends StatelessWidget {
  final String name;
  final String value;
  final Function(String name, String value)? onTap;
  final List<SegmentedButtonOption> options;
  final double width;
  final double height;

  const CmSegmentedButton({
    super.key,
    required this.name,
    required this.value,
    this.onTap,
    required this.options,
    this.width = double.infinity,
    this.height = 45,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(5), // 전체 컨테이너 패딩
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5), // 연한 회색 배경
          borderRadius: BorderRadius.circular(20), // 둥근 모서리
        ),
        child: Row(
          children: options.asMap().entries.map((entry) {
            final option = entry.value;
            final isSelected = option.value == value;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  onTap?.call(name, option.value);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? GlobalColor.bk08 : Colors.transparent,
                    borderRadius: BorderRadius.circular(100), // radius 100 적용
                  ),
                  child: Center(
                    child: Text(
                      option.title,
                      style: isSelected
                          ? GlobalTextStyle.body01M
                          : GlobalTextStyle.body01M.copyWith(
                              color: GlobalColor.bk03,
                            ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
