import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class AlarmItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const AlarmItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return historyCard(data);
  }
}

Widget historyCard(Map<String, dynamic> item) {
  return Container(
    decoration: BoxDecoration(
      color: GlobalColor.bk08,
      border: Border.all(color: GlobalColor.bk04),
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.all(15),
    child: item['alarmFlag'] == '0' ? openCard(item) : closeCard(item),
  );
}

Widget openCard(Map<String, dynamic> item) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getParsedStringCreatedAt(item['createdAt']),
            style: GlobalTextStyle.body02M,
          ),
          alarmFlagChip(item['alarmFlag']),
        ],
      ),
      divider(),
      getLabelItem('영업일자', item['saleDe']),
      getLabelItem('포스번호', item['posNo']),
      getLabelItem(
        '준비금',
        '${CommonHelpers.stringParsePrice(item['posReadyAmt'])}원',
      ),
      divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            DateHelpers.getIntlTime(
              DateHelpers.getDateTimeStringConvertDateTime(item['createdAt']),
            ),
            style: GlobalTextStyle.small02.copyWith(color: GlobalColor.bk03),
          ),
        ],
      ),
    ],
  );
}

Widget closeCard(Map<String, dynamic> item) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getParsedStringCreatedAt(item['createdAt']),
            style: GlobalTextStyle.body02M,
          ),
          alarmFlagChip(item['alarmFlag']),
        ],
      ),
      divider(),
      getLabelItem('영업일자', item['saleDe']),
      getLabelItem('포스번호', item['posNo']),
      getLabelItem('영수건수', '70건'),
      getLabelItem(
        '실매출액',
        '${CommonHelpers.stringParsePrice(item['dcmSaleAmt'])}원',
      ),
      divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            DateHelpers.getIntlTime(
              DateHelpers.getDateTimeStringConvertDateTime(item['createdAt']),
            ),
            style: GlobalTextStyle.small02.copyWith(color: GlobalColor.bk03),
          ),
        ],
      ),
    ],
  );
}

// 구분선
Widget divider() {
  return Column(
    children: [
      const SizedBox(height: 13),
      Container(
        height: 1,
        color: GlobalColor.bk04,
        margin: const EdgeInsets.symmetric(vertical: 10),
      ),
      const SizedBox(height: 13),
    ],
  );
}

Widget alarmFlagChip(String alarmFlag) {
  return Container(
    decoration: BoxDecoration(
      color: getAlarmFlagChipColor(alarmFlag),
      borderRadius: BorderRadius.circular(100),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 17),
    child: Text(
      getAlarmFlagText(alarmFlag),
      style: GlobalTextStyle.small01.copyWith(color: GlobalColor.bk07),
    ),
  );
}

Color getAlarmFlagChipColor(String alarmFlag) {
  switch (alarmFlag) {
    case '0':
      return GlobalColor.brand01;
    default:
      return GlobalColor.brand03;
  }
}

String getAlarmFlagText(String alarmFlag) {
  switch (alarmFlag) {
    case '0':
      return '개점';
    default:
      return '일마감';
  }
}

// 2025-05-15 18:15:40 -> 2025.05.15 오후 6:15 변경 해주는 함수
String getParsedStringCreatedAt(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  String formattedDate = DateFormat('yyyy.MM.dd').format(dateTime);
  String period = dateTime.hour < 12 ? '오전' : '오후';
  String formattedTime = DateFormat('HH:mm').format(dateTime);
  return '$formattedDate $period $formattedTime';
}

// 내역 표시 위젯젯
Widget getLabelItem(String label, String value) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GlobalTextStyle.small01.copyWith(color: GlobalColor.bk02),
          ),
          Text(
            value,
            style: GlobalTextStyle.body02.copyWith(color: GlobalColor.bk02),
          ),
        ],
      ),
      const SizedBox(height: 13),
    ],
  );
}
