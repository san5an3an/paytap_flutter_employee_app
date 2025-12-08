import 'package:intl/intl.dart';

class CommonHelpers {
  //int 숫자를 -> String 금액으로 변경 ex) 10000 -> 10,000
  static String stringParsePrice(int price, {isSymbol = false}) {
    var f = NumberFormat.currency(locale: 'ko_KR', symbol: '');
    if (isSymbol && price > 0) {
      return '+${f.format(price)}';
    }
    return f.format(price);
  }

  //String 금액를 -> int 숫자으로 변경 ex) 10,000 -> 10000
  static int intParsePrice(String formattedPrice) {
    var f = NumberFormat.currency(locale: 'ko_KR', symbol: '');

    return f.parse(formattedPrice).toInt();
  }

  //
  static Map<String, List<Map<String, dynamic>>> grouyByList(List<dynamic> list, name) {
    Map<String, List<Map<String, dynamic>>> groupedBySaleDe = {};
    for (var sale in list) {
      String saleDe = sale[name];
      if (!groupedBySaleDe.containsKey(saleDe)) {
        groupedBySaleDe[saleDe] = [];
      }
      groupedBySaleDe[saleDe]?.add(sale);
    }
    return groupedBySaleDe;
  }
}
