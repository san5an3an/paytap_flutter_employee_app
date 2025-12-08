import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/menu/profile/profile_home/view_models/profile_view_model.dart';
import 'package:paytap_app/menu/profile/profile_home/views/app_info_modal.dart';
import 'package:paytap_app/menu/profile/profile_home/views/headline_account.dart';
import 'package:paytap_app/menu/profile/profile_home/views/inquiry_modal.dart';
import 'package:paytap_app/menu/profile/profile_home/views/privacy_modal.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  @override
  void initState() {
    super.initState();
    // 초기화 (한 번만 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(profileViewModelProvider.notifier);
      final state = ref.read(profileViewModelProvider);
      if (!state.isInitialized && !state.isLoading) {
        notifier.initializeData(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final notifier = ref.read(profileViewModelProvider.notifier);

    return Layout(
      title: '마이페이지',
      currentIdx: 2,
      children: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          _showBackDialog(context);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeadlineAccount(
                  storeNm: state.storeNm,
                  phone: state.phone,
                  detailAdres: state.detailAdres,
                  roadnmAdres: state.roadnmAdres,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: GlobalColor.bk08,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: state.menuList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final menuItem = entry.value;
                      final isLast = index == state.menuList.length - 1;
                      return Column(
                        children: [
                          menuTile(
                            context,
                            menuItem['label'],
                            menuItem['icon'],
                            menuItem['route'],
                            menuItem['action'],
                          ),
                          if (!isLast) const SizedBox(height: 5),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
                      highlightColor: GlobalColor.brand01.withValues(
                        alpha: 0.1,
                      ),
                      onTap: () {
                        notifier.showLogoutDialog(context);
                      },
                      child: Container(
                        width: 200,
                        padding: EdgeInsets.all(15),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: GlobalColor.systemRed,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                        child: Text(
                          '로그아웃',
                          style: GlobalTextStyle.title04.copyWith(
                            color: GlobalColor.systemRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showBackDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ConfirmDialog(
        type: 'multiple',
        title: '앱 종료',
        content: '앱을 종료하시겠습니까?',
        confirmBtnLabel: '종료하기',
        confirmBtnOnPressed: () {
          SystemNavigator.pop();
        },
        cancelBtnLabel: '취소하기',
      );
    },
  );
}

Widget menuTile(
  BuildContext context,
  String title,
  String icon,
  String? route,
  String? action,
) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
      highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
      onTap: () {
        if (route != null) {
          context.push(route);
        }
        if (action != null) {
          _handleAction(context, action);
        }
      },
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(width: 30, height: 30, icon),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: GlobalTextStyle.title04.copyWith(
                          color: GlobalColor.bk01,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Icon(Symbols.arrow_right_alt_rounded, fill: 1),
                    const SizedBox(width: 15),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

void _handleAction(BuildContext context, String action) {
  switch (action) {
    case 'inquiry':
      // 문의하기 모달 표시
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return TextareaModal();
        },
      );
      break;
    case 'privacy':
      // 개인정보 처리 방침 모달 표시
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return PrivacyModal();
        },
      );
      break;
    case 'app_info':
      // 앱 정보 모달 표시
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return AppInfoModal();
        },
      );
      break;
  }
}
