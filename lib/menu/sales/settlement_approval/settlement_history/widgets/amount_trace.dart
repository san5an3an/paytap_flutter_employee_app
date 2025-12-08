import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class AmountTrace extends StatelessWidget {
  final Map<String, dynamic> list;
  final String type;
  const AmountTrace({super.key, required this.list, this.type = 'pos'});

  @override
  Widget build(BuildContext context) {
    return Column(children: [_posCardItem(list)]);
  }

  Widget _posCardItem(item) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: GlobalColor.bk08,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'], style: GlobalTextStyle.title03),
                        Text(
                          item['date'],
                          style: GlobalTextStyle.body02.copyWith(
                            color: GlobalColor.bk03,
                          ),
                        ),
                        Text(
                          '매출 : ${CommonHelpers.stringParsePrice(item['saleAmt'].toInt())} / 할인 :  ${CommonHelpers.stringParsePrice(item['dcAmt'].toInt())}',
                          style: GlobalTextStyle.body02.copyWith(
                            color: GlobalColor.bk03,
                          ),
                        ),
                        Text(
                          '실매출 : ${CommonHelpers.stringParsePrice(item['dcmSaleAmt'].toInt())}',
                          style: GlobalTextStyle.body02.copyWith(
                            color: GlobalColor.bk03,
                          ),
                        ),
                        ...item['child'].map(
                          (item) => _posItem(
                            item['title'],
                            item['color'],
                            item['icon'],
                            item['child'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _posItem(
    String title,
    String color,
    String icon,
    List<Map<String, dynamic>> child,
  ) {
    return Column(
      children: [
        SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(icon, width: 20, height: 20),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
              child: Text(
                title,
                style: GlobalTextStyle.body01M.copyWith(
                  color: GlobalColor.getColorByName(color),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Flexible(
              child: Column(
                children: [
                  ...child.asMap().entries.map(
                    (entry) => _posChildItem(
                      title: entry.value['title'],
                      value: entry.value['value'],
                      isLast: entry.key == child.length - 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  Widget _posChildItem({
    String title = '',
    double value = 0,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GlobalTextStyle.body01.copyWith(color: GlobalColor.bk03),
            ),
            Text(
              CommonHelpers.stringParsePrice(value.toInt()),
              style: GlobalTextStyle.body01,
            ),
          ],
        ),
        if (!isLast) const SizedBox(height: 5),
      ],
    );
  }
}
