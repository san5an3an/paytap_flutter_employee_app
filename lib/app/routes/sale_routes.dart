import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paytap_app/menu/sales/cancel_hist/cancel_hist_screen.dart';
import 'package:paytap_app/menu/sales/cancel_hist_detail/cancel_hist_detail_screen.dart';
import 'package:paytap_app/menu/sales/card_company_sales/card_company_sales_screen.dart';
import 'package:paytap_app/menu/sales/card_company_sales/views/card_company_sales_detail_view.dart';
import 'package:paytap_app/menu/sales/dc_type_sales/dc_type_sales_screen.dart';
import 'package:paytap_app/menu/sales/goods_detail/goods_detail_screen.dart';
import 'package:paytap_app/menu/sales/goods_sales/goods_sales_screen.dart';
import 'package:paytap_app/menu/sales/receipt_detail/receipt_detail_screen.dart';
import 'package:paytap_app/menu/sales/sales_differences/days_sales/days_sales_screen.dart';
import 'package:paytap_app/menu/sales/sales_differences/months_sales/months_sales_screen.dart';
import 'package:paytap_app/menu/sales/sales_differences/time_sales/time_sales_screen.dart';
import 'package:paytap_app/menu/sales/sales_home/sales_home_screen.dart';
import 'package:paytap_app/menu/sales/sales_home_search/sales_home_search_screen.dart';
import 'package:paytap_app/menu/sales/sales_view/daily_sales_detail/daily_sales_detail_screen.dart';
import 'package:paytap_app/menu/sales/sales_view/daily_total_sales/daily_total_sales_screen.dart';
import 'package:paytap_app/menu/sales/sales_view/monthly_total_sales/monthly_total_sales_screen.dart';
import 'package:paytap_app/menu/sales/sales_view/payment_history/payment_history_screen.dart';
import 'package:paytap_app/menu/sales/sales_view/receipt_history/receipt_history_screen.dart';
import 'package:paytap_app/menu/sales/sales_view/return_history/return_history_screen.dart';
import 'package:paytap_app/menu/sales/settlement_approval/card_approval_history/card_approval_history_screen.dart';
import 'package:paytap_app/menu/sales/settlement_approval/cash_receipt_approval_history/cash_receipt_approval_history_screen.dart';
import 'package:paytap_app/menu/sales/settlement_approval/easy_approval_history/easy_approval_history_screen.dart';
import 'package:paytap_app/menu/sales/settlement_approval/settlement_history/settlement_history_screen.dart';
import 'package:paytap_app/menu/sales/settlement_approval/user_register_history/user_register_history_screen.dart';

class SaleRoutes {
  static List<GoRoute> goRoutes = [
    // 매출 홈 화면
    GoRoute(
      path: '/sales/home',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const SalesHomeScreen()),
    ),
    // 매출 검색 화면
    GoRoute(
      path: '/sales/home/search',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const SalesHomeSearchScreen(),
      ),
    ),
    // 당일 매출 상세
    GoRoute(
      path: '/sales/sales-view/daily-sales-detail',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const DailySalesDetailScreen(),
      ),
    ),
    // 영수 내역
    GoRoute(
      path: '/sales/sales-view/receipt-history',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const ReceiptHistoryScreen()),
    ),
    // 영수증 상세 내역 화면
    GoRoute(
      path: '/sales/sales-view/receipt-detail',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const ReceiptDetailScreen()),
    ),
    // 결제 내역
    GoRoute(
      path: '/sales/sales-view/payment-history',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const PaymentHistoryScreen()),
    ),
    // 반품 내역
    GoRoute(
      path: '/sales/sales-view/return-history',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const ReturnHistoryScreen()),
    ),
    // 일 종합 매출
    GoRoute(
      path: '/sales/sales-view/daily-total-sales',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const DailyTotalSalesScreen(),
      ),
    ),
    // 월 종합 매출
    GoRoute(
      path: '/sales/sales-view/monthly-total-sales',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const MonthlyTotalSalesScreen(),
      ),
    ),
    // 시간대별 매출 동향
    GoRoute(
      path: '/sales/sales-differences/time-sales',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const TimeSalesScreen()),
    ),
    // 요일별 매출 동향
    GoRoute(
      path: '/sales/sales-differences/days-sales',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const DaysSalesScreen()),
    ),
    // 월별 매출 동향
    GoRoute(
      path: '/sales/sales-differences/months-sales',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const MonthsSales()),
    ),
    // 상품별 매출
    GoRoute(
      path: '/sales/goods-sales',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const GoodsSalesScreen()),
    ),
    // 상품 상세 화면
    GoRoute(
      path: '/sales/goods-sales/detail',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const GoodsDetailScreen()),
    ),
    // 카드사별 누계
    GoRoute(
      path: '/sales/card-company-sales',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const CardCompanySalesScreen(),
      ),
    ),
    // 카드사별 상세
    GoRoute(
      path: '/sales/card-company-sales/detail',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const CardCompanySalesDetailView(),
      ),
    ),
    // 할인 유형별 매출
    GoRoute(
      path: '/sales/dc-type-sales',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const DcTypeSalesScreen()),
    ),
    // 정산 내역
    GoRoute(
      path: '/sales/settlement_approval/settlement_history',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const SettlementHistoryScreen(),
      ),
    ),
    // 카드 승인 내역
    GoRoute(
      path: '/sales/settlement_approval/card-approval-history',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const CardApprovalHistoryScreen(),
      ),
    ),
    // 간편 승인 내역
    GoRoute(
      path: '/sales/settlement_approval/easy-approval-history',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const EasyApprovalHistoryScreen(),
      ),
    ),
    // 현금 영수 승인 내역
    GoRoute(
      path: '/sales/settlement_approval/cash-receipt-approval-history',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const CashReceiptApprovalHistoryScreen(),
      ),
    ),
    // 임의 등록 내역
    GoRoute(
      path: '/sales/settlement_approval/user-register-history',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const UserRegisterHistoryScreen(),
      ),
    ),
    // 주문 취소
    GoRoute(
      path: '/sales/cancel-hist',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const CancelHistScreen()),
    ),
    // 주문 취소 상세
    GoRoute(
      path: '/sales/cancel-hist/detail',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const CancelHistDetailScreen(),
      ),
    ),
  ];
}
