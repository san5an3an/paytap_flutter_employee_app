import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class Footer extends StatelessWidget {
  final int currentIndex;

  const Footer({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> menuList = [
      {
        'idx': 0,
        'label': '홈',
        'selectIcon': SvgPicture.asset('assets/icons/i_home_selected.svg'),
        'defaultIcon': SvgPicture.asset('assets/icons/i_home_unselected.svg'),
      },
      {
        'idx': 1,
        'label': '매출 관리',
        'selectIcon': SvgPicture.asset(
          'assets/icons/i_receipt-disscount_selected.svg',
        ),
        'defaultIcon': SvgPicture.asset(
          'assets/icons/i_receipt-disscount_unselected.svg',
        ),
      },
      {
        'idx': 2,
        'label': '마이페이지',
        'selectIcon': SvgPicture.asset('assets/icons/i_user_selected.svg'),
        'defaultIcon': SvgPicture.asset('assets/icons/i_user_unselected.svg'),
      },
    ];
    return BottomNavigationBar(
      selectedLabelStyle: GlobalTextStyle.small02,
      unselectedLabelStyle: GlobalTextStyle.small02,
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      items: menuList.map((menu) {
        return BottomNavigationBarItem(
          icon: currentIndex == menu['idx']
              ? menu['selectIcon']
              : menu['defaultIcon'],
          label: menu['label'],
        );
      }).toList(),
      unselectedItemColor: const Color(0X99FFFFFF),
      backgroundColor: const Color(0XFF112255),
      selectedItemColor: const Color(0XFFFFFFFF),
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/sales/home');
            break;
          case 2:
            context.go('/profile/home');
            break;
        }
      },
    );
  }
}
