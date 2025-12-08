import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/bottom_modal/bottom_modal.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FaqDetailModal extends StatefulWidget {
  const FaqDetailModal({super.key});

  @override
  State<FaqDetailModal> createState() => _FaqDetailModalState();
}

class _FaqDetailModalState extends State<FaqDetailModal> {
  late final WebViewController _controller;
  double _webViewHeight = 500; // 초기 높이 설정
  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    _controller.setJavaScriptMode(
      JavaScriptMode.unrestricted,
    ); // JavaScript 모드 설정
    _controller.loadFlutterAsset('assets/html/view.html');
    // HTML이 로드된 후에 JavaScript 실행
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) {
          // HTML이 완전히 로드된 후에 JavaScript 실행
          _updateHtmlContent();
        },
      ),
    );

    _controller.addJavaScriptChannel(
      'messageHandler',
      onMessageReceived: (args) {
        print('html -> flutter: ${args.message}');
        setState(() {
          _webViewHeight = double.parse(args.message);
        });
      },
    );
  }

  // JavaScript 실행 함수: content에 새로운 HTML을 삽입
  void _updateHtmlContent() {
    final deviceWidth = MediaQuery.of(context).size.width;

    String htmlContent =
        "<p><del><img src=\"https://osp-dev.s3.ap-northeast-2.amazonaws.com/board/image/t1713862849052-image.png\" alt=\"alt text\" contenteditable=\"false\">1. 파일을 업로드 합니다</del></p><p><del>2. 파일을 삭제합니다</del></p><p><del>3. 기존 파일 삭제후 신규 파일 업로드 합니다</del></p><p>4. 파일 추가 업로드 합니다</p><p><del><img src=\"https://osp-dev.s3.ap-northeast-2.amazonaws.com/board/image/t1713862849052-image.png\" alt=\"alt text\" contenteditable=\"false\">1. 파일을 업로드 합니다</del></p><p><del>2. 파일을 삭제합니다</del></p><p><del>3. 기존 파일 삭제후 신규 파일 업로드 합니다</del></p><p>4. 파일 추가 업로드 합니다</p><p><del><img src=\"https://osp-dev.s3.ap-northeast-2.amazonaws.com/board/image/t1713862849052-image.png\" alt=\"alt text\" contenteditable=\"false\">1. 파일을 업로드 합니다</del></p><p><del>2. 파일을 삭제합니다</del></p><p><del>3. 기존 파일 삭제후 신규 파일 업로드 합니다</del></p><p>4. 파일 추가 업로드 합니다</p>";
    _controller.runJavaScript("setContent('$htmlContent',$deviceWidth);");
  }

  @override
  Widget build(BuildContext context) {
    return BottomModal(
      content: [
        const SizedBox(height: 10),
        Text(
          'FAQ 제목 가나다라 마바사아',
          style: GlobalTextStyle.title03.copyWith(
            color: GlobalColor.bk01,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '0000-00-00 (금)',
          style: GlobalTextStyle.body02.copyWith(color: GlobalColor.bk03),
        ),
        SizedBox(
          height: _webViewHeight + 30, // WebView의 최대 높이 제한
          child: WebViewWidget(controller: _controller),
        ),
      ],
    );
  }
}
