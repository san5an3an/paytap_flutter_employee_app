import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/constants/menu_list.dart';

/// 매출 홈 화면의 상태 모델
class SalesHomeState {
  final Map<String, dynamic>? selectedItem;
  final bool isAnimatingOut;
  final bool isAnimatingIn;

  const SalesHomeState({
    this.selectedItem,
    this.isAnimatingOut = false,
    this.isAnimatingIn = false,
  });

  SalesHomeState copyWith({
    Map<String, dynamic>? Function()? selectedItem,
    bool? isAnimatingOut,
    bool? isAnimatingIn,
  }) {
    return SalesHomeState(
      selectedItem: selectedItem != null ? selectedItem() : this.selectedItem,
      isAnimatingOut: isAnimatingOut ?? this.isAnimatingOut,
      isAnimatingIn: isAnimatingIn ?? this.isAnimatingIn,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class SalesHomeScreenModel extends Notifier<SalesHomeState> {
  // 기본 아이템 목록 (초기값)
  final List<Map<String, dynamic>> _defaultItems = MenuList.salesList;

  @override
  SalesHomeState build() {
    return const SalesHomeState();
  }

  /// 선택된 아이템을 설정하는 메서드
  void setSelectedItem(Map<String, dynamic>? item) {
    // 이미 선택된 아이템이 있고, 다른 아이템을 선택하는 경우
    if (state.selectedItem != null && state.selectedItem != item) {
      // 먼저 현재 아이템을 닫고, 그 다음에 새로운 아이템을 열기
      state = state.copyWith(isAnimatingOut: true, isAnimatingIn: false);

      // 현재 아이템 닫기 애니메이션 완료 후 새로운 아이템 설정
      Future.delayed(const Duration(milliseconds: 300), () {
        state = state.copyWith(
          selectedItem: () => item,
          isAnimatingOut: false,
          isAnimatingIn: true,
        );

        // 새로운 아이템 열기 애니메이션 완료 후 상태 정리
        Future.delayed(const Duration(milliseconds: 300), () {
          state = state.copyWith(isAnimatingIn: false);
        });
      });
    } else {
      // 처음 선택하거나 같은 아이템을 다시 선택하는 경우
      state = state.copyWith(
        selectedItem: () => item,
        isAnimatingOut: false,
        isAnimatingIn: true,
      );

      // 애니메이션 완료 후 상태 정리
      Future.delayed(const Duration(milliseconds: 300), () {
        state = state.copyWith(isAnimatingIn: false);
      });
    }
  }

  /// 선택된 아이템을 초기화하는 메서드 (역방향 애니메이션)
  void clearSelectedItem() {
    state = state.copyWith(isAnimatingOut: true, isAnimatingIn: false);

    // 애니메이션 완료 후 실제로 아이템 제거
    Future.delayed(const Duration(milliseconds: 300), () {
      state = state.copyWith(selectedItem: () => null, isAnimatingOut: false);
    });
  }

  /// 선택된 아이템만 제외한 리스트 반환
  List<Map<String, dynamic>> availableItems() {
    if (state.selectedItem == null) return _defaultItems;
    return _defaultItems.where((item) => item != state.selectedItem).toList();
  }

  /// 현재 선택된 아이템 반환
  Map<String, dynamic>? getSelectedItem() {
    return state.selectedItem;
  }

  /// 전체 아이템 목록 반환
  List<Map<String, dynamic>> items() {
    return _defaultItems;
  }
}

/// SalesHomeScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final salesHomeScreenModelProvider =
    NotifierProvider.autoDispose<SalesHomeScreenModel, SalesHomeState>(
      SalesHomeScreenModel.new,
    );
