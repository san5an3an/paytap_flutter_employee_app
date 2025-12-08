// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:material_symbols_icons/material_symbols_icons.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:paytap_app/common/utils/styles/global_color.dart';
// import 'package:paytap_app/common/utils/styles/global_text_style.dart';
// import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
// import 'package:paytap_app/common/widget/layout/layout.dart';
// import 'package:paytap_app/menu/profile/alarm_history/view_models/alarm_history_view_model.dart';
// import 'package:paytap_app/menu/profile/alarm_history/views/alarm_item.dart';
// import 'package:paytap_app/menu/profile/alarm_history/views/alarm_setting_modal.dart';

// class AlarmHistory extends ConsumerStatefulWidget {
//   const AlarmHistory({super.key});

//   @override
//   ConsumerState<AlarmHistory> createState() => _AlarmHistoryState();
// }

// class _AlarmHistoryState extends ConsumerState<AlarmHistory>
//     with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   // @override
//   // void didChangeAppLifecycleState(AppLifecycleState state) {
//   //   super.didChangeAppLifecycleState(state);

//   //   // 앱이 다시 포커스될 때 권한 상태 확인
//   //   if (state == AppLifecycleState.resumed) {
//   //     _checkPermissionOnResume();
//   //   }
//   // }

//   /// 앱이 다시 포커스될 때 권한 상태를 확인합니다.
//   Future<void> _checkPermissionOnResume() async {
//     final vm = ref.read(alarmHistoryProvider.notifier);
//     final isNotificationAuthorized = await vm.checkNotificationPermission();

//     // 권한이 허용되었을 때 알림 설정 모달을 자동으로 표시
//     if (isNotificationAuthorized) {
//       if (mounted) {
//         showModalBottomSheet(
//           context: context,
//           isScrollControlled: true,
//           builder: (context) => const AlarmSettingModal(),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final vm = ref.watch(alarmHistoryProvider);
//     return Layout(
//       title: '알림 내역',
//       currentIdx: 2,
//       isDisplayBottomNavigationBar: false,
//       rightWidgetOnTap: () async {
//         final notifier = ref.read(alarmHistoryProvider.notifier);
//         final isNotificationAuthorized = await notifier
//             .checkNotificationPermission();
//         if (isNotificationAuthorized) {
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             builder: (context) => const AlarmSettingModal(),
//           );
//         // } else {
//         //   _showAlarmAuthCheckDialog(context);
//         }
//       },
//       rightWidget: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           Icon(
//             Symbols.notification_settings,
//             color: GlobalColor.brand01,
//             size: 20,
//           ),
//           const SizedBox(width: 5),
//           Text(
//             '알림설정',
//             style: GlobalTextStyle.body02M.copyWith(color: GlobalColor.brand01),
//           ),
//         ],
//       ),
//       children: vm.when(
//         data: (list) => SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Column(
//               children: [
//                 ...list.map(
//                   (item) => Padding(
//                     padding: const EdgeInsets.only(top: 20),
//                     child: AlarmItem(data: item),
//                   ),
//                 ),
//                 const SizedBox(height: 100),
//               ],
//             ),
//           ),
//         ),
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(
//           child: SelectableText.rich(
//             TextSpan(
//               text: '에러: $err',
//               style: const TextStyle(color: Colors.red),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showAlarmAuthCheckDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => ConfirmDialog(
//         type: 'multiple',
//         title: '알림 권한 설정',
//         content: '알림 권한이 거부되었습니다.\n앱 설정에서 알림 권한을 허용해주세요.',
//         confirmBtnLabel: '설정으로 이동',
//         confirmBtnOnPressed: () async {
//           await openAppSettings();
//         },
//         cancelBtnLabel: '취소',
//         cancelBtnOnPressed: () {},
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/menu/profile/alarm_history/view_models/alarm_history_view_model.dart';
import 'package:paytap_app/menu/profile/alarm_history/views/alarm_item.dart';
import 'package:paytap_app/menu/profile/alarm_history/views/alarm_setting_modal.dart';
class AlarmHistory extends ConsumerStatefulWidget {
  const AlarmHistory({super.key});
  @override
  ConsumerState<AlarmHistory> createState() => _AlarmHistoryState();
}
class _AlarmHistoryState extends ConsumerState<AlarmHistory>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  /// 앱 재포커스 시 권한 체크 (주석처리)
  /*
  Future<void> _checkPermissionOnResume() async {
    final vm = ref.read(alarmHistoryProvider.notifier);
    final isNotificationAuthorized = await vm.checkNotificationPermission();
    if (isNotificationAuthorized) {
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const AlarmSettingModal(),
        );
      }
    }
  }
  */
  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(alarmHistoryProvider);
    return Layout(
      title: '알림 내역',
      currentIdx: 2,
      isDisplayBottomNavigationBar: false,
      // 알림 권한 확인 제거
      rightWidgetOnTap: () async {
        // final notifier = ref.read(alarmHistoryProvider.notifier);
        // final isNotificationAuthorized = await notifier.checkNotificationPermission();
        //
        // if (isNotificationAuthorized) {
        //   showModalBottomSheet(
        //     context: context,
        //     isScrollControlled: true,
        //     builder: (context) => const AlarmSettingModal(),
        //   );
        // } else {
        //   _showAlarmAuthCheckDialog(context);
        // }
        // 권한 체크 없이 바로 모달 오픈
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const AlarmSettingModal(),
        );
      },
      rightWidget: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Symbols.notification_settings,
            color: GlobalColor.brand01,
            size: 20,
          ),
          const SizedBox(width: 5),
          Text(
            '알림설정',
            style: GlobalTextStyle.body02M.copyWith(
              color: GlobalColor.brand01,
            ),
          ),
        ],
      ),
      children: vm.when(
        data: (list) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                ...list.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: AlarmItem(data: item),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: SelectableText.rich(
            TextSpan(
              text: '에러: $err',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
  void _showAlarmAuthCheckDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        type: 'multiple',
        title: '알림 권한 설정',
        content: '알림 권한이 거부되었습니다.\n앱 설정에서 알림 권한을 허용해주세요.',
        confirmBtnLabel: '설정으로 이동',
        confirmBtnOnPressed: () async {
          await openAppSettings();
        },
        cancelBtnLabel: '취소',
        cancelBtnOnPressed: () {},
      ),
    );
  }
}