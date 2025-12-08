import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paytap_app/common/widget/amount_card/amount_card.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/sales/sales_view/payment_history/payment_history_screen_model.dart';
import 'package:paytap_app/menu/sales/sales_view/payment_history/widgets/payment_history_item.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화는 한 번만 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // go_router에서는 extra를 사용
      final args = GoRouterState.of(context).extra;
      if (args != null) {
        print('PaymentHistory route extra: $args');
      }

      final vm = ref.read(paymentHistoryScreenModelProvider.notifier);
      final state = ref.read(paymentHistoryScreenModelProvider);
      if (!state.isInitialized && !state.isLoading) {
        vm.initializeData(context, args);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentHistoryScreenModelProvider);
    final vm = ref.read(paymentHistoryScreenModelProvider.notifier);

    return Layout(
      title: '결제 내역',
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
                  ...state.itemList.map(
                    (item) => PaymentHistoryItem(data: item),
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
