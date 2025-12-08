class MenuList {
  static const List<Map<String, dynamic>> salesList = [
    {
      'title': '매출 조회',
      'icon': 'assets/icons/i_searchSales.svg',
      'child': [
        {
          'title': '당일 매출 상세',
          'icon': 'assets/icons/i_todaySalesInfo.svg',
          'route': '/sales/sales-view/daily-sales-detail',
        },
        {
          'title': '영수 내역',
          'icon': 'assets/icons/i_receiptInfo.svg',
          'route': '/sales/sales-view/receipt-history',
        },
        {
          'title': '결제 내역',
          'icon': 'assets/icons/i_moneyActive.svg',
          'route': '/sales/sales-view/payment-history',
        },
        {
          'title': '일 종합 매출',
          'icon': 'assets/icons/i_today_sale.svg',
          'route': '/sales/sales-view/daily-total-sales',
        },
        {
          'title': '월 종합 매출',
          'icon': 'assets/icons/i_monthSales.svg',
          'route': '/sales/sales-view/monthly-total-sales',
        },
        {
          'title': '반품 내역',
          'icon': 'assets/icons/i_refundMoney.svg',
          'route': '/sales/sales-view/return-history',
        },
      ],
    },
    {
      'title': '매출 변화',
      'icon': 'assets/icons/i_changeSales.svg',
      'child': [
        {
          'title': '시간대별 매출 변화',
          'icon': 'assets/icons/i_analytics_time.svg',
          'route': '/sales/sales-differences/time-sales',
        },
        {
          'title': '요일별 매출 변화',
          'icon': 'assets/icons/i_analytics_day.svg',
          'route': '/sales/sales-differences/days-sales',
        },
        {
          'title': '월별 매출 변화',
          'icon': 'assets/icons/i_analytics_month.svg',
          'route': '/sales/sales-differences/months-sales',
        },
      ]
    },
    {
      'title': '상품 매출',
      'icon': 'assets/icons/i_productSales.svg',
      'route': '/sales/goods-sales'
    },
    {
      'title': '카드사 매출',
      'icon': 'assets/icons/i_cardSales.svg',
      'route': '/sales/card-company-sales'
    },
    {
      'title': '할인 유형별 매출',
      'icon': 'assets/icons/i_salesCategory.svg',
      'route': '/sales/dc-type-sales'
    },
    {
      'title': '정산 및 승인',
      'icon': 'assets/icons/i_calc.svg',
      'child': [
        {
          'title': '정산 내역',
          'icon': 'assets/icons/i_adjustment_payment.svg',
          'route': '/sales/settlement_approval/settlement_history',
        },
        {
          'title': '카드 승인 내역',
          'icon': 'assets/icons/i_adjustment_card.svg',
          'route': '/sales/settlement_approval/card-approval-history',
        },
        {
          'title': '간편 승인 내역',
          'icon': 'assets/icons/i_adjustment_simplePayment.svg',
          'route': '/sales/settlement_approval/easy-approval-history',
        },
        {
          'title': '현금 영수 승인 내역',
          'icon': 'assets/icons/i_adjustment_cash.svg',
          'route': '/sales/settlement_approval/cash-receipt-approval-history',
        },
        {
          'title': '임의 등록 내역',
          'icon': 'assets/icons/i_loyalty.svg',
          'route': '/sales/settlement_approval/user-register-history',
        },
      ],
    },
    {
      'title': '주문 취소',
      'icon': 'assets/icons/i_cancelPayment.svg',
      'route': '/sales/cancel-hist'
    },
  ];
  static const List<Map<String, dynamic>> profileList = [
    {
      'title': '비밀번호 변경',
      'icon': 'assets/icons/i_Account.svg',
      'child': [
        {
          'title': '알림센터',
          'icon': 'assets/icons/i_todaySalesInfo.svg',
          'route': '/sales/sales-view/daily-sales-detail',
        },
        {
          'title': '공지사항',
          'icon': 'assets/icons/i_receiptInfo.svg',
          'route': '/sales/sales-view/receipt-history',
        },
        {
          'title': '문의하기',
          'icon': 'assets/icons/i_moneyActive.svg',
          'route': '/sales/sales-view/payment-history',
        },
        {
          'title': 'FAQ',
          'icon': 'assets/icons/i_today_sale.svg',
          'route': '/sales/sales-view/daily-total-sales',
        },
        {
          'title': '서비스 이용약관',
          'icon': 'assets/icons/i_refundMoney.svg',
          'route': '/sales/sales-view/return-history',
        },
        {
          'title': '개인정보 처리방침침',
          'icon': 'assets/icons/i_refundMoney.svg',
          'route': '/sales/sales-view/return-history',
        },
      ],
    },
  ];
}
