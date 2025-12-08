import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/amount_card/data/amount_card_model.dart';

class DcTypeSalesAmountCard extends StatelessWidget {
  final List<AmountCardModel> mainList;

  const DcTypeSalesAmountCard({super.key, required this.mainList});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GlobalColor.bk08,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(children: [..._buildItems()]),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItems() {
    return mainList.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (item.icon.isNotEmpty) SvgPicture.asset(item.icon),
                  if (item.icon.isNotEmpty) const SizedBox(width: 10),
                  Text(item.label, style: GlobalTextStyle.body01M),
                ],
              ),
              Text(
                "${CommonHelpers.stringParsePrice(item.value.toInt())}원",
                style: GlobalTextStyle.body01M.copyWith(
                  color: GlobalColor.getColorByName(item.color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 3번째 아이템(index: 2) 다음에 구분선 추가
          if (index == 2)
            Container(
              height: 1,
              color: GlobalColor.bk06,
              margin: const EdgeInsets.symmetric(vertical: 15),
            ),
        ],
      );
    }).toList();
  }
}
