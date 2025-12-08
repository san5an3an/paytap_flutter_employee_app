import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:paytap_app/menu/profile/notice/services/notice_detail_modal_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 공지사항 상세 모달 화면의 상태 모델
class NoticeDetailModalState {
  final WebViewController controller;
  final double webViewHeight;

  const NoticeDetailModalState({
    required this.controller,
    this.webViewHeight = 500,
  });

  NoticeDetailModalState copyWith({
    WebViewController? controller,
    double? webViewHeight,
  }) {
    return NoticeDetailModalState(
      controller: controller ?? this.controller,
      webViewHeight: webViewHeight ?? this.webViewHeight,
    );
  }
}

/// Riverpod 3.0.3 - Notifier 사용 (auto-dispose는 Provider 선언 방식으로 결정)
class NoticeDetailModalViewModel extends Notifier<NoticeDetailModalState> {
  final NoticeDetailModalService noticeDetailModalService =
      NoticeDetailModalService();
  final storage = FlutterSecureStorage();

  @override
  NoticeDetailModalState build() {
    return NoticeDetailModalState(controller: WebViewController());
  }

  //데이터 조회 하는 함수
  Future<void> getNoticeDetailModal(context, row) async {
    Map<String, dynamic> data = {"boardPid": row["boardPid"]};
    Map<String, dynamic> res = await noticeDetailModalService
        .getNoticeDetailList(data);
    if (res.containsKey('error')) {
      return _showErrorDialog(context, res["results"]);
    }
    if (res['results'].length > 0) {
      settingWebView(context, res['results']['boardCntnts']);
    }
  }

  void settingWebView(context, boardCntnts) {
    final controller = WebViewController();
    controller.setJavaScriptMode(
      JavaScriptMode.unrestricted,
    ); // JavaScript 모드 설정
    controller.loadFlutterAsset('assets/html/view.html');
    // HTML이 로드된 후에 JavaScript 실행
    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) {
          // HTML이 완전히 로드된 후에 JavaScript 실행
          _updateHtmlContent(context, boardCntnts);
        },
      ),
    );

    controller.addJavaScriptChannel(
      'messageHandler',
      onMessageReceived: (args) {
        final webViewHeight = double.parse(args.message);
        state = state.copyWith(webViewHeight: webViewHeight);
      },
    );

    state = state.copyWith(controller: controller);
  }

  // JavaScript 실행 함수: content에 새로운 HTML을 삽입
  void _updateHtmlContent(context, boardCntnts) {
    final deviceWidth = MediaQuery.of(context).size.width;

    state.controller.runJavaScript("setContent('$boardCntnts',$deviceWidth);");
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

/// NoticeDetailModalViewModel Provider
final noticeDetailModalViewModelProvider =
    NotifierProvider.autoDispose<
      NoticeDetailModalViewModel,
      NoticeDetailModalState
    >(NoticeDetailModalViewModel.new);
