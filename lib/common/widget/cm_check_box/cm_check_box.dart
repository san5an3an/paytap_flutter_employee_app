import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class CmCheckBox extends StatelessWidget {
  final String label;
  final String name;
  final bool? value;
  final void Function(String, dynamic) onTapCheckBox;

  const CmCheckBox({
    super.key,
    this.name = '',
    this.label = '',
    required this.value,
    required this.onTapCheckBox,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (value) {
            onTapCheckBox(name, value);
          },
          tristate: true,
          checkColor: GlobalColor.rev01,
          activeColor: GlobalColor.brand01,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: const BorderSide(color: GlobalColor.bk03, width: 2),
        ),
        Text(label, style: GlobalTextStyle.small01),
      ],
    );
  }
}
