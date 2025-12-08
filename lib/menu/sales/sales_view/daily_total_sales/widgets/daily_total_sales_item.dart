import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class DailyTotalSalesItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isLast;
  const DailyTotalSalesItem({
    super.key,
    this.data = const {},
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    String date = data['saleDe'];
    String formattedDate =
        "${date.substring(2, 4)}.${date.substring(4, 6)}.${date.substring(6, 8)}";
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 126,
                child: Text(
                  formattedDate,
                  style: GlobalTextStyle.title04M.copyWith(
                    color: GlobalColor.brand01,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '매출',
                          style: GlobalTextStyle.body02M.copyWith(
                            color: GlobalColor.bk01,
                          ),
                        ),
                        Text(
                          '${CommonHelpers.stringParsePrice(data['saleAmt'].toInt())}원',
                          style: GlobalTextStyle.body02M,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '할인',
                          style: GlobalTextStyle.body02M.copyWith(
                            color: GlobalColor.bk03,
                          ),
                        ),
                        Text(
                          '${CommonHelpers.stringParsePrice(data['dcAmt'].toInt())}원',
                          style: GlobalTextStyle.body02M,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '실매출',
                          style: GlobalTextStyle.body02M.copyWith(
                            color: GlobalColor.brand01,
                          ),
                        ),
                        Text(
                          '${CommonHelpers.stringParsePrice((data['dcmSaleAmt']).toInt())}원',
                          style: GlobalTextStyle.body02M.copyWith(
                            color: data['dcmSaleAmt'].toInt() > 0
                                ? GlobalColor.brand01
                                : GlobalColor.bk03,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '가액',
                          style: GlobalTextStyle.body02M.copyWith(
                            color: GlobalColor.bk03,
                          ),
                        ),
                        Text(
                          '${CommonHelpers.stringParsePrice((data['dcmSaleAmt'] - data['vatAmt']).toInt())}원',
                          style: GlobalTextStyle.body02M.copyWith(
                            color: GlobalColor.bk03,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '→ 일반',
                          style: GlobalTextStyle.body02M.copyWith(
                            color: GlobalColor.bk03,
                          ),
                        ),
                        Text(
                          '${CommonHelpers.stringParsePrice((data['vatSaleAmt']).toInt())}원',
                          style: GlobalTextStyle.body02M.copyWith(
                            color: GlobalColor.bk03,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '→ 면세',
                          style: GlobalTextStyle.body02M.copyWith(
                            color: GlobalColor.bk03,
                          ),
                        ),
                        Text(
                          '${CommonHelpers.stringParsePrice((data['noVatSaleAmt']).toInt())}원',
                          style: GlobalTextStyle.body02M.copyWith(
                            color: GlobalColor.bk03,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '부가세',
                          style: GlobalTextStyle.body02M.copyWith(
                            color: GlobalColor.bk03,
                          ),
                        ),
                        Text(
                          '${CommonHelpers.stringParsePrice((data['vatAmt']).toInt())}원',
                          style: GlobalTextStyle.body02M.copyWith(
                            color: GlobalColor.bk03,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isLast)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              height: 1,
              color: GlobalColor.bk05,
            ),
        ],
      ),
    );
  }
}
