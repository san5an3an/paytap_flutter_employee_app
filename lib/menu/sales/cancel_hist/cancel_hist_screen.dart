import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/widget/amount_card/amount_card.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/sales/cancel_hist/cancel_hist_screen_model.dart';
import 'package:paytap_app/menu/sales/cancel_hist/widgets/cancel_hist_item.dart';

class CancelHistScreen extends ConsumerStatefulWidget {
  const CancelHistScreen({super.key});

  @override
  ConsumerState<CancelHistScreen> createState() => _CancelHistScreenState();
}

class _CancelHistScreenState extends ConsumerState<CancelHistScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화 (한 번만 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(cancelHistScreenModelProvider.notifier);
      final state = ref.read(cancelHistScreenModelProvider);
      if (!state.isInitialized && !state.isLoading) {
        vm.initializeData(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod 3.0.3 - ref.watch로 상태 구독 (리빌드용)
    final state = ref.watch(cancelHistScreenModelProvider);
    // MVVM 패턴 -  인스턴스 가져오기
    final vm = ref.read(cancelHistScreenModelProvider.notifier);

    return Layout(
      title: '주문 취소',
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
                    // MVVM 패턴 -  메서드 호출
                    vm.updateSearchState(newState);
                    vm.refreshData(context);
                  },
                ),
                const SizedBox(height: 10),
                AmountCard(mainList: state.amountCardList),
                if (state.isInitialLoading)
                  const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!state.isInitialLoading)
                  ...state.cancelHistItemList.map(
                    (item) => CancelHistItem(data: item),
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
