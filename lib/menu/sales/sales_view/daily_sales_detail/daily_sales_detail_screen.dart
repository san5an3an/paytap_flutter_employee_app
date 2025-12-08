import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/sales/sales_view/daily_sales_detail/daily_sales_detail_model.dart';
import 'package:paytap_app/menu/sales/sales_view/daily_sales_detail/widgets/daily_sales_detail_amount_card.dart';
import 'package:paytap_app/menu/sales/sales_view/daily_sales_detail/widgets/daily_sales_detail_item.dart';

class DailySalesDetailScreen extends ConsumerStatefulWidget {
  const DailySalesDetailScreen({super.key});

  @override
  ConsumerState<DailySalesDetailScreen> createState() =>
      _DailySalesDetailScreenState();
}

class _DailySalesDetailScreenState
    extends ConsumerState<DailySalesDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailySalesDetailScreenModelProvider);
    final vm = ref.read(dailySalesDetailScreenModelProvider.notifier);

    // 초기화 (한 번만 실행)
    if (!state.isInitialized && !state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.initializeData(context);
      });
    }
    return Layout(
      title: '당일 매출 상세',
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
                DailySalesDetailAmountCard(
                  title: '판매',
                  mainList: state.totalSaleList,
                ),
                const SizedBox(height: 20),
                DailySalesDetailAmountCard(
                  title: "반품",
                  mainList: state.totalReturnSaleList,
                ),
                if (state.isInitialLoading)
                  const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!state.isInitialLoading)
                  ...state.dailySalesDetailItemList.map(
                    (item) => DailySalesDetailItem(data: item),
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
