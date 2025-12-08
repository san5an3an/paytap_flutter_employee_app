import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/amount_title/amount_title.dart';

class CashReceiptApprovalHistoryItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const CashReceiptApprovalHistoryItem({super.key, this.data = const {}});

  @override
  Widget build(BuildContext context) {
    List<dynamic> child = data['child'];
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          AmountTitle(saleDe: data['saleDe']),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GlobalColor.bk08,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...child.asMap().entries.map((entry) {
                  int index = entry.key;
                  dynamic item = entry.value;
                  bool isLastItem = index == child.length - 1;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: getDealItem(item, isLastItem),
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

List<Widget> getDealItem(item, bool isLastItem) {
  List<Widget> widgets = [
    const SizedBox(height: 15),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            '${item['posNo']}-${item['recptUnqno']}',
            style: GlobalTextStyle.title04M.copyWith(
              color: GlobalColor.bk01,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Flexible(
          child: Text(
            '${CommonHelpers.stringParsePrice(item['apprPrice'].toInt())}원',
            style: GlobalTextStyle.body01M.copyWith(
              color: item['apprPrice'] > 0
                  ? GlobalColor.brand01
                  : GlobalColor.bk03,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
    const SizedBox(height: 10),
    Row(
      children: [
        Text(
          '${getApprIdtTypeText(item['apprIdtType'])} ) ${item['apprIdtNo']}',
          style: GlobalTextStyle.body02M.copyWith(color: GlobalColor.bk03),
        ),
      ],
    ),
    const SizedBox(height: 5),
    Row(
      children: [
        Text(
          '승인번호: ${item['apprNo']}',
          style: GlobalTextStyle.body02M.copyWith(color: GlobalColor.bk03),
        ),
      ],
    ),
  ];

  // 마지막 아이템이 아닌 경우에만 구분선 추가
  if (!isLastItem) {
    widgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Divider(color: GlobalColor.bk05, thickness: 1, height: 1),
      ),
    );
  }

  return widgets;
}

String formatDateTime(DateTime dateTime) {
  // 오후/오전을 처리하는 AM/PM 표시와 함께 포맷
  String formattedTime = DateFormat('a hh:mm', 'ko').format(dateTime);

  // '오전'을 'AM', '오후'를 'PM'으로 변환
  formattedTime = formattedTime.replaceAll('AM', '오전').replaceAll('PM', '오후');

  return formattedTime;
}

String getApprIdtTypeText(String apprIdtType) {
  if (apprIdtType == "0") return "비승인";
  if (apprIdtType == "1") return "개인";
  if (apprIdtType == "2") return "사업자";
  if (apprIdtType == "3") return "자진발급";
  return "";
}
