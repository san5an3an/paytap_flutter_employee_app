import 'package:flutter/material.dart';
import 'package:paytap_app/common/services/statistics_service.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

class DcTypeSalesDetailViewModal with ChangeNotifier {
  List<dynamic> orderList = [];

  Map<String, dynamic> goodsDetail = {};
  List optInfoList = [];
  double optTotalPrice = 0;

  //데이터 조회 하는 함수
  Future<void> getGoodsSalesDetail(context, data) async {
    Map<String, dynamic> res = await StatisticsService.getAppRankGoodsDetail(
      data,
    );
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }

    goodsDetail = res['results']['goodsDetail'];

    optInfoList = convertOptInfoList(res['results']['optInfo']);

    notifyListeners();
  }

  List<Map<String, dynamic>> convertOptInfoList(list) {
    for (var item in list) {
      optTotalPrice += item['dcmSalePrice'];
    }
    Map<String, List<Map<String, dynamic>>> groupedByOptGrpNm =
        CommonHelpers.grouyByList(list, 'optGrpNm');

    // 결과 출력
    List<Map<String, dynamic>> resultList = [];
    groupedByOptGrpNm.forEach((groupNm, groupItem) {
      Map<String, dynamic> totalData = {'groupNm': groupNm, 'child': groupItem};

      resultList.add(totalData);
    });

    return resultList;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: '오류',
          content: message,
          confirmBtnLabel: '확인',
        );
      },
    );
  }
}
