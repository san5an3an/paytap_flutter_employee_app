import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/bottom_modal/bottom_modal.dart';
import 'package:paytap_app/menu/sales/dc_type_sales/view_models/dc_type_sales_detail_view_modal.dart';

class DcTypeSalesDetailModal extends StatefulWidget {
  final Map<String, dynamic> data;
  const DcTypeSalesDetailModal({super.key, required this.data});

  @override
  State<DcTypeSalesDetailModal> createState() => _DcTypeSalesDetailModalState();
}

class _DcTypeSalesDetailModalState extends State<DcTypeSalesDetailModal> {
  final DcTypeSalesDetailViewModal _vm = DcTypeSalesDetailViewModal();
  bool isLoading = false;

  DateTime dateTime = DateTime.now();
  int orderTotalPrice = 0;

  @override
  void initState() {
    super.initState();
    getDealHistoryDetailData(context, widget.data);
  }

  Future<void> getDealHistoryDetailData(context, data) async {
    setState(() {
      isLoading = true;
    });
    try {
      await _vm.getGoodsSalesDetail(context, data);
    } catch (e) {
      print('Error loading more data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> goodsDetail = _vm.goodsDetail;
    List optInfoList = _vm.optInfoList;

    return BottomModal(
      content: [
        if (isLoading)
          const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
        if (!isLoading)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      '${goodsDetail['goodsNm']}',
                      style: GlobalTextStyle.title02.copyWith(
                        color: GlobalColor.bk01,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              goodsInfoItem(
                title: "분류",
                value:
                    '${goodsDetail['highCtgNm']} ${goodsDetail['midCtgNm'] != null ? '> ${goodsDetail['lowCtgNm']}' : ""} ${goodsDetail['lowCtgNm'] != null ? '> ${goodsDetail['lowCtgNm']}' : ""}',
              ),
              goodsInfoItem(title: "상품명", value: goodsDetail['goodsNm']),
              goodsInfoItem(title: "상품Code", value: goodsDetail['storeGcode']),
              const SizedBox(height: 15),
              goodsInfoItem(title: "판매수량", value: '${goodsDetail['saleQty']}개'),
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
                value: CommonHelpers.stringParsePrice(
                  goodsDetail['salePrice'].toInt(),
                ),
              ),
              goodsInfoTotalItem(
                title: "할인",
                value: CommonHelpers.stringParsePrice(
                  goodsDetail['dcPrice'].toInt(),
                ),
              ),
              goodsInfoTotalItem(
                title: "실매출",
                value: CommonHelpers.stringParsePrice(
                  goodsDetail['dcmSalePrice'].toInt(),
                ),
                isBlue: true,
              ),
              goodsInfoTotalItem(
                title: "→ 상품가",
                value: CommonHelpers.stringParsePrice(
                  (goodsDetail['dcmSalePrice'] - goodsDetail['optDcmSaleAmt'])
                      .toInt(),
                ),
              ),
              goodsInfoTotalItem(
                title: "→ 옵션가",
                value: CommonHelpers.stringParsePrice(
                  goodsDetail['optDcmSaleAmt'].toInt(),
                ),
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
                bool isLast = optInfoList.length - 1 == index ? true : false;
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
                          _vm.optTotalPrice.toInt(),
                        ),
                        style: GlobalTextStyle.small01.copyWith(
                          color: GlobalColor.brand01,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),
            ],
          ),
      ],
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
  Widget goodsInfoTotalItem({required title, required value, isBlue = false}) {
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
                value,
                style: GlobalTextStyle.small01.copyWith(
                  color: isBlue ? GlobalColor.brand01 : GlobalColor.bk01,
                ),
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
