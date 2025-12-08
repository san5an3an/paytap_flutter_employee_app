import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/bottom_modal/bottom_modal.dart';
import 'package:paytap_app/common/widget/confrim_two_button/confrim_two_button.dart';
import 'package:paytap_app/common/widget/date_time_bottom_modal/data/date_time_type.dart';
import 'package:paytap_app/common/widget/date_time_bottom_modal/date_time_bottom_modal.dart';
import 'package:paytap_app/common/widget/switch_button/switch_button.dart';
import 'package:paytap_app/menu/profile/alarm_history/views/alarm_pos_modal.dart';

import '../view_models/alarm_setting_modal_view_model.dart';

class AlarmSettingModal extends ConsumerWidget {
  const AlarmSettingModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alarmSettingModalViewModelProvider);
    final notifier = ref.read(alarmSettingModalViewModelProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!state.isInitialized) {
        notifier.initialize();
      }

      // 에러 메시지가 있을 때만 dialog 표시
      if (state.errorMessage.isNotEmpty) {
        notifier.showConfirmDialog(context, state.errorMessage);
      }
    });

    return BottomModal(
      title: '알림 설정',
      bottomWidget: ConfirmTwoButton(
        leftButtonText: '닫기',
        rightButtonText: '저장하기',
        onLeftButtonPressed: () {
          Navigator.pop(context);
        },
        onRightButtonPressed: () async {
          final isSuccess = await notifier.onTapSaveAlarm(context);
          if (isSuccess) {
            Navigator.pop(context);
          }
        },
      ),
      content: [
        const SizedBox(height: 10),
        SizedBox(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '전체 알림',
                style: GlobalTextStyle.body02.copyWith(color: GlobalColor.bk01),
              ),
              SwitchButton(
                name: 'isAll',
                onChange: notifier.onChangeQuery,
                value: state.alarmSettingState['isAll'],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '개점 알림',
                style: GlobalTextStyle.body02.copyWith(color: GlobalColor.bk01),
              ),
              SwitchButton(
                name: 'openAlarmYn',
                onChange: notifier.onChangeQuery,
                value: state.alarmSettingState['openAlarmYn'],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '일마감 알림',
                style: GlobalTextStyle.body02.copyWith(color: GlobalColor.bk01),
              ),
              SwitchButton(
                name: 'closeAlarmYn',
                onChange: notifier.onChangeQuery,
                value: state.alarmSettingState['closeAlarmYn'],
              ),
            ],
          ),
        ),

        /// 구분선 위젯 추가 (디자인 일관성 및 시각적 구분을 위해 사용)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Divider(color: GlobalColor.bk05, thickness: 1, height: 1),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
            highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
            onTap: () {
              _showPosListModal(context, ref);
            },
            child: SizedBox(
              height: 55,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '알림을 허용할 포스',
                    style: GlobalTextStyle.body02.copyWith(
                      color: GlobalColor.bk01,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: GlobalColor.bk03),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Divider(color: GlobalColor.bk05, thickness: 1, height: 1),
        ),
        SizedBox(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                children: [
                  Text(
                    '알림 시간 설정',
                    style: GlobalTextStyle.body02.copyWith(
                      color: GlobalColor.bk01,
                    ),
                  ),
                  const SizedBox(width: 5),
                  SvgPicture.asset('assets/icons/i_Timer.svg'),
                ],
              ),
              SwitchButton(
                name: 'alarmTimeYn',
                onChange: notifier.onChangeQuery,
                value: state.alarmSettingState['alarmTimeYn'],
              ),
            ],
          ),
        ),
        if (state.alarmSettingState['alarmTimeYn'] == true)
          _selectDateTile(context, ref, true),
        if (state.alarmSettingState['alarmTimeYn'] == true)
          _selectDateTile(context, ref, false),
      ],
    );
  }

  // 알림을 허용할 포스 모달 표시
  void _showPosListModal(BuildContext context, WidgetRef ref) {
    final state = ref.read(alarmSettingModalViewModelProvider);
    final notifier = ref.read(alarmSettingModalViewModelProvider.notifier);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AlarmPosModal(
          name: 'alarmPosList',
          alarmPosList: state.alarmSettingState['alarmPosList'],
          onTapSave: (name, value) {
            notifier.onChangeQuery(name, value);
          },
        );
      },
    );
  }

  // 알림 시간 설정 모달 표시
  Widget _selectDateTile(BuildContext context, WidgetRef ref, bool isStart) {
    final state = ref.watch(alarmSettingModalViewModelProvider);
    final notifier = ref.read(alarmSettingModalViewModelProvider.notifier);
    final title = isStart ? '시작 시간' : '종료 시간';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
        highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return DateTimeBottomModal(
                title: '$title 설정',
                name: isStart ? 'rcvStartHour' : 'rcvEndHour',
                value: isStart
                    ? state.alarmSettingState['rcvStartHour']
                    : state.alarmSettingState['rcvEndHour'],
                type: DateTimeType.time,
                onTapSave: (name, value) {
                  notifier.onChangeQuery(name, value);
                },
              );
            },
          );
        },
        child: SizedBox(
          height: 55,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GlobalTextStyle.body02.copyWith(
                    color: GlobalColor.bk01,
                  ),
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          isStart
                              ? notifier.formatTime(
                                  state.alarmSettingState['rcvStartHour'],
                                )
                              : notifier.formatTime(
                                  state.alarmSettingState['rcvEndHour'],
                                ),
                          style: GlobalTextStyle.body01.copyWith(
                            color: GlobalColor.bk03,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: GlobalColor.bk03,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
