import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paytap_app/menu/profile/alarm_history/alarm_history.dart';
import 'package:paytap_app/menu/profile/faq/faq.dart';
import 'package:paytap_app/menu/profile/inquiry/inquiry.dart';
import 'package:paytap_app/menu/profile/notice/notice.dart';
import 'package:paytap_app/menu/profile/profile_home/profile.dart';
import 'package:paytap_app/menu/profile/pwd_change/pwd_change_screen.dart';
import 'package:paytap_app/menu/profile/terms/terms_screen.dart';

class ProfileRoutes {
  static List<GoRoute> goRoutes = [
    // 마이페이지 홈 화면
    GoRoute(
      path: '/profile/home',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const Profile()),
    ),
    // 알림 내역
    GoRoute(
      path: '/profile/alarm-history',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const AlarmHistory()),
    ),
    // 공지사항
    GoRoute(
      path: '/profile/notice',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const Notice()),
    ),
    // FAQ
    GoRoute(
      path: '/profile/faq',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const Faq()),
    ),
    // 문의하기
    GoRoute(
      path: '/profile/inquiry',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const Inquiry()),
    ),
    // 비밀번호 변경
    GoRoute(
      path: '/profile/pwd-change',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const PwdChangeScreen()),
    ),
    // 서비스 이용약관
    GoRoute(
      path: '/profile/terms',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const TermsScreen()),
    ),
  ];
}
