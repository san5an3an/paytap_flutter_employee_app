import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/menu/home/view_models/home_screen_view_model.dart';

/// 홈 화면
/// ConsumerWidget을 사용하여 Riverpod 상태 관리를 구현
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State 참조
    final state = ref.watch(homeScreenViewModelProvider);
    final vm = ref.read(homeScreenViewModelProvider.notifier);

    // 화면이 처음 로드될 때 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.initializeHome(context);
    });

    return Layout(
      headerEmptyHeight: 0,
      currentIdx: 0,
      children: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          _showBackDialog(context);
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    if (state.isLoading)
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 60,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (!state.isLoading)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 디버그 모드일 때만 /test로 이동하는 버튼을 보여줍니다.
                          if (_isDebugMode()) // _isDebugMode 함수는 아래에 정의
                          AspectRatio(
                            aspectRatio: 1.8, // 1.8
                            child: Image.asset(
                              'assets/images/mainAsset.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${state.userNm}님",
                                style: GlobalTextStyle.title01B,
                              ),
                              Text('반가워요!', style: GlobalTextStyle.title01B),
                              const SizedBox(height: 10),
                              Text(
                                "최종 업데이트 시간: ${state.lastUpdateTime}",
                                style: GlobalTextStyle.body02,
                              ),
                            ],
                          ),
                          SizedBox(height: 40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("총 매출은", style: GlobalTextStyle.title03B),
                              Text("아래와 같아요.", style: GlobalTextStyle.title03B),
                              SizedBox(height: 20),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (
                                      int i = 0;
                                      i < state.totalSaleList.length;
                                      i++
                                    )
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right:
                                              i ==
                                                  state.totalSaleList.length - 1
                                              ? 0
                                              : 15,
                                        ),
                                        child: saleCard(
                                          context,
                                          state.totalSaleList[i]['title'],
                                          (state.totalSaleList[i]['price'] as num).toInt(),
                                          state.totalSaleList[i]['icon'],
                                          state.totalSaleList[i]['link'],
                                          state.totalSaleList[i]['type'],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "오늘 매출건에 대해",
                                style: GlobalTextStyle.title03B,
                              ),
                              Text("분석했어요.", style: GlobalTextStyle.title03B),
                              SizedBox(height: 20),

                              /// todaySaleList를 기기 너비에 맞게 2개씩 배치
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double screenWidth = constraints.maxWidth;
                                  double cardWidth =
                                      (screenWidth - 15) / 2; // 15는 간격

                                  return Wrap(
                                    spacing: 15, // 가로 간격
                                    runSpacing: 15, // 세로 간격
                                    children: [
                                      for (
                                        int i = 0;
                                        i < state.todaySaleList.length;
                                        i++
                                      )
                                        saleCard(
                                          context,
                                          state.todaySaleList[i]['title'],
                                          (state.todaySaleList[i]['price'] as num).toInt(),
                                          state.todaySaleList[i]['icon'],
                                          state.todaySaleList[i]['link'],
                                          state.todaySaleList[i]['type'],
                                          cardType: "today",
                                          cardWidth: cardWidth,
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            // 알림 센터 버튼을 스크롤과 관계없이 고정 위치에 배치
            Positioned(
              top: 15,
              right: 15,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  splashColor: GlobalColor.brand02.withValues(alpha: 0.2),
                  highlightColor: GlobalColor.brand02.withValues(alpha: 0.1),
                  onTap: () {
                    context.push('/profile/alarm-history');
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 5, 15, 5),
                    decoration: BoxDecoration(
                      color: GlobalColor.brand02,
                      border: Border.all(color: GlobalColor.brand02),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/i_notification.svg',
                              colorFilter: ColorFilter.mode(
                                GlobalColor.bk08,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '알림 센터',
                          style: GlobalTextStyle.body01M.copyWith(
                            color: GlobalColor.bk08,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  /// 디버그 모드인지 확인하는 함수
  bool _isDebugMode() {
    return kDebugMode;
  }

  /// 뒤로가기 다이얼로그를 표시하는 함수
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

/// InkWell의 onTap 효과(리플 효과 등)를 보이게 하려면 Material 위젯으로 감싸야 함
/// 배경색은 GlobalColor.bk08을 사용해야 하며, 우측 padding 15도 적용해야 함
Widget saleCard(
  BuildContext context,
  String title,
  int price,
  String icon,
  String link,
  String type, {
  String cardType = "total",
  double? cardWidth,
}) {
  return Material(
    color: GlobalColor.bk08, // 배경색을 bk08로 설정
    borderRadius: BorderRadius.circular(28),
    child: InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        context.push(link, extra: {"type": type});
      },
      child: Container(
        width: cardWidth ?? (cardType == "total" ? 166 : 158),
        constraints: BoxConstraints(
          minHeight: 134, // 최소 높이 설정
        ),
        decoration: BoxDecoration(
          color: Colors.transparent, // Material에서 배경색 처리
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // 내부 컨텐츠에 맞게 크기 조절
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(icon, width: 36, height: 36),
                  Icon(
                    Symbols.arrow_right_alt_rounded,
                    size: 36,
                    color: GlobalColor.bk03,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GlobalTextStyle.body02M.copyWith(
                  color: GlobalColor.bk03,
                ),
              ),
              Text(
                "${CommonHelpers.stringParsePrice(price)}원",
                style: GlobalTextStyle.title04B,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
