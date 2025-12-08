import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class CmChip extends StatelessWidget {
  final String label;
  final Function()? onTap;
  const CmChip({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GlobalColor.bk08,
      borderRadius: BorderRadius.all(Radius.circular(100)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.all(Radius.circular(100)),
        splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
        highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 5, 5, 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GlobalTextStyle.small01),
              Icon(
                Symbols.keyboard_arrow_down_rounded,
                color: GlobalColor.bk03,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
