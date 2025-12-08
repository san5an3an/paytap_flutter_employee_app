import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/bottom_modal/bottom_modal.dart';
import 'package:paytap_app/menu/profile/notice/view_models/notice_detail_modal_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NoticeDetailModal extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;

  const NoticeDetailModal({super.key, required this.data});

  @override
  ConsumerState<NoticeDetailModal> createState() => _NoticeDetailModalState();
}

class _NoticeDetailModalState extends ConsumerState<NoticeDetailModal> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getNoticeData(widget.data);
  }

  Future<void> getNoticeData(data) async {
    setState(() {
      isLoading = true;
    });

    try {
      final notifier = ref.read(noticeDetailModalViewModelProvider.notifier);
      await notifier.getNoticeDetailModal(context, data);
    } catch (e) {
      print('Error loading more data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(noticeDetailModalViewModelProvider);

    return BottomModal(
      content: [
        const SizedBox(height: 10),
        Text(
          widget.data['boardSbjct'],
          style: GlobalTextStyle.title03.copyWith(
            color: GlobalColor.bk01,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${widget.data['startDe']} (${DateHelpers.getStringWeekday(widget.data['startDe'])})',
          style: GlobalTextStyle.body02.copyWith(color: GlobalColor.bk03),
        ),
        SizedBox(
          height: state.webViewHeight + 30, // WebView의 최대 높이 제한
          child: WebViewWidget(controller: state.controller),
        ),
      ],
    );
  }
}
