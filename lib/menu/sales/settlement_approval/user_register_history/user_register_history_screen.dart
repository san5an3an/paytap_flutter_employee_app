import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paytap_app/common/widget/cm_search/cm_search.dart';
import 'package:paytap_app/common/widget/layout/layout.dart';
import 'package:paytap_app/common/widget/layout_list_view_body/layout_list_view_body.dart';
import 'package:paytap_app/menu/sales/settlement_approval/user_register_history/user_register_history_screen_model.dart';
import 'package:paytap_app/menu/sales/settlement_approval/user_register_history/widgets/user_register_history_item.dart';

class UserRegisterHistoryScreen extends ConsumerStatefulWidget {
  const UserRegisterHistoryScreen({super.key});

  @override
  ConsumerState<UserRegisterHistoryScreen> createState() =>
      _UserRegisterHistoryScreenState();
}

class _UserRegisterHistoryScreenState
    extends ConsumerState<UserRegisterHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(userRegisterHistoryScreenModelProvider.notifier);
      vm.initializeData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userRegisterHistoryScreenModelProvider);
    final vm = ref.read(userRegisterHistoryScreenModelProvider.notifier);

    return Layout(
      title: '임의 등록 내역',
      isDisplayBottomNavigationBar: false,
      children: LayoutListViewBody(
        scrollController: vm.scrollController,
        isLoading: state.isLoading,
        refresh: () => vm.refreshData(context),
        onScrollBottom: () => vm.getUserRegisterHistory(context),
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
                  ...state.userRegisterHistoryItemList.map(
                    (item) => UserRegisterHistoryItem(data: item),
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
