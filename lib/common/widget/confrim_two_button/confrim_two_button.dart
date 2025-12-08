import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class ConfirmTwoButton extends StatelessWidget {
  final String leftButtonText;
  final String rightButtonText;
  final VoidCallback onLeftButtonPressed;
  final VoidCallback onRightButtonPressed;

  const ConfirmTwoButton({
    super.key,
    required this.leftButtonText,
    required this.rightButtonText,
    required this.onLeftButtonPressed,
    required this.onRightButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () {
              onLeftButtonPressed();
            },
            style: FilledButton.styleFrom(
              backgroundColor: GlobalColor.bk06,
              minimumSize: const Size.fromHeight(50),
            ),
            child: Text(
              '닫기',
              style: GlobalTextStyle.body02M.copyWith(color: GlobalColor.bk01),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            onPressed: () {
              onRightButtonPressed();
            },
            style: FilledButton.styleFrom(
              backgroundColor: GlobalColor.brand01,
              minimumSize: const Size.fromHeight(50),
            ),
            child: Text(
              '저장하기',
              style: GlobalTextStyle.body02M.copyWith(color: GlobalColor.bk08),
            ),
          ),
        ),
      ],
    );
  }
}
