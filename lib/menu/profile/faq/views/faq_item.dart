import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/menu/profile/faq/views/faq_detail_modal.dart';

class FaqItem extends StatelessWidget {
  final String searchWord;
  const FaqItem({super.key, this.searchWord = ''});

  @override
  Widget build(BuildContext context) {
    String title = 'FAQ 제목 (가나다라 마바사아)';

    List<TextSpan> spans = _highlightOccurrences(title, searchWord);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return FaqDetailModal();
          },
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: Text(
              '구분',
              style: GlobalTextStyle.body02.copyWith(
                color: GlobalColor.brand01,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            flex: 8,
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
          Flexible(
            flex: 1,
            child: SvgPicture.asset('assets/icons/i_Enter.svg'),
          ),
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
