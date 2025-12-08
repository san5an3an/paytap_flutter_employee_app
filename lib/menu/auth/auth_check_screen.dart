import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/app/app_config.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:paytap_app/menu/auth/view_models/auth_check_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthCheckScreen extends ConsumerStatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  ConsumerState<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends ConsumerState<AuthCheckScreen> {
  bool isLoading = false;
  bool _hasInitialized = false; // 중복 호출 방지 플래그 추가

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 중복 호출 방지
    if (_hasInitialized) return;
    _hasInitialized = true;

    // go_router에서는 extra를 사용하지 않으므로 arguments는 null로 처리
    // (AuthCheckScreen은 초기 라우트이므로 extra가 없음)
    // WidgetsBinding을 사용하여 다음 프레임에서 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAuth();
    });
  }

  Future<void> getAuth() async {
    setState(() {
      isLoading = true;
    });

    try {
      final notifier = ref.read(authCheckViewModelProvider.notifier);
      await notifier.getAuth(context);
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
  Widget build(BuildContext context) {
    final state = ref.watch(authCheckViewModelProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.isAppUpdateAlert) {
        _showUpdateDialog(context);
      }
    });
    return const Scaffold(
      backgroundColor: Colors.white, // 하얀 배경 설정
      body: Center(
        child: CircularProgressIndicator(), // 로딩 인디케이터 표시 (옵션)
      ),
    );
  }

  void _showUpdateDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Platform.isAndroid) {
          return ConfirmDialog(
            type: 'multiple',
            title: '업데이트',
            content: '최신 버전 필수 업데이트가 있습니다.',
            confirmBtnLabel: '이동하기',
            confirmBtnOnPressed: () async {
              final url = Uri.parse(AppConfig.googlePlayUrl);
              if (await canLaunchUrl(url)) {
                launchUrl(url, mode: LaunchMode.externalApplication);
                SystemNavigator.pop();
              }
            },
            cancelBtnLabel: '종료하기',
            cancelBtnOnPressed: () {
              SystemNavigator.pop();
            },
          );
        }

        return ConfirmDialog(
          type: 'multiple',
          title: '업데이트',
          content: '최신 버전 필수 업데이트가 있습니다.',
          confirmBtnLabel: '확인',
          confirmBtnOnPressed: () async {
            final url = Uri.parse(AppConfig.appStoreUrl);
            if (await canLaunchUrl(url)) {
              launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          cancelBtnLabel: '취소',
          cancelBtnOnPressed: () {
            Navigator.of(context).pop(); // 팝업 닫기
            _showCancelUpdateIosDialog(context);
          },
        );
      },
    );
  }

  void _showCancelUpdateIosDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: '앱 종료',
          content: '최신 버전이 아니어서 앱 사용이 불가능합니다. 앱을 종료해주세요.',
          confirmBtnLabel: '확인',
          confirmBtnOnPressed: () async {},
        );
      },
    );
  }
}
