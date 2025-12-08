import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class GoodsSalesItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final int index;
  const GoodsSalesItem({super.key, this.data = const {}, required this.index});

  @override
  State<GoodsSalesItem> createState() => _GoodsSalesItemState();
}

class _GoodsSalesItemState extends State<GoodsSalesItem> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
        highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
        onTapDown: (_) {
          setState(() {
            isPressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            isPressed = false;
          });
        },
        onTapCancel: () {
          setState(() {
            isPressed = false;
          });
        },
        onTap: () {
          context.push('/sales/goods-sales/detail', extra: widget.data);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: isPressed ? 8 : 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 상품 정보 컬럼
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  transform: isPressed
                      ? Matrix4.translationValues(4, 0, 0)
                      : Matrix4.translationValues(0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 순위 컬럼 (시작 부분)
                      Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              '${widget.index + 1}위',
                              style: GlobalTextStyle.body01M.copyWith(
                                color: GlobalColor.brand01,
                              ),
                            ),
                          ),
                          Text(
                            '${widget.data['goodsNm']}',
                            style: GlobalTextStyle.body01,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 개수 (상품명과 함께 이동)
                            Text(
                              '${widget.data['saleQty']}개',
                              style: GlobalTextStyle.body02M.copyWith(
                                color: GlobalColor.bk03,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // 금액 (왼쪽으로 이동)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInOut,
                              transform: isPressed
                                  ? Matrix4.translationValues(-4, 0, 0)
                                  : Matrix4.translationValues(0, 0, 0),
                              child: Text(
                                "${CommonHelpers.stringParsePrice(widget.data['dcmSalePrice'].toInt())}원",
                                style: GlobalTextStyle.body02M,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 아이콘 컬럼
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                transform: isPressed
                    ? Matrix4.translationValues(-4, 0, 0)
                    : Matrix4.translationValues(0, 0, 0),
                child: SizedBox(
                  width: 25,
                  height: 20,
                  child: Center(
                    child: Icon(
                      Symbols.chevron_right_rounded,
                      color: GlobalColor.bk03,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatDateTime(DateTime dateTime) {
  // 오후/오전을 처리하는 AM/PM 표시와 함께 포맷
  String formattedTime = DateFormat('a hh:mm', 'ko').format(dateTime);

  // '오전'을 'AM', '오후'를 'PM'으로 변환
  formattedTime = formattedTime.replaceAll('AM', '오전').replaceAll('PM', '오후');

  return formattedTime;
}
