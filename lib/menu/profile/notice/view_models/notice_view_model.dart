import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paytap_app/common/utils/Common/common_helpers.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:paytap_app/menu/profile/notice/services/notice_service.dart';

/// 공지사항 화면의 상태 모델
class NoticeState {
  final int startNo;
  final int recordSize;
  final List<dynamic> originalList;
  final List<dynamic> noticeItemList;

  const NoticeState({
    this.startNo = 0,
    this.recordSize = 10,
    this.originalList = const [],
    this.noticeItemList = const [],
  });

  NoticeState copyWith({
    int? startNo,
    int? recordSize,
    List<dynamic>? originalList,
    List<dynamic>? noticeItemList,
  }) {
    return NoticeState(
      startNo: startNo ?? this.startNo,
      recordSize: recordSize ?? this.recordSize,
      originalList: originalList ?? this.originalList,
      noticeItemList: noticeItemList ?? this.noticeItemList,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class NoticeViewModel extends Notifier<NoticeState> {
  final NoticeService noticeService = NoticeService();
  final storage = FlutterSecureStorage();
  final ScrollController scrollController = ScrollController();

  @override
  NoticeState build() {
    // dispose 콜백 등록
    ref.onDispose(() {
      scrollController.dispose();
    });
    return const NoticeState();
  }

  //데이터 초기화 하는 함수
  Future<void> resetNoticeList() async {
    state = state.copyWith(originalList: [], noticeItemList: [], startNo: 0);
  }

  //데이터 조회 하는 함수
  Future<void> getNotice(context) async {
    Map<String, dynamic> data = {
      "startNo": state.startNo,
      "recordSize": state.recordSize,
    };
    Map<String, dynamic> res = await noticeService.getNoticeList(data);
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }

    if (res['results'].length > 0) {
      state = state.copyWith(
        noticeItemList: res['results'],
        startNo: state.startNo + state.recordSize,
      );
    }
  }

  List<Map<String, dynamic>> convertNoticeItemData(List<dynamic> list) {
    Map<String, List<Map<String, dynamic>>> groupedBySaleDe =
        CommonHelpers.grouyByList(list, 'saleDe');
    // 결과 출력
    List<Map<String, dynamic>> resultList = [];
    groupedBySaleDe.forEach((saleDe, sales) {
      Map<String, dynamic> totalData = {'saleDe': saleDe, 'child': sales};

      resultList.add(totalData);
    });

    return resultList;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: '오류',
          content: message,
          confirmBtnLabel: '확인',
        );
      },
    );
  }
}

/// NoticeViewModel Provider
final noticeViewModelProvider =
    NotifierProvider.autoDispose<NoticeViewModel, NoticeState>(
      NoticeViewModel.new,
    );
