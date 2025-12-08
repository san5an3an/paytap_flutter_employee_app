import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paytap_app/common/models/c_option.dart';
import 'package:paytap_app/common/services/statistics_service.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/widget/amount_card/data/amount_card_model.dart';
import 'package:paytap_app/common/widget/cm_donut_chart/data/cm_donut_chart_data_model.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';
import 'package:paytap_app/common/widget/cm_search/data/search_config.dart';
import 'package:paytap_app/common/widget/cm_segmented_button/data/segmented_button_data.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';

/// 상품 매출 화면의 상태 모델
class GoodsSalesState {
  final Map<String, dynamic> searchState;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isInitialized;
  final List originalList;
  final List goodsSalesItemList;
  final SearchConfig searchConfig;
  final List<COption> posList;
  final List<AmountCardModel> amountCardList;
  final List<CmDonutChartDataModel> donutChartData;

  GoodsSalesState({
    required this.searchState,
    this.isLoading = false,
    this.isInitialLoading = false,
    this.isInitialized = false,
    this.originalList = const [],
    this.goodsSalesItemList = const [],
    SearchConfig? searchConfig,
    this.posList = const [],
    this.amountCardList = const [],
    this.donutChartData = const [],
  }) : searchConfig =
           searchConfig ??
           SearchConfig(
             list: [
               SearchConfigItem(
                 label: "기간",
                 type: CmSearchType.rangeDayDate,
                 name: "dateRange",
                 startDateKey: "startDe",
                 endDateKey: "endDe",
               ),
               SearchConfigItem(
                 label: "포스",
                 type: CmSearchType.pos,
                 name: "posNo",
               ),
             ],
           );

