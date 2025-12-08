import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class DailySalesDetailAmountCard extends StatelessWidget {
  final List<Map<String, dynamic>> mainList;
  final String title;
  const DailySalesDetailAmountCard({
    super.key,
    required this.mainList,
    this.title = "",
  });

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
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                ...mainList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Column(
                    children: [
                      if (index == 3)
                        Container(
                          height: 1,
                          color: GlobalColor.bk05,
                          margin: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(item['icon']),
                              const SizedBox(width: 10),
                              Text(
                                item['title'],
                                style: GlobalTextStyle.body01M,
                              ),
                            ],
                          ),
                          Text(
                            "${CommonHelpers.stringParsePrice(item['value'].toInt())}원",
                            style: GlobalTextStyle.body01M.copyWith(
                              color: GlobalColor.getColorByName(item['color']),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
