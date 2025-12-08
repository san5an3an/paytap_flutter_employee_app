import 'package:paytap_app/common/models/c_option.dart';

class CommonFlag {
  // 예 아니오
  static const List<COption> YN = [
    COption(title: "Y", value: "Y"),
    COption(title: "N", value: "N"),
  ];

  static const List<COption> NY = [
    COption(title: "N", value: "N"),
    COption(title: "Y", value: "Y"),
  ];

  // 사용여부
  static const List<COption> USE_YN = [
    COption(title: "사용", value: "Y"),
    COption(title: "미사용", value: "N"),
  ];

  // 재직상태
  static const List<COption> RETIRE_FLAG = [
    COption(title: "재직", value: "0"),
    COption(title: "퇴직", value: "1"),
    COption(title: "휴직", value: "2"),
  ];

  // POS 권한
  static const List<COption> STAFF_FLAG = [
    COption(title: "점주", value: "O"),
    COption(title: "사원", value: "S"),
    COption(title: "배달", value: "D"),
  ];

  // 자사 구분
  static const List<COption> SBSDR_FLAG = [
    COption(title: "자사", value: "Y"),
    COption(title: "타사", value: "N"),
  ];

  // 교육 가능 여부
  static const List<COption> EDCTN_YN = [
    COption(title: "가능", value: "Y"),
    COption(title: "불가", value: "N"),
  ];

  // 회원 상태
  static const List<COption> MBR_STT = [
    COption(title: "정상", value: "Y"),
    COption(title: "탈퇴", value: "N"),
    COption(title: "휴면", value: "D"),
  ];

  // 회원관리 - 회원 결혼
  static const List<COption> MBR_Mttl_FLAG = [
    COption(title: "비공개", value: "S"),
    COption(title: "기혼", value: "Y"),
    COption(title: "미혼", value: "N"),
  ];

  // 회원관리 - 회원 생년원일
  static const List<COption> BIRTH_FLAG = [
    COption(title: "비공개", value: "S"),
    COption(title: "양력", value: "Y"),
    COption(title: "음력", value: "N"),
  ];

  // 회원관리 -기념일 적립
  static const List<COption> ANNIVERSARY_FLAG = [
    COption(title: "미사용", value: "N"),
    COption(title: "결혼기념일", value: "W"),
    COption(title: "생일", value: "B"),
  ];

  // 회원관리 - 회원 성별
  static const List<COption> GENDER = [
    COption(title: "비공개", value: "S"),
    COption(title: "남", value: "M"),
    COption(title: "여", value: "F"),
  ];

  // 회원관리 - 정보 수신 구분
  static const List<COption> INFO_RECEIVER_FLAG = [
    COption(title: "알림톡", value: "D"),
    COption(title: "문자", value: "S"),
    COption(title: "이메일", value: "E"),
  ];

  // 회원 등급
  static const List<COption> DEF_YN = [
    COption(title: "기본등급", value: "Y"),
    COption(title: "일반등급", value: "N"),
  ];

  // 회원 등급 관리 - 적립 조건
  static const List<COption> ACM_FLAG = [
    COption(title: "백분율(%)", value: "P"),
    COption(title: "금액기준", value: "A"),
  ];

  // 포인트 관리 - 포인트 사용구분
  static const List<COption> USE_FLAG = [
    COption(title: "회원활동", value: "M"),
    COption(title: "판매원조정", value: "S"),
    COption(title: "매장정책", value: "P"),
  ];

  // 포인트 관리 - 사용처
  static const List<COption> PROCESS_FLAG = [
    COption(title: "ASP", value: "A"),
    COption(title: "POS", value: "P"),
    COption(title: "KIOSK", value: "K"),
  ];

  // 포인트 관리 - 사용구분
  static const List<COption> CHG_PT_FLAG = [
    COption(title: "신규", value: "N"),
    COption(title: "적립", value: "C"),
    COption(title: "적립취소", value: "Q"),
    COption(title: "스탬프 -> 포인트", value: "P"),
    COption(title: "포인트 -> 스탬프", value: "S"),
    COption(title: "사용", value: "U"),
    COption(title: "사용취소", value: "E"),
    COption(title: "조정", value: "A"),
    COption(title: "이관", value: "T"),
  ];

