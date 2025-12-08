import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paytap_app/common/models/device_storage.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:paytap_app/menu/profile/profile_home/services/profile_service.dart';

/// 프로필 화면의 상태 모델
class ProfileState {
  final String storeNm;
  final String roadnmAdres;
  final String detailAdres;
  final String phone;
  final bool isInitialized;
  final bool isLoading;
  final List<Map<String, dynamic>> menuList;

  const ProfileState({
    this.storeNm = "",
    this.roadnmAdres = "",
    this.detailAdres = "",
    this.phone = "",
    this.isInitialized = false,
    this.isLoading = false,
    required this.menuList,
  });

  ProfileState copyWith({
    String? storeNm,
    String? roadnmAdres,
    String? detailAdres,
    String? phone,
    bool? isInitialized,
    bool? isLoading,
    List<Map<String, dynamic>>? menuList,
  }) {
    return ProfileState(
      storeNm: storeNm ?? this.storeNm,
      roadnmAdres: roadnmAdres ?? this.roadnmAdres,
      detailAdres: detailAdres ?? this.detailAdres,
      phone: phone ?? this.phone,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      menuList: menuList ?? this.menuList,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class ProfileViewModel extends Notifier<ProfileState> {
  final ProfileService profileService = ProfileService();

  @override
  ProfileState build() {
    return ProfileState(
      menuList: const [
        {
          "label": "비밀번호 변경",
          "icon": "assets/icons/key-square 2.svg",
          "route": "/profile/pwd-change",
        },
        {
          "label": "알림센터",
          "icon": "assets/icons/i_notification.svg",
          "route": "/profile/alarm-history",
        },
        {
          "label": "서비스 이용 약관",
          "icon": "assets/icons/i_refundMoney.svg",
          "route": "/profile/terms",
        },
        {
          "label": "앱 정보",
          "icon": "assets/icons/paytap_Logo.svg",
          "action": "app_info",
        },
      ],
    );
  }

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// 초기 데이터 로딩 함수
  Future<void> initializeData(BuildContext context) async {
    if (state.isInitialized) return;

    setLoading(true);
    try {
      await getStoreInfo(context);
      state = state.copyWith(isInitialized: true);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setLoading(false);
    }
  }

  // 매장 정보 조회
  Future<void> getStoreInfo(BuildContext context) async {
    Map<String, dynamic>? storeInfoList = await DeviceStorage.read('storeInfo');

    if (storeInfoList == null) {
      return;
    }
    String fchqCode = storeInfoList['storeInfo']['storeUnqcd'].substring(
      0,
      5,
    ); // 앞 5자리
    String storeCode = storeInfoList['storeInfo']['storeUnqcd'].substring(
      5,
      12,
    ); // 뒤 6자리

    Map<String, dynamic> res = await profileService.getStoreInfo({
      'fchqCode': fchqCode,
      "storeCode": storeCode,
    });
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }

    state = state.copyWith(
      storeNm: res["results"]['storeNm'],
      phone: res["results"]['storeCellno'],
      roadnmAdres: res["results"]['roadnmAdres'],
      detailAdres: res["results"]['detailAdres'],
    );
  }

  //APP 로그아웃 함수
  Future<void> postLogout(context) async {
    final loginInfoStorage = await DeviceStorage.read("loginInfo");

    Map<String, dynamic> res = await profileService.postLogout(
      loginInfoStorage,
    );
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }
    await DeviceStorage.delete('storeInfo');
    GoRouter.of(context).go('/login');
  }

  void showLogoutDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          type: 'multiple',
          autoBtnClose: false,
          title: '로그아웃',
          content: "로그아웃 하시겠습니까?",
          confirmBtnLabel: "로그아웃",
          confirmBtnOnPressed: () {
            postLogout(context);
          },
          confirmBtnColor: GlobalColor.systemRed,
          cancelBtnOnPressed: () {
            Navigator.of(context).pop();
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

/// ProfileViewModel Provider
final profileViewModelProvider =
    NotifierProvider.autoDispose<ProfileViewModel, ProfileState>(
      ProfileViewModel.new,
    );
