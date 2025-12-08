import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:paytap_app/menu/profile/profile_home/services/app_info_modal_service.dart';

/// 앱 정보 모달 화면의 상태 모델
class AppInfoModalState {
  final String storeAppVersion;
  final String deviceAppVersion;
  final String appName;
  final bool isSameVersion;

  const AppInfoModalState({
    this.storeAppVersion = '',
    this.deviceAppVersion = '',
    this.appName = '',
    this.isSameVersion = false,
  });

  AppInfoModalState copyWith({
    String? storeAppVersion,
    String? deviceAppVersion,
    String? appName,
    bool? isSameVersion,
  }) {
    return AppInfoModalState(
      storeAppVersion: storeAppVersion ?? this.storeAppVersion,
      deviceAppVersion: deviceAppVersion ?? this.deviceAppVersion,
      appName: appName ?? this.appName,
      isSameVersion: isSameVersion ?? this.isSameVersion,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class AppInfoModalViewModel extends Notifier<AppInfoModalState> {
  final AppInfoModalService appInfoModalService = AppInfoModalService();

  @override
  AppInfoModalState build() {
    return const AppInfoModalState();
  }

  //데이터 조회 하는 함수
  Future<void> getAppVersion(context) async {
    final data = await _getPackageInfo();
    String deviceAppVersion = data.version;
    String storeAppVersion = '';

    if (Platform.isAndroid) {
      final res = await appInfoModalService.getAppVer({'platformFlag': "A"});
      if (res.containsKey('error')) {
        return _showErrorDialog(context, res["results"]);
      }
      if (res['results'].length > 0) {
        storeAppVersion = res['results']['appVer'];
      }
    }
    if (Platform.isIOS) {
      final res = await appInfoModalService.getAppVer({'platformFlag': "I"});
      if (res.containsKey('error')) {
        return _showErrorDialog(context, res["results"]);
      }
      if (res['results'].length > 0) {
        storeAppVersion = res['results']['appVer'];
      }
    }

    final appName = data.appName;
    final isSameVersion = storeAppVersion == deviceAppVersion;

    state = state.copyWith(
      storeAppVersion: storeAppVersion,
      deviceAppVersion: deviceAppVersion,
      appName: appName,
      isSameVersion: isSameVersion,
    );
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

/// AppInfoModalViewModel Provider
final appInfoModalViewModelProvider =
    NotifierProvider.autoDispose<AppInfoModalViewModel, AppInfoModalState>(
      AppInfoModalViewModel.new,
    );
