import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';

class SwitchButton extends StatelessWidget {
  final void Function(String, dynamic)? onChange;
  final String name;
  final bool value;

  const SwitchButton({
    super.key,
    this.name = '',
    this.value = false,
    this.onChange,
  });

  static const WidgetStateProperty<Icon> thumbIcon =
      WidgetStateProperty<Icon>.fromMap(<WidgetStatesConstraint, Icon>{
        WidgetState.selected: Icon(Icons.check),
        WidgetState.any: Icon(Icons.close),
      });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: (val) {
        if (onChange != null) {
          onChange!(name, val);
        }
      },
      thumbIcon: thumbIcon,
      trackOutlineColor: WidgetStateProperty.all(
        value ? GlobalColor.brand01 : GlobalColor.bk03,
      ),
      activeColor: GlobalColor.bk08,
      activeTrackColor: GlobalColor.brand01,
      inactiveThumbColor: GlobalColor.bk03,
      inactiveTrackColor: GlobalColor.bk05,
    );
  }
}