  GoodsSalesState copyWith({
    Map<String, dynamic>? searchState,
    bool? isLoading,
    bool? isInitialLoading,
    bool? isInitialized,
    List? originalList,
    List? goodsSalesItemList,
    SearchConfig? searchConfig,
    List<COption>? posList,
    List<AmountCardModel>? amountCardList,
    List<CmDonutChartDataModel>? donutChartData,
  }) {
    return GoodsSalesState(
      searchState: searchState ?? this.searchState,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      originalList: originalList ?? this.originalList,
      goodsSalesItemList: goodsSalesItemList ?? this.goodsSalesItemList,
      searchConfig: searchConfig ?? this.searchConfig,
      posList: posList ?? this.posList,
      amountCardList: amountCardList ?? this.amountCardList,
      donutChartData: donutChartData ?? this.donutChartData,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class GoodsSalesScreenModel extends Notifier<GoodsSalesState> {
  final storage = FlutterSecureStorage();
  final ScrollController scrollController = ScrollController();

  // 세그먼트 버튼 옵션 (상수)
  final List<SegmentedButtonOption> contentTypeOptions = [
    const SegmentedButtonOption(title: '매출', value: 'sales'),
    const SegmentedButtonOption(title: '상품', value: 'goods'),
  ];
  final List<SegmentedButtonOption> itemOptions = [
    const SegmentedButtonOption(title: '원', value: 'P'),
    const SegmentedButtonOption(title: '개', value: 'Q'),
  ];

  // 도넛 차트 색상 배열 (상수)
  final List<Color> chartColors = [
    GlobalColor.brand01, // 파란색
    GlobalColor.brand03, // 회색
    GlobalColor.systemGreen, // 녹색
    GlobalColor.brand04, // 티얼
    GlobalColor.bk03, // 연한 회색
  ];

  @override
  GoodsSalesState build() {
    // dispose 콜백 등록
    ref.onDispose(() {
      scrollController.dispose();
    });

    return GoodsSalesState(
      searchState: {
        'startDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
        'endDe': DateHelpers.getYYYYMMDDString(DateTime.now()),
        'posNo': '',
        'startNo': 0,
        'recordSize': 10,
        'orderFlag': 'P',
        'contentType': 'sales',
      },
      amountCardList: [
        AmountCardModel(
          name: 'saleAmt',
          label: '총 매출 금액',
          value: 0,
          icon: 'assets/icons/i_sale.svg',
          color: 'bk01',
        ),
        AmountCardModel(
          name: 'dcAmt',
          label: '총 판매 개수',
          value: 0,
          icon: 'assets/icons/i_product.svg',
          color: 'bk03',
        ),
      ],
    );
  }

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// 초기 로딩 상태 설정
  void setInitialLoading(bool loading) {
    state = state.copyWith(isInitialLoading: loading);
  }

  /// 검색 상태 업데이트
  void updateSearchState(Map<String, dynamic> newState) {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState.addAll(newState);
    state = state.copyWith(searchState: updatedState);
  }

  /// 도넛 차트 데이터 생성
  void generateDonutChartData(List<dynamic> goodsData) {
    if (goodsData.isEmpty) {
      state = state.copyWith(donutChartData: []);
      return;
    }

    // 상위 5개 상품만 선택
    final top5Goods = goodsData.take(5).toList();

    // 총 매출액 계산
    final totalSalePrice = top5Goods.fold<double>(
      0,
      (sum, item) => sum + (item['salePrice'] ?? 0.0),
    );

    // 도넛 차트 데이터 생성
    final donutChartData = top5Goods.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final salePrice = item['salePrice'] ?? 0.0;
      final goodsNm = item['goodsNm'] ?? '상품명 없음';

      // 비율 계산 (총 매출액 대비)
      final percentage = totalSalePrice > 0
          ? (salePrice / totalSalePrice) * 100
          : 0.0;

      return CmDonutChartDataModel(
        label: goodsNm,
        value: percentage,
        color: chartColors[index % chartColors.length],
      );
    }).toList();

    state = state.copyWith(donutChartData: donutChartData);
  }

  /// 초기 데이터 로딩 함수
  Future<void> initializeData(BuildContext context) async {
    if (state.isInitialized) return;

    setLoading(true);
    try {
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

  //데이터 초기화 하는 함수
  Future<void> resetGoodsSalesList() async {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['startNo'] = 0;
    updatedState['recordSize'] = 10;

    state = state.copyWith(
      originalList: [],
      goodsSalesItemList: [],
      searchState: updatedState,
      donutChartData: [],
    );
  }

  //데이터 조회 하는 함수
  Future<void> getGoodsSales(BuildContext context) async {
    Map<String, dynamic> data = {...state.searchState};

    Map<String, dynamic> res = await StatisticsService.getAppRankGoods(data);
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }
    if (res['results']['goods'].length > 0) {
      final updatedAmountCardList = state.amountCardList.map((item) {
        if (item.name == "saleAmt") {
          return AmountCardModel(
            name: item.name,
            label: item.label,
            value: res['results']['totalAmt']['salePrice'] ?? 0,
            icon: item.icon,
            color: item.color,
          );
        } else if (item.name == "dcAmt") {
          return AmountCardModel(
            name: item.name,
            label: item.label,
            value: res['results']['totalAmt']['dcPrice'] ?? 0,
            icon: item.icon,
            color: item.color,
          );
        }
        return item;
      }).toList();

      final updatedState = Map<String, dynamic>.from(state.searchState);
      updatedState['startNo'] =
          updatedState['startNo'] + updatedState['recordSize'];

      final goodsList = List<Map<String, dynamic>>.from(
        res['results']['goods'],
      );
      for (var item in goodsList) {
        item['startDe'] = data['startDe'];
        item['endDe'] = data['endDe'];
      }

      final updatedOriginalList = [...state.originalList, ...goodsList];

      // 도넛 차트 데이터 생성
      generateDonutChartData(res['results']['goods']);

      state = state.copyWith(
        searchState: updatedState,
        originalList: updatedOriginalList,
        goodsSalesItemList: updatedOriginalList,
        amountCardList: updatedAmountCardList,
      );
    }
  }

  /// 매출 상품 구분 메서드
  void onSalesGoodsButtonTap(String name, String value, BuildContext context) {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['contentType'] = value;
    if (value == 'sales') {
      updatedState['orderFlag'] = 'P';
    }
    state = state.copyWith(searchState: updatedState);
    refreshData(context);
  }

  /// 상품 원,개 선택 메서드
  void onPriceOrCountButtonTap(
    String name,
    String value,
    BuildContext context,
  ) {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState['orderFlag'] = value;
    state = state.copyWith(searchState: updatedState);
    refreshData(context);
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

/// GoodsSalesScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final goodsSalesScreenModelProvider =
    NotifierProvider.autoDispose<GoodsSalesScreenModel, GoodsSalesState>(
      GoodsSalesScreenModel.new,
    );
