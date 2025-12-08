import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 검색 컴포넌트의 상태 모델
class CmSearchState {
  final Map<String, dynamic> searchState;
  final bool isInitialized;
  final Map<String, dynamic> tempState;

  const CmSearchState({
    this.searchState = const {},
    this.isInitialized = false,
    this.tempState = const {},
  });

  CmSearchState copyWith({
    Map<String, dynamic>? searchState,
    bool? isInitialized,
    Map<String, dynamic>? tempState,
  }) {
    return CmSearchState(
      searchState: searchState ?? this.searchState,
      isInitialized: isInitialized ?? this.isInitialized,
      tempState: tempState ?? this.tempState,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class CmSearchModel extends Notifier<CmSearchState> {
  @override
  CmSearchState build() {
    return const CmSearchState();
  }

  /// 모달이 열릴 때 초기 상태 설정
  void initializeState(Map<String, dynamic> initialState) {
    if (!state.isInitialized) {
      Map<String, dynamic> newSearchState;

      // tempState 값이 있으면 searchState와 합쳐서 초기화
      if (state.tempState.isNotEmpty) {
        newSearchState = Map<String, dynamic>.from(initialState);
        newSearchState.addAll(state.tempState);
      } else {
        newSearchState = Map<String, dynamic>.from(initialState);
      }

      state = state.copyWith(
        searchState: newSearchState,
        isInitialized: true,
      );
    }
  }

  // 검색 조건 set함수
  void setSearchState({required String name, required String value}) {
    final updatedSearchState = Map<String, dynamic>.from(state.searchState);
    updatedSearchState[name] = value;
    state = state.copyWith(searchState: updatedSearchState);
  }

  // 달력 선택 set함수
  void setTempState({required String name, required String value}) {
    print("setTempState: $name, $value");
    final updatedTempState = Map<String, dynamic>.from(state.tempState);
    updatedTempState[name] = value;
    state = state.copyWith(tempState: updatedTempState);
  }

  // 달력 선택 값 초기화
  void clearTempState() {
    state = state.copyWith(tempState: {});
  }
}

/// Riverpod 3.0.3 - NotifierProvider.autoDispose.family (권장)
final cmSearchModelProvider =
    NotifierProvider.autoDispose.family<CmSearchModel, CmSearchState, String>(
  (ref) => CmSearchModel(),
);
