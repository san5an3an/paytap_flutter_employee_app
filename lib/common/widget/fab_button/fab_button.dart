import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';

class FabButton extends StatelessWidget {
  final ScrollController scrollController;

  const FabButton({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: GlobalColor.dim01,
      ),
      child: SizedBox(
        child: IconButton(
          onPressed: () {
            scrollController.animateTo(
              0, // 최상단으로 이동
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          },
          icon: SvgPicture.asset('assets/icons/i_Top.svg'),
        ),
      ),
    );
  }
}
