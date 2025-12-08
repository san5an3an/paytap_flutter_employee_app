import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';

import 'sales_home_search_screen_model.dart';

/// 판매 홈 검색 화면
/// 검색 기능을 제공하는 화면입니다.
class SalesHomeSearchScreen extends ConsumerWidget {
  const SalesHomeSearchScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesHomeSearchScreenModelProvider);
    final vm = ref.read(salesHomeSearchScreenModelProvider.notifier);

    // 화면이 처음 로드될 때만 데이터를 가져옴
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!state.isInitialized) {
        vm.initialize();
      }
    });

    // 초기화가 완료되지 않았으면 로딩 표시
    if (!state.isInitialized) {
      return Layout(
        isDisplayBottomNavigationBar: false,
        headerEmptyHeight: 0,
        onBackButtonPressed: () {
          Navigator.of(context).pop();
        },
        children: const Center(child: CircularProgressIndicator()),
      );
    }
    return Layout(
      isDisplayBottomNavigationBar: false,
      headerEmptyHeight: 0,
      onBackButtonPressed: () {
        Navigator.of(context).pop();
      },
      children: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: searchInput(
                      hintText: "기능 검색",
                      controller: vm.searchController,
                      onClear: () {
                        vm.onTapClearSearch();
                      },
                      onChanged: (value) {
                        vm.onChangeSearch(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
                    highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('취소', style: GlobalTextStyle.body02),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                vm.searchController.text.isEmpty ? '최근 검색어' : '검색 결과',
                style: TextStyle(
                  color: GlobalColor.bk01,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ...(vm.searchController.text.isEmpty
                      ? state.recentSearchList
                      : state.searchMenuList)
                  .map(
                    (item) => menuTile(
                      title: item["title"],
                      icon: item["icon"],
                      isDelete: vm
                          .searchController
                          .text
                          .isEmpty, // 최근 검색어일 때만 삭제 버튼 표시
                      onTap: () async {
                        vm.onTapMenuTile(context, item);
                      },
                      onTapDelete: () async {
                        await vm.onTapSearchDelete(item);
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 검색 인풋 위젯
/// - 좌측에 돋보기 아이콘, 우측에 닫기(X) 버튼
/// - 배경색, 라운드, 그림자 등 디자인 반영
Widget searchInput({
  String hintText = "기능 검색",
  TextEditingController? controller,
  VoidCallback? onClear,
  ValueChanged<String>? onChanged,
}) {
  return Container(
    height: 44,
    decoration: BoxDecoration(
      color: GlobalColor.bk08,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Row(
      children: [
        const SizedBox(width: 15),
        Icon(Icons.search, color: GlobalColor.bk03, size: 20),
        const SizedBox(width: 15),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: GlobalTextStyle.body02,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: GlobalTextStyle.body02.copyWith(
                color: GlobalColor.bk03,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (controller != null && controller.text.isNotEmpty)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
              highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
              onTap: onClear,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Icon(
                  Symbols.cancel,
                  color: GlobalColor.bk03,
                  size: 24,
                  fill: 1,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget menuTile({
  String? title,
  String? icon,
  bool isDelete = false,
  VoidCallback? onTap,
  VoidCallback? onTapDelete,
}) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTap,
            child: Row(
              children: [
                SvgPicture.asset(icon ?? "", width: 20, height: 20),
                const SizedBox(width: 15),
                Text(title ?? ""),
              ],
            ),
          ),
        ),
        if (isDelete)
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTapDelete,
            child: SizedBox(
              width: 50,
              height: 50,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Icon(
                    Symbols.close_small,
                    size: 20,
                    color: GlobalColor.bk03,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
