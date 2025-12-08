import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class NavSlider extends StatelessWidget {
  final String startDeName;
  final String endDeName;
  final String startDe;
  final String? endDe;

  final void Function(Map<String, dynamic>) onChange;
  final String type;
  const NavSlider({
    super.key,
    this.startDeName = '',
    this.endDeName = '',
    this.type = 'day',
    this.endDe,
    required this.startDe,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: GlobalColor.bk07,
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 50,
            child: GestureDetector(
              onTap: () {
                onTapPrev();
              },
              child: SvgPicture.asset(
                'assets/icons/i_Prev.svg', // 사용자 정의 아이콘 경로
              ),
            ),
          ),
          Expanded(
            child: Text(
              getLabel(),
              textAlign: TextAlign.center,
              style: GlobalTextStyle.body01.copyWith(
                color: GlobalColor.brand01,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: GestureDetector(
              onTap: () {
                onTapNext();
              },
              child: SvgPicture.asset(
                'assets/icons/i_Next.svg', // 사용자 정의 아이콘 경로
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onTapNext() {
    if (type == 'day') {
      DateTime currentDate =
          DateHelpers.parseYYYYMMDDToDateTime(startDe) ?? DateTime.now();
      DateTime resultDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day + 1,
      );
      onChange({startDeName: DateHelpers.getYYYYMMDDString(resultDate)});
    }

    if (type == 'week') {
      onTapWeekNext();
    }

    if (type == 'year') {
      DateTime currentYear =
          DateHelpers.parseYYYYToDateTime(startDe) ?? DateTime.now();
      DateTime nextYear = DateTime(currentYear.year + 1, 1, 1);
      onChange({startDeName: DateHelpers.getYYYYString(nextYear)});
    }
  }

  void onTapPrev() {
    if (type == 'day') {
      DateTime currentDate =
          DateHelpers.parseYYYYMMDDToDateTime(startDe) ?? DateTime.now();
      DateTime resultDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day - 1,
      );
      onChange({startDeName: DateHelpers.getYYYYMMDDString(resultDate)});
    }

    if (type == 'week') {
      onTapWeekPrev();
    }

    if (type == 'year') {
      DateTime currentYear =
          DateHelpers.parseYYYYToDateTime(startDe) ?? DateTime.now();
      DateTime prevYear = DateTime(currentYear.year - 1, 1, 1);
      onChange({startDeName: DateHelpers.getYYYYString(prevYear)});
    }
  }

  //week 다음버튼 클릭
  void onTapWeekNext() {
    DateTime currentDate =
        DateHelpers.parseYYYYMMDDToDateTime(startDe) ?? DateTime.now();
    DateTime startWeek = currentDate
        .subtract(Duration(days: currentDate.weekday - 1))
        .add(const Duration(days: 7)); // 이번 주의 시작일 (월요일)
    DateTime endWeek = startWeek.add(
      const Duration(
        days: 6,
        hours: 23,
        minutes: 59,
        seconds: 59,
        milliseconds: 999,
      ),
    ); // 이번 주의 마지막일 (일요일)

    onChange({
      startDeName: DateHelpers.getYYYYMMDDString(startWeek),
      endDeName: DateHelpers.getYYYYMMDDString(endWeek),
    });
  }

  //week 이전버튼 클릭
  void onTapWeekPrev() {
    DateTime currentDate =
        DateHelpers.parseYYYYMMDDToDateTime(startDe) ?? DateTime.now();
    DateTime startWeek = currentDate
        .subtract(Duration(days: currentDate.weekday - 1))
        .subtract(const Duration(days: 7)); // 이번 주의 시작일 (월요일)
    DateTime endWeek = startWeek.add(
      const Duration(
        days: 6,
        hours: 23,
        minutes: 59,
        seconds: 59,
        milliseconds: 999,
      ),
    ); // 이번 주의 마지막일 (일요일)

    onChange({
      startDeName: DateHelpers.getYYYYMMDDString(startWeek),
      endDeName: DateHelpers.getYYYYMMDDString(endWeek),
    });
  }

  String getLabel() {
    switch (type) {
      case 'day':
        DateTime date =
            DateHelpers.parseYYYYMMDDToDateTime(startDe) ?? DateTime.now();
        return DateHelpers.getParsedStringDe(date);
      case 'week':
        if (endDe != null) {
          DateTime endDate =
              DateHelpers.parseYYYYMMDDToDateTime(endDe!) ?? DateTime.now();
          return DateHelpers.stringParseWeek(endDate);
        }
        return startDe;
      case 'year':
        return startDe;

      default:
        DateTime date =
            DateHelpers.parseYYYYMMDDToDateTime(startDe) ?? DateTime.now();
        return DateHelpers.getParsedStringDe(date);
    }
  }
}
