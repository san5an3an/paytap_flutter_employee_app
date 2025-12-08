import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/menu/profile/notice/views/notice_detail_modal.dart';

class NoticeItem extends StatelessWidget {
  final String searchWord;
  final Map<String, dynamic> data;
  const NoticeItem({super.key, this.searchWord = '', required this.data});

  @override
  Widget build(BuildContext context) {
    List<TextSpan> spans = _highlightOccurrences(
      data['boardSbjct'],
      searchWord,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return NoticeDetailModal(data: data);
          },
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: RichText(
              text: TextSpan(
                children: spans,
                style: GlobalTextStyle.body01.copyWith(
                  color: GlobalColor.bk01,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SvgPicture.asset('assets/icons/i_Enter.svg'),
        ],
      ),
    );
  }

  List<TextSpan> _highlightOccurrences(String text, String searchWord) {
    if (searchWord.isEmpty) {
      return [TextSpan(text: text)];
    }

    List<TextSpan> spans = [];
    int start = 0;
    int index;

    // 대소문자 구분 없이 검색하기 위해 두 문자열을 소문자로 변환
    String lowerCaseText = text.toLowerCase();
    String lowerCaseSearchWord = searchWord.toLowerCase();

    while ((index = lowerCaseText.indexOf(lowerCaseSearchWord, start)) != -1) {
      if (index > start) {
        // 일치하지 않는 부분 추가
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      // 일치하는 부분에 색상 적용
      spans.add(
        TextSpan(
          text: text.substring(index, index + searchWord.length),
          style: TextStyle(color: GlobalColor.brand01), // 강조 색상
        ),
      );
      start = index + searchWord.length;
    }

    // 마지막 남은 부분 추가
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}
