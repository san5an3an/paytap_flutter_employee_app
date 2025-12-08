import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:paytap_app/common/enums/pay_type_code.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/menu/sales/receipt_detail/receipt_detail_screen_model.dart';

class ReceiptDetailScreen extends ConsumerStatefulWidget {
  const ReceiptDetailScreen({super.key});

  @override
  ConsumerState<ReceiptDetailScreen> createState() =>
      _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends ConsumerState<ReceiptDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화 (한 번만 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      print('Route extra: $extra');
      if (extra != null) {
        final state = ref.read(receiptDetailScreenModelProvider);
        final vm = ref.read(receiptDetailScreenModelProvider.notifier);
        if (!state.isLoading) {
          vm.getDealHistoryDetail(context, extra);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(receiptDetailScreenModelProvider);
    Map<String, dynamic> receiptInfo = vm.receiptInfo;
    Map<String, dynamic> totalReceiptOrderList = vm.totalReceiptOrderList;
    List<dynamic> receiptOrderList = vm.receiptOrderList;
    List<dynamic> receiptPaymentList = vm.receiptPaymentList;

    return Layout(
      title:
          '${receiptInfo['posNo'] ?? ""}${receiptInfo['posNo'] != null && receiptInfo['recptUnqno'] != null ? "-" : ""}${receiptInfo['recptUnqno'] ?? ""}',
      isDisplayBottomNavigationBar: false,
      children: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              if (vm.isLoading)
                const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!vm.isLoading)
                Column(
                  children: [
                    posInfoItem(
                      title: "일시",
                      value: receiptInfo['createdAt']?.split(' ')[0] ?? '',
                    ),
                    posInfoItem(title: "포스", value: receiptInfo['posNo'] ?? ''),
                    posInfoItem(
                      title: "영수",
                      value: receiptInfo['recptUnqno'] ?? '',
                    ),
                    const SizedBox(height: 15),
                    posInfoItem(
                      title: "판매원",
                      value: receiptInfo['staffNm'] ?? '',
                    ),
                    posInfoItem(title: "테이블", value: ""),
                    const SizedBox(height: 15),
                    posInfoItem(title: "회원", value: receiptInfo['mbrNm'] ?? ''),
                    posInfoItem(
                      title: "연락처",
                      value: receiptInfo['mbrCelno'] ?? '',
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      height: 1,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: GlobalColor.bk05, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            '주문 정보',
                            style: GlobalTextStyle.body01.copyWith(
                              color: GlobalColor.bk01,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...receiptOrderList.map((item) => getOrderItem(item)),
                    const SizedBox(height: 15),
                    DottedLine(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      lineLength: double.infinity,
                      lineThickness: 1.0,
                      dashLength: 4.0,
                      dashColor: GlobalColor.bk03,
                    ),
                    const SizedBox(height: 15),
                    getOrderTotalItem(
                      title: "주문금액",
                      value: totalReceiptOrderList['totalSalePrice'],
                    ),
                    getOrderTotalItem(
                      title: "할인",
                      value: totalReceiptOrderList['totalDcPrice'],
                    ),
                    getOrderTotalItem(
                      title: "결제금액",
                      value: totalReceiptOrderList['totalDcmSalePrice'],
                      isPayment: true,
                    ),
                    getOrderTotalItem(
                      title: "→ 가액",
                      value: totalReceiptOrderList['totalSupplyPrice'],
                    ),
                    getOrderTotalItem(
                      title: "→ 부가세",
                      value: totalReceiptOrderList['totalVatPrice'],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      height: 1,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: GlobalColor.bk05, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            '결제 정보',
                            style: GlobalTextStyle.body01.copyWith(
                              color: GlobalColor.bk01,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...receiptPaymentList.map(
                      (item) => getPaymentInfoItem(item),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    // 오후/오전을 처리하는 AM/PM 표시와 함께 포맷
    String formattedTime = DateFormat(
      'yyyy-MM-dd a hh:mm',
      'ko',
    ).format(dateTime);

    // '오전'을 'AM', '오후'를 'PM'으로 변환
    formattedTime = formattedTime.replaceAll('AM', '오전').replaceAll('PM', '오후');

    return formattedTime;
  }

  // 주문 정보 옵션 아이템
  Widget getOrderItem(item) {
    return Column(
      children: [
        if (item['prdTypeFlag'] == "0") const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${item['prdTypeFlag'] == "0" ? "" : "→"}${item['goodsNm']}',
                style: GlobalTextStyle.small01.copyWith(
                  color: GlobalColor.bk03,
                ),
              ),
            ),
            if (item['prdTypeFlag'] == "0")
              SizedBox(
                width: 40,
                child: Text(
                  'X ${item['saleQty'].toString()}',
                  style: GlobalTextStyle.small01,
                ),
              ),
            Container(
              width: 80,
              alignment: Alignment.centerRight,
              child: Text(
                CommonHelpers.stringParsePrice(
                  (item['salePrice'] ?? 0).toInt(),
                ),
                style: GlobalTextStyle.small01,
              ),
            ),
          ],
        ),
      ],
    );
  }

  //주문 정보 토탈 영역
  Widget getOrderTotalItem({required title, required value, bool? isPayment}) {
    Color textColor = GlobalColor.bk01;
    if (isPayment != null) {
      textColor = (value ?? 0).toInt() > 0
          ? GlobalColor.brand01
          : GlobalColor.bk03;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GlobalTextStyle.small01.copyWith(color: GlobalColor.bk03),
        ),
        Text(
          CommonHelpers.stringParsePrice((value ?? 0).toInt()),
          style: GlobalTextStyle.small01.copyWith(color: textColor),
        ),
      ],
    );
  }

  //포스 정보 위젯
  Widget posInfoItem({required title, required value}) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: GlobalTextStyle.small01.copyWith(color: GlobalColor.bk03),
          ),
        ),
        Text(value, style: GlobalTextStyle.small01),
      ],
    );
  }

  // 결제 정보 위젯
  Widget getPaymentInfoItem(item) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                PayTypeCode.fromCode(item['payTypeFlag'])!.desc,
                style: GlobalTextStyle.small01.copyWith(
                  color: GlobalColor.bk03,
                ),
              ),
            ),
            Text(
              CommonHelpers.stringParsePrice((item['payAmt'] ?? 0).toInt()),
              style: GlobalTextStyle.small01.copyWith(
                color: (item['payAmt'] ?? 0).toInt() > 0
                    ? GlobalColor.brand01
                    : GlobalColor.bk03,
              ),
            ),
          ],
        ),
        if (item['payMethodNo'] != null)
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  "정보",
                  style: GlobalTextStyle.small01.copyWith(
                    color: GlobalColor.bk03,
                  ),
                ),
              ),
              Text(
                '${item['payCorpNm'] != null ? item['payCorpNm'] + " ) " : ""}${item['payMethodNo']}',
                style: GlobalTextStyle.small01,
              ),
            ],
          ),
        if (item['apprNo'] != null)
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  "승인번호",
                  style: GlobalTextStyle.small01.copyWith(
                    color: GlobalColor.bk03,
                  ),
                ),
              ),
              Text(item['apprNo'], style: GlobalTextStyle.small01),
            ],
          ),
        const SizedBox(height: 15),
      ],
    );
  }
}
