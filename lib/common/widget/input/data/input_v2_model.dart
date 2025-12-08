import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// InputV2 컴포넌트의 상태 모델
class InputV2State {
  final TextEditingController controller;
  final FocusNode textFocus;
  final bool isObscureText;
  final bool isPasswordVisible;
  final bool isInitialized;
  final bool isVisibleErrorText;
  final bool hasBeenFocused;
  final String name;
  final void Function(String, dynamic)? onChange;

  const InputV2State({
    required this.controller,
    required this.textFocus,
    this.isObscureText = false,
    this.isPasswordVisible = false,
    this.isInitialized = false,
    this.isVisibleErrorText = false,
    this.hasBeenFocused = false,
    this.name = '',
    this.onChange,
  });

  InputV2State copyWith({
    TextEditingController? controller,
    FocusNode? textFocus,
    bool? isObscureText,
    bool? isPasswordVisible,
    bool? isInitialized,
    bool? isVisibleErrorText,
    bool? hasBeenFocused,
    String? name,
    void Function(String, dynamic)? onChange,
  }) {
    return InputV2State(
      controller: controller ?? this.controller,
      textFocus: textFocus ?? this.textFocus,
      isObscureText: isObscureText ?? this.isObscureText,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isInitialized: isInitialized ?? this.isInitialized,
      isVisibleErrorText: isVisibleErrorText ?? this.isVisibleErrorText,
      hasBeenFocused: hasBeenFocused ?? this.hasBeenFocused,
      name: name ?? this.name,
      onChange: onChange ?? this.onChange,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class InputV2ViewModel extends Notifier<InputV2State> {
  VoidCallback? _textChangedListener;
  VoidCallback? _focusChangedListener;

  @override
  InputV2State build() {
    // dispose 콜백 등록
    ref.onDispose(() {
      if (_textChangedListener != null) {
        state.controller.removeListener(_textChangedListener!);
      }
      if (_focusChangedListener != null) {
        state.textFocus.removeListener(_focusChangedListener!);
      }
      state.controller.dispose();
      state.textFocus.dispose();
    });

    return InputV2State(
      controller: TextEditingController(),
      textFocus: FocusNode(),
    );
  }

  /// InputV2ViewModel 초기화 메서드
  /// 전달받은 모든 키워드들을 설정
  void initInputV2Settings({
    required String? value,
    required String name,
    FocusNode? textFocus,
    bool isObscureText = false,
    void Function(String, dynamic)? onChange,
  }) {
    if (!state.isInitialized) {
      if (value != null) {
        state.controller.text = value;
      }

      final newTextFocus = textFocus ?? FocusNode();

      // 기존 리스너 제거
      if (_textChangedListener != null) {
        state.controller.removeListener(_textChangedListener!);
      }
      if (_focusChangedListener != null) {
        state.textFocus.removeListener(_focusChangedListener!);
      }

      // 새로운 리스너 추가
      _textChangedListener = _onTextChanged;
      _focusChangedListener = _onFocusChanged;
      state.controller.addListener(_textChangedListener!);
      newTextFocus.addListener(_focusChangedListener!);

      state = state.copyWith(
        name: name,
        textFocus: newTextFocus,
        onChange: onChange,
        isObscureText: isObscureText,
        isInitialized: true,
        hasBeenFocused: false,
      );
    }
  }

  /// 텍스트 변경 시 onChange 콜백 실행
  void _onTextChanged() {
    if (state.onChange != null) {
      state.onChange!(state.name, state.controller.text);
    }
    // 최초 포커스 이후에만 에러 텍스트 표시
    if (state.hasBeenFocused) {
      state = state.copyWith(isVisibleErrorText: true);
    }
  }

  // 클리어 아이콘 클릭
  void onTapClearIcon() {
    state.controller.clear();
    if (state.onChange != null) {
      state.onChange!(state.name, "");
    }
    // 클리어 시에도 최초 포커스 이후에만 에러 텍스트 표시
    if (state.hasBeenFocused) {
      state = state.copyWith(isVisibleErrorText: false);
    }
  }

  // 텍스트 focus 헤제
  void onTapOutside() {
    state.textFocus.unfocus();
    // 포커스 해제 시에도 최초 포커스 이후에만 에러 텍스트 표시
    if (state.hasBeenFocused) {
      state = state.copyWith(isVisibleErrorText: true);
    }
  }

  /// 포커스 상태 변경 시 UI 업데이트
  void _onFocusChanged() {
    // 포커스를 받았을 때 최초 포커스 플래그 설정
    if (state.textFocus.hasFocus && !state.hasBeenFocused) {
      state = state.copyWith(hasBeenFocused: true);
    }
  }

  /// 비밀번호 표시/숨김 토글
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }
}

/// InputV2ViewModel Provider 팩토리
/// 각 InputV2 위젯마다 고유한 ViewModel 인스턴스를 생성
/// Riverpod 3.0.3 - NotifierProvider.autoDispose.family (권장)
final inputV2ViewModelProvider =
    NotifierProvider.autoDispose.family<InputV2ViewModel, InputV2State, String>(
  (ref) => InputV2ViewModel(),
);
