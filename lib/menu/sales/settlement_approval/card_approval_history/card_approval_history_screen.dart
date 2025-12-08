import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/sales/settlement_approval/card_approval_history/card_approval_history_screen_model.dart';
import 'package:paytap_app/menu/sales/settlement_approval/card_approval_history/widgets/card_approval_history_item.dart';

class CardApprovalHistoryScreen extends ConsumerStatefulWidget {
  const CardApprovalHistoryScreen({super.key});

  @override
  ConsumerState<CardApprovalHistoryScreen> createState() =>
      _CardApprovalHistoryScreenState();
}

class _CardApprovalHistoryScreenState
    extends ConsumerState<CardApprovalHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(cardApprovalHistoryScreenModelProvider.notifier);
      vm.initializeData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cardApprovalHistoryScreenModelProvider);
    final vm = ref.read(cardApprovalHistoryScreenModelProvider.notifier);

    return Layout(
      title: '카드 승인 내역',
      isDisplayBottomNavigationBar: false,
      children: LayoutListViewBody(
        scrollController: vm.scrollController,
        isLoading: state.isLoading,
        refresh: () => vm.refreshData(context),
        onScrollBottom: () => vm.getCardApprovalHistory(context),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                CmSearch(
                  searchConfig: state.searchConfig,
                  searchState: state.searchState,
                  searchSetState: (newState) {
                    vm.updateSearchState(newState, context);
                    vm.refreshData(context);
                  },
                ),
                if (state.isInitialLoading)
                  const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!state.isInitialLoading)
                  ...state.cardApprovalHistoryItemList.map(
                    (item) => CardApprovalHistoryItem(data: item),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
