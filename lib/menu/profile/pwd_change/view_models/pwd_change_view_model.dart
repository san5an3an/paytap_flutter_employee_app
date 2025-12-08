import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paytap_app/common/models/device_storage.dart';
import 'package:paytap_app/common/utils/query_state.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:paytap_app/menu/profile/pwd_change/services/pwd_change_service.dart';

/// 비밀번호 변경 화면의 상태 모델
class PwdChangeState {
  final String currentPwdError;
  final String newPwdError;
  final String confirmPwdError;
  final bool currentPwdValid;
  final bool newPwdValid;
  final bool confirmPwdValid;
  final QueryState queryState;

  const PwdChangeState({
    this.currentPwdError = "비밀번호를 입력해주세요.",
    this.newPwdError = "비밀번호를 입력해주세요.",
    this.confirmPwdError = "비밀번호를 입력해주세요.",
    this.currentPwdValid = false,
    this.newPwdValid = false,
    this.confirmPwdValid = false,
    required this.queryState,
  });

  PwdChangeState copyWith({
    String? currentPwdError,
    String? newPwdError,
    String? confirmPwdError,
    bool? currentPwdValid,
    bool? newPwdValid,
    bool? confirmPwdValid,
    QueryState? queryState,
  }) {
    return PwdChangeState(
      currentPwdError: currentPwdError ?? this.currentPwdError,
      newPwdError: newPwdError ?? this.newPwdError,
      confirmPwdError: confirmPwdError ?? this.confirmPwdError,
      currentPwdValid: currentPwdValid ?? this.currentPwdValid,
      newPwdValid: newPwdValid ?? this.newPwdValid,
      confirmPwdValid: confirmPwdValid ?? this.confirmPwdValid,
      queryState: queryState ?? this.queryState,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class PwdChangeViewModel extends Notifier<PwdChangeState> {
  final PwdChangeService pwdChangeService = PwdChangeService();

  @override
  PwdChangeState build() {
    return PwdChangeState(
      queryState: QueryState({
        "currentPwd": "",
        "newPwd": "",
        "confirmPwd": "",
      }),
    );
  }

  // 현재 비밀번호 onChange
  Future<void> onChangeCurrentPwd(String name, value) async {
    final loginInfoStorage = await DeviceStorage.read("loginInfo");

    final updatedQueryState = QueryState({
      ...state.queryState.getAllQuery(),
      'currentPwd': value,
    });

    if (value == "") {
      state = state.copyWith(
        currentPwdError: "비밀번호를 입력해주세요.",
        currentPwdValid: false,
        queryState: updatedQueryState,
      );
      return;
    }
    if (loginInfoStorage!['password'] != value) {
      state = state.copyWith(
        currentPwdError: "비밀번호가 일치하지 않아요.",
        currentPwdValid: false,
        queryState: updatedQueryState,
      );
      return;
    }

    state = state.copyWith(
      currentPwdError: "",
      currentPwdValid: true,
      queryState: updatedQueryState,
    );
  }

  // 새 비밀번호 onChange
  void onChangeNewPwd(String name, value) {
    final updatedQueryState = QueryState({
      ...state.queryState.getAllQuery(),
      'newPwd': value,
    });

    String confirmPwdError = state.confirmPwdError;
    bool confirmPwdValid = state.confirmPwdValid;

    if (updatedQueryState['confirmPwd'] != value) {
      confirmPwdError = "비밀번호가 일치하지 않아요.";
      confirmPwdValid = false;
    }
    if (updatedQueryState['confirmPwd'] == value) {
      confirmPwdError = "";
      confirmPwdValid = true;
    }

    if (value == "") {
      state = state.copyWith(
        newPwdError: "비밀번호를 입력해주세요.",
        newPwdValid: false,
        confirmPwdError: confirmPwdError,
        confirmPwdValid: confirmPwdValid,
        queryState: updatedQueryState,
      );
      return;
    }

    // 새로운 비밀번호 유효성 검증 (영문, 숫자,특수문자 포함 10~20자리)
    // 영문, 숫자가 각각 하나 이상 포함되어 있는지 확인
    bool hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    bool hasNumber = RegExp(r'\d').hasMatch(value);
    bool hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    bool isValidLength = value.length >= 10 && value.length <= 20;

    if (!hasLetter || !hasNumber || !isValidLength || !hasSpecialChar) {
      state = state.copyWith(
        newPwdError: "비밀번호는 영문,숫자,특수문자를 포함한 10~20자리까지 설정 가능해요",
        newPwdValid: false,
        confirmPwdError: confirmPwdError,
        confirmPwdValid: confirmPwdValid,
        queryState: updatedQueryState,
      );
      return;
    }

    state = state.copyWith(
      newPwdError: "",
      newPwdValid: true,
      confirmPwdError: confirmPwdError,
      confirmPwdValid: confirmPwdValid,
      queryState: updatedQueryState,
    );
  }

  // 비밀번호 확인 onChange
  void onChangeConfirmPwd(String name, value) {
    final updatedQueryState = QueryState({
      ...state.queryState.getAllQuery(),
      'confirmPwd': value,
    });

    if (value == "") {
      state = state.copyWith(
        confirmPwdError: "비밀번호를 입력해주세요.",
        confirmPwdValid: false,
        queryState: updatedQueryState,
      );
      return;
    }

    // 새 비밀번호와 값이 같은지 확인
    if (value != updatedQueryState['newPwd']) {
      state = state.copyWith(
        confirmPwdError: "비밀번호가 일치하지 않아요.",
        confirmPwdValid: false,
        queryState: updatedQueryState,
      );
      return;
    }

    state = state.copyWith(
      confirmPwdError: "",
      confirmPwdValid: true,
      queryState: updatedQueryState,
    );
  }

  //비밀번호 변경
  Future<void> changePassword(context) async {
    if (!state.currentPwdValid ||
        !state.newPwdValid ||
        !state.confirmPwdValid) {
      return;
    }
    final loginInfoStorage = await DeviceStorage.read("loginInfo");

    Map<String, dynamic> res = await pwdChangeService.patchChangePw({
      'serviceCode': "1000004",
      'userId': loginInfoStorage!['userId'],
      'password': state.queryState['newPwd'],
    });

    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }

    await DeviceStorage.delete("storeInfo");
    await DeviceStorage.delete("loginInfo");

    _showConfirmDialog(
      context,
      '비밀번호 변경 완료',
      '비밀번호가 변경 되었습니다. 다시 로그인 해주세요.',
      isSuccess: true,
    );
  }

  void _showConfirmDialog(context, title, message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: title,
          content: message,
          confirmBtnLabel: '확인',
          autoBtnClose: !isSuccess,
          confirmBtnOnPressed: () {
            if (isSuccess) {
              GoRouter.of(context).go('/login');
            }
          },
        );
      },
    );
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

/// PwdChangeViewModel Provider
final pwdChangeViewModelProvider =
    NotifierProvider.autoDispose<PwdChangeViewModel, PwdChangeState>(
      PwdChangeViewModel.new,
    );
