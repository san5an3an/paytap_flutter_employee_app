import 'package:intl/intl.dart';

class DateHelpers {
  // 문자열 2024-01-09 -> 문자열 요일 가져오기
  static String getStringWeekday(String dateString) {
    // 1. 문자열을 DateTime으로 변환
    DateTime date = DateTime.parse(dateString);

    // 2. 요일 배열 생성
    List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

    // 3. 요일 가져오기 (weekday는 1부터 시작)
    return weekdays[date.weekday - 1];
  }

  //DateTime -> 문자열 2014-12-13 형태로 변환
  static String getParsedStringDe(DateTime time) {
    // 년, 월, 일을 각각 추출
    int year = time.year;
    int month = time.month;
    int day = time.day;

    // 월과 일이 두 자릿수 형식으로 출력되도록 포맷팅
    String formattedMonth = month.toString().padLeft(2, '0');
    String formattedDay = day.toString().padLeft(2, '0');

    // 포맷팅된 문자열 생성
    return '$year-$formattedMonth-$formattedDay';
  }

  //DateTime -> 문자열 2014-12 형태로 변환
  static String getParsedStringMonth(DateTime time) {
    // 년, 월, 일을 각각 추출
    int year = time.year;
    int month = time.month;

    // 월과 일이 두 자릿수 형식으로 출력되도록 포맷팅
    String formattedMonth = month.toString().padLeft(2, '0');

    // 포맷팅된 문자열 생성
    return '$year-$formattedMonth';
  }

  //DateTime -> 문자열 2014 형태로 변환
  static String getParsedStringYear(DateTime time) {
    // 년, 월, 일을 각각 추출
    int year = time.year;

    // 포맷팅된 문자열 생성
    return '$year';
  }

  // DateTime -> yyyyMM 형태로 변환 (예: 202506)
  static String getYYYYMMString(DateTime dateTime) {
    int year = dateTime.year;
    int month = dateTime.month;
    String formattedMonth = month.toString().padLeft(2, '0');
    return '$year$formattedMonth';
  }

  // DateTime -> yyyy 형태로 변환 (예: 2025)
  static String getYYYYString(DateTime dateTime) {
    int year = dateTime.year;
    return year.toString();
  }

  static String stringParseWeek(DateTime time) {
    // 1. 해당 날짜가 속한 주의 월요일 구하기
    DateTime monday = time.subtract(Duration(days: time.weekday - 1));
    // 2. 그 주의 수요일 구하기
    DateTime wednesday = monday.add(const Duration(days: 2));
    // 3. 수요일이 속한 달
    int year = wednesday.year;
    int month = wednesday.month;

    // 4. 해당 월의 1일~말일까지 모든 주의 수요일 리스트 만들기
    List<DateTime> wednesdays = [];
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    // 첫 주의 월요일 구하기
    DateTime firstMonday =
        firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
    // 첫 주의 수요일
    DateTime currentWednesday = firstMonday.add(const Duration(days: 2));

    while (currentWednesday
        .isBefore(lastDayOfMonth.add(const Duration(days: 1)))) {
      if (currentWednesday.month == month) {
        wednesdays.add(currentWednesday);
      }
      currentWednesday = currentWednesday.add(const Duration(days: 7));
    }

    // 5. 현재 주의 수요일이 몇 번째 wednesdays에 속하는지 찾기
    int weekNumber = wednesdays.indexWhere((w) =>
            w.day == wednesday.day &&
            w.month == wednesday.month &&
            w.year == wednesday.year) +
        1;

    String formattedMonth = month.toString().padLeft(2, '0');
    String formattedWeek = weekNumber.toString();
    return '$year-$formattedMonth, $formattedWeek주';
  }

  /// DateTime 객체를 'yyyyMMdd' 형식의 문자열로 변환합니다.
  /// 예시: 2024년 6월 1일 -> '20240601'
  static String getYYYYMMDDString(DateTime dateTime) {
    // intl 패키지의 DateFormat을 사용하여 날짜를 포맷팅합니다.
    String formattedDate = DateFormat('yyyyMMdd').format(dateTime);
    return formattedDate;
  }

  //DateTime -> 문자열 24.12.24
  static String getYYMMDDString(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yy.MM.dd');
    return formatter.format(dateTime);
  }

  //DateTime -> 문자열 05:00 형태로 변환
  static String getTimehours(DateTime time) {
    // 년, 월, 일을 각각 추출
    int hour = time.hour;
    int minute = time.minute;

    // 월과 일이 두 자릿수 형식으로 출력되도록 포맷팅
    String formattedHour = hour.toString().padLeft(2, '0');
    String formattedMinute = minute.toString().padLeft(2, '0');

    // 포맷팅된 문자열 생성
    return '$formattedHour : $formattedMinute';
  }

