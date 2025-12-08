import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class HeadlineAccount extends StatelessWidget {
  final String phone;
  final String storeNm;
  final String roadnmAdres;
  final String detailAdres;
  const HeadlineAccount({
    super.key,
    this.storeNm = '',
    this.roadnmAdres = '',
    this.detailAdres = '',
    this.phone = '000-0000-0000',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: GlobalColor.bk08,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              storeNm,
              style: GlobalTextStyle.body02.copyWith(
                color: GlobalColor.bk01,
                fontWeight: FontWeight.w500,
              ),
            ),
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
          Text(
            '대표 연락처 : $phone',
            style: GlobalTextStyle.small01.copyWith(color: GlobalColor.bk02),
          ),
          Text(
            '주소 : $roadnmAdres',
            style: GlobalTextStyle.small01.copyWith(color: GlobalColor.bk02),
          ),
          Text(
            detailAdres,
            style: GlobalTextStyle.small01.copyWith(color: GlobalColor.bk02),
          ),
        ],
      ),
    );
  }
}
