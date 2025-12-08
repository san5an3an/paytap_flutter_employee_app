import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:paytap_app/common/models/device_storage.dart';
import 'package:paytap_app/common/models/session.dart';
import 'package:paytap_app/common/services/login_service.dart';
import 'package:paytap_app/common/services/push_notification_service.dart';
import 'package:paytap_app/common/utils/crypto_helper.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:uuid/uuid.dart';

/// 인증 체크 화면의 상태 모델
class AuthCheckState {
  final String storeAppVersion;
  final String deviceAppVersion;
  final String requiredYn;
  final bool isAppUpdateAlert;
  final bool isSameVersion;
  final String nextRouteLink;
  final bool isAuthInProgress;

  const AuthCheckState({
    this.storeAppVersion = '',
    this.deviceAppVersion = '',
    this.requiredYn = "",
    this.isAppUpdateAlert = false,
    this.isSameVersion = false,
    this.nextRouteLink = "/home",
    this.isAuthInProgress = false,
  });

  AuthCheckState copyWith({
    String? storeAppVersion,
    String? deviceAppVersion,
    String? requiredYn,
    bool? isAppUpdateAlert,
    bool? isSameVersion,
    String? nextRouteLink,
    bool? isAuthInProgress,
  }) {
    return AuthCheckState(
      storeAppVersion: storeAppVersion ?? this.storeAppVersion,
      deviceAppVersion: deviceAppVersion ?? this.deviceAppVersion,
      requiredYn: requiredYn ?? this.requiredYn,
      isAppUpdateAlert: isAppUpdateAlert ?? this.isAppUpdateAlert,
      isSameVersion: isSameVersion ?? this.isSameVersion,
      nextRouteLink: nextRouteLink ?? this.nextRouteLink,
      isAuthInProgress: isAuthInProgress ?? this.isAuthInProgress,
    );
  }
}

class AuthCheckViewModel extends Notifier<AuthCheckState> {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final storage = FlutterSecureStorage();
  var uuid = Uuid();

  @override
  AuthCheckState build() {
    // 초기화 함수 실행
    _initialize();
    return const AuthCheckState();
  }

  // 초기화
  Future<void> _initialize() async {
    await DeviceStorage.delete("storeInfo");
  }

  Future<void> getAuth(BuildContext context) async {
    // 이미 인증 진행 중이면 중단
    if (state.isAuthInProgress) {
      print('인증이 이미 진행 중입니다. 중복 호출을 방지합니다.');
      return;
    }

    state = state.copyWith(isAuthInProgress: true);

    try {
      final data = await _getPackageInfo();
      final deviceAppVersion = data.version;

      //앱 버전 체크
      final platformFlag = Platform.isAndroid ? "A" : "I";
      final appVerRes = await PushNotificationService.getAppVer({
        'platformFlag': platformFlag,
      });
      if (appVerRes.containsKey('error')) {
        state = state.copyWith(isAuthInProgress: false);
        return _showErrorDialog(context, appVerRes["results"]);
      }

      String storeAppVersion = '';
      String requiredYn = "";
      if (appVerRes['results'].length > 0) {
        storeAppVersion = appVerRes['results']['appVer'];
        requiredYn = appVerRes['results']['requiredYn'];
      }

      if (storeAppVersion != deviceAppVersion && requiredYn == "Y") {
        state = state.copyWith(
          storeAppVersion: storeAppVersion,
          deviceAppVersion: deviceAppVersion,
          requiredYn: requiredYn,
          isAppUpdateAlert: true,
          isAuthInProgress: false,
        );
        return;
      }

      final loginInfoStorage = await DeviceStorage.read("loginInfo");

      // 디바이스 정보 초기화
      await initDeviceSetting();

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.getNotificationSettings();
      String? fcmToken = "";

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        fcmToken = await messaging.getToken();
      }
      //이전에 로그인 기록 O 이면서 자동로그인여부가  Y이면 자동로그인 처리
      if (loginInfoStorage != null && loginInfoStorage['autoLoginYn'] == "Y") {
        print('자동 로그인 시도 중...');
        final res = await LoginService.postAppAuto({
          "deviceUuid": loginInfoStorage['deviceUuid'], //Device uuid 값
          "userId": loginInfoStorage['userId'],
          "appTkn": fcmToken,
        });
        if (res.containsKey('error')) {
          await DeviceStorage.delete("loginInfo");
          state = state.copyWith(isAuthInProgress: false);
          _showErrorDialog(context, res["results"]);
          // 에러 다이얼로그 표시 후 로그인 페이지로 이동
          Future.microtask(() {
            if (context.mounted) {
              GoRouter.of(context).go('/login');
            }
          });
          return;
        }
        await Session.initialize(
          res["results"]["encryptUserInfo"],
          res["results"]["accessTkn"],
        );
        // storage에 storeInfo 토큰 등록
        final decryptedJson = CryptoHelper.decryptJson(
          (res["results"]["encryptUserInfo"]),
        );
        await DeviceStorage.write("storeInfo", decryptedJson);
        print('자동 로그인 성공 - 홈 화면으로 이동');
        // 홈 화면으로 이동
        Future.microtask(() {
          if (context.mounted) {
            GoRouter.of(context).go('/home');
          }
        });
        return;
      }

      print('자동 로그인 조건 불충족 - 로그인 화면으로 이동');
      // 자동 로그인 조건 불충족 시 로그인 페이지로 이동
      Future.microtask(() {
        if (context.mounted) {
          GoRouter.of(context).go('/login');
        }
      });
    } catch (e) {
      print('인증 처리 중 오류 발생: $e');
      state = state.copyWith(isAuthInProgress: false);
    } finally {
      state = state.copyWith(isAuthInProgress: false);
    }
  }

  // 디바이스 저장
  Future<void> postDeviceInfo(data) async {
    await DeviceStorage.write("deviceInfo", data);
  }

  // 디바이스 정보 초기화
  Future<void> initDeviceSetting() async {
    final deviceInfoStorage = await DeviceStorage.read("deviceInfo");

    if (Platform.isAndroid && deviceInfoStorage == null) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      await DeviceStorage.write("deviceInfo", {
        "uuid": uuid.v4(),
        "platForm": "A",
        "modelNm": androidInfo.device,
      });
    }
    if (Platform.isIOS && deviceInfoStorage == null) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      await DeviceStorage.write("deviceInfo", {
        "uuid": uuid.v4(),
        "platForm": "I",
        "modelNm": iosInfo.modelName,
      });
    }
  }

  //데이터 조회 하는 함수
  Future<PackageInfo> _getPackageInfo() async {
    return PackageInfo.fromPlatform();
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: '오류',
          content: message,
          confirmBtnLabel: '확인',
        );
      },
    );
  }
}

/// AuthCheckViewModel Provider
final authCheckViewModelProvider =
    NotifierProvider<AuthCheckViewModel, AuthCheckState>(
      AuthCheckViewModel.new,
    );
