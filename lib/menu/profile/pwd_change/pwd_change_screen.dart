import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/input/input_v2.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/menu/profile/pwd_change/view_models/pwd_change_view_model.dart';

class PwdChangeScreen extends ConsumerWidget {
  const PwdChangeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pwdChangeViewModelProvider);
    final notifier = ref.read(pwdChangeViewModelProvider.notifier);

    return Layout(
      title: '비밀번호 변경',
      isDisplayBottomNavigationBar: false,
      children: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Text('현재 비밀번호', style: GlobalTextStyle.small01),
              SizedBox(height: 10),
              InputV2(
                name: 'currentPwd',
                value: state.queryState['currentPwd'],
                onChange: notifier.onChangeCurrentPwd,
                isObscureText: true,
                labelText: "현재 비밀번호 입력",
                errorText: state.currentPwdError,
                leftIcon: Center(
                  child: SvgPicture.asset('assets/icons/key-square 1.svg'),
                ),
                isClearIcon: true,
              ),
              const SizedBox(height: 40),
              Text('새 비밀번호', style: GlobalTextStyle.small01),
              SizedBox(height: 10),
              Text(
                "* 비밀번호는 영문, 숫자, 특수문자를 포함한 10 ~ 20자리로 설정해주세요.",
                style: GlobalTextStyle.small01.copyWith(
                  color: GlobalColor.bk03,
                ),
              ),
              const SizedBox(height: 10),
              InputV2(
                name: 'newPwd',
                value: state.queryState['newPwd'],
                onChange: notifier.onChangeNewPwd,
                leftIcon: Center(
                  child: SvgPicture.asset('assets/icons/key-square 2.svg'),
                ),
                labelText: "새 비밀번호 입력",
                isObscureText: true,
                errorText: state.newPwdError,
                isClearIcon: true,
              ),
              const SizedBox(height: 10),
              InputV2(
                name: 'confirmPwd',
                value: state.queryState['confirmPwd'],
                onChange: notifier.onChangeConfirmPwd,
                leftIcon: Center(
                  child: SvgPicture.asset('assets/icons/key-square 2.svg'),
                ),
                labelText: "비밀번호 확인",
                errorText: state.confirmPwdError,
                isClearIcon: true,
                isObscureText: true,
              ),
              const SizedBox(height: 65),
              Center(
                child: FilledButton(
                  onPressed: () async {
                    await notifier.changePassword(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        state.currentPwdValid &&
                            state.newPwdValid &&
                            state.confirmPwdValid
                        ? GlobalColor.brand01
                        : GlobalColor.bk04,
                    minimumSize: const Size(200, 50),
                  ),
                  child: Text(
                    '변경하기',
                    style: GlobalTextStyle.body02M.copyWith(
                      color: GlobalColor.rev01,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
