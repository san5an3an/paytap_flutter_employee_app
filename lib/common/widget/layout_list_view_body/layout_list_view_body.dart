import 'package:flutter/material.dart';
import 'package:paytap_app/common/widget/fab_button/fab_button.dart';

class LayoutListViewBody extends StatefulWidget {
  final ScrollController scrollController;
  final List<Widget> children;
  final bool isLoading;
  final VoidCallback? refresh;
  final VoidCallback? onScrollBottom;
  const LayoutListViewBody({
    super.key,
    required this.scrollController,
    required this.children,
    required this.isLoading,
    this.refresh,
    this.onScrollBottom,
  });

  @override
  State<LayoutListViewBody> createState() => _LayoutListViewBodyState();
}

class _LayoutListViewBodyState extends State<LayoutListViewBody> {
  bool _showFabButton = false;
  bool _hasReachedBottom = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController.offset > 0) {
      if (!_showFabButton) {
        setState(() {
          _showFabButton = true;
        });
      }
    } else {
      if (_showFabButton) {
        setState(() {
          _showFabButton = false;
        });
      }
    }

    // 스크롤이 바닥에 도달했는지 확인
    if (widget.onScrollBottom != null) {
      final position = widget.scrollController.position;
      const threshold = 50.0; // 바닥으로부터 50픽셀 이내면 도달한 것으로 간주

      if (position.pixels >= position.maxScrollExtent - threshold) {
        // 아직 바닥에 도달하지 않았을 때만 호출
        if (!_hasReachedBottom) {
          _hasReachedBottom = true;
          widget.onScrollBottom!();
        }
      } else {
        // 스크롤이 위로 올라가면 플래그 리셋
        _hasReachedBottom = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [Expanded(child: Scrollbar(child: content()))],
        ),
        if (_showFabButton)
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FabButton(scrollController: widget.scrollController),
          ),
      ],
    );
  }

  Widget content() {
    // ListView.builder를 Column으로 감싸서 최소 높이 보장
    final listView = Column(
      children: [
        // ListView를 Expanded로 감싸서 남은 공간을 모두 차지하도록 함
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: widget.children.length + (widget.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == widget.children.length) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return widget.children[index];
            },
          ),
        ),
      ],
    );

    if (widget.refresh == null) {
      return listView;
    }

    // 기기 높이에 따라 동적으로 최소 높이 계산
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final availableHeight = screenHeight - statusBarHeight - bottomPadding;

    // RefreshIndicator를 SingleChildScrollView로 감싸서 스크롤 가능한 영역 확보
    return RefreshIndicator(
      onRefresh: () async {
        widget.refresh!();
      },
      child: SingleChildScrollView(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(), // 항상 스크롤 가능하도록 설정
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: availableHeight, // 기기 높이에 따라 동적으로 설정
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                ...widget.children,
                if (widget.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
