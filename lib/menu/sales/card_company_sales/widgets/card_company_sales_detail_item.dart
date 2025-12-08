import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/amount_title/amount_title.dart';

class CardCompanySalesDetailItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const CardCompanySalesDetailItem({super.key, this.data = const {}});

  @override
  Widget build(BuildContext context) {
    List<dynamic> child = data['child'];
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          AmountTitle(saleDe: data['saleDe']),
          ...child.map(
            (item) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getDealItem(item),
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> getDealItem(item) {
  return [
    const SizedBox(height: 15),
    Row(
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
                CommonHelpers.stringParsePrice(item['saleAmt'].toInt()),
                style: GlobalTextStyle.title04.copyWith(
                  color: item['saleAmt'] > 0
                      ? GlobalColor.brand01
                      : GlobalColor.bk03,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: 15),
  ];
}

String formatDateTime(DateTime dateTime) {
  // 오후/오전을 처리하는 AM/PM 표시와 함께 포맷
  String formattedTime = DateFormat('a hh:mm', 'ko').format(dateTime);

  // '오전'을 'AM', '오후'를 'PM'으로 변환
  formattedTime = formattedTime.replaceAll('AM', '오전').replaceAll('PM', '오후');

  return formattedTime;
}
