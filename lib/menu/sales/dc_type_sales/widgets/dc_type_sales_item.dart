import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class DcTypeSalesItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  final int totalCount;

  const DcTypeSalesItem({
    super.key,
    this.data = const {},
    required this.index,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 첫 번째 아이템(index: 0)이 아닌 경우에만 위쪽 패딩 추가
          if (index > 0) const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Wrap(
                  children: [
                    Text(
                      '${data['goodsNm']}',
                      style: GlobalTextStyle.body01.copyWith(
                        color: GlobalColor.bk01,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('수량', style: GlobalTextStyle.body02M),
              Text(
                '${CommonHelpers.stringParsePrice(data['totSaleCnt'].toInt())}개',
                style: GlobalTextStyle.body02M,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('매출', style: GlobalTextStyle.body02M),
              Text(
                '${CommonHelpers.stringParsePrice(data['totSaleAmt'].toInt())}원',
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
                '총 할인',
                style: GlobalTextStyle.body02M.copyWith(
                  color: GlobalColor.bk03,
                ),
              ),
              Text(
                '${CommonHelpers.stringParsePrice(data['totDcAmt'].toInt())}원',
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
                '실매출',
                style: GlobalTextStyle.body02M.copyWith(
                  color: GlobalColor.brand01,
                ),
              ),
              Text(
                '${CommonHelpers.stringParsePrice(data['totDcmSaleAmt'].toInt())}원',
                style: GlobalTextStyle.body02M.copyWith(
                  color: data['totDcmSaleAmt'].toInt() > 0
                      ? GlobalColor.brand01
                      : GlobalColor.bk03,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // 마지막 아이템이 아닌 경우에만 구분선 추가
          if (index < totalCount - 1)
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
