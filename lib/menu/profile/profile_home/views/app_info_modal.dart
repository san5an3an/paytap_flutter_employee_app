import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/app/app_config.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/bottom_modal/bottom_modal.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:paytap_app/menu/profile/profile_home/view_models/app_info_modal_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfoModal extends ConsumerStatefulWidget {
  const AppInfoModal({super.key});

  @override
  ConsumerState<AppInfoModal> createState() => _AppInfoModalState();
}

class _AppInfoModalState extends ConsumerState<AppInfoModal> {
  bool isLoading = false;

  Future _getAppVersion() async {
    setState(() {
      isLoading = true;
    });
    try {
      final notifier = ref.read(appInfoModalViewModelProvider.notifier);
      await notifier.getAppVersion(context);
    } catch (e) {
      print('Error loading more data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _getAppVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appInfoModalViewModelProvider);

    return BottomModal(
      title: '앱 정보',
      content: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: GlobalColor.bk07,
                    border: Border.all(width: 1, color: GlobalColor.dim03),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  'V.${state.deviceAppVersion}',
                  style: GlobalTextStyle.body02.copyWith(
                    color: GlobalColor.bk03,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              state.appName,
              style: GlobalTextStyle.title03.copyWith(
                color: GlobalColor.bk01,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            if (state.isSameVersion)
              Text(
                '앱이 최신버전입니다.',
                style: GlobalTextStyle.body02.copyWith(color: GlobalColor.bk03),
              ),
            if (!state.isSameVersion)
              Text(
                '앱이 최신버전이 아닙니다.',
                style: GlobalTextStyle.body02.copyWith(color: GlobalColor.bk03),
              ),
            if (!state.isSameVersion)
              Text(
                '업데이트 하실 것을 권장드립니다.',
                style: GlobalTextStyle.body02.copyWith(color: GlobalColor.bk03),
              ),
            const SizedBox(height: 40),
            if (!state.isSameVersion)
              Center(
                child: FilledButton(
                  onPressed: () async {
                    if (Platform.isAndroid) {
                      final url = Uri.parse(AppConfig.googlePlayUrl);
                      if (await canLaunchUrl(url)) {
                        launchUrl(url, mode: LaunchMode.externalApplication);
                        SystemNavigator.pop();
                      }
                    }
                    if (Platform.isIOS) {
                      _showUpdateDialog(context);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: GlobalColor.brand01,
                    minimumSize: const Size(200, 50),
                  ),
                  child: Text(
                    '업데이트',
                    style: GlobalTextStyle.body02M.copyWith(
                      color: GlobalColor.rev01,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

void _showUpdateDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ConfirmDialog(
        title: '업데이트',
        content: '최신 버전 업데이트 링크로 이동하겠습니다.',
        type: 'multiple',
        confirmBtnLabel: '확인',
        cancelBtnLabel: '취소',
        confirmBtnOnPressed: () async {
          final url = Uri.parse(AppConfig.appStoreUrl);
          if (await canLaunchUrl(url)) {
            launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
      );
    },
  );
}
