import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/menu/sales/goods_detail/goods_detail_screen_modal.dart';

class GoodsDetailScreen extends ConsumerStatefulWidget {
  const GoodsDetailScreen({super.key});

  @override
  ConsumerState<GoodsDetailScreen> createState() => _GoodsDetailScreenState();
}

class _GoodsDetailScreenState extends ConsumerState<GoodsDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화 (한 번만 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      print('Route extra: $extra');
      if (extra != null) {
        final vm = ref.read(goodsDetailScreenModelProvider.notifier);
        final state = ref.read(goodsDetailScreenModelProvider);
        if (!state.isInitialized && !state.isLoading) {
          vm.initializeData(context, extra);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goodsDetailScreenModelProvider);
    Map<String, dynamic> goodsDetail = state.goodsDetail;
    List optInfoList = state.optInfoList;

    return Layout(
      title: '${goodsDetail['goodsNm'] ?? ''}',
      isDisplayBottomNavigationBar: false,
      children: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            if (state.isLoading)
              const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!state.isLoading && state.isInitialized)
              Column(
                children: [
                  goodsInfoItem(
                    title: "분류",
                    value:
                        '${goodsDetail['highCtgNm']} ${goodsDetail['midCtgNm'] != null ? '> ${goodsDetail['lowCtgNm']}' : ""} ${goodsDetail['lowCtgNm'] != null ? '> ${goodsDetail['lowCtgNm']}' : ""}',
                  ),
                  goodsInfoItem(
                    title: "상품명",
                    value: goodsDetail['goodsNm'] ?? '-',
                  ),
                  goodsInfoItem(
                    title: "상품Code",
                    value: goodsDetail['storeGcode'] ?? '-',
                  ),
                  const SizedBox(height: 15),
                  goodsInfoItem(
                    title: "판매수량",
                    value: goodsDetail['saleQty'] != null
                        ? '${goodsDetail['saleQty']}개'
                        : '-',
                  ),
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
                  goodsInfoTotalItem(
                    title: "매출",
                    value: goodsDetail['salePrice'],
                  ),
                  goodsInfoTotalItem(
                    title: "할인",
                    value: goodsDetail['dcPrice'],
                  ),
                  goodsInfoTotalItem(
                    title: "실매출",
                    value: goodsDetail['dcmSalePrice'],
                    isDcmSalePrice: true,
                  ),
                  goodsInfoTotalItem(
                    title: "→ 상품가",
                    value:
                        goodsDetail['dcmSalePrice'] -
                        goodsDetail['optDcmSaleAmt'],
                  ),
                  goodsInfoTotalItem(
                    title: "→ 옵션가",
                    value: goodsDetail['optDcmSaleAmt'],
                  ),
                  const SizedBox(height: 30),
                  if (optInfoList.isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 1,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: GlobalColor.bk03, width: 1),
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                  if (optInfoList.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '옵션 정보',
                          style: GlobalTextStyle.body01.copyWith(
                            color: GlobalColor.bk01,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ...optInfoList.asMap().entries.map((entry) {
                    int index = entry.key; // 인덱스
                    var item = entry.value; // 실제 요소
                    bool isLast = optInfoList.length - 1 == index
                        ? true
                        : false;
                    return getOrderItem(item, isLast);
                  }),
                  const SizedBox(height: 15),
                  if (optInfoList.isNotEmpty)
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
                  if (optInfoList.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '총계',
                            style: GlobalTextStyle.small01.copyWith(
                              color: GlobalColor.bk03,
                            ),
                          ),
                        ),
                        Container(
                          width: 80,
                          alignment: Alignment.centerRight,
                          child: Text(
                            CommonHelpers.stringParsePrice(
                              state.optTotalPrice.toInt(),
                            ),
                            style: GlobalTextStyle.small01.copyWith(
                              color: state.optTotalPrice.toInt() > 0
                                  ? GlobalColor.brand01
                                  : GlobalColor.bk03,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 30),
                ],
              ),
          ],
        ),
      ),
    );
  }

  //상품 정보 위젯
  Widget goodsInfoItem({required title, required value}) {
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

  // 옵션 정보 옵션 아이템
  Widget goodsInfoTotalItem({
    required title,
    required value,
    bool? isDcmSalePrice,
  }) {
    Color textColor = GlobalColor.bk01;
    if (isDcmSalePrice != null) {
      textColor = value.toInt() > 0 ? GlobalColor.brand01 : GlobalColor.bk03;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: GlobalTextStyle.small01.copyWith(
                  color: GlobalColor.bk03,
                ),
              ),
            ),
            Container(
              width: 80,
              alignment: Alignment.centerRight,
              child: Text(
                CommonHelpers.stringParsePrice(value.toInt() ?? 0),
                style: GlobalTextStyle.small01.copyWith(color: textColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 옵션 정보 옵션 아이템
  Widget getOrderItem(data, isLast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(data['groupNm']),
        const SizedBox(height: 15),
        ...data['child'].map(
          (item) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${item['optINm']}',
                  style: GlobalTextStyle.small01.copyWith(
                    color: GlobalColor.bk03,
                  ),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  'X ${item['saleQty'].toString()}',
                  style: GlobalTextStyle.small01,
                ),
              ),
              Container(
                width: 80,
                alignment: Alignment.centerRight,
                child: Text(
                  CommonHelpers.stringParsePrice(item['dcmSalePrice'].toInt()),
                  style: GlobalTextStyle.small01,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        if (!isLast)
          DottedLine(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            lineLength: double.infinity,
            lineThickness: 1.0,
            dashLength: 4.0,
            dashColor: GlobalColor.bk03,
          ),
        const SizedBox(height: 15),
      ],
    );
  }
}
