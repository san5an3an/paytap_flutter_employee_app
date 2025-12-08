import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 날짜/시간 선택 모달의 상태 모델
class DateTimeBottomState {
  final Map<String, dynamic> initState;
  final Map<String, dynamic> tempState;
  final bool isInitialized;

  const DateTimeBottomState({
    this.initState = const {},
    this.tempState = const {},
    this.isInitialized = false,
  });

  DateTimeBottomState copyWith({
    Map<String, dynamic>? initState,
    Map<String, dynamic>? tempState,
    bool? isInitialized,
  }) {
    return DateTimeBottomState(
      initState: initState ?? this.initState,
      tempState: tempState ?? this.tempState,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class DateTimeBottomModel extends Notifier<DateTimeBottomState> {
  @override
  DateTimeBottomState build() {
    return const DateTimeBottomState();
  }

  /// 모달이 열릴 때 초기 상태 설정
  void initializeState(String name, String value) {
    if (!state.isInitialized) {
      final updatedInitState = Map<String, dynamic>.from(state.initState);
      final updatedTempState = Map<String, dynamic>.from(state.tempState);
      updatedInitState[name] = value;
      updatedTempState[name] = value;

      state = state.copyWith(
        initState: updatedInitState,
        tempState: updatedTempState,
        isInitialized: true,
      );
    }
  }

  void setTempState({required String name, required String value}) {
    final updatedTempState = Map<String, dynamic>.from(state.tempState);
    updatedTempState[name] = value;
    state = state.copyWith(tempState: updatedTempState);
  }

  void clearTempState() {
    state = state.copyWith(tempState: {});
  }
}

/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final dateTimeBottomModelProvider =
    NotifierProvider.autoDispose<DateTimeBottomModel, DateTimeBottomState>(
  DateTimeBottomModel.new,
);
