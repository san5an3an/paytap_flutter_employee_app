import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/widget/amount_card/amount_card.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/sales/sales_view/return_history/return_history_screen_model.dart';
import 'package:paytap_app/menu/sales/sales_view/return_history/widgets/return_history_item.dart';

class ReturnHistoryScreen extends ConsumerStatefulWidget {
  const ReturnHistoryScreen({super.key});

  @override
  ConsumerState<ReturnHistoryScreen> createState() =>
      _ReturnHistoryScreenState();
}

class _ReturnHistoryScreenState extends ConsumerState<ReturnHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화 (한 번만 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(returnHistoryScreenModelProvider.notifier);
      final state = ref.read(returnHistoryScreenModelProvider);
      if (!state.isInitialized && !state.isLoading) {
        vm.initializeData(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(returnHistoryScreenModelProvider);
    final vm = ref.read(returnHistoryScreenModelProvider.notifier);

    return Layout(
      title: '반품 내역',
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
                AmountCard(mainList: state.amountCardMainList),
                const SizedBox(height: 10),
                if (state.isInitialLoading)
                  const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!state.isInitialLoading)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: GlobalColor.bk08,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: [
                        ...state.returnHistoryItemList.map(
                          (item) => ReturnHistoryItem(data: item),
                        ),
                      ],
                    ),
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
