import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class AmountTitle extends StatelessWidget {
  final String saleDe;
  const AmountTitle({super.key, required this.saleDe});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              DateHelpers.getYYYYMMDDKR(saleDe),
              style: GlobalTextStyle.small01.copyWith(color: GlobalColor.bk03),
            ),
          ),
        ],
      ),
    );
  }
}
