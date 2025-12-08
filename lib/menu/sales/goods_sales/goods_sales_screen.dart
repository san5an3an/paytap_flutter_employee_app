import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/amount_card/amount_card.dart';
import 'package:paytap_app/common/widget/cm_donut_chart/cm_donut_chart.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/cm_segmented_button/cm_segmented_button.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/sales/goods_sales/goods_sales_screen_model.dart';
import 'package:paytap_app/menu/sales/goods_sales/widgets/goods_sales_item.dart';

class GoodsSalesScreen extends ConsumerStatefulWidget {
  const GoodsSalesScreen({super.key});

  @override
  ConsumerState<GoodsSalesScreen> createState() => _GoodsSalesScreenState();
}

class _GoodsSalesScreenState extends ConsumerState<GoodsSalesScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화 (한 번만 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(goodsSalesScreenModelProvider.notifier);
      final state = ref.read(goodsSalesScreenModelProvider);
      if (!state.isInitialized && !state.isLoading) {
        vm.initializeData(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goodsSalesScreenModelProvider);
    final vm = ref.read(goodsSalesScreenModelProvider.notifier);

    return Layout(
      title: '상품 매출',
      isDisplayBottomNavigationBar: false,
      children: state.searchState['contentType'] == 'sales'
          ? _salesContent(context, state, vm)
          : _goodsContent(context, state, vm),
    );
  }
}

Widget _salesContent(
  BuildContext context,
  GoodsSalesState state,
  GoodsSalesScreenModel vm,
) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CmSearch(
            searchConfig: state.searchConfig,
            searchState: state.searchState,
            searchSetState: (newState) {
              vm.updateSearchState(newState);
              vm.refreshData(context);
            },
          ),
          const SizedBox(height: 15),
          CmSegmentedButton(
            name: 'contentType',
            value: state.searchState['contentType'],
            options: vm.contentTypeOptions,
            onTap: (name, value) =>
                vm.onSalesGoodsButtonTap(name, value, context),
          ),
          const SizedBox(height: 15),
          AmountCard(mainList: state.amountCardList),
          const SizedBox(height: 30),
          if (state.isInitialLoading)
            const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!state.isInitialLoading) ...[
            const SizedBox(height: 15),
            Text('가장 많이 판매한 상품 Best 5', style: GlobalTextStyle.body01M),
            const SizedBox(height: 15),
            CmDonutChart(chartData: state.donutChartData, height: 190),
          ],
        ],
      ),
    ),
  );
}

Widget _goodsContent(
  BuildContext context,
  GoodsSalesState state,
  GoodsSalesScreenModel vm,
) {
  return LayoutListViewBody(
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
            const SizedBox(height: 15),
            CmSegmentedButton(
              name: 'contentType',
              value: state.searchState['contentType'],
              options: vm.contentTypeOptions,
              onTap: (name, value) =>
                  vm.onSalesGoodsButtonTap(name, value, context),
            ),
            const SizedBox(height: 15),
            AmountCard(mainList: state.amountCardList),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CmSegmentedButton(
                  width: 120,
                  height: 40,
                  name: 'orderFlag',
                  value: state.searchState['orderFlag'],
                  options: vm.itemOptions,
                  onTap: (name, value) =>
                      vm.onPriceOrCountButtonTap(name, value, context),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (state.isInitialLoading)
              const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!state.isInitialLoading && state.goodsSalesItemList.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: GlobalColor.bk08,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: state.goodsSalesItemList.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        GoodsSalesItem(data: item, index: index),
                        if (index < state.goodsSalesItemList.length - 1)
                          const SizedBox(height: 15),
                      ],
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ],
  );
}
