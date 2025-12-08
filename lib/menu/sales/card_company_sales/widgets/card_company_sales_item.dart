import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class CardCompanySalesItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isLast;
  const CardCompanySalesItem({
    super.key,
    this.data = const {},
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [...getDealItem(context, data, isLast)],
      ),
    );
  }
}

List<Widget> getDealItem(BuildContext context, item, bool isLast) {
  List<Widget> widgets = [
    InkWell(
      onTap: () {
        context.push('/sales/card-company-sales/detail', extra: item);
      },
      borderRadius: BorderRadius.circular(12),
      splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
      highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Wrap(
                children: [
                  Text(
                    item['payCorpNm'],
                    style: GlobalTextStyle.title04.copyWith(
                      color: GlobalColor.bk01,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Wrap(
                children: [
                  Text(
                    CommonHelpers.stringParsePrice(item['totSaleAmt'].toInt()),
                    style: GlobalTextStyle.title04.copyWith(
                      color: item['totSaleAmt'] > 0
                          ? GlobalColor.brand01
                          : GlobalColor.bk03,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SvgPicture.asset('assets/icons/i_Enter_Darker.svg'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ];

  // 마지막 아이템이 아닐 때만 구분선 추가
  if (!isLast) {
    widgets.add(
      Container(
        margin: const EdgeInsets.symmetric(vertical: 15),
        height: 1,
        color: GlobalColor.bk05,
      ),
    );
  }

  return widgets;
}
