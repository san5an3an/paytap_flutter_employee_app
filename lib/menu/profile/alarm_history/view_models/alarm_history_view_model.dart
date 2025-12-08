import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/app/app_router.dart';
import 'package:paytap_app/common/models/device_storage.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:paytap_app/menu/profile/alarm_history/services/alarm_history_service.dart';

class AlarmHistoryViewModel extends AsyncNotifier<List<Map<String, dynamic>>> {
  final AlarmHistoryService alarmHistoryService = AlarmHistoryService();
  String initFCMToken = '';
  bool isInitNotificationPermission = false;
  WidgetsBindingObserver? _observer;

  @override
  Future<List<Map<String, dynamic>>> build() async {
    // 앱 생명주기 관찰자 등록
    _observer = _AlarmHistoryObserver(this);
    WidgetsBinding.instance.addObserver(_observer!);

    // onDispose 콜백 등록
    ref.onDispose(() {
      if (_observer != null) {
        WidgetsBinding.instance.removeObserver(_observer!);
      }
    });
    // 초기 권한 확인 및 FCM 토큰 가져오기
    final isNotificationAuthorized = await checkNotificationPermission();
    isInitNotificationPermission = isNotificationAuthorized;
    if (isNotificationAuthorized) {
      final messaging = FirebaseMessaging.instance;
      final fcmToken = await messaging.getToken();
      initFCMToken = fcmToken ?? '';
      print('초기 FCM 토큰: $fcmToken');
    } else {
      print('알림 권한이 승인되지 않아 FCM 토큰을 가져오지 않습니다.');
    }
    return await _getAlarmHistory();
  }

  /// 권한 상태 변화를 확인하고 필요시 provider를 갱신합니다.
  Future<void> checkPermissionChange() async {
    final currentPermission = await checkNotificationPermission();

    // 권한 상태가 변경되었고, 이전에 권한이 없었는데 지금은 권한이 있는 경우
    if (!isInitNotificationPermission && currentPermission) {
      isInitNotificationPermission = currentPermission;
      if (currentPermission) {
        // FCM 토큰 다시 가져오기
        final messaging = FirebaseMessaging.instance;
        final fcmToken = await messaging.getToken();
        initFCMToken = fcmToken ?? '';
        print('권한 변경 후 FCM 토큰: $fcmToken');
        // FCM 토큰을 저장하는 API 호출
        // final storeInfo = await DeviceStorage.read("storeInfo");
        // final deviceInfo = await DeviceStorage.read("deviceInfo");

        // final res = await PushNotificationService.saveDevice({
        //   'userId': storeInfo?['userId'],
        //   'storeUnqcd': storeInfo?['storeUnqcd'],
        //   'deviceUuid': deviceInfo?['uuid'],
        //   'platformFlag': deviceInfo?['platForm'],
        //   'appTkn': fcmToken,
        //   'alarmRcvYn': 'Y',
        // });
        // if (res.containsKey('error')) {
        //   _showErrorDialog(res["results"]);
        //   return;
        // }
        // print(res);
      }
      // Provider 상태 갱신
      ref.invalidateSelf();
    }
  }

  /// 알림 내역 조회
  Future<List<Map<String, dynamic>>> _getAlarmHistory() async {
    final deviceInfo = await DeviceStorage.read("deviceInfo");

    final storeInfo = await DeviceStorage.read("storeInfo");

    final res = await alarmHistoryService.getAlarmHistoryList(
      data: {
        "userId": storeInfo?['userId'],
        "storeUnqcd": storeInfo?['storeUnqcd'],
        "deviceUuid": deviceInfo?['uuid'],
      },
    );
    if (res.containsKey('error')) {
      _showErrorDialog(res["results"]);
      throw Exception(res["results"] ?? 'Unknown error');
    }
    return List<Map<String, dynamic>>.from(res["results"]);
  }

  // 디바이스 설정 알림 허용 여부 확인
  Future<bool> checkNotificationPermission() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  void _showErrorDialog(String? message) {
    BuildContext context = rootNavigatorKey.currentContext!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            title: '오류',
            content: message ?? '알 수 없는 오류가 발생했습니다.',
            confirmBtnLabel: '확인',
          );
        },
      );
    });
  }
}

/// 앱 생명주기 관찰자 클래스
class _AlarmHistoryObserver extends WidgetsBindingObserver {
  final AlarmHistoryViewModel viewModel;

  _AlarmHistoryObserver(this.viewModel);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 다시 포커스될 때 권한 상태 확인
    if (state == AppLifecycleState.resumed) {
      viewModel.checkPermissionChange();
    }
  }
}

/// Riverpod 3.0.3 - AsyncNotifierProvider.autoDispose (권장)
final alarmHistoryProvider =
    AsyncNotifierProvider.autoDispose<
      AlarmHistoryViewModel,
      List<Map<String, dynamic>>
    >(AlarmHistoryViewModel.new);
