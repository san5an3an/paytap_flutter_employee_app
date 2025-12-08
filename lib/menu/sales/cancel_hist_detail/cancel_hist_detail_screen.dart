import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/menu/sales/cancel_hist_detail/cancel_hist_detail_screen_model.dart';

class CancelHistDetailScreen extends ConsumerStatefulWidget {
  const CancelHistDetailScreen({super.key});

  @override
  ConsumerState<CancelHistDetailScreen> createState() =>
      _CancelHistDetailScreenState();
}

class _CancelHistDetailScreenState
    extends ConsumerState<CancelHistDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화 (한 번만 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(cancelHistDetailScreenModelProvider.notifier);
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;

      if (extra != null) {
        vm.initializeData(context, extra);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cancelHistDetailScreenModelProvider);
    final vm = ref.read(cancelHistDetailScreenModelProvider.notifier);

    return Layout(
      title: state.title,
      isDisplayBottomNavigationBar: false,
      children: SingleChildScrollView(
        child: Column(
          children: [
            if (state.isLoading)
              const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!state.isLoading && state.isInitialized)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        ...state.cancelHistDetailList.asMap().entries.map(
                          (entry) => getCancelHistDetailItem(
                            entry.value,
                            isFirst: entry.key == 0,
                            isLast:
                                entry.key ==
                                state.cancelHistDetailList.length - 1,
                          ),
                        ),
                        // 구분선
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: DottedLine(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.center,
                            lineLength: double.infinity,
                            lineThickness: 1.0,
                            dashLength: 4.0,
                            dashColor: GlobalColor.bk05,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "주문 금액",
                              style: GlobalTextStyle.small01.copyWith(
                                color: GlobalColor.bk03,
                              ),
                            ),
                            Text(
                              vm.getFormattedPrice('orderPrice'),
                              style: GlobalTextStyle.small01,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "할인",
                              style: GlobalTextStyle.small01.copyWith(
                                color: GlobalColor.bk03,
                              ),
                            ),
                            Text(
                              vm.getFormattedPrice('totDcAmt'),
                              style: GlobalTextStyle.small01,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "→ 가액",
                              style: GlobalTextStyle.small01.copyWith(
                                color: GlobalColor.bk03,
                              ),
                            ),
                            Text(
                              vm.getFormattedPrice('vatMinusPrice'),
                              style: GlobalTextStyle.small01,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "→ 부가세",
                              style: GlobalTextStyle.small01.copyWith(
                                color: GlobalColor.bk03,
                              ),
                            ),
                            Text(
                              vm
                                  .getFormattedPrice('totVatPrice')
                                  .replaceAll('원', ''),
                              style: GlobalTextStyle.small01,
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 15),
                          child: Divider(
                            color: GlobalColor.bk05,
                            thickness: 1,
                            height: 1,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "총 취소금액",
                              style: GlobalTextStyle.small01.copyWith(
                                color: GlobalColor.bk03,
                              ),
                            ),
                            Text(
                              "-${vm.getFormattedPrice('orderPrice')}",
                              style: GlobalTextStyle.small01,
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 15),
                          child: Divider(
                            color: GlobalColor.bk05,
                            thickness: 1,
                            height: 1,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "취소 사유",
                              style: GlobalTextStyle.small01.copyWith(
                                color: GlobalColor.bk03,
                              ),
                            ),
                            Text("", style: GlobalTextStyle.small01),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget getCancelHistDetailItem(
    Map<String, dynamic> item, {
    required bool isFirst,
    required bool isLast,
  }) {
    return Container(
      padding: EdgeInsets.only(top: isFirst ? 0 : 15, bottom: isLast ? 0 : 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 210,
                child: Text(
                  item['prdNm'],
                  style: GlobalTextStyle.small01.copyWith(
                    color: GlobalColor.bk03,
                  ),
                ),
              ),
              Expanded(
                flex: 40,
                child: Text(
                  "X ${item['saleQty']}",
                  textAlign: TextAlign.center,
                  style: GlobalTextStyle.small01,
                ),
              ),
              Expanded(
                flex: 80,
                child: Text(
                  CommonHelpers.stringParsePrice(
                    double.parse(item['salePrice']).toInt(),
                  ),
                  textAlign: TextAlign.end,
                  style: GlobalTextStyle.small01,
                ),
              ),
            ],
          ),
          if (item['optItems'] != null)
            ...item['optItems'].map(
              (optItem) => getCancelHistDetailOptItem(optItem),
            ),
        ],
      ),
    );
  }
}

Widget getCancelHistDetailOptItem(Map<String, dynamic> item) {
  return Row(
    children: [
      Expanded(
        flex: 210,
        child: Text(
          "→ ${item['prdNm']}",
          style: GlobalTextStyle.small01.copyWith(color: GlobalColor.bk03),
        ),
      ),
      Expanded(
        flex: 40,
        child: Text(
          item['saleQty'] > 1 ? "X ${item['saleQty']}" : "",
          textAlign: TextAlign.center,
          style: GlobalTextStyle.small01,
        ),
      ),
      Expanded(
        flex: 80,
        child: Text(
          CommonHelpers.stringParsePrice(
            double.parse(item['salePrice']).toInt(),
          ),
          textAlign: TextAlign.end,
          style: GlobalTextStyle.small01,
        ),
      ),
    ],
  );
}
