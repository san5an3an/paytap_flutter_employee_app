import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paytap_app/common/widget/amount_card/amount_card.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/sales/sales_view/receipt_history/receipt_history_screen_model.dart';
import 'package:paytap_app/menu/sales/sales_view/receipt_history/widgets/receipt_history_item.dart';

class ReceiptHistoryScreen extends ConsumerStatefulWidget {
  const ReceiptHistoryScreen({super.key});

  @override
  ConsumerState<ReceiptHistoryScreen> createState() =>
      _ReceiptHistoryScreenState();
}

class _ReceiptHistoryScreenState extends ConsumerState<ReceiptHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화를 initState에서 한 번만 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // go_router에서는 extra를 사용
      final args = GoRouterState.of(context).extra;
      if (args != null) {
        print('ReceiptHistory route extra: $args');
      }
      final vm = ref.read(receiptHistoryScreenModelProvider.notifier);
      final state = ref.read(receiptHistoryScreenModelProvider);
      if (!state.isInitialized && !state.isLoading) {
        vm.initializeData(context, args);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptHistoryScreenModelProvider);
    final vm = ref.read(receiptHistoryScreenModelProvider.notifier);

    return Layout(
      title: '영수 내역',
      isDisplayBottomNavigationBar: false,
      children: LayoutListViewBody(
        scrollController: vm.scrollController,
        isLoading: state.isLoading,
        refresh: () => vm.refreshData(context),
        onScrollBottom: () => vm.loadMoreData(context),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                CmSearch(
                  searchConfig: state.searchConfig,
                  searchState: state.searchState,
                  searchSetState: (newState) =>
                      vm.setSearchState(newState, context),
                ),
                const SizedBox(height: 10),
                AmountCard(mainList: state.amountCardList),
                if (state.isInitialLoading)
                  const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!state.isInitialLoading)
                  ...state.receiptHistoryItemList.map(
                    (item) => ReceiptHistoryItem(data: item),
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
