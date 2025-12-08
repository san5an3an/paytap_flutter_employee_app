import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/amount_title/amount_title.dart';

class CancelHistItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const CancelHistItem({super.key, this.data = const {}});

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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GlobalColor.bk08,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: child.asMap().entries.map((entry) {
                int index = entry.key;
                dynamic item = entry.value;
                return Column(
                  children: [
                    CancelHistItemDetail(data: item, index: index),
                    if (index < child.length - 1) const SizedBox(height: 15),
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

class CancelHistItemDetail extends StatefulWidget {
  final Map<String, dynamic> data;
  final int index;
  const CancelHistItemDetail({
    super.key,
    this.data = const {},
    required this.index,
  });

  @override
  State<CancelHistItemDetail> createState() => _CancelHistItemDetailState();
}

class _CancelHistItemDetailState extends State<CancelHistItemDetail> {
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
          context.push(
            '/sales/cancel-hist/detail',
            extra: {
              "saleDe": widget.data['saleDe'],
              "posNo": widget.data['posNo'],
              "orderNo": widget.data['orderNo'],
            },
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            vertical: 7,
            horizontal: isPressed ? 8 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 주문 정보 컬럼
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 주문번호 (상품명과 함께 이동)
                          Text(
                            '${widget.data['posNo']}-${widget.data['orderNo']}',
                            style: GlobalTextStyle.body01,
                          ),

                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeInOut,
                            transform: isPressed
                                ? Matrix4.translationValues(-4, 0, 0)
                                : Matrix4.translationValues(0, 0, 0),
                            child: Text(
                              '${CommonHelpers.stringParsePrice(double.parse(widget.data['totalCancelPrice']).toInt())}원',
                              style: GlobalTextStyle.body01M,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _parseInt(widget.data['otherCount']) > 0
                                ? '${widget.data['prdNm']} 외 ${widget.data['otherCount']}개'
                                : widget.data['prdNm'],
                            style: GlobalTextStyle.small01M.copyWith(
                              color: GlobalColor.bk03,
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeInOut,
                            transform: isPressed
                                ? Matrix4.translationValues(-4, 0, 0)
                                : Matrix4.translationValues(0, 0, 0),
                            child: Text(
                              _formatOrderDt(widget.data['orderDt']),
                              style: GlobalTextStyle.small01.copyWith(
                                color: GlobalColor.bk03,
                              ),
                            ),
                          ),
                        ],
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
                  width: 20,
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

String _formatOrderDt(String orderDt) {
  try {
    // "20250625234542" 형식의 문자열을 DateTime으로 변환
    DateTime dateTime = DateHelpers.getDtStringConvertDateTime(orderDt);
    // "오후 00:00" 형식으로 변환
    return DateHelpers.getTimehoursWithPeriod(dateTime);
  } catch (e) {
    // 변환 실패 시 원본 문자열 반환
    return orderDt;
  }
}

/// 안전한 정수 파싱 메서드
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) {
    try {
      return int.parse(value);
    } catch (e) {
      return 0;
    }
  }
  return 0;
}