  // 결제 수단 구분
  static const List<COption> PAY_TYPE_FLAG = [
    COption(title: "현금", value: "01"),
    COption(title: "현금영수증", value: "02"),
    COption(title: "신용카드", value: "03"),
    COption(title: "은련카드", value: "04"),
    COption(title: "간편결제", value: "05"),
    COption(title: "제휴할인카드", value: "06"),
    COption(title: "상품권", value: "07"),
    COption(title: "식권", value: "08"),
    COption(title: "외상", value: "09"),
    COption(title: "선불카드", value: "10"),
    COption(title: "선결제", value: "11"),
    COption(title: "전자상품권", value: "12"),
    COption(title: "모바일상품권", value: "13"),
    COption(title: "회원포인트적립", value: "14"),
    COption(title: "회원포인트사용", value: "15"),
    COption(title: "사원카드", value: "16"),
    COption(title: "회원스탬프적립", value: "17"),
    COption(title: "회원스탬프사용", value: "18"),
    COption(title: "배달", value: "19"),
    COption(title: "현금환불", value: "CR"),
  ];

  // 승인 구분
  static const List<COption> APPR_FLAG = [
    COption(title: "승인", value: "0"),
    COption(title: "취소", value: "1"),
  ];

  // 승인 처리 구분
  static const List<COption> APPR_PROC_FLAG = [
    COption(title: "비승인", value: "0"),
    COption(title: "포스승인", value: "1"),
    COption(title: "임의등록", value: "2"),
    COption(title: "전화승인", value: "3"),
  ];

  // 할부 개월 구분
  static const List<COption> INST_MM_FLAG = [
    COption(title: "일시불", value: "0"),
    COption(title: "할부", value: "1"),
    COption(title: "할인-일시불", value: "2"),
    COption(title: "할인-할부", value: "3"),
  ];

  // 포스 마감 구분
  static const List<COption> CLOSE_FLAG = [
    COption(title: "개점 전", value: "0"),
    COption(title: "개점", value: "1"),
    COption(title: "중간 정산", value: "2"),
    COption(title: "일마감", value: "3"),
    COption(title: "일마감 취소", value: "4"),
  ];

  // 게시판 열람 미열람
  static const List<COption> VIEW_YN = [
    COption(title: "열람", value: "Y"),
    COption(title: "미열람", value: "N"),
  ];

  // 게시판 조회 타입
  static const List<COption> BOARD_SEARCH_TYPE = [
    COption(title: "제목", value: "T"),
    COption(title: "내용", value: "C"),
    COption(title: "제목 + 내용", value: "TC"),
    COption(title: "작성자", value: "CR"),
  ];

  // 게시판 구분
  static const List<COption> BOARD_FLAG = [
    COption(title: "공지사항", value: "0"),
    COption(title: "메뉴얼", value: "1"),
    COption(title: "FAQ", value: "2"),
    COption(title: "문의하기", value: "3"),
    COption(title: "시스템", value: "4"),
    COption(title: "대리점", value: "5"),
  ];

  // 매출, 반품 구분
  static const List<COption> SALE_YN = [
    COption(title: "매출", value: "Y"),
    COption(title: "반품", value: "N"),
  ];

  // 일반, 배달, 포장 구분
  static const List<COption> DLV_PACK_FLAG = [
    COption(title: "일반", value: "0"),
    COption(title: "배달", value: "1"),
    COption(title: "포장", value: "2"),
  ];

  // 상품 세트 여부
  static const List<COption> SET_YN = [
    COption(title: "세트", value: "Y"),
    COption(title: "일반", value: "N"),
  ];

  // 상품 분류 타입
  static const List<COption> CTG_TYPE = [
    COption(title: "대분류", value: "H"),
    COption(title: "중분류", value: "M"),
    COption(title: "소분류", value: "L"),
  ];

