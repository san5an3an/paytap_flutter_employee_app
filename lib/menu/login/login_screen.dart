import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/cm_check_box/cm_check_box.dart';
import 'package:paytap_app/common/widget/input/input_v2.dart';
import 'package:paytap_app/menu/login/view_models/login_view_model.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginViewModelProvider);
    final notifier = ref.read(loginViewModelProvider.notifier);

    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          notifier.showBackDialog(context);
        },
        child: Center(
          child: Container(
            color: GlobalColor.systemBackGround,
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: 240,
                      height: 60,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                    const SizedBox(height: 30),
                    InputV2(
                      name: 'userId',
                      value: state.loginData["userId"],
                      textFocus: state.idFocusNode,
                      leftIcon: Center(
                        child: SvgPicture.asset('assets/icons/i_id.svg'),
                      ),
                      labelText: '아이디',
                      onChange: notifier.onChangeData,
                      isClearIcon: true,
                      onSubmitted: (_) {
                        notifier.moveToPasswordField(context);
                      },
                    ),
                    const SizedBox(height: 15),
                    InputV2(
                      textFocus: state.pwdFocusNode,
                      name: 'password',
                      value: state.loginData["password"],
                      leftIcon: Center(
                        child: SvgPicture.asset(
                          'assets/icons/key-square 1.svg',
                        ),
                      ),
                      labelText: '비밀번호',
                      isObscureText: true,
                      onChange: notifier.onChangeData,
                      isClearIcon: true,
                      onSubmitted: (_) {
                        notifier.onLoginSubmitted(context);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CmCheckBox(
                          name: "autoLoginYn",
                          value: state.loginData["autoLoginYn"],
                          label: '자동 로그인',
                          onTapCheckBox: notifier.onChangeData,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GlobalColor.brand01,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        onPressed: state.isLoading
                            ? null
                            : () => notifier.onTapLogin(context),
                        child: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    GlobalColor.rev01,
                                  ),
                                ),
                              )
                            : Text(
                                '로그인',
                                style: GlobalTextStyle.title04.copyWith(
                                  color: GlobalColor.rev01,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
