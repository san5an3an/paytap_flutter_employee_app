import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/menu/sales/sales_home/sales_home_screen_model.dart';

class SalesHomeScreen extends ConsumerStatefulWidget {
  const SalesHomeScreen({super.key});

  @override
  ConsumerState<SalesHomeScreen> createState() => _SalesHomeScreenState();
}

class _SalesHomeScreenState extends ConsumerState<SalesHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesHomeScreenModelProvider);
    final vm = ref.read(salesHomeScreenModelProvider.notifier);
    final selectedItem = state.selectedItem;
    final availableItems = vm.availableItems();

    return Layout(
      headerEmptyHeight: 0,
      currentIdx: 1,
      children: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          _showBackDialog(context);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 65),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text("매출 관리", style: GlobalTextStyle.title03),
                        ),
                        InkWell(
                          onTap: () {
                            context.push('/sales/home/search');
                          },
                          borderRadius: BorderRadius.circular(12),
                          splashColor: GlobalColor.brand01.withValues(
                            alpha: 0.2,
                          ),
                          highlightColor: GlobalColor.brand01.withValues(
                            alpha: 0.1,
                          ),
                          child: Icon(
                            Symbols.search,
                            color: GlobalColor.bk03,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // selectMenuCard와 GridView를 AnimatedSize로 감싸서 자연스러운 레이아웃 변화
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Column(
                    children: [
                      // 선택된 아이템이 있으면 selectMenuCard 표시 (좌측위에서 우측아래로 펼쳐지는 애니메이션)
                      if (selectedItem != null)
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 300),
                          tween: Tween(
                            begin: state.isAnimatingOut ? 1.0 : 0.0,
                            end: state.isAnimatingOut ? 0.0 : 1.0,
                          ),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              alignment: Alignment.topLeft,
                              child: Opacity(
                                opacity: value,
                                child: selectMenuCard(
                                  context,
                                  selectedItem,
                                  state,
                                  vm,
                                ),
                              ),
                            );
                          },
                        ),

                      // 아래 GridView는 그대로 둡니다.
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 15,
                              childAspectRatio: 1.3,
                            ),
                        itemCount: availableItems.length,
                        itemBuilder: (context, index) {
                          final item = availableItems[index];
                          return menuLinkCard(
                            context,
                            item['title'] as String,
                            item['icon'] as String,
                            item['route'] as String?,
                            item, // 전체 아이템을 전달
                            vm,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: '앱 종료',
          content: '앱을 종료하시겠습니까?',
          type: 'multiple',
          confirmBtnLabel: '종료하기',
          cancelBtnLabel: '취소하기',
          confirmBtnOnPressed: () {
            SystemNavigator.pop();
          },
        );
      },
    );
  }
}

Widget menuLinkCard(
  BuildContext context,
  String title,
  String icon,
  String? route,
  Map<String, dynamic> item,
  SalesHomeScreenModel vm,
) {
  return Material(
    color: GlobalColor.bk08,
    borderRadius: BorderRadius.circular(28),
    child: InkWell(
      borderRadius: BorderRadius.circular(28),
      splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
      highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
      onTap: () {
        // route가 있으면 해당 라우트로 이동
        if (route != null) {
          context.push(route);
        }
        // child나 children이 있으면 선택된 아이템으로 설정하여 selectMenuCard 표시
        else if (item['child'] != null || item['children'] != null) {
          vm.setSelectedItem(item);
        }
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(icon),
                Icon(Symbols.add, color: GlobalColor.bk03),
              ],
            ),
            Text(
              title,
              style: GlobalTextStyle.body01M.copyWith(color: GlobalColor.bk01),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget selectMenuCard(
  BuildContext context,
  Map<String, dynamic> item,
  SalesHomeState state,
  SalesHomeScreenModel vm,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: GlobalColor.bk08,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      children: [
        Row(
          children: [
            SvgPicture.asset(width: 30, height: 30, item['icon']),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  item['title'],
                  style: GlobalTextStyle.title04.copyWith(
                    color: GlobalColor.bk01,
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  vm.clearSelectedItem();
                },
                borderRadius: BorderRadius.circular(12),
                splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
                highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
                child: Icon(
                  Symbols.close_small_rounded,
                  color: GlobalColor.bk03,
                  size: 36,
                ),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 15, bottom: 15),
          child: Divider(color: GlobalColor.bk05, thickness: 1, height: 1),
        ),
        if (item['child'] != null)
          ...List.generate(item['child'].length, (index) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(
                begin: state.isAnimatingOut ? 1.0 : 0.0,
                end: state.isAnimatingOut ? 0.0 : 1.0,
              ),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: selectMenuItem(
                      context,
                      item['child'][index]['title'],
                      item['child'][index]['icon'],
                      item['child'][index]['route'],
                    ),
                  ),
                );
              },
            );
          }),
        if (item['children'] != null)
          ...List.generate(item['children'].length, (index) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(
                begin: state.isAnimatingOut ? 1.0 : 0.0,
                end: state.isAnimatingOut ? 0.0 : 1.0,
              ),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: selectMenuItem(
                      context,
                      item['children'][index]['title'],
                      item['children'][index]['icon'],
                      item['children'][index]['route'],
                    ),
                  ),
                );
              },
            );
          }),
      ],
    ),
  );
}

Widget selectMenuItem(
  BuildContext context,
  String title,
  String icon,
  String? route,
) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
      highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
      onTap: () {
        if (route != null) {
          context.push(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset(width: 22, height: 22, icon),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      title,
                      style: GlobalTextStyle.body01.copyWith(
                        color: GlobalColor.bk01,
                      ),
                    ),
                  ),
                ),
                Icon(Symbols.arrow_right_alt_rounded, color: GlobalColor.bk03),
                const SizedBox(width: 15),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
