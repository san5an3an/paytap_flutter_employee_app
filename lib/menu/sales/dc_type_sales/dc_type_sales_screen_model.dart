import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paytap_app/common/models/c_option.dart';
import 'package:paytap_app/common/models/cm_code.dart';
import 'package:paytap_app/common/services/statistics_service.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/widget/amount_card/data/amount_card_model.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';
import 'package:paytap_app/common/widget/cm_search/data/search_config.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 할인 유형 매출 화면의 상태 모델
class DcTypeSalesState {
  final Map<String, dynamic> searchState;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isInitialized;
  final List originalList;
  final List goodsSalesItemList;
  final List<COption> dcTypeList;
  final List<AmountCardModel> amountCardList;

  DcTypeSalesState({
    required this.searchState,
    this.isLoading = false,
    this.isInitialLoading = false,
    this.isInitialized = false,
    this.originalList = const [],
    this.goodsSalesItemList = const [],
    this.dcTypeList = const [],
    this.amountCardList = const [],
  });

  SearchConfig get searchConfig => SearchConfig(
    list: [
      SearchConfigItem(label: "포스", type: CmSearchType.pos, name: "posNo"),
      SearchConfigItem(
        label: "할인 유형",
        type: CmSearchType.select,
        name: "dcTypeCode",
        options: dcTypeList,
      ),
      SearchConfigItem(
        label: "기간",
        type: CmSearchType.rangeDayDate,
        name: "dateRange",
        startDateKey: "startDe",
        endDateKey: "endDe",
      ),
    ],
  );

