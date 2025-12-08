import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paytap_app/common/services/payment_service.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/widget/amount_card/data/amount_card_model.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';
import 'package:paytap_app/common/widget/cm_search/data/search_config.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 결제 내역 화면의 상태 모델
class PaymentHistoryState {
  final Map<String, dynamic> searchState;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isInitialized;
  final List originalList;
  final List itemList;
  final SearchConfig searchConfig;
  final List<AmountCardModel> amountCardMainList;

  PaymentHistoryState({
    required this.searchState,
    this.isLoading = false,
    this.isInitialLoading = false,
    this.isInitialized = false,
    this.originalList = const [],
    this.itemList = const [],
    SearchConfig? searchConfig,
    this.amountCardMainList = const [],
  }) : searchConfig =
           searchConfig ??
           SearchConfig(
             list: [
               SearchConfigItem(
                 label: "포스",
                 name: "posNo",
                 type: CmSearchType.pos,
                 options: [],
               ),
               SearchConfigItem(
                 label: "날짜",
                 name: "startDe",
                 type: CmSearchType.rangeDayDate,
                 startDateKey: "startDe",
                 endDateKey: "endDe",
               ),
               SearchConfigItem(
                 label: "승인구분",
                 name: "payTypeFlag",
                 type: CmSearchType.approvalType,
               ),
             ],
           );

  PaymentHistoryState copyWith({
    Map<String, dynamic>? searchState,
    bool? isLoading,
    bool? isInitialLoading,
    bool? isInitialized,
    List? originalList,
    List? itemList,
    SearchConfig? searchConfig,
    List<AmountCardModel>? amountCardMainList,
  }) {
    return PaymentHistoryState(
      searchState: searchState ?? this.searchState,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      originalList: originalList ?? this.originalList,
      itemList: itemList ?? this.itemList,
      searchConfig: searchConfig ?? this.searchConfig,
      amountCardMainList: amountCardMainList ?? this.amountCardMainList,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class PaymentHistoryScreenModel extends Notifier<PaymentHistoryState> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final ScrollController scrollController = ScrollController();

  @override
  PaymentHistoryState build() {
    // dispose 콜백 등록
    ref.onDispose(() {
      scrollController.dispose();
    });

    return PaymentHistoryState(
      searchState: {
        "posNo": "",
        "startDe": DateHelpers.getYYYYMMDDString(DateTime.now()),
        "endDe": DateHelpers.getYYYYMMDDString(DateTime.now()),
        "payTypeFlag": "",
        "startNo": 0,
        "recordSize": 10,
      },
      amountCardMainList: [
        AmountCardModel(
          name: 'totalDcmSaleAmt',
          label: '승인금액누계',
          value: 0,
          icon: 'assets/icons/i_sale.svg',
          color: 'bk01',
        ),
      ],
    );
  }

  void setSearchState(Map<String, dynamic> newState, BuildContext context) {
    state = state.copyWith(searchState: newState);
    print(newState);
    refreshData(context);
  }

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// 초기 로딩 상태 설정
  void setInitialLoading(bool loading) {
    state = state.copyWith(isInitialLoading: loading);
  }

  /// 초기 데이터 로드
  Future<void> initializeData(BuildContext context, args) async {
    if (state.isInitialized) return;

    Map<String, dynamic> updatedState = Map<String, dynamic>.from(
      state.searchState,
    );
    // args가 null이면 건너뛰기
    if (args != null) {
      if (args['type'] == "card") {
        updatedState['payTypeFlag'] = "03"; // 신용카드
      } else if (args['type'] == "cash") {
        updatedState['payTypeFlag'] = "01"; // 현금
      } else if (args['type'] == "simple") {
        updatedState['payTypeFlag'] = "05"; // 간편결제
      } else if (args['type'] == "point") {
        updatedState['payTypeFlag'] = "15"; // 회원포인트적립
      }
    }

    state = state.copyWith(searchState: updatedState);
    setLoading(true);
    try {
      await getPaymentHistory(context);

      state = state.copyWith(isInitialized: true);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 추가 데이터 로드
  Future<void> loadMoreData(BuildContext context) async {
    if (!state.isLoading) {
      setLoading(true);
      try {
        await getPaymentHistory(context);
      } catch (e) {
        print('Error loading more data: $e');
      } finally {
        setLoading(false);
      }
    }
  }

  /// 새로고침
  Future<void> refreshData(BuildContext context) async {
    if (!state.isInitialLoading) {
      setInitialLoading(true);
      try {
        await resetPaymentHistoryList();
        await getPaymentHistory(context);
      } catch (e) {
        print('Error during reset and reload: $e');
      } finally {
        setInitialLoading(false);
      }
    }
  }

  //데이터 초기화 하는 함수
  Future<void> resetPaymentHistoryList() async {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['startNo'] = 0;
    updatedState['recordSize'] = 10;

    final updatedAmountCardList = state.amountCardMainList.map((item) {
      return AmountCardModel(
        name: item.name,
        label: item.label,
        value: 0,
        icon: item.icon,
        color: item.color,
      );
    }).toList();

    state = state.copyWith(
      originalList: [],
      itemList: [],
      searchState: updatedState,
      amountCardMainList: updatedAmountCardList,
    );
  }

  //데이터 조회 하는 함수
  Future<void> getPaymentHistory(BuildContext context) async {
    Map<String, dynamic> data = {...state.searchState};
    data['startNo'] = 0;
    data['recordSize'] = 10;

    Map<String, dynamic> res = await PaymentService.getAppSale(data);

    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }
    if (res['results'].isNotEmpty) {
      final updatedAmountCardList = state.amountCardMainList.map((item) {
        return AmountCardModel(
          name: item.name,
          label: item.label,
          value: res['results']['totalStats'][item.name] ?? 0,
          icon: item.icon,
          color: item.color,
        );
      }).toList();

      final updatedState = Map<String, dynamic>.from(state.searchState);
      updatedState['startNo'] =
          updatedState['startNo'] + updatedState['recordSize'];

      final paymentList = List<Map<String, dynamic>>.from(
        res['results']['paymentList'],
      );
      for (var item in paymentList) {
        item['apprDate'] = item['apprDt'].substring(0, 8);
      }

      final updatedOriginalList = [...state.originalList, ...paymentList];
      final convertData = convertPaymentHistoryItemData(updatedOriginalList);

      state = state.copyWith(
        searchState: updatedState,
        originalList: updatedOriginalList,
        itemList: convertData,
        amountCardMainList: updatedAmountCardList,
      );
    }
  }

  List<Map<String, dynamic>> convertPaymentHistoryItemData(List<dynamic> list) {
    Map<String, List<Map<String, dynamic>>> groupedBySaleDe =
        CommonHelpers.grouyByList(list, 'apprDate');

    // 결과 출력
    List<Map<String, dynamic>> resultList = [];
    groupedBySaleDe.forEach((apprDate, sales) {
      Map<String, dynamic> totalData = {'apprDate': apprDate, 'child': sales};

      resultList.add(totalData);
    });

    return resultList;
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

/// PaymentHistoryScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final paymentHistoryScreenModelProvider =
    NotifierProvider.autoDispose<
      PaymentHistoryScreenModel,
      PaymentHistoryState
    >(PaymentHistoryScreenModel.new);
