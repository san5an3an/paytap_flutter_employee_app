import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/models/pos.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/bottom_modal/bottom_modal.dart';
import 'package:paytap_app/common/widget/cm_check_box/cm_check_box.dart';
import 'package:paytap_app/common/widget/confrim_two_button/confrim_two_button.dart';
import 'package:paytap_app/menu/profile/alarm_history/view_models/alarm_pos_modal_view_model.dart';

class AlarmPosModal extends ConsumerWidget {
  final String name;
  final List<dynamic> alarmPosList;
  final Function(String, List<dynamic>) onTapSave;
  const AlarmPosModal({
    super.key,
    required this.alarmPosList,
    required this.onTapSave,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alarmPosModalViewModelProvider);
    final notifier = ref.read(alarmPosModalViewModelProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!state.isInitialized) {
        print('initialize');
        notifier.initialize(alarmPosList);
      }
    });
    return state.isInitialized
        ? BottomModal(
            title: '알림을 허용할 포스',
            bottomWidget: ConfirmTwoButton(
              leftButtonText: '닫기',
              rightButtonText: '저장하기',
              onLeftButtonPressed: () {
                Navigator.pop(context);
              },
              onRightButtonPressed: () {
                onTapSave(name, state.selectedAlarmPosList);
                Navigator.pop(context);
              },
            ),
            content: [
              Column(
                children: [
                  _posAllSelectTile(state, notifier),
                  ...state.posList.map(
                    (posItem) => _posTile(posItem, state, notifier),
                  ),
                ],
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}

Widget _posAllSelectTile(
  AlarmPosModalState state,
  AlarmPosModalViewModel notifier,
) {
  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      notifier.toggleAllPosSelection();
    },
    child: SizedBox(
      height: 55,
      child: Row(
        children: [
          CmCheckBox(
            value: state.isAllPosSelected,
            name: 'isAllPosSelected',
            onTapCheckBox: (name, value) {
              notifier.toggleAllPosSelection();
            },
          ),
          const SizedBox(width: 10),
          Text(
            '전체',
            style: GlobalTextStyle.body01.copyWith(color: GlobalColor.bk01),
          ),
        ],
      ),
    ),
  );
}

Widget _posTile(
  PosItem posItem,
  AlarmPosModalState state,
  AlarmPosModalViewModel notifier,
) {
  // selectedAlarmPosList에서 posItem.posNo와 일치하는 항목이 있는지 확인
  final isSelected = state.selectedAlarmPosList.contains(posItem.posNo);

  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      notifier.togglePosSelection(posItem.posNo);
    },
    child: Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          CmCheckBox(
            value: isSelected,
            name: posItem.posNo,
            onTapCheckBox: (name, value) {
              notifier.togglePosSelection(posItem.posNo);
            },
          ),
          const SizedBox(width: 10),
          Text(
            posItem.posNm,
            style: GlobalTextStyle.body01.copyWith(color: GlobalColor.bk01),
          ),
        ],
      ),
    ),
  );
}
