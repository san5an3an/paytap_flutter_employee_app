import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/models/pos.dart';

/// 알림 포스 모달 화면의 상태 모델
class AlarmPosModalState {
  final bool isInitialized;
  final List<dynamic> selectedAlarmPosList;
  final List<PosItem> posList;
  final bool? isAllPosSelected;

  const AlarmPosModalState({
    this.isInitialized = false,
    this.selectedAlarmPosList = const [],
    this.posList = const [],
    this.isAllPosSelected = false,
  });

  AlarmPosModalState copyWith({
    bool? isInitialized,
    List<dynamic>? selectedAlarmPosList,
    List<PosItem>? posList,
    bool? isAllPosSelected,
  }) {
    return AlarmPosModalState(
      isInitialized: isInitialized ?? this.isInitialized,
      selectedAlarmPosList: selectedAlarmPosList ?? this.selectedAlarmPosList,
      posList: posList ?? this.posList,
      isAllPosSelected: isAllPosSelected ?? this.isAllPosSelected,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class AlarmPosModalViewModel extends Notifier<AlarmPosModalState> {
  @override
  AlarmPosModalState build() {
    return const AlarmPosModalState();
  }

  void initialize(List<dynamic> alarmPosList) {
    if (state.isInitialized) return;

    // 원본을 변경하지 않고 복사본 생성
    final selectedAlarmPosList = List<dynamic>.from(alarmPosList);
    final posList = Pos.posList;

    // 초기 상태에서 isAllPosSelected 설정
    final isAllPosSelected = _calculateAllPosSelected(
      selectedAlarmPosList,
      posList,
    );

    state = state.copyWith(
      isInitialized: true,
      selectedAlarmPosList: selectedAlarmPosList,
      posList: posList,
      isAllPosSelected: isAllPosSelected,
    );
  }

  /// 포스 선택/해제 처리
  void togglePosSelection(String posNo) {
    final updatedSelectedList = List<dynamic>.from(state.selectedAlarmPosList);

    if (updatedSelectedList.contains(posNo)) {
      // 이미 선택된 경우 제거
      updatedSelectedList.remove(posNo);
    } else {
      // 선택되지 않은 경우 추가
      updatedSelectedList.add(posNo);
    }

    // 모든 포스가 선택되었는지 확인하여 isAllPosSelected 업데이트
    final isAllPosSelected = _calculateAllPosSelected(
      updatedSelectedList,
      state.posList,
    );

    state = state.copyWith(
      selectedAlarmPosList: updatedSelectedList,
      isAllPosSelected: isAllPosSelected,
    );
  }

  /// 전체 선택 상태 계산
  bool? _calculateAllPosSelected(
    List<dynamic> selectedList,
    List<PosItem> posList,
  ) {
    // 모든 포스의 posNo 목록 생성
    final allPosNos = posList.map((posItem) => posItem.posNo).toList();

    // selectedAlarmPosList가 모든 포스를 포함하는지 확인
    if (allPosNos.every((posNo) => selectedList.contains(posNo))) {
      // 모든 포스가 선택된 경우
      return true;
    } else if (selectedList.isEmpty) {
      // 선택된 포스가 없는 경우
      return false;
    } else {
      // 일부만 선택된 경우 (부분 선택)
      return null;
    }
  }

  // 포스 전체 선택
  void toggleAllPosSelection() {
    if (state.isAllPosSelected == true) {
      // 전체 해제: selectedAlarmPosList에서 모든 포스 제거
      state = state.copyWith(selectedAlarmPosList: [], isAllPosSelected: false);
    } else {
      // 전체 선택: selectedAlarmPosList에 모든 포스 추가
      final allPosNos = state.posList.map((posItem) => posItem.posNo).toList();
      state = state.copyWith(
        selectedAlarmPosList: allPosNos,
        isAllPosSelected: true,
      );
    }
  }
}

/// AlarmPosModalViewModel Provider
final alarmPosModalViewModelProvider =
    NotifierProvider.autoDispose<AlarmPosModalViewModel, AlarmPosModalState>(
      AlarmPosModalViewModel.new,
    );
