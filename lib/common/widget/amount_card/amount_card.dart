import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/amount_card/data/amount_card_model.dart';

class AmountCard extends StatelessWidget {
  final List<AmountCardModel> mainList;
  final String title;
  const AmountCard({super.key, required this.mainList, this.title = ""});

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
          if (title != "")
            SizedBox(child: Text(title, style: GlobalTextStyle.title04M)),
          if (title != "") const SizedBox(height: 15),
          Column(children: [..._buildItems()]),
        ],
      ),
    );
  }

  List<Widget> _buildItems() {
    return mainList.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isLast = index == mainList.length - 1;

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
          if (!isLast) const SizedBox(height: 10),
        ],
      );
    }).toList();
  }
}
