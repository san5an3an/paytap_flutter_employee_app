import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:paytap_app/common/models/device_storage.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Android 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정 (권한 요청은 main.dart에서 처리)
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false, // 권한 요청은 main.dart에서 처리
          requestBadgePermission: false, // 권한 요청은 main.dart에서 처리
          requestSoundPermission: false, // 권한 요청은 main.dart에서 처리
        );

    // 초기화 설정
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // 플러그인 초기화
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTapped,
    );

    // Android 알림 채널 생성
    await _createNotificationChannel();
  }

  // Android 알림 채널 생성
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'paytap_channel',
      'PayTap Notifications',
      description: 'PayTap 앱의 알림을 위한 채널',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // 알림 탭 이벤트 처리
  static void onNotificationTapped(NotificationResponse response) {
    print('알림이 탭되었습니다: ${response.payload}');
    // 여기에 알림 클릭 시 앱 내 네비게이션 로직을 추가할 수 있습니다
  }

  // 포그라운드 알림 표시
  static Future<void> showForegroundNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'paytap_channel',
          'PayTap Notifications',
          channelDescription: 'PayTap 앱의 알림을 위한 채널',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          enableLights: true,
          playSound: true,
          visibility: NotificationVisibility.public,
          actions: [
            AndroidNotificationAction('open', '열기'),
            AndroidNotificationAction('dismiss', '닫기'),
          ],
          // 백그라운드에서도 알림이 표시되도록 설정
          ongoing: false,
          autoCancel: true,
          // paytap_notifications.png를 알림 아이콘으로 사용
          icon: '@drawable/paytap_notifications',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.active,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // 고유한 알림 ID 생성
    int notificationId = _generateNotificationId(message);

    try {
      // 알림 표시
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        message.notification?.title ?? '새 알림',
        message.notification?.body ?? '새로운 메시지가 도착했습니다.',
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
      print('로컬 알림이 성공적으로 표시되었습니다. ID: $notificationId');
    } catch (e) {
      print('로컬 알림 표시 중 오류 발생: $e');
    }
  }

  // 고유한 알림 ID 생성
  static int _generateNotificationId(RemoteMessage message) {
    if (message.messageId != null) {
      return message.messageId!.hashCode;
    }

    String content =
        '${message.notification?.title ?? ''}${message.notification?.body ?? ''}${message.data.toString()}';
    return content.hashCode;
  }

  // 최초 실행 시에만 알림 권한 요청
  static Future<bool> requestPermissionsOnFirstLaunch() async {
    const String permissionRequestedKey = 'notification_permission_requested';

    // 이미 권한 요청을 한 적이 있는지 확인
    final permissionData = await DeviceStorage.read(permissionRequestedKey);
    bool hasRequestedBefore = permissionData?['requested'] ?? false;

    if (hasRequestedBefore) {
      print('이미 알림 권한을 요청한 적이 있습니다. 권한 요청을 건너뜁니다.');
      return false;
    }

    // 현재 권한 상태 확인
    final messaging = FirebaseMessaging.instance;
    final currentSettings = await messaging.getNotificationSettings();

    print('현재 권한 상태: ${currentSettings.authorizationStatus}');

    if (currentSettings.authorizationStatus == AuthorizationStatus.authorized) {
      print('이미 알림 권한이 승인되어 있습니다.');
      // 권한 요청 완료 표시
      await DeviceStorage.write(permissionRequestedKey, {
        'requested': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return true;
    }

    // 권한이 거부된 상태인지 확인 (이미 요청한 적이 있는 경우에만)
    if (currentSettings.authorizationStatus == AuthorizationStatus.denied &&
        hasRequestedBefore) {
      print('알림 권한이 거부된 상태입니다. 권한 요청을 건너뜁니다.');
      // 권한 거부 상태도 저장
      await DeviceStorage.write(permissionRequestedKey, {
        'requested': true,
        'denied': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return false;
    }

    // 최초 실행 시에만 권한 요청
    print('최초 실행: 알림 권한을 요청합니다.');
    bool granted = await requestPermissions();

    // 권한 요청 완료 표시 (권한 승인 여부와 관계없이)
    await DeviceStorage.write(permissionRequestedKey, {
      'requested': true,
      'granted': granted,
      'denied': !granted,
      'timestamp': DateTime.now().toIso8601String(),
    });

    print('권한 요청 완료 - 승인: $granted');
    return granted;
  }

  // 알림 권한 요청 (플랫폼별 분리 처리)
  static Future<bool> requestPermissions() async {
    try {
      // 플랫폼별 권한 요청
      if (Platform.isAndroid) {
        return await _requestAndroidPermissions();
      } else if (Platform.isIOS) {
        return await _requestIOSPermissions();
      }

      return false;
    } catch (e) {
      print('권한 요청 중 오류 발생: $e');
      return false;
    }
  }

  // Android 권한 요청
  static Future<bool> _requestAndroidPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      bool? granted = await androidImplementation
          .requestNotificationsPermission();
      print('Android 권한 상태: $granted');
      return granted == true;
    }

    return false;
  }

  // iOS 권한 요청
  static Future<bool> _requestIOSPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('iOS FCM 권한 상태: ${settings.authorizationStatus}');
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // 모든 알림 제거
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // 특정 알림 제거
  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // 권한 요청 상태 초기화 (테스트용)
  static Future<void> resetPermissionRequest() async {
    const String permissionRequestedKey = 'notification_permission_requested';
    await DeviceStorage.delete(permissionRequestedKey);
    print('알림 권한 요청 상태가 초기화되었습니다.');
  }
}
