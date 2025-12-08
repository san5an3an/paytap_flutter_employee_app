import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/sales/dc_type_sales/dc_type_sales_screen_model.dart';
import 'package:paytap_app/menu/sales/dc_type_sales/widgets/dc_type_sales_amount_card.dart';
import 'package:paytap_app/menu/sales/dc_type_sales/widgets/dc_type_sales_item.dart';

class DcTypeSalesScreen extends ConsumerStatefulWidget {
  const DcTypeSalesScreen({super.key});

  @override
  ConsumerState<DcTypeSalesScreen> createState() => _DcTypeSalesScreenState();
}

class _DcTypeSalesScreenState extends ConsumerState<DcTypeSalesScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화 (한 번만 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(dcTypeSalesScreenModelProvider.notifier);
      final state = ref.read(dcTypeSalesScreenModelProvider);
      if (!state.isInitialized && !state.isLoading) {
        vm.initializeData(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dcTypeSalesScreenModelProvider);
    final vm = ref.read(dcTypeSalesScreenModelProvider.notifier);

    return Layout(
      title: '할인 유형별 매출',
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
                DcTypeSalesAmountCard(mainList: state.amountCardList),
                const SizedBox(height: 30),
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
                      borderRadius: BorderRadius.circular(29),
                    ),
                    width: double.infinity,
                    child: Column(
                      children: state.goodsSalesItemList
                          .asMap()
                          .entries
                          .map(
                            (entry) => DcTypeSalesItem(
                              data: entry.value,
                              index: entry.key,
                              totalCount: state.goodsSalesItemList.length,
                            ),
                          )
                          .toList(),
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
