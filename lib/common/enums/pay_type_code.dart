enum PayTypeCode {
  ptc01("01", "현금"),
  ptc02("02", "현금영수증"),
  ptc03("03", "신용카드"),
  ptc04("04", "은련카드"),
  ptc05("05", "간편결제"),
  ptc06("06", "제휴할인카드"),
  ptc07("07", "상품권"),
  ptc08("08", "식권"),
  ptc09("09", "외상"),
  ptc10("10", "선불카드"),
  ptc11("11", "선결제"),
  ptc12("12", "전자상품권"),
  ptc13("13", "모바일상품권"),
  ptc14("14", "회원포인트적립"),
  ptc15("15", "회원포인트사용"),
  ptc16("16", "사원카드"),
  ptc17("17", "회원스탬프적립"),
  ptc18("18", "회원스탬프사용");

  const PayTypeCode(this.code, this.desc);

  final String code;
  final String desc;

  // 특정 코드를 기반으로 PayTypeCode 찾기
  static PayTypeCode? fromCode(String inputCode) {
    return PayTypeCode.values.firstWhere(
      (e) => e.code == inputCode,
    );
  }
}
