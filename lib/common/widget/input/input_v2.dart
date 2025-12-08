import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/input/data/input_v2_model.dart';

class InputV2 extends ConsumerStatefulWidget {
  final String? value;
  final String name;
  final String? labelText;
  final String errorText;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final bool isObscureText;
  final bool isClearIcon;
  final FocusNode? textFocus;
  final void Function(String, dynamic)? onChange;
  final void Function(String)? onSubmitted;

  const InputV2({
    super.key,
    required this.value,
    required this.name,
    this.labelText,
    this.errorText = "",
    this.leftIcon,
    this.rightIcon,
    this.isObscureText = false,
    this.isClearIcon = false,
    this.textFocus,
    this.onChange,
    this.onSubmitted,
  });

  @override
  ConsumerState<InputV2> createState() => _InputV2State();
}

class _InputV2State extends ConsumerState<InputV2> {
  @override
  void initState() {
    super.initState();
    // 초기화 (한 번만 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(inputV2ViewModelProvider(widget.name).notifier);
      final state = ref.read(inputV2ViewModelProvider(widget.name));
      if (!state.isInitialized) {
        vm.initInputV2Settings(
          value: widget.value,
          name: widget.name,
          textFocus: widget.textFocus,
          onChange: widget.onChange,
          isObscureText: widget.isObscureText,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inputV2ViewModelProvider(widget.name));
    final vm = ref.read(inputV2ViewModelProvider(widget.name).notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: GlobalColor.bk08,
            borderRadius: BorderRadius.circular(16),
            border: getInputBorder(state, widget.errorText),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: state.controller,
                  focusNode: state.textFocus,
                  obscureText: state.isObscureText && !state.isPasswordVisible,
                  obscuringCharacter: '*',
                  onTapOutside: (event) {
                    vm.onTapOutside();
                  },
                  onSubmitted: widget.onSubmitted,
                  style: GlobalTextStyle.body01.copyWith(
                    color: getInputFontColor(state, widget.errorText),
                  ),
                  decoration: InputDecoration(
                    labelText: widget.labelText,
                    labelStyle: GlobalTextStyle.body01.copyWith(
                      color:
                          state.textFocus.hasFocus ||
                              state.controller.text.isNotEmpty
                          ? GlobalColor.bk01
                          : GlobalColor.bk04,
                    ),
                    border: InputBorder.none,
                    focusColor: GlobalColor.brand01,
                    prefixIcon: widget.leftIcon,
                    prefixIconConstraints: const BoxConstraints.expand(
                      width: 50,
                      height: 50,
                    ),
                    suffixIcon:
                        widget.isClearIcon && state.controller.text != ""
                        ? _clearIcon(vm, widget.name, widget.onChange)
                        : widget.rightIcon,
                    suffixIconConstraints: const BoxConstraints.expand(
                      width: 50,
                      height: 50,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                  ),
                ),
              ),
              if (widget.value != "")
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: _passwordVisibilityIcon(vm, state),
                ),
            ],
          ),
        ),
        if (widget.errorText != "" &&
            state.isVisibleErrorText &&
            state.hasBeenFocused) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              widget.errorText,
              style: GlobalTextStyle.small02.copyWith(
                color: GlobalColor.systemRed,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _clearIcon(
    InputV2ViewModel vm,
    String name,
    void Function(String, dynamic)? onChange,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          vm.onTapClearIcon();
        },
        borderRadius: BorderRadius.all(Radius.circular(100)),
        splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
        highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
        child: Icon(Symbols.cancel_rounded, color: GlobalColor.bk03, fill: 1),
      ),
    );
  }

  /// 비밀번호 표시/숨김 아이콘 위젯
  Widget _passwordVisibilityIcon(InputV2ViewModel vm, InputV2State state) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          vm.togglePasswordVisibility();
        },
        borderRadius: BorderRadius.all(Radius.circular(100)),
        splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
        highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
        child: Icon(
          state.isPasswordVisible ? Symbols.visibility : Symbols.visibility_off,
          color: GlobalColor.bk03,
          fill: 0,
        ),
      ),
    );
  }
}

Color getInputFontColor(InputV2State state, String errorText) {
  if (errorText != "" && state.isVisibleErrorText && state.hasBeenFocused) {
    return GlobalColor.systemRed;
  }
  if (state.textFocus.hasFocus) {
    return GlobalColor.brand01;
  }
  return GlobalColor.bk01;
}

Border getInputBorder(InputV2State state, String errorText) {
  if (!state.textFocus.hasFocus &&
      errorText != "" &&
      state.isVisibleErrorText &&
      state.hasBeenFocused) {
    return Border.all(color: GlobalColor.systemRed, width: 1);
  }
  if (state.textFocus.hasFocus &&
      errorText != "" &&
      state.isVisibleErrorText &&
      state.hasBeenFocused) {
    return Border.all(color: GlobalColor.systemRed, width: 2);
  }
  if (state.textFocus.hasFocus) {
    return Border.all(color: GlobalColor.brand01, width: 2);
  }
  return Border.all(color: GlobalColor.bk04, width: 1);
}
