import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/sales/settlement_approval/easy_approval_history/easy_approval_history_screen_model.dart';
import 'package:paytap_app/menu/sales/settlement_approval/easy_approval_history/widgets/easy_approval_history_item.dart';

class EasyApprovalHistoryScreen extends ConsumerStatefulWidget {
  const EasyApprovalHistoryScreen({super.key});

  @override
  ConsumerState<EasyApprovalHistoryScreen> createState() =>
      _EasyApprovalHistoryScreenState();
}

class _EasyApprovalHistoryScreenState
    extends ConsumerState<EasyApprovalHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(easyApprovalHistoryScreenModelProvider.notifier);
      vm.initializeData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(easyApprovalHistoryScreenModelProvider);
    final vm = ref.read(easyApprovalHistoryScreenModelProvider.notifier);

    return Layout(
      title: '간편 승인 내역',
      isDisplayBottomNavigationBar: false,
      children: LayoutListViewBody(
        scrollController: vm.scrollController,
        isLoading: state.isLoading,
        refresh: () => vm.refreshData(context),
        onScrollBottom: () => vm.getEasyApprovalHistory(context),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                CmSearch(
                  searchConfig: state.searchConfig,
                  searchState: state.searchState,
                  searchSetState: (newState) {
                    vm.updateSearchState(newState, context);
                    vm.refreshData(context);
                  },
                ),
                if (state.isInitialLoading)
                  const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!state.isInitialLoading)
                  ...state.easyApprovalHistoryItemList.map(
                    (item) => EasyApprovalHistoryItem(data: item),
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