  //DateTime -> 문자열 "오후 00:00" 형태로 변환
  static String getTimehoursWithPeriod(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;

    // 오전/오후 구분
    String period = hour < 12 ? '오전' : '오후';

    // 12시간 형식으로 변환 (0시는 12시로 표시)
    int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    // 시간과 분을 두 자릿수 형식으로 포맷팅
    String formattedHour = displayHour.toString().padLeft(2, '0');
    String formattedMinute = minute.toString().padLeft(2, '0');

    // 포맷팅된 문자열 생성
    return '$period $formattedHour:$formattedMinute';
  }

  //문자열 '20141213' -> 문자열 '2014-12-13' 형태로 변환
  static String getHyphenDate(String time) {
    return '${time.substring(0, 4)}-${time.substring(4, 6)}-${time.substring(6)}';
  }

  //문자열 '20141213' -> 문자열 '2014년 12월 13일' 형태로 변환
  static String getYYYYMMDDKR(String time) {
    return '${time.substring(0, 4)}년 ${time.substring(4, 6)}월 ${time.substring(6)}일';
  }

  /// 문자열 '20250320184154'를 DateTime으로 변환합니다.
  /// 예: '20250320184154' -> DateTime(2025, 03, 20, 18, 41, 54)
  static DateTime getDtStringConvertDateTime(String dateString) {
    if (dateString.length != 14) {
      throw FormatException('잘못된 날짜 형식입니다(길이 14 필요): $dateString');
    }
    // 연, 월, 일, 시, 분, 초를 각각 추출
    final year = int.parse(dateString.substring(0, 4));
    final month = int.parse(dateString.substring(4, 6));
    final day = int.parse(dateString.substring(6, 8));
    final hour = int.parse(dateString.substring(8, 10));
    final minute = int.parse(dateString.substring(10, 12));
    final second = int.parse(dateString.substring(12, 14));

    return DateTime(year, month, day, hour, minute, second);
  }

  // '2025-05-15 18:15:40' 형식의 문자열을 DateTime으로 변환
  static DateTime getDateTimeStringConvertDateTime(String dateString) {
    // 공백 기준으로 날짜와 시간 분리
    final parts = dateString.split(' ');
    if (parts.length != 2) {
      throw FormatException('잘못된 날짜 형식입니다: $dateString');
    }
    final datePart = parts[0].split('-');
    final timePart = parts[1].split(':');

    if (datePart.length != 3 || timePart.length != 3) {
      throw FormatException('잘못된 날짜/시간 형식입니다: $dateString');
    }

    return DateTime(
      int.parse(datePart[0]), // year
      int.parse(datePart[1]), // month
      int.parse(datePart[2]), // day
      int.parse(timePart[0]), // hour
      int.parse(timePart[1]), // minute
      int.parse(timePart[2]), // second
    );
  }

  static bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  //'1일전, 한달전, 시간전, 분전 표기'
  static String getIntlTime(DateTime date) {
    final Duration diff = DateTime.now().difference(date);

    if (diff.inDays >= 365) {
      return "${diff.inDays ~/ 365}년 전"; // 1년 이상의 차이일 때
    } else if (diff.inDays >= 30) {
      return "${diff.inDays ~/ 30}달 전"; // 1달 이상의 차이일 때
    } else if (diff.inDays >= 1) {
      return "${diff.inDays}일 전"; // 1일 이상의 차이일 때
    } else if (diff.inHours >= 1) {
      return "${diff.inHours}시간 전"; // 1시간 이상의 차이일 때
    } else if (diff.inMinutes >= 1) {
      return "${diff.inMinutes}분 전"; // 1분 이상의 차이일 때
    } else {
      return "방금 전"; // 1분 미만일 때
    }
  }

  //문자열 '2025-05-15 18:15:40' -> 문자열 "2024.09.05 오후 03:05" 변환
  static String getParsedStringServerDt(String dateString) {
    DateTime dateTime = getDateTimeStringConvertDateTime(dateString);
    String formattedDate = DateFormat('yyyy.MM.dd').format(dateTime);
    String period = dateTime.hour < 12 ? '오전' : '오후';
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    return '$formattedDate $period $formattedTime';
  }

