import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paytap_app/common/constants/menu_list.dart';
import 'package:paytap_app/common/models/device_storage.dart';

/// 판매 홈 검색 화면의 상태 모델
class SalesHomeSearchScreenState {
  final Map<String, dynamic> searchState;
  final bool isInitialized;
  final List<Map<String, dynamic>> initMenuList;
  final List<Map<String, dynamic>> searchMenuList;
  final List<Map<String, dynamic>> recentSearchList;

  const SalesHomeSearchScreenState({
    this.searchState = const {"searchText": ""},
    this.isInitialized = false,
    this.initMenuList = const [],
    this.searchMenuList = const [],
    this.recentSearchList = const [],
  });

  SalesHomeSearchScreenState copyWith({
    Map<String, dynamic>? searchState,
    bool? isInitialized,
    List<Map<String, dynamic>>? initMenuList,
    List<Map<String, dynamic>>? searchMenuList,
    List<Map<String, dynamic>>? recentSearchList,
  }) {
    return SalesHomeSearchScreenState(
      searchState: searchState ?? this.searchState,
      isInitialized: isInitialized ?? this.isInitialized,
      initMenuList: initMenuList ?? this.initMenuList,
      searchMenuList: searchMenuList ?? this.searchMenuList,
      recentSearchList: recentSearchList ?? this.recentSearchList,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class SalesHomeSearchScreenModel extends Notifier<SalesHomeSearchScreenState> {
  //검색 Controller
  final TextEditingController searchController = TextEditingController();

  @override
  SalesHomeSearchScreenState build() {
    return const SalesHomeSearchScreenState();
  }

  void initialize() async {
    /// 최근 검색어 리스트를 저장하는 변수

    final recentList = await DeviceStorage.read("recentSearchData");
    List<Map<String, dynamic>> recentSearchList = [];
    if (recentList != null && recentList["recentSearchList"] != null) {
      recentSearchList = List<Map<String, dynamic>>.from(
        recentList["recentSearchList"],
      );
    }

    // salesList에서 child가 있는 항목들을 단일 뎁스 리스트로 변환
    List<Map<String, dynamic>> initMenuList = [];
    for (var menuItem in MenuList.salesList) {
      if (menuItem.containsKey('child') && menuItem['child'] != null) {
        // child가 있는 경우, child 항목들을 recentSearchList에 추가
        for (var childItem in menuItem['child']) {
          initMenuList.add(childItem);
        }
      } else if (menuItem.containsKey('route')) {
        // 단일 항목인 경우 직접 추가
        initMenuList.add(menuItem);
      }
    }
    print(initMenuList);
    state = state.copyWith(
      isInitialized: true,
      initMenuList: initMenuList,
      recentSearchList: recentSearchList,
    );
    print(initMenuList);
  }

  /// 검색어 변경 시 호출되는 메서드
  void onChangeSearch(String searchText) {
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState["searchText"] = searchText;

    List<Map<String, dynamic>> searchMenuList = [];
    if (searchText.isEmpty) {
      // 검색어가 없으면 빈 리스트로 설정 (최근 검색어 표시)
      searchMenuList = [];
    } else {
      // 검색어가 있으면 해당 문자열을 포함하는 메뉴 필터링
      searchMenuList = state.initMenuList.where((item) {
        return item['title'].toString().toLowerCase().contains(
          searchText.toLowerCase(),
        );
      }).toList();
    }

    state = state.copyWith(
      searchState: updatedState,
      searchMenuList: searchMenuList,
    );
  }

  /// 검색어 초기화
  void onTapClearSearch() {
    searchController.clear();
    final updatedState = Map<String, dynamic>.from(state.searchState);
    updatedState["searchText"] = "";
    state = state.copyWith(searchState: updatedState, searchMenuList: []);
  }

  // 메뉴 타일 클릭
  Future<void> onTapMenuTile(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    final recentSearchData = await DeviceStorage.read("recentSearchData");
    List<Map<String, dynamic>> recentList = [];

    // 기존 데이터가 있으면 가져오기
    if (recentSearchData != null &&
        recentSearchData["recentSearchList"] != null) {
      recentList = List<Map<String, dynamic>>.from(
        recentSearchData["recentSearchList"],
      );
    }

    // 중복 제거 (같은 title이 있으면 제거)
    recentList.removeWhere((element) => element["title"] == item["title"]);

    // 새 아이템 추가
    recentList.add({
      "title": item["title"],
      "icon": item["icon"],
      "route": item["route"],
    });

    // 5개 초과시 맨 앞 제거
    if (recentList.length > 5) {
      recentList.removeAt(0);
    }

    // 저장
    await DeviceStorage.write("recentSearchData", {
      "recentSearchList": recentList,
    });

    // recentSearchList 업데이트
    state = state.copyWith(recentSearchList: recentList);

    // 현재 화면을 제거하고 /sales/home으로 이동한 후 선택한 화면으로 이동
    GoRouter.of(context).go('/sales/home');

    // 선택한 화면으로 이동
    GoRouter.of(context).push(item["route"]);
  }

  // 최근 검색어 삭제
  Future<void> onTapSearchDelete(Map<String, dynamic> item) async {
    // 메모리에서 제거
    final updatedList = List<Map<String, dynamic>>.from(state.recentSearchList);
    updatedList.removeWhere((element) => element["title"] == item["title"]);

    // DeviceStorage에서도 제거
    final recentSearchData = await DeviceStorage.read("recentSearchData");
    if (recentSearchData != null &&
        recentSearchData["recentSearchList"] != null) {
      List<Map<String, dynamic>> storageList = List<Map<String, dynamic>>.from(
        recentSearchData["recentSearchList"],
      );

      // title을 기준으로 제거
      storageList.removeWhere((element) => element["title"] == item["title"]);

      // 업데이트된 리스트를 저장
      await DeviceStorage.write("recentSearchData", {
        "recentSearchList": storageList,
      });
    }

    state = state.copyWith(recentSearchList: updatedList);
  }
}

/// SalesHomeSearchScreenModel Provider
/// Riverpod 3.0.3 - NotifierProvider.autoDispose (권장)
final salesHomeSearchScreenModelProvider =
    NotifierProvider.autoDispose<
      SalesHomeSearchScreenModel,
      SalesHomeSearchScreenState
    >(SalesHomeSearchScreenModel.new);
