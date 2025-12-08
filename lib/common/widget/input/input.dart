import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class Input extends StatefulWidget {
  final int maxLength;
  final String placeholder;
  final String value;
  final String name;
  final String errorText;
  final bool disabled;
  final bool isObscureText;

  final Widget? leftIcon;
  final Widget? rightIcon;
  final FocusNode? textFocus;
  final void Function(String, dynamic)? onChange;
  final void Function(String)? onSubmitted;
  const Input({
    super.key,
    this.maxLength = 20,
    this.placeholder = '',
    this.name = '',
    this.disabled = false,
    this.value = '',
    this.errorText = '',
    this.leftIcon,
    this.rightIcon,
    this.isObscureText = false,
    this.onChange,
    this.onSubmitted,
    this.textFocus,
  });

  @override
  InputState createState() => InputState();
}

class InputState extends State<Input> {
  String errorText = '';
  late TextEditingController _textController;
  bool _isPasswordVisible = false;

  FocusNode textFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.textFocus != null) {
      textFocus = widget.textFocus!;
    }
    _textController = TextEditingController(text: widget.value);
    _textController.addListener(() {
      if (widget.onChange != null) {
        widget.onChange!(
          widget.name,
          _textController.text,
        ); // 부모 위젯으로 변경된 값을 전달
      }
    });
    errorText = widget.errorText;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// 비밀번호 표시/숨김 토글 메서드
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  /// 비밀번호 숨김/표시 아이콘 위젯
  Widget _passwordVisibilityIcon() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _togglePasswordVisibility,
        borderRadius: BorderRadius.all(Radius.circular(100)),
        splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
        highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
        child: Icon(
          _isPasswordVisible ? Symbols.visibility : Symbols.visibility_off,
          color: GlobalColor.bk03,
          fill: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        obscureText: widget.isObscureText && !_isPasswordVisible,
        textInputAction: TextInputAction.next,
        controller: _textController,
        focusNode: textFocus,
        onTapOutside: (event) {
          textFocus.unfocus();
        },
        onChanged: (text) {},
        onSubmitted: widget.onSubmitted,
        style: GlobalTextStyle.body01.copyWith(color: GlobalColor.bk01),
        maxLength: widget.maxLength,
        decoration: InputDecoration(
          isDense: true,
          labelText: widget.placeholder,
          labelStyle: GlobalTextStyle.body01.copyWith(color: GlobalColor.bk04),
          prefixIcon: widget.leftIcon,
          prefixIconConstraints: const BoxConstraints.expand(
            width: 50,
            height: 50,
          ),
          suffixIcon: widget.isObscureText
              ? _passwordVisibilityIcon()
              : widget.rightIcon,
          suffixIconConstraints: const BoxConstraints.expand(
            width: 50,
            height: 50,
          ),
          enabled: !widget.disabled,
          fillColor: widget.disabled ? GlobalColor.bk06 : GlobalColor.bk08,
          filled: true,
          disabledBorder: _getOutlineInputBorder(GlobalColor.bk05),
          border: InputBorder.none,
          isCollapsed: true,
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: _getOutlineInputBorder(GlobalColor.brand01),
          contentPadding: const EdgeInsets.all(15),
          errorText: errorText.isNotEmpty ? errorText : null,
          errorBorder: _getOutlineInputBorder(GlobalColor.systemRed),
          focusedErrorBorder: _getOutlineInputBorder(GlobalColor.systemRed),
        ),
      ),
    );
  }

  OutlineInputBorder _getOutlineInputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: color, width: 2),
    );
  }
}
