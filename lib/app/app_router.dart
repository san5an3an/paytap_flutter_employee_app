import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paytap_app/app/routes/profile_routes.dart';
import 'package:paytap_app/app/routes/sale_routes.dart';
import 'package:paytap_app/menu/auth/auth_check_screen.dart';
import 'package:paytap_app/menu/home/home_screen.dart';
import 'package:paytap_app/menu/login/login_screen.dart';
import 'package:paytap_app/menu/test/test_screen.dart';

/// go_router 설정
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  observers: [AppRouteObserver()],
  routes: [
    // 홈 화면
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
    ),
    // 인증 체크 화면
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const AuthCheckScreen()),
    ),
    // 로그인 화면
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const LoginScreen()),
    ),
    // 테스트 화면
    GoRoute(
      path: '/test',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const TestScreen()),
    ),
    // 매출 관련 라우트
    ...SaleRoutes.goRoutes,
    // 프로필 관련 라우트
    ...ProfileRoutes.goRoutes,
  ],
);

/// 라우트 옵저버
class AppRouteObserver extends NavigatorObserver {
  static String? currentRouteName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    currentRouteName = route.settings.name;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    currentRouteName = previousRoute?.settings.name;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    currentRouteName = newRoute?.settings.name;
  }
}
