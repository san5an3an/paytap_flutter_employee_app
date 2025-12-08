import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class BottomModal extends StatelessWidget {
  final String title;

  final List<Widget> content;
  final Widget? bottomWidget;
  const BottomModal({
    super.key,
    this.title = '',
    this.content = const <Widget>[],
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.8; // 최대 높이를 화면의 80%로 제한
    final bottomPadding = keyboardHeight > 0 ? keyboardHeight : 0.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: maxHeight),
          padding: EdgeInsets.fromLTRB(15, 15, 15, bottomPadding),
          decoration: BoxDecoration(
            color: GlobalColor.systemBackGround,
            borderRadius: const BorderRadius.all(Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xf0000000).withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: const Color(0xf0000000).withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: const Color(0xf0000000).withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: const Color(0xf0000000).withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 고정 영역: 타이틀
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: GlobalColor.bk03,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                if (title.isNotEmpty) ...[
                  Text(
                    title,
                    style: GlobalTextStyle.title02.copyWith(
                      color: GlobalColor.bk01,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
                // 스크롤 영역: 콘텐츠
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: content,
                    ),
                  ),
                ),
                // 조건부 고정 영역: 버튼
                const SizedBox(height: 15),
                if (bottomWidget != null) ...[bottomWidget!],
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
