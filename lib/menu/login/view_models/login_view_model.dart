import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paytap_app/common/models/device_storage.dart';
import 'package:paytap_app/common/models/session.dart';
import 'package:paytap_app/common/services/login_service.dart';
import 'package:paytap_app/common/utils/crypto_helper.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:uuid/uuid.dart';

/// 로그인 화면의 상태 모델
class LoginState {
  final Map<String, dynamic> loginData;
  final String deviceModelVal;
  final String platformFlag;
  final String deviceUuid;
  final String? fcmToken;
  final bool isLoginHistory;
  final bool isLoading;
  final FocusNode? idFocusNode;
  final FocusNode? pwdFocusNode;

  const LoginState({
    required this.loginData,
    this.deviceModelVal = "",
    this.platformFlag = "",
    this.deviceUuid = "",
    this.fcmToken,
    this.isLoginHistory = false,
    this.isLoading = false,
    this.idFocusNode,
    this.pwdFocusNode,
  });

  LoginState copyWith({
    Map<String, dynamic>? loginData,
    String? deviceModelVal,
    String? platformFlag,
    String? deviceUuid,
    String? fcmToken,
    bool? isLoginHistory,
    bool? isLoading,
    FocusNode? idFocusNode,
    FocusNode? pwdFocusNode,
  }) {
    return LoginState(
      loginData: loginData ?? this.loginData,
      deviceModelVal: deviceModelVal ?? this.deviceModelVal,
      platformFlag: platformFlag ?? this.platformFlag,
      deviceUuid: deviceUuid ?? this.deviceUuid,
      fcmToken: fcmToken ?? this.fcmToken,
      isLoginHistory: isLoginHistory ?? this.isLoginHistory,
      isLoading: isLoading ?? this.isLoading,
      idFocusNode: idFocusNode ?? this.idFocusNode,
      pwdFocusNode: pwdFocusNode ?? this.pwdFocusNode,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class LoginViewModel extends Notifier<LoginState> {
  var uuid = Uuid();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  @override
  LoginState build() {
    final idFocusNode = FocusNode();
    final pwdFocusNode = FocusNode();

    // onDispose 콜백 등록
    ref.onDispose(() {
      try {
        idFocusNode.dispose();
      } catch (e) {
        // 이미 dispose된 경우 무시
      }
      try {
        pwdFocusNode.dispose();
      } catch (e) {
        // 이미 dispose된 경우 무시
      }
    });

    final initialState = LoginState(
      loginData: {"userId": "", "password": "", "autoLoginYn": false},
      idFocusNode: idFocusNode,
      pwdFocusNode: pwdFocusNode,
    );

    // 초기화 함수 실행
    _initialize();

    return initialState;
  }

  // 초기화
  Future<void> _initialize() async {
    await getDeviceInfo();

    await DeviceStorage.delete("loginInfo");

    final loginInfoStorage = await DeviceStorage.read("loginInfo");

    bool isLoginHistory = false;
    if (loginInfoStorage != null) {
      isLoginHistory = true;
    }

    // FCM 토큰 가져오기 (권한이 승인된 경우에만)
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();

    String? fcmToken;
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        print('FCM Token: $fcmToken');
      } else {
        print('FCM Token: null');
      }
    } else {
      print('알림 권한이 승인되지 않아 FCM 토큰을 가져오지 않습니다.');
    }

    state = state.copyWith(isLoginHistory: isLoginHistory, fcmToken: fcmToken);
  }

  /// 데이터 변경 메서드
  void onChangeData(String name, dynamic value) {
    final updatedLoginData = Map<String, dynamic>.from(state.loginData)
      ..[name] = value;
    state = state.copyWith(loginData: updatedLoginData);
  }

  /// 비밀번호 입력 필드로 포커스 이동
  void moveToPasswordField(BuildContext context) {
    FocusScope.of(context).requestFocus(state.pwdFocusNode);
  }

  /// 로그인 버튼 클릭 시 실행
  void onLoginSubmitted(BuildContext context) {
    onTapLogin(context);
  }

  /// 앱 종료 다이얼로그 표시
  void showBackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: '앱 종료',
          content: '앱을 종료하시겠습니까?',
          type: 'multiple',
          confirmBtnLabel: '종료하기',
          cancelBtnLabel: '취소하기',
          confirmBtnOnPressed: () {
            SystemNavigator.pop();
          },
        );
      },
    );
  }

  //데이터 초기화 하는 함수
  Future<void> postLogin(BuildContext context) async {
    state = state.copyWith(isLoading: true);

    try {
      // 로그인 전에 FCM 토큰을 다시 확인하고 가져오기
      // (권한 허용 후 로그인하는 경우를 대비)
      String? fcmToken = state.fcmToken;
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 권한이 승인된 경우 FCM 토큰 다시 가져오기
        final token = await messaging.getToken();
        if (token != null) {
          fcmToken = token;
          print('로그인 시 FCM Token 재확인: $fcmToken');
          // state 업데이트
          state = state.copyWith(fcmToken: fcmToken);
        }
      }

      Map<String, dynamic> data = Map.from(state.loginData);

      data['deviceModelVal'] = state.deviceModelVal;
      data['platformFlag'] = state.platformFlag;
      data['deviceUuid'] = state.deviceUuid;
      data['appTkn'] = fcmToken;
      print('로그인 시 사용할 fcmToken: $fcmToken');
      if (state.loginData['autoLoginYn']) {
        data['autoLoginYn'] = 'Y';
      } else {
        data['autoLoginYn'] = 'N';
      }

      final res = await LoginService.postAppInitial(data);
      if (res.containsKey('error')) {
        _showConfirmDialog(context, res["results"]);
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

      if (state.isLoginHistory) {
        await DeviceStorage.write("loginInfo", data);
      } else {
        await DeviceStorage.write("loginInfo", data);
      }
      // 로컬 db에 로그인 정보 등록

      GoRouter.of(context).go('/home');
    } catch (e) {
      _showConfirmDialog(context, "로그인 중 오류가 발생했습니다.");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> getDeviceInfo() async {
    final deviceInfoStorage = await DeviceStorage.read("deviceInfo");

    String deviceModelVal = "";
    String platformFlag = "";
    String deviceUuid = "";

    if (deviceInfoStorage != null) {
      deviceModelVal = deviceInfoStorage["modelNm"];
      platformFlag = deviceInfoStorage["platForm"];
      deviceUuid = deviceInfoStorage["uuid"];
    }

    state = state.copyWith(
      deviceModelVal: deviceModelVal,
      platformFlag: platformFlag,
      deviceUuid: deviceUuid,
    );
  }

  void onTapLogin(BuildContext context) {
    if (state.loginData['userId'] == "" || state.loginData['password'] == "") {
      return _showConfirmDialog(context, "아이디와 비밀번호를 확인해주세요.");
    }
    postLogin(context);
  }

  void _showConfirmDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: '로그인 실패',
          content: message,
          confirmBtnLabel: '확인',
        );
      },
    );
  }
}

/// LoginViewModel Provider
final loginViewModelProvider =
    NotifierProvider.autoDispose<LoginViewModel, LoginState>(
      LoginViewModel.new,
    );
