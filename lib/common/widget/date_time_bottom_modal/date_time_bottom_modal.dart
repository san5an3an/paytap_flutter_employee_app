import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/widget/bottom_modal/bottom_modal.dart';
import 'package:paytap_app/common/widget/confrim_two_button/confrim_two_button.dart';
import 'package:paytap_app/common/widget/date_time_bottom_modal/data/date_time_bottom_model.dart';
import 'package:paytap_app/common/widget/date_time_bottom_modal/data/date_time_type.dart';
import 'package:paytap_app/common/widget/date_wheel/date_wheel.dart';

class DateTimeBottomModal extends ConsumerWidget {
  final String title;
  final String name;
  final String value;
  final DateTimeType type;
  final void Function(String name, String value)? onTapSave;

  const DateTimeBottomModal({
    super.key,
    this.title = "",
    required this.name,
    required this.value,
    required this.type,
    this.onTapSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dateTimeBottomModelProvider);
    final vm = ref.read(dateTimeBottomModelProvider.notifier);
    // 모달이 처음 열릴 때 초기 상태 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!state.isInitialized) {
        vm.initializeState(name, value);
      }
    });

    return state.isInitialized
        ? BottomModal(
            title: title,
            bottomWidget: ConfirmTwoButton(
              leftButtonText: '닫기',
              rightButtonText: '저장하기',
              onLeftButtonPressed: () {
                Navigator.of(context).pop();
              },
              onRightButtonPressed: () {
                if (onTapSave != null) {
                  onTapSave!(name, state.tempState[name]);
                }
                Navigator.of(context).pop();
              },
            ),
            content: [
              Container(
                padding: const EdgeInsets.all(15),
                height: 200,
                child: DateWheel(
                  // "20250715" 형태의 문자열을 DateTime으로 변환
                  name: name,
                  value: _getConvertWheelDateTime(state.tempState[name], type),
                  onChange: (name, value) {
                    vm.setTempState(
                      name: name,
                      value: _getConvertWheelStringDate(value, type),
                    );
                  },
                  type: type,
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}

// DateWheelV2 에서 사용하는 날짜 형식 변환
DateTime _getConvertWheelDateTime(String date, DateTimeType type) {
  switch (type) {
    case DateTimeType.day:
      return DateTime.parse(
        "${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6, 8)}",
      );
    case DateTimeType.month:
      final year = int.parse(date.substring(0, 4));
      final month = int.parse(date.substring(4, 6));

      // 시작일: 해당 월의 1일
      return DateTime.parse(
        "${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-01",
      );
    case DateTimeType.year:
      return DateTime.parse("${date.substring(0, 4)}-01-01");
    case DateTimeType.time:
      // "2300" -> 오후 11시 00분
      final hour = int.parse(date.substring(0, 2));
      final minute = int.parse(date.substring(2, 4));
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
  }
}

// DateWheelV2에서 주는 데이터 String 형식으로 변환
String _getConvertWheelStringDate(DateTime date, DateTimeType type) {
  switch (type) {
    case DateTimeType.day:
      return "${date.year.toString().padLeft(4, '0')}"
          "${date.month.toString().padLeft(2, '0')}"
          "${date.day.toString().padLeft(2, '0')}";
    case DateTimeType.month:
      return "${date.year.toString().padLeft(4, '0')}"
          "${date.month.toString().padLeft(2, '0')}";
    case DateTimeType.year:
      return date.year.toString().padLeft(4, '0');
    case DateTimeType.time:
      // DateTime -> "2300" 형식 (24시간제)
      return "${date.hour.toString().padLeft(2, '0')}"
          "${date.minute.toString().padLeft(2, '0')}";
  }
}
