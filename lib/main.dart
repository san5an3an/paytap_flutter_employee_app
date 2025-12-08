import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/app/app_config.dart'; // AppConfig import 추가
import 'package:paytap_app/app/app_router.dart'; // go_router 설정을 가져옵니다.
import 'package:paytap_app/app/firebase_options.dart';
import 'package:paytap_app/common/services/Common/http_service.dart';
import 'package:paytap_app/common/services/Common/notification_service.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';

final HttpService _httpService = HttpService();

// 권한 요청 상태를 추적하는 변수
bool _isPermissionRequestInProgress = false;

Future<Map<String, dynamic>> postError(data) async {
  final res = await _httpService.post('/monitoring/collect/app', data);
  return res;
}

// 릴리즈 모드에서만 에러 리포팅하는 함수
Future<void> reportErrorIfNotDebug(FlutterErrorDetails details) async {
  print("FlutterError: ${details.exception.toString()}");
  print('에러가 발생한 라우트: ${AppRouteObserver.currentRouteName}');

  await postError({
    "serverDomainNm": "outpos-front-app",
    "routeNm": AppRouteObserver.currentRouteName ?? "",
    "errLevel": "ERROR",
    "source": "${details.exception}",
    "serverType": "release",
  });
}

/// 백그라운드 초기화 작업
Future<void> _initializeBackgroundServices() async {
  try {
    // AppConfig 초기화 (환경변수 로드)
    await AppConfig.initialize();

    // 파이어베이스 관련 APP 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 로컬 알림 서비스 초기화
    await NotificationService.initialize();

    print('✅ 백그라운드 서비스 초기화 완료');
  } catch (e) {
    print('❌ 백그라운드 서비스 초기화 실패: $e');
  }
}

/// FCM 설정 최적화
Future<void> _setupFirebaseMessaging() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 현재 권한 상태 확인
    final currentSettings = await messaging.getNotificationSettings();
    print('현재 FCM 권한 상태: ${currentSettings.authorizationStatus}');
    print('권한 상태 상세: ${currentSettings.authorizationStatus.name}');

    // 권한이 승인되지 않은 경우에만 최초 실행 시 권한 요청
    if (currentSettings.authorizationStatus != AuthorizationStatus.authorized) {
      // 권한이 거부된 상태인지 확인
      if (currentSettings.authorizationStatus == AuthorizationStatus.denied) {
        print('알림 권한이 거부된 상태입니다. NotificationService에서 처리합니다.');
      }

      // 이미 권한 요청이 진행 중인지 확인
      if (_isPermissionRequestInProgress) {
        print('권한 요청이 이미 진행 중입니다. 대기 중...');
        return;
      }

      try {
        _isPermissionRequestInProgress = true;

        // 최초 실행 시에만 알림 권한 요청 (NotificationService에서 통합 처리)
        bool permissionGranted =
            await NotificationService.requestPermissionsOnFirstLaunch();

        if (permissionGranted) {
          print('알림 권한이 승인되었습니다.');
        } else {
          print('알림 권한이 거부되었습니다. 더 이상 요청하지 않습니다.');
        }
      } catch (e) {
        print('알림 권한 요청 중 오류: $e');
        // 권한 요청 실패 시에도 계속 진행
      } finally {
        _isPermissionRequestInProgress = false;
      }
    } else {
      print('이미 FCM 권한이 승인되어 있습니다.');
    }

    // 포그라운드 메시지 처리 (LocalNotification 사용)
    FirebaseMessaging.onMessage.listen((message) {
      print('포그라운드 메시지 수신: ${message.messageId}');
      print('메시지 데이터: ${message.data}');
      if (message.notification != null) {
        NotificationService.showForegroundNotification(message);
      }
    });

    // 백그라운드에서 알림 클릭 처리
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('백그라운드에서 알림 클릭으로 앱 열림');
      print('클릭된 메시지 데이터: ${message.data}');
    });

    // 앱 종료 상태에서 알림 클릭 처리
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('앱 종료 상태에서 알림으로 실행');
        print('초기 메시지 데이터: ${message.data}');
      }
    });

    // 백그라운드 메시지 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // FCM 토큰 변경 감지
    messaging.onTokenRefresh.listen((newToken) {
      print('FCM 토큰이 갱신되었습니다: $newToken');
    });

    print('✅ FCM 설정 완료');
  } catch (e) {
    print('❌ FCM 설정 실패: $e');
    _isPermissionRequestInProgress = false;
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('백그라운드/종료 상태 메시지 처리:  [38;5;2m${message.messageId} [0m');
  print('메시지 데이터: ${message.data}');
  print('알림 제목: ${message.notification?.title}');
  print('알림 내용: ${message.notification?.body}');

  return;
}

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 에러 핸들러 설정
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      // 디버그 모드에서는 기본 Flutter 에러 처리 사용
      FlutterError.dumpErrorToConsole(details);
    } else {
      // 릴리즈 모드에서만 커스텀 에러 리포팅
      reportErrorIfNotDebug(details);
    }
  };

  // 화면 방향 설정 (메인 스레드에서 빠르게 처리)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 앱을 먼저 실행하고 백그라운드에서 서비스 초기화
  runApp(const MyApp());

  // 백그라운드에서 무거운 초기화 작업 수행
  _initializeBackgroundServices().then((_) {
    // 백그라운드 서비스 초기화 완료 후 FCM 설정
    _setupFirebaseMessaging();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'My App',
        theme: ThemeData(
          scaffoldBackgroundColor: GlobalColor.systemBackGround,
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.transparent,
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        routerConfig: appRouter,
        locale: const Locale('ko'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', ''), // 한국어
          Locale('en', ''), // 영어
        ],
      ),
    );
  }
}