  DcTypeSalesState copyWith({
    Map<String, dynamic>? searchState,
    bool? isLoading,
    bool? isInitialLoading,
    bool? isInitialized,
    List? originalList,
    List? goodsSalesItemList,
    List<COption>? dcTypeList,
    List<AmountCardModel>? amountCardList,
  }) {
    return DcTypeSalesState(
      searchState: searchState ?? this.searchState,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      originalList: originalList ?? this.originalList,
      goodsSalesItemList: goodsSalesItemList ?? this.goodsSalesItemList,
      dcTypeList: dcTypeList ?? this.dcTypeList,
      amountCardList: amountCardList ?? this.amountCardList,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class DcTypeSalesScreenModel extends Notifier<DcTypeSalesState> {
  final storage = FlutterSecureStorage();
  final ScrollController scrollController = ScrollController();

  @override
  DcTypeSalesState build() {
    // dispose 콜백 등록
    ref.onDispose(() {
      scrollController.dispose();
    });

    return DcTypeSalesState(
      searchState: {
        'startDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
        'endDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
        'dcTypeCode': '',
        'posNo': '',
        'startNo': 0,
        'recordSize': 10,
      },
      amountCardList: [
        AmountCardModel(
          name: 'totSaleCnt',
          label: '총 판매 수량',
          value: 0,
          icon: 'assets/icons/i_product.svg',
          color: 'bk01',
        ),
        AmountCardModel(
          name: 'totSaleAmt',
          label: '총 매출 금액',
          value: 0,
          icon: 'assets/icons/i_saleTotal.svg',
          color: 'bk01',
        ),
        AmountCardModel(
          name: 'dcAmt',
          label: '할인 금액',
          value: 0,
          icon: 'assets/icons/i_discount.svg',
          color: 'bk03',
        ),
        AmountCardModel(
          name: 'totDcAmt',
          label: '총 할인 금액',
          value: 0,
          icon: 'assets/icons/i_discountTotal.svg',
          color: 'bk03',
        ),
        AmountCardModel(
          name: 'totDcmSaleAmt',
          label: '실 매출 금액',
          value: 0,
          icon: 'assets/icons/i_equal.svg',
          color: 'brand01',
        ),
      ],
    );
  }

  /// 검색 상태 업데이트
  void updateSearchState(Map<String, dynamic> newState) {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState.addAll(newState);
    state = state.copyWith(searchState: updatedState);
  }

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// 초기 로딩 상태 설정
  void setInitialLoading(bool loading) {
    state = state.copyWith(isInitialLoading: loading);
  }

  /// 초기 데이터 로딩 함수
  Future<void> initializeData(BuildContext context) async {
    if (state.isInitialized) return;

    setLoading(true);
    try {
      await setTopFiltter();
      await getGoodsSales(context);

      state = state.copyWith(isInitialized: true);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 추가 데이터 로딩 함수
  Future<void> loadMoreData(BuildContext context) async {
    if (!state.isLoading) {
      setLoading(true);
      try {
        await getGoodsSales(context);
      } catch (e) {
        print('Error loading more data: $e');
      } finally {
        setLoading(false);
      }
    }
  }

  /// 새로고침 함수
  Future<void> refreshData(BuildContext context) async {
    if (!state.isInitialLoading) {
      setInitialLoading(true);
      try {
        await resetGoodsSalesList();
        await getGoodsSales(context);
      } catch (e) {
        print('Error during refresh: $e');
      } finally {
        setInitialLoading(false);
      }
    }
  }

  Future<void> setTopFiltter() async {
    await getDcTypeList();
  }

  // 할인 유형 조회
  Future<void> getDcTypeList() async {
    final cmCodeDcTypeList = CmCode.getFindCmcodeList('636');
    final dcTypeList = <COption>[COption(title: '전체', value: '')];
    for (var element in cmCodeDcTypeList) {
      dcTypeList.add(COption(title: element.codeNm, value: element.code));
    }
    state = state.copyWith(dcTypeList: dcTypeList);
  }

  //데이터 초기화 하는 함수
  Future<void> resetGoodsSalesList() async {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['startNo'] = 0;
    updatedState['recordSize'] = 10;

    state = state.copyWith(
      originalList: [],
      goodsSalesItemList: [],
      searchState: updatedState,
    );
  }

  //데이터 조회 하는 함수
  Future<void> getGoodsSales(BuildContext context) async {
    Map<String, dynamic> data = {...state.searchState};

    Map<String, dynamic> res = await StatisticsService.getAppSaleDiscount(data);
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }
    if (res['results']['totalStats'].length > 0) {
      final updatedAmountCardList = state.amountCardList.map((item) {
        final totalStats = res['results']['totalStats'];
        if (item.name == "totSaleCnt") {
          return AmountCardModel(
            name: item.name,
            label: item.label,
            value: totalStats['totSaleCnt']?.toDouble() ?? 0.0,
            icon: item.icon,
            color: item.color,
          );
        } else if (item.name == "totSaleAmt") {
          return AmountCardModel(
            name: item.name,
            label: item.label,
            value: totalStats['totSaleAmt'] ?? 0,
            icon: item.icon,
            color: item.color,
          );
        } else if (item.name == "dcAmt") {
          return AmountCardModel(
            name: item.name,
            label: item.label,
            value: totalStats['dcAmt'] ?? 0,
            icon: item.icon,
            color: item.color,
          );
        } else if (item.name == "totDcAmt") {
          return AmountCardModel(
            name: item.name,
            label: item.label,
            value: totalStats['totDcAmt'] ?? 0,
            icon: item.icon,
            color: item.color,
          );
        } else if (item.name == "totDcmSaleAmt") {
          return AmountCardModel(
            name: item.name,
            label: item.label,
            value: totalStats['totDcmSaleAmt'] ?? 0,
            icon: item.icon,
            color: item.color,
          );
        }
        return item;
      }).toList();

      final updatedState = Map<String, dynamic>.from(state.searchState);
      updatedState['startNo'] =
          updatedState['startNo'] + updatedState['recordSize'];

      final statsList = List<Map<String, dynamic>>.from(
        res['results']['statsList'],
      );
      for (var item in statsList) {
        item['startDe'] = data['startDe'];
        item['endDe'] = data['endDe'];
      }

      final updatedOriginalList = [...state.originalList, ...statsList];

      state = state.copyWith(
        searchState: updatedState,
        originalList: updatedOriginalList,
        goodsSalesItemList: updatedOriginalList,
        amountCardList: updatedAmountCardList,
      );
    }
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

/// DcTypeSalesScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final dcTypeSalesScreenModelProvider =
    NotifierProvider.autoDispose<DcTypeSalesScreenModel, DcTypeSalesState>(
      DcTypeSalesScreenModel.new,
    );
