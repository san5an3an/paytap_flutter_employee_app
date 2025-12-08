import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/profile/notice/view_models/notice_view_model.dart';

class Notice extends ConsumerStatefulWidget {
  const Notice({super.key});

  @override
  ConsumerState<Notice> createState() => _NoticeState();
}

class _NoticeState extends ConsumerState<Notice> {
  bool _isInitialLoading = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getNoticeData();
  }

  Future<void> getNoticeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final notifier = ref.read(noticeViewModelProvider.notifier);
      await notifier.getNotice(context);
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

  Future<void> setRefresh() async {
    if (!_isInitialLoading) {
      setState(() {
        _isInitialLoading = true;
      });

      try {
        final notifier = ref.read(noticeViewModelProvider.notifier);
        await notifier.resetNoticeList();
        getNoticeData();
      } catch (e) {
        print('Error during reset and reload: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isInitialLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: '공지사항',
      currentIdx: 2,
      children: LayoutListViewBody(
        scrollController: ref
            .read(noticeViewModelProvider.notifier)
            .scrollController,
        isLoading: isLoading,
        refresh: setRefresh,
        onScrollBottom: getNoticeData,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(children: []),
          ),
        ],
      ),
    );
  }
}