  // 테이블 포장 구분
  static const List<COption> TABLE_PACK_FLAG = [
    COption(title: "홀", value: "0"),
    COption(title: "포장", value: "1"),
    COption(title: "배달", value: "2"),
  ];

  // 예약 여부
  static const List<COption> RESERVATION_FLAG = [
    COption(title: "예약", value: "Y"),
    COption(title: "취소", value: "N"),
  ];

  // 상품 판매가 타입
  static const List<COption> SUPPLY_COST_FLAG = [
    COption(title: "정가상품", value: "0"),
    COption(title: "싯가상품", value: "1"),
    COption(title: "저울상품", value: "2"),
  ];

  // 포스 마감 구분
  static const List<COption> ACCOUNT_HIST_CLOSE_FLAG = [
    COption(title: "개점", value: "1"),
    COption(title: "중간정산", value: "2"),
    COption(title: "마감", value: "3"),
  ];

  // 판매 결제 수단
  static const List<COption> SALE_PAY_TYPE_FLAG = [
    COption(title: "현금", value: "C"),
    COption(title: "카드", value: "D"),
    COption(title: "간편결제", value: "E"),
    COption(title: "식권", value: "F"),
    COption(title: "상품권", value: "G"),
    COption(title: "쿠폰", value: "CP"),
  ];

  // 가격 단위 검색
  static const List<COption> SEARCH_PRICE_FLAG = [
    COption(title: "1원", value: "1"),
    COption(title: "10원", value: "10"),
    COption(title: "100원", value: "100"),
    COption(title: "1000원", value: "1000"),
  ];

  // 가격 단위 검색(올림, 내림, 반올림)
  static const List<COption> SEARCH_PRICE_UNIT = [
    COption(title: "반올림", value: "RD"),
    COption(title: "올림", value: "UP"),
    COption(title: "내림", value: "DN"),
  ];

  // 판매가 공급가 원가 타입
  static const List<COption> PRICE_TYPE_FLAG = [
    COption(title: "판매가", value: "0"),
    COption(title: "공급가", value: "1"),
    COption(title: "원가", value: "2"),
  ];

  // 적립 방식 조건
  static const List<COption> PUT_ASIDE_TYPE = [
    COption(title: "포인트", value: "0000001"),
    COption(title: "스탬프", value: "0000002"),
  ];

  // 판매가 통제 여부
  static const List<COption> PRICE_CONTROL_FLAG = [
    COption(title: "본사(판매가통제)", value: "Y"),
    COption(title: "매장(판매가통제)", value: "N"),
  ];

  // 매장 판매가 관리 판매가 타입
  static const List<COption> STORE_SALE_PRICE_TYPE = [
    COption(title: "매장판매가", value: "0"),
    COption(title: "본사판매가", value: "1"),
    COption(title: "엑셀업로드", value: "2"),
  ];

  // 옵션 그룹 타입
  static const List<COption> OPTION_GRP_FLAG = [
    COption(title: "단일", value: "0"),
    COption(title: "사이드", value: "2"),
  ];

  // 할인 타입
  static const List<COption> DISCOUNT_TYPE_FLAG = [
    COption(title: "일반 할인", value: "NORMAL"),
    COption(title: "서비스 할인", value: "SERVICE"),
    COption(title: "제휴카드 할인", value: "PARTNER_CARD"),
    COption(title: "쿠폰 할인", value: "COUPON"),
    COption(title: "회원 할인", value: "MEMBER"),
    COption(title: "식권 할인", value: "TICKET"),
    COption(title: "프로모션 할인", value: "PROMOTION"),
    COption(title: "신용카드 현장할인", value: "CREDIT_CARD"),
    COption(title: "포장 할인", value: "PACKING"),
  ];

  // 품절 여부
  static const List<COption> SOLD_OUT_FLAG = [
    COption(title: "품절", value: "Y"),
    COption(title: "판매", value: "N"),
  ];
}
