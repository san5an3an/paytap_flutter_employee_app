import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paytap_app/common/models/c_option.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class Dropdown extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;
  final List<COption> options;
  const Dropdown({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: DropdownButtonFormField(
        isExpanded: true,
        isDense: false,
        itemHeight: 50,
        focusColor: Colors.transparent,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: GlobalColor.bk05, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: GlobalColor.bk05, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: GlobalColor.bk05, width: 1),
          ),
          contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 15),
        ),
        value: value,
        items: options.map((item) {
          return DropdownMenuItem(
            value: item.value,
            child: Text(
              item.title,
              style: GlobalTextStyle.body02,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          onChanged(value!);
        },
        icon: SvgPicture.asset('assets/icons/i_Select.svg'),
      ),
    );
  }
}
