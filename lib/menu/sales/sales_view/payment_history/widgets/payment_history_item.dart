import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/amount_title/amount_title.dart';

class PaymentHistoryItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const PaymentHistoryItem({super.key, this.data = const {}});

  @override
  Widget build(BuildContext context) {
    List<dynamic> child = data['child'];
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          AmountTitle(saleDe: data['apprDate']),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GlobalColor.bk08,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...child.map(
                  (item) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: getDealItem(
                      item,
                      child.indexOf(item) == 0,
                      child.indexOf(item) == child.length - 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> getDealItem(item, bool isFirst, bool isLast) {
  DateTime dateTime = DateHelpers.getDtStringConvertDateTime(item['apprDt']);
  String paymentNm = getPaymentNm(item['payTypeFlag']);

  return [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Wrap(
            children: [
              Text(
                paymentNm,
                style: GlobalTextStyle.body01M.copyWith(
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
                "${CommonHelpers.stringParsePrice(item['payAmt'].toInt())}원",
                style: GlobalTextStyle.body01M.copyWith(
                  color: item['payAmt'] > 0
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
    Row(
      children: [
        Text(
          '${item['posNo']}-${item['recptUnqno']} / ${formatDateTime(dateTime)}',
          style: GlobalTextStyle.body02M.copyWith(color: GlobalColor.bk03),
        ),
      ],
    ),
    // payCorpNm이 있을 때만 표시
    if (item['payCorpNm'] != null && item['payCorpNm'].toString().isNotEmpty)
      Row(
        children: [
          Text(
            '${item['payCorpNm']} ) ${item['payMethodNo'] ?? ''}',
            style: GlobalTextStyle.body02M.copyWith(color: GlobalColor.bk03),
          ),
        ],
      ),
    // 마지막 요소가 아닐 때만 구분선 표시
    if (!isLast)
      Container(
        margin: const EdgeInsets.symmetric(vertical: 15),
        height: 1,
        color: GlobalColor.bk05,
      ),
  ];
}

String formatDateTime(DateTime dateTime) {
  // 오후/오전을 처리하는 AM/PM 표시와 함께 포맷
  String formattedTime = DateFormat('a hh:mm', 'ko').format(dateTime);

  // '오전'을 'AM', '오후'를 'PM'으로 변환
  formattedTime = formattedTime.replaceAll('AM', '오전').replaceAll('PM', '오후');

  return formattedTime;
}

String getPaymentNm(String payment) {
  switch (payment) {
    case '01':
      return '현금';
    case '02':
      return '현금영수증';
    case '03':
      return '신용카드';
    case '04':
      return '은련카드';
    case '05':
      return '간편결제';
    case '06':
      return '제휴할인카드';
    case '07':
      return '상품권';
    case '08':
      return '식권';
    case '09':
      return '외상';
    case '10':
      return '선불카드';
    case '11':
      return '선결제';
    case '12':
      return '전자상품권';
    case '13':
      return '모바일상품권';
    case '14':
      return '회원포인트적립';
    case '15':
      return '회원포인트사용';
    case '16':
      return '사원카드';
    case '17':
      return '회원스탬프적립';
    case '18':
      return '회원스탬프사용';
    case '19':
      return '배달';
  }
  return payment;
}
