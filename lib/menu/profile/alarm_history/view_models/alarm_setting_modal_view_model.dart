import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/models/device_storage.dart';
import 'package:paytap_app/common/services/push_notification_service.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 알림 설정 모달 화면의 상태 모델
class AlarmSettingModalState {
  // 상수 정의
  static const String _keyIsAll = 'isAll';
  static const String _keyOpenAlarmYn = 'openAlarmYn';
  static const String _keyCloseAlarmYn = 'closeAlarmYn';
  static const String _keyAlarmTimeYn = 'alarmTimeYn';
  static const String _keyRcvStartHour = 'rcvStartHour';
  static const String _keyRcvEndHour = 'rcvEndHour';
  static const String _keyAlarmPosList = 'alarmPosList';

  final bool isDatePickerStartVisible;
  final bool isDatePickerEndVisible;
  final GlobalKey startDatePickerKey;
  final GlobalKey endDatePickerKey;
  final String errorMessage;
  final bool isInitialized;
  final Map<String, dynamic> alarmSettingState;

  const AlarmSettingModalState({
    this.isDatePickerStartVisible = false,
    this.isDatePickerEndVisible = false,
    required this.startDatePickerKey,
    required this.endDatePickerKey,
    this.errorMessage = '',
    this.isInitialized = false,
    required this.alarmSettingState,
  });

