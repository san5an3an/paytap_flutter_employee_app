import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class MenuLinkItem extends StatelessWidget {
  final Widget leftIcon;
  final String label;
  final void Function()? onTap;
  const MenuLinkItem({
    super.key,
    this.label = '',
    this.onTap,
    this.leftIcon = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(padding: const EdgeInsets.only(right: 15), child: leftIcon),
            Expanded(
              child: Text(
                label,
                style: GlobalTextStyle.body01.copyWith(
                  color: GlobalColor.bk01,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: SvgPicture.asset('assets/icons/i_Enter.svg'),
            ),
          ],
        ),
      ),
    );
  }
}
