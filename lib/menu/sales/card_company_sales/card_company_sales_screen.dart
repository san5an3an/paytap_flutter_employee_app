import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/sales/card_company_sales/card_company_sales_screen_model.dart';
import 'package:paytap_app/menu/sales/card_company_sales/widgets/card_company_sales_item.dart';

class CardCompanySalesScreen extends ConsumerStatefulWidget {
  const CardCompanySalesScreen({super.key});

  @override
  ConsumerState<CardCompanySalesScreen> createState() =>
      _CardCompanySalesScreenState();
}

class _CardCompanySalesScreenState
    extends ConsumerState<CardCompanySalesScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화 (한 번만 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(cardCompanySalesScreenModelProvider.notifier);
      final state = ref.read(cardCompanySalesScreenModelProvider);
      if (!state.isInitialized && !state.isLoading) {
        vm.initializeData(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cardCompanySalesScreenModelProvider);
    final vm = ref.read(cardCompanySalesScreenModelProvider.notifier);

    return Layout(
      title: '카드사별 매출',
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
                  searchSetState: (newState) {
                    vm.updateSearchState(newState);
                    vm.refreshData(context);
                  },
                ),
                const SizedBox(height: 10),
                if (state.isInitialLoading)
                  const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!state.isInitialLoading)
                  ...state.dealHistoryItemList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isLast =
                        index == state.dealHistoryItemList.length - 1;
                    return CardCompanySalesItem(data: item, isLast: isLast);
                  }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
