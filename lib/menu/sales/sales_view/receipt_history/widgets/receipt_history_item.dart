import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/amount_title/amount_title.dart';

class ReceiptHistoryItem extends StatefulWidget {
  final Map<String, dynamic> data;
  const ReceiptHistoryItem({super.key, this.data = const {}});

  @override
  State<ReceiptHistoryItem> createState() => _ReceiptHistoryItemState();
}

class _ReceiptHistoryItemState extends State<ReceiptHistoryItem> {
  Map<int, bool> pressedStates = {};

  @override
  Widget build(BuildContext context) {
    List<dynamic> child = widget.data['child'];
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AmountTitle(saleDe: widget.data['apprDate']),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GlobalColor.bk08,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: child.asMap().entries.map((entry) {
                int index = entry.key;
                dynamic item = entry.value;
                bool isLastItem = index == child.length - 1;

                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
                        highlightColor: GlobalColor.brand01.withValues(
                          alpha: 0.1,
                        ),
                        onTapDown: (_) {
                          setState(() {
                            pressedStates[index] = true;
                          });
                        },
                        onTapUp: (_) {
                          setState(() {
                            pressedStates[index] = false;
                          });
                        },
                        onTapCancel: () {
                          setState(() {
                            pressedStates[index] = false;
                          });
                        },
                        onTap: () {
                          context.push(
                            '/sales/sales-view/receipt-detail',
                            extra: {
                              "saleDe": item['saleDe'],
                              "recptUnqno": item['recptUnqno'],
                              "posNo": item['posNo'],
                            },
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: pressedStates[index] == true ? 8 : 4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: getDealItem(
                              item,
                              isLastItem,
                              index == 0,
                              pressedStates[index] == true,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 마지막 아이템이 아닐 때만 구분선 추가
                    if (!isLastItem)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 15),
                        height: 1,
                        // color: GlobalColor.bk05,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> getDealItem(
  item,
  bool isLastItem,
  bool isFirstItem,
  bool isPressed,
) {
  DateTime dateTime = DateHelpers.getDtStringConvertDateTime(item['apprDt']);

  List<Widget> widgets = [];

  // 첫 번째 아이템인 경우에만 top 패딩 추가
  if (isFirstItem) {
    widgets.add(const SizedBox(height: 5));
  }

  widgets.add(
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            transform: isPressed
                ? Matrix4.translationValues(4, 0, 0)
                : Matrix4.translationValues(0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['posNo']}-${item['recptUnqno']}',
                  style: GlobalTextStyle.body01M.copyWith(
                    color: GlobalColor.bk01,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatDateTime(dateTime),
                  style: GlobalTextStyle.body02M.copyWith(
                    color: GlobalColor.bk03,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            transform: isPressed
                ? Matrix4.translationValues(-4, 0, 0)
                : Matrix4.translationValues(0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "${CommonHelpers.stringParsePrice(item['dcmSaleAmt'].toInt())}원",
                  style: GlobalTextStyle.body01M.copyWith(
                    color: item['dcmSaleAmt'] > 0
                        ? GlobalColor.brand01
                        : GlobalColor.bk03,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Symbols.chevron_right_rounded,
                  size: 18,
                  color: GlobalColor.bk03,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
  if (isLastItem) {
    widgets.add(const SizedBox(height: 5));
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
