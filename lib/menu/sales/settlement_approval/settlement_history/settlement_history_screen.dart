import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/sales/settlement_approval/settlement_history/settlement_history_screen_model.dart';

class SettlementHistoryScreen extends ConsumerStatefulWidget {
  const SettlementHistoryScreen({super.key});

  @override
  ConsumerState<SettlementHistoryScreen> createState() =>
      _SettlementHistoryScreenState();
}

class _SettlementHistoryScreenState
    extends ConsumerState<SettlementHistoryScreen> {
  @override
  void initState() {
    super.initState();

    // 위젯 트리 빌드 완료 후 초기화 실행
    Future.microtask(() {
      final vm = ref.read(settlementHistoryScreenModelProvider.notifier);
      vm.initializeSettlementHistory(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settlementHistoryScreenModelProvider);
    final vm = ref.read(settlementHistoryScreenModelProvider.notifier);

    return Layout(
      title: '정산 내역',
      isDisplayBottomNavigationBar: false,
      children: LayoutListViewBody(
        scrollController: vm.scrollController,
        isLoading: state.isLoading,
        refresh: () => vm.setRefresh(context),
        onScrollBottom: () => vm.getHistory(context),
        children: [
          if (state.isInitialLoading)
            const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!state.isInitialLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  CmSearch(
                    searchConfig: state.searchConfig,
                    searchState: state.searchState,
                    searchSetState: (newState) =>
                        vm.updateSearchState(newState, context),
                  ),
                  const SizedBox(height: 10),
                  if (!state.isInitialLoading)
                    ...state.historyList.map((item) => vm.getHistoryItem(item)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
