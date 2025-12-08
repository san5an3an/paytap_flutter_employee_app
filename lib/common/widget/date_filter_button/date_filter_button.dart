import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class DateFilterButton extends StatelessWidget {
  final String label;
  final void Function()? onTap;
  final bool isActive;
  const DateFilterButton({
    super.key,
    this.label = '',
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? GlobalColor.brand03 : GlobalColor.bk08,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
        highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: Text(
            label,
            style: GlobalTextStyle.small01.copyWith(
              color: isActive ? GlobalColor.rev01 : GlobalColor.bk01,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
