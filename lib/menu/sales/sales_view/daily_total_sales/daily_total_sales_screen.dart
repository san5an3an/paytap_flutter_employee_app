import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/widget/amount_card/amount_card.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/sales/sales_view/daily_total_sales/daily_total_sales_screen_model.dart';
import 'package:paytap_app/menu/sales/sales_view/daily_total_sales/widgets/daily_total_sales_item.dart';

class DailyTotalSalesScreen extends ConsumerStatefulWidget {
  const DailyTotalSalesScreen({super.key});

  @override
  ConsumerState<DailyTotalSalesScreen> createState() =>
      _DailyTotalSalesScreenState();
}

class _DailyTotalSalesScreenState extends ConsumerState<DailyTotalSalesScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyTotalSalesScreenModelProvider);
    final vm = ref.read(dailyTotalSalesScreenModelProvider.notifier);

    // 초기화 (한 번만 실행)
    if (!state.isInitialized && !state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.initializeData(context);
      });
    }

    return Layout(
      title: '일 종합 매출',
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
                const SizedBox(height: 20),
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
                        ...state.itemList.asMap().entries.map((entry) {
                          int index = entry.key;
                          var item = entry.value;
                          bool isLast = state.itemList.length - 1 == index;
                          return DailyTotalSalesItem(
                            data: item,
                            isLast: isLast,
                          );
                        }),
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
