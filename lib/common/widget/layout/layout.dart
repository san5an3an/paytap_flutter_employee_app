import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/footer/footer.dart';

class Layout extends StatefulWidget {
  final double headerEmptyHeight;
  final Widget children;
  final Widget? rightWidget;
  final void Function()? rightWidgetOnTap;
  final String? title;
  final bool? isDisplayBottomNavigationBar;
  final int? currentIdx;
  final VoidCallback? onBackButtonPressed;

  const Layout({
    super.key,
    required this.children,
    this.headerEmptyHeight = 110,
    this.currentIdx,
    this.rightWidgetOnTap,
    this.title,
    this.onBackButtonPressed,
    this.rightWidget,
    this.isDisplayBottomNavigationBar = true,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColor.systemBackGround,
      appBar: AppBar(
        toolbarHeight: widget.headerEmptyHeight,
        leadingWidth: 50,
        backgroundColor: GlobalColor.systemBackGround,
        scrolledUnderElevation: 0.0, // This will fix the problem
        centerTitle: false,
        leading: Container(),
        title: null,
        flexibleSpace: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 뒤로가기 아이콘 영역 (50px)
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (Navigator.canPop(context))
                      IconButton(
                        icon: Icon(
                          Symbols.arrow_left_alt_rounded,
                          color: GlobalColor.bk01,
                        ),
                        splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
                        highlightColor: GlobalColor.brand01.withValues(
                          alpha: 0.1,
                        ),
                        onPressed: () {
                          if (widget.onBackButtonPressed != null) {
                            widget.onBackButtonPressed!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        padding: EdgeInsets.zero,
                      ),
                    if (widget.rightWidget != null)
                      Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              splashColor: GlobalColor.brand01.withValues(
                                alpha: 0.2,
                              ),
                              highlightColor: GlobalColor.brand01.withValues(
                                alpha: 0.1,
                              ),
                              onTap: widget.rightWidgetOnTap,
                              child: Container(
                                padding: const EdgeInsets.only(
                                  right: 10,
                                  top: 15,
                                  bottom: 15,
                                  left: 10,
                                ),
                                child: widget.rightWidget,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                        ],
                      ),
                  ],
                ),
              ),
              // 제목 영역 (60px)
              if (widget.title != null)
                Container(
                  height: 60,
                  padding: const EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title ?? '',
                        style: GlobalTextStyle.title02.copyWith(
                          fontWeight: FontWeight.w500,
                          color: GlobalColor.bk01,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [],
      ),
      body: widget.children,
      bottomNavigationBar: widget.isDisplayBottomNavigationBar == true
          ? Footer(currentIndex: widget.currentIdx ?? 0)
          : null,
    );
  }
}