  /// 'yyyyMM' 형식의 문자열을 DateTime으로 변환합니다.
  /// 예: '202506' -> DateTime(2025, 6, 1)
  ///
  /// [dateString] 'yyyyMM' 형식의 문자열 (예: '202506')
  /// [nullable] true인 경우 null을 반환할 수 있음, false인 경우 예외 발생
  static DateTime? parseYYYYMMToDateTime(String? dateString,
      {bool nullable = true}) {
    if (dateString == null || dateString.isEmpty) {
      return nullable ? null : throw FormatException('날짜 문자열이 비어있습니다');
    }

    if (dateString.length != 6) {
      return nullable
          ? null
          : throw FormatException('잘못된 날짜 형식입니다(yyyyMM 필요): $dateString');
    }

    try {
      final year = int.parse(dateString.substring(0, 4));
      final month = int.parse(dateString.substring(4, 6));
      return DateTime(year, month, 1);
    } catch (e) {
      return nullable ? null : throw FormatException('날짜 파싱 오류: $dateString');
    }
  }

  /// 'yyyyMMdd' 형식의 문자열을 DateTime으로 변환합니다.
  /// 예: '20250615' -> DateTime(2025, 6, 15)
  ///
  /// [dateString] 'yyyyMMdd' 형식의 문자열 (예: '20250615')
  /// [nullable] true인 경우 null을 반환할 수 있음, false인 경우 예외 발생
  static DateTime? parseYYYYMMDDToDateTime(String? dateString,
      {bool nullable = true}) {
    if (dateString == null || dateString.isEmpty) {
      return nullable ? null : throw FormatException('날짜 문자열이 비어있습니다');
    }

    if (dateString.length != 8) {
      return nullable
          ? null
          : throw FormatException('잘못된 날짜 형식입니다(yyyyMMdd 필요): $dateString');
    }

    try {
      final year = int.parse(dateString.substring(0, 4));
      final month = int.parse(dateString.substring(4, 6));
      final day = int.parse(dateString.substring(6, 8));
      return DateTime(year, month, day);
    } catch (e) {
      return nullable ? null : throw FormatException('날짜 파싱 오류: $dateString');
    }
  }

  /// 'yyyy' 형식의 문자열을 DateTime으로 변환합니다.
  /// 예: '2025' -> DateTime(2025, 1, 1)
  ///
  /// [dateString] 'yyyy' 형식의 문자열 (예: '2025')
  /// [nullable] true인 경우 null을 반환할 수 있음, false인 경우 예외 발생
  static DateTime? parseYYYYToDateTime(String? dateString,
      {bool nullable = true}) {
    if (dateString == null || dateString.isEmpty) {
      return nullable ? null : throw FormatException('날짜 문자열이 비어있습니다');
    }

    if (dateString.length != 4) {
      return nullable
          ? null
          : throw FormatException('잘못된 날짜 형식입니다(yyyy 필요): $dateString');
    }

    try {
      final year = int.parse(dateString);
      return DateTime(year, 1, 1);
    } catch (e) {
      return nullable ? null : throw FormatException('날짜 파싱 오류: $dateString');
    }
  }

  /// 주어진 날짜가 속한 주의 시작일(월요일)과 끝일(일요일)을 반환합니다.
  /// 예: 2025년 1월 15일(수요일) -> 월요일(1월 13일), 일요일(1월 19일)
  ///
  /// [date] 기준 날짜
  /// Returns: Map<String, DateTime> {'start': 월요일, 'end': 일요일}
  static Map<String, DateTime> getWeekStartEnd(DateTime date) {
    // 해당 날짜가 속한 주의 월요일 구하기 (weekday: 1=월요일, 7=일요일)
    DateTime monday = date.subtract(Duration(days: date.weekday - 1));
    // 해당 주의 일요일 구하기
    DateTime sunday = monday.add(const Duration(days: 6));

    return {'start': monday, 'end': sunday};
  }

  /// 주어진 날짜가 속한 월의 시작일(1일)과 끝일(마지막일)을 반환합니다.
  /// 예: 2025년 1월 15일 -> 1일(1월 1일), 마지막일(1월 31일)
  ///
  /// [date] 기준 날짜
  /// Returns: Map<String, DateTime> {'start': 1일, 'end': 마지막일}
  static Map<String, DateTime> getMonthStartEnd(DateTime date) {
    // 해당 월의 1일
    DateTime firstDay = DateTime(date.year, date.month, 1);
    // 해당 월의 마지막일 (다음 달의 0일 = 이번 달의 마지막일)
    DateTime lastDay = DateTime(date.year, date.month + 1, 0);

    return {'start': firstDay, 'end': lastDay};
  }
}