  AlarmSettingModalState copyWith({
    bool? isDatePickerStartVisible,
    bool? isDatePickerEndVisible,
    GlobalKey? startDatePickerKey,
    GlobalKey? endDatePickerKey,
    String? errorMessage,
    bool? isInitialized,
    Map<String, dynamic>? alarmSettingState,
  }) {
    return AlarmSettingModalState(
      isDatePickerStartVisible:
          isDatePickerStartVisible ?? this.isDatePickerStartVisible,
      isDatePickerEndVisible:
          isDatePickerEndVisible ?? this.isDatePickerEndVisible,
      startDatePickerKey: startDatePickerKey ?? this.startDatePickerKey,
      endDatePickerKey: endDatePickerKey ?? this.endDatePickerKey,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
      alarmSettingState: alarmSettingState ?? this.alarmSettingState,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class AlarmSettingModalViewModel extends Notifier<AlarmSettingModalState> {
  // 상수 정의
  static const String _keyIsAll = 'isAll';
  static const String _keyOpenAlarmYn = 'openAlarmYn';
  static const String _keyCloseAlarmYn = 'closeAlarmYn';
  static const String _keyAlarmTimeYn = 'alarmTimeYn';
  static const String _keyRcvStartHour = 'rcvStartHour';
  static const String _keyRcvEndHour = 'rcvEndHour';
  static const String _keyAlarmPosList = 'alarmPosList';

  @override
  AlarmSettingModalState build() {
    return AlarmSettingModalState(
      startDatePickerKey: GlobalKey(),
      endDatePickerKey: GlobalKey(),
      alarmSettingState: {
        _keyIsAll: true,
        _keyOpenAlarmYn: true,
        _keyCloseAlarmYn: true,
        _keyAlarmTimeYn: true,
        _keyRcvStartHour: '0000',
        _keyRcvEndHour: '0000',
      },
    );
  }

  /// 초기화 메서드
  Future<void> initialize() async {
    if (state.isInitialized) return;

    state = state.copyWith(isInitialized: true);
    await getArarmSetting();
  }

  /// 상태 변경 메서드
  void onChangeQuery(String name, dynamic value) {
    final updatedState = Map<String, dynamic>.from(state.alarmSettingState)
      ..[name] = value;

    _handleDependentStates(name, value, updatedState);
    state = state.copyWith(alarmSettingState: updatedState);
  }

  /// 의존성 있는 상태들 처리
  void _handleDependentStates(
    String name,
    dynamic value,
    Map<String, dynamic> updatedState,
  ) {
    switch (name) {
      case _keyOpenAlarmYn:
      case _keyCloseAlarmYn:
        _updateIsAllState(updatedState);
        break;
      case _keyIsAll:
        _updateDependentAlarmStates(value, updatedState);
        break;
    }
  }

  /// isAll 상태 업데이트
  void _updateIsAllState(Map<String, dynamic> updatedState) {
    final openAlarmYn = updatedState[_keyOpenAlarmYn];
    final closeAlarmYn = updatedState[_keyCloseAlarmYn];
    final isAll = (openAlarmYn == true && closeAlarmYn == true);

    updatedState[_keyIsAll] = isAll;
  }

  /// isAll 변경 시 의존 상태들 업데이트
  void _updateDependentAlarmStates(
    bool isAllValue,
    Map<String, dynamic> updatedState,
  ) {
    updatedState[_keyOpenAlarmYn] = isAllValue;
    updatedState[_keyCloseAlarmYn] = isAllValue;

    // isAll이 false면 alarmTimeYn도 false로 변경
    if (isAllValue == false) {
      updatedState[_keyAlarmTimeYn] = false;
    }
  }

  /// 디바이스 알람 상태 조회
  Future<void> getArarmSetting() async {
    final deviceInfo = await DeviceStorage.read("deviceInfo");
    final storeInfo = await DeviceStorage.read("storeInfo");

    final res = await PushNotificationService.getDevice({
      'userId': storeInfo?['userId'],
      'storeUnqcd': storeInfo?['storeUnqcd'],
      'deviceUuid': deviceInfo?['uuid'],
    });

    if (res.containsKey('error')) {
      state = state.copyWith(errorMessage: res["results"]);
      return;
    }

    final alarmSetting = res["results"]['device'];
    final alarmPosList = res["results"]['alarmPosList'];

    _updateAlarmSettingState(alarmSetting, alarmPosList);
  }

  /// 알림 설정 상태 업데이트
  void _updateAlarmSettingState(
    Map<String, dynamic> alarmSetting,
    dynamic alarmPosList,
  ) {
    final openAlarmYn = alarmSetting[_keyOpenAlarmYn] == "Y";
    final closeAlarmYn = alarmSetting[_keyCloseAlarmYn] == "Y";

    final updatedAlarmSettingState = {
      _keyIsAll: openAlarmYn && closeAlarmYn,
      _keyOpenAlarmYn: openAlarmYn,
      _keyCloseAlarmYn: closeAlarmYn,
      _keyAlarmTimeYn: alarmSetting[_keyAlarmTimeYn] == "Y",
      _keyRcvStartHour: alarmSetting[_keyRcvStartHour],
      _keyRcvEndHour: alarmSetting[_keyRcvEndHour],
      _keyAlarmPosList: alarmPosList,
    };

    state = state.copyWith(alarmSettingState: updatedAlarmSettingState);
  }

  void showConfirmDialog(BuildContext context, String message) {
    // 이미 dialog가 표시되어 있는지 확인
    if (state.errorMessage.isEmpty) return;

    // 에러 메시지를 먼저 클리어하여 중복 호출 방지
    final currentMessage = state.errorMessage;
    state = state.copyWith(errorMessage: '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: '알림',
          content: currentMessage,
          confirmBtnLabel: '확인',
          confirmBtnOnPressed: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // 알림 설정 저장하기
  Future<bool> onTapSaveAlarm(BuildContext context) async {
    final deviceInfo = await DeviceStorage.read("deviceInfo");
    final storeInfo = await DeviceStorage.read("storeInfo");

    final messaging = FirebaseMessaging.instance;
    final fcmToken = await messaging.getToken();

    // 시분 문자열("HHmm")을 DateTime으로 변환하여 비교
    final String startStr = state.alarmSettingState[_keyRcvStartHour] ?? '';
    final String endStr = state.alarmSettingState[_keyRcvEndHour] ?? '';

    // "HHmm" 형식의 문자열을 오늘 날짜의 DateTime으로 변환하는 함수
    DateTime? parseTime(String timeStr) {
      if (timeStr.length != 4) return null;
      final hour = int.tryParse(timeStr.substring(0, 2));
      final minute = int.tryParse(timeStr.substring(2, 4));
      if (hour == null || minute == null) return null;
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    }

    final startTime = parseTime(startStr);
    final endTime = parseTime(endStr);

    if (startTime != null && endTime != null && startTime.isAfter(endTime)) {
      showTimeErrorConfirmDialog(context, "시작 시간이 종료 시간보다 큽니다.");
      return false;
    }

    final res = await PushNotificationService.patchDevice({
      'userId': storeInfo?['userId'],
      'storeUnqcd': storeInfo?['storeUnqcd'],
      'deviceUuid': deviceInfo?['uuid'],
      'openAlarmYn': state.alarmSettingState[_keyOpenAlarmYn] ? "Y" : "N",
      'closeAlarmYn': state.alarmSettingState[_keyCloseAlarmYn] ? "Y" : "N",
      'alarmTimeYn': state.alarmSettingState[_keyAlarmTimeYn] ? "Y" : "N",
      'rcvStartHour': state.alarmSettingState[_keyRcvStartHour],
      'rcvEndHour': state.alarmSettingState[_keyRcvEndHour],
      'alarmPosList': state.alarmSettingState[_keyAlarmPosList],
      'appTkn': fcmToken,
    });

    if (res.containsKey('error')) {
      state = state.copyWith(errorMessage: res["results"]);
      return false;
    }
    //성공햇을 경우
    return true;
  }

  // 시간 비교 에러 알람 표시
  void showTimeErrorConfirmDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: '조회 오류',
          content: message,
          confirmBtnLabel: '확인',
          confirmBtnOnPressed: () {},
        );
      },
    );
  }

  String formatTime(String time) {
    final hour = time.substring(0, 2);
    final minute = time.substring(2, 4);
    return '$hour : $minute';
  }
}

/// AlarmSettingModalViewModel Provider
final alarmSettingModalViewModelProvider =
    NotifierProvider.autoDispose<
      AlarmSettingModalViewModel,
      AlarmSettingModalState
    >(AlarmSettingModalViewModel.new);
