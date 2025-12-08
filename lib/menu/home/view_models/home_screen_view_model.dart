import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/models/session.dart';
import 'package:paytap_app/common/services/statistics_service.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/utils/query_state.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 홈 화면의 상태 모델
class HomeScreenState {
  final bool isLoading;
  final bool isInitialized;
  final String lastUpdateTime;
  final String userNm;
  final QueryState queryState;
  final List<Map<String, dynamic>> totalSaleList;
  final List<Map<String, dynamic>> todaySaleList;

  HomeScreenState({
    this.isLoading = false,
    this.isInitialized = false,
    this.lastUpdateTime = "",
    this.userNm = "",
    QueryState? queryState,
    this.totalSaleList = const [],
    this.todaySaleList = const [],
  }) : queryState =
           queryState ??
           QueryState({
             "targetDe": DateHelpers.getYYYYMMDDString(DateTime.now()),
             "weeklyStartDe": DateHelpers.getYYYYMMDDString(DateTime.now()),
             "weeklyEndDe": DateHelpers.getYYYYMMDDString(DateTime.now()),
             "monthlyStartDe": DateHelpers.getYYYYMMString(DateTime.now()),
             "monthlyEndDe": DateHelpers.getYYYYMMString(DateTime.now()),
           });

  HomeScreenState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? lastUpdateTime,
    String? userNm,
    QueryState? queryState,
    List<Map<String, dynamic>>? totalSaleList,
    List<Map<String, dynamic>>? todaySaleList,
  }) {
    return HomeScreenState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      userNm: userNm ?? this.userNm,
      queryState: queryState ?? this.queryState,
      totalSaleList: totalSaleList ?? this.totalSaleList,
      todaySaleList: todaySaleList ?? this.todaySaleList,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class HomeScreenViewModel extends Notifier<HomeScreenState> {
  @override
  HomeScreenState build() {
    return HomeScreenState(
      totalSaleList: [
        {
          "title": "오늘 총 매출",
          "price": 0,
          "icon": "assets/icons/i_today.svg",
          "link": "/sales/sales-view/daily-sales-detail",
          "type": "today",
        },
        {
          "title": "이번 주 총 매출",
          "price": 0,
          "icon": "assets/icons/i_weekly.svg",
          "link": "/sales/sales-view/receipt-history",
          "type": "week",
        },
        {
          "title": "이번 달 총 매출",
          "price": 0,
          "icon": "assets/icons/i_monthly.svg",
          "link": "/sales/sales-view/receipt-history",
          "type": "month",
        },
      ],
      todaySaleList: [
        {
          "title": "카드 결제",
          "price": 0,
          "icon": "assets/icons/i_creditCard.svg",
          "link": "/sales/sales-view/payment-history",
          "type": "card",
        },
        {
          "title": "현금 결제",
          "price": 0,
          "icon": "assets/icons/i_money.svg",
          "link": "/sales/sales-view/payment-history",
          "type": "cash",
        },
        {
          "title": "간편 결제",
          "price": 0,
          "icon": "assets/icons/i_simplePayment.svg",
          "link": "/sales/sales-view/payment-history",
          "type": "simple",
        },
        {
          "title": "포인트 결제",
          "price": 0,
          "icon": "assets/icons/i_pointPay.svg",
          "link": "/sales/sales-view/payment-history",
          "type": "point",
        },
      ],
    );
  }

  /// 홈 화면 초기화 메서드
  /// 화면이 처음 로드될 때만 데이터를 가져옴
  void initializeHome(BuildContext context) {
    if (!state.isInitialized) {
      final userNm = Session.storeInfo["storeNm"];
      final updatedQueryState = QueryState(
        Map<String, dynamic>.from(state.queryState.getAllQuery()),
      );
      _updateWeekDates(updatedQueryState);
      _updateMonthDates(updatedQueryState);

      state = state.copyWith(
        isInitialized: true,
        userNm: userNm,
        queryState: updatedQueryState,
      );

      getHome(context);
    }
  }

  /// 이번 주 날짜로 queryState를 업데이트하는 메서드
  void _updateWeekDates(QueryState queryState) {
    final now = DateTime.now();
    final weekDates = DateHelpers.getWeekStartEnd(now);
    queryState.onChangeQuery(
      "weeklyStartDe",
      DateHelpers.getYYYYMMDDString(weekDates['start']!),
    );
    queryState.onChangeQuery(
      "weeklyEndDe",
      DateHelpers.getYYYYMMDDString(weekDates['end']!),
    );
  }

  void _updateMonthDates(QueryState queryState) {
    final now = DateTime.now();
    final monthDates = DateHelpers.getMonthStartEnd(now);
    queryState.onChangeQuery(
      "monthlyStartDe",
      DateHelpers.getYYYYMMString(monthDates['start']!),
    );
    queryState.onChangeQuery(
      "monthlyEndDe",
      DateHelpers.getYYYYMMString(monthDates['end']!),
    );
  }

  Future<void> getHome(BuildContext context) async {
    // 업데이트 시간 기록
    final now = DateTime.now();
    final lastUpdateTime = DateHelpers.getTimehoursWithPeriod(now);

    state = state.copyWith(lastUpdateTime: lastUpdateTime);

    final data = {
      "targetDe": state.queryState["targetDe"],
      "weeklyStartDe": state.queryState["weeklyStartDe"],
      "weeklyEndDe": state.queryState["weeklyEndDe"],
      "monthlyStartDe": state.queryState["monthlyStartDe"],
      "monthlyEndDe": state.queryState["monthlyEndDe"],
    };
    final res = await StatisticsService.getAppSaleHome(data);
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }

    _updateSaleData(res["results"]);
  }

  /// API 응답 데이터를 파싱하여 매출 데이터를 업데이트하는 메서드
  void _updateSaleData(Map<String, dynamic> results) {
    final updatedTotalSaleList = state.totalSaleList.map((item) {
      final itemMap = Map<String, dynamic>.from(item);

      // 이번 달 총 매출 업데이트
      if (results["monthlyStats"] != null && itemMap["type"] == "month") {
        final monthlyStats = results["monthlyStats"] as Map<String, dynamic>;
        final monthlySaleAmt = monthlyStats["saleAmt"] ?? 0.0;
        itemMap["price"] = monthlySaleAmt;
      }

      // 이번 주 총 매출 업데이트
      if (results["weeklyStats"] != null && itemMap["type"] == "week") {
        final weeklyStats = results["weeklyStats"] as Map<String, dynamic>;
        final weeklySaleAmt = weeklyStats["saleAmt"] ?? 0.0;
        itemMap["price"] = weeklySaleAmt;
      }

      // 오늘 총 매출 업데이트
      if (results["todayStats"] != null && itemMap["type"] == "today") {
        final todayStats = results["todayStats"] as Map<String, dynamic>;
        final todaySaleAmt = todayStats["saleAmt"] ?? 0.0;
        itemMap["price"] = todaySaleAmt;
      }

      return itemMap;
    }).toList();

    final updatedTodaySaleList = state.todaySaleList.map((item) {
      final itemMap = Map<String, dynamic>.from(item);

      if (results["todayStats"] != null) {
        final todayStats = results["todayStats"] as Map<String, dynamic>;

        // 카드 결제
        if (itemMap["type"] == "card") {
          itemMap["price"] = todayStats["cardApprAmt"] ?? 0.0;
        }
        // 현금 결제
        else if (itemMap["type"] == "cash") {
          itemMap["price"] = todayStats["totCashAmt"] ?? 0.0;
        }
        // 간편 결제
        else if (itemMap["type"] == "simple") {
          itemMap["price"] = todayStats["easyPayAmt"] ?? 0.0;
        }
        // 포인트 결제
        else if (itemMap["type"] == "point") {
          itemMap["price"] = todayStats["usePtAmt"] ?? 0.0;
        }
      }

      return itemMap;
    }).toList();

    state = state.copyWith(
      totalSaleList: updatedTotalSaleList,
      todaySaleList: updatedTodaySaleList,
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

/// HomeViewModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final homeScreenViewModelProvider =
    NotifierProvider.autoDispose<HomeScreenViewModel, HomeScreenState>(
      HomeScreenViewModel.new,
    );
