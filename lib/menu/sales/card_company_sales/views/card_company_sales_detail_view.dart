import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/sales/card_company_sales/view_model/card_company_sales_detail_view_model.dart';
import 'package:paytap_app/menu/sales/card_company_sales/widgets/card_company_sales_detail_item.dart';

class CardCompanySalesDetailView extends ConsumerStatefulWidget {
  const CardCompanySalesDetailView({super.key});

  @override
  ConsumerState<CardCompanySalesDetailView> createState() =>
      _CardCompanySalesDetailViewState();
}

class _CardCompanySalesDetailViewState
    extends ConsumerState<CardCompanySalesDetailView> {
  @override
  void initState() {
    super.initState();
    // 초기화 (한 번만 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      print('Route extra: $extra');
      if (extra != null) {
        final vm = ref.read(cardCompanySalesDetailViewModelProvider.notifier);
        final state = ref.read(cardCompanySalesDetailViewModelProvider);
        vm.setInitialData(extra);
        if (!state.isInitialized && !state.isLoading) {
          vm.initializeData(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cardCompanySalesDetailViewModelProvider);
    final vm = ref.read(cardCompanySalesDetailViewModelProvider.notifier);

    return Layout(
      title: '${state.payCorpNm} 매출 상세',
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
                const SizedBox(height: 10),
                if (state.isInitialLoading)
                  const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!state.isInitialLoading)
                  ...state.itemList.map(
                    (item) => CardCompanySalesDetailItem(data: item),
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
