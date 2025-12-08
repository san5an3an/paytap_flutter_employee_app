import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:paytap_app/common/constants/common_flag.dart';
import 'package:paytap_app/common/models/c_option.dart';
import 'package:paytap_app/common/models/cm_code.dart';
import 'package:paytap_app/common/models/pos.dart';
import 'package:paytap_app/common/utils/date_helpers.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/bottom_modal/bottom_modal.dart';
import 'package:paytap_app/common/widget/cm_chip/cm_chip.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_model.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';
import 'package:paytap_app/common/widget/cm_search/data/search_config.dart';
import 'package:paytap_app/common/widget/confirm_dialog/confirm_dialog.dart';
import 'package:paytap_app/common/widget/confrim_two_button/confrim_two_button.dart';
import 'package:paytap_app/common/widget/date_filter_button/date_filter_button.dart';
import 'package:paytap_app/common/widget/date_time_bottom_modal/data/date_time_type.dart';
import 'package:paytap_app/common/widget/date_time_bottom_modal/date_time_bottom_modal.dart';

class CmSearch extends ConsumerWidget {
  final SearchConfig searchConfig;
  final Map<String, dynamic> searchState;
  final Function(Map<String, dynamic>) searchSetState;
  const CmSearch({
    super.key,
    required this.searchConfig,
    required this.searchState,
    required this.searchSetState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < searchConfig.list.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  right: i < searchConfig.list.length - 1 ? 5.0 : 0.0,
                ),
                child: CmChip(
                  label: getChipLabel(searchConfig.list[i], searchState),
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        switch (searchConfig.list[i].type) {
                          // pos 경우
                          case CmSearchType.pos:
                            return _showPosSelectBottomModal(
                              context,
                              searchConfig.list[i],
                              searchState,
                            );

                          // 정산구분 경우
                          case CmSearchType.approvalType:
                            return _showApprovalTypeSelectBottomModal(
                              context,
                              searchConfig.list[i],
                              searchState,
                            );

                          // 선택 경우
                          case CmSearchType.select:
                            return _showSelectBottomModal(
                              context,
                              searchConfig.list[i],
                              searchState,
                            );

                          // 날짜 경우
                          case CmSearchType.dayDate:
                          case CmSearchType.rangeDayDate:
                          case CmSearchType.monthDate:
                          case CmSearchType.rangeMonthDate:
                            return _showDateTimeBottomModal(
                              context,
                              searchConfig.list[i],
                              searchState,
                            );

                          default:
                            // 예외 처리: 미처리 타입에 대한 기본 반환
                            return const SizedBox.shrink();
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String getChipLabel(SearchConfigItem item, Map<String, dynamic> searchState) {
    switch (item.type) {
      case CmSearchType.pos:
        return _getPosChipLabel(item, searchState);
      case CmSearchType.approvalType:
        return _getApprovalTypeChipLabel(item, searchState);
      case CmSearchType.select:
        return _getSelectChipLabel(item, searchState);
      case CmSearchType.dayDate:
        return _formatDate(searchState[item.name]);
      case CmSearchType.rangeDayDate:
        return _getRangeDateChipLabel(item, searchState);
      case CmSearchType.monthDate:
        return _formatMonth(searchState[item.name]);
      case CmSearchType.rangeMonthDate:
        return _getRangeMonthChipLabel(item, searchState);
      default:
        return "";
    }
  }

  // 포스 칩 라벨 생성
  String _getPosChipLabel(
    SearchConfigItem item,
    Map<String, dynamic> searchState,
  ) {
    final posNo = searchState[item.name];

    // 값이 없거나 빈 문자열이면 "전체" 표시
    if (posNo == null || posNo.toString().isEmpty) {
      return "${item.label} : 전체";
    }

    final pos = Pos.posList.firstWhere((pos) => pos.posNo == posNo);
    final cmCodeList = CmCode.getFindCmcodeList("629");
    final deviceTypeNm = cmCodeList
        .firstWhere((type) => type.code == pos.deviceTypeCode)
        .codeNm;
    return "${item.label} : ${pos.posNm} ($deviceTypeNm)";
  }

  // 정산구분 칩 라벨 생성
  String _getApprovalTypeChipLabel(
    SearchConfigItem item,
    Map<String, dynamic> searchState,
  ) {
    final approvalType = searchState[item.name];

    // 값이 없거나 빈 문자열이면 "전체" 표시
    if (approvalType == null || approvalType.toString().isEmpty) {
      return "${item.label} : 전체";
    }

    final approvalTypeNm = CommonFlag.PAY_TYPE_FLAG
        .firstWhere((type) => type.value == approvalType)
        .title;
    return "${item.label} : $approvalTypeNm";
  }

  // 범위 일자 칩 라벨 생성
  String _getRangeDateChipLabel(
    SearchConfigItem item,
    Map<String, dynamic> searchState,
  ) {
    final startDate = _formatDate(searchState[item.startDateKey]);
    final endDate = _formatDate(searchState[item.endDateKey]);
    return "$startDate ~ $endDate";
  }

  // 범위 월 칩 라벨 생성
  String _getRangeMonthChipLabel(
    SearchConfigItem item,
    Map<String, dynamic> searchState,
  ) {
    final startMonth = _formatMonth(searchState[item.startDateKey]);
    final endMonth = _formatMonth(searchState[item.endDateKey]);
    return "$startMonth ~ $endMonth";
  }

  // 날짜 형식 변환: "20250716" -> "25.07.16"
  String _formatDate(String? date) {
    if (date == null || date.length != 8) return "";
    return "${date.substring(2, 4)}.${date.substring(4, 6)}.${date.substring(6, 8)}";
  }

  // 월 형식 변환: "202507" -> "25.07"
  String _formatMonth(String? month) {
    if (month == null || month.length != 6) return "";
    return "${month.substring(2, 4)}.${month.substring(4, 6)}";
  }

  // 날짜 선택 모달
  Widget _showDateTimeBottomModal(
    BuildContext context,
    SearchConfigItem item,
    Map<String, dynamic> initialSearchState,
  ) {
    print("item: ${item.name}");
    final modalKey = "date_select_modal_${item.label}";

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(cmSearchModelProvider(modalKey));
        final vm = ref.read(cmSearchModelProvider(modalKey).notifier);
        // 모달이 처음 열릴 때 초기 상태 설정
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!state.isInitialized) {
            vm.initializeState(initialSearchState);
          }
        });

        return state.isInitialized
            ? BottomModal(
                title: "기간 선택",
                bottomWidget: ConfirmTwoButton(
                  leftButtonText: '닫기',
                  rightButtonText: '저장하기',
                  onLeftButtonPressed: () {
                    Navigator.of(context).pop();
                  },
                  onRightButtonPressed: () {
                    if (_isRangeType(item.type) &&
                        !_validateDateRange(item, state, context)) {
                      return;
                    }

                    searchSetState(state.searchState);
                    Navigator.of(context).pop();
                  },
                ),
                content: [
                  if (state.isInitialized) getDateChip(item, state, vm),
                  const SizedBox(height: 15),
                  // 시작일/시작 시간 타일
                  selectDateTile(
                    modalKey: modalKey,
                    label: _getDateTileLabel(item.type, true),
                    itemName: _getDateKey(item, true),
                    type: item.type,
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return _showWhileDateSelectBottomModal(
                            context,
                            item,
                            true,
                            modalKey,
                          );
                        },
                      );
                    },
                  ),
                  // 종료일/종료 시간 타일 (range 타입인 경우에만 표시)
                  if (_isRangeType(item.type))
                    selectDateTile(
                      modalKey: modalKey,
                      label: _getDateTileLabel(item.type, false),
                      type: item.type,
                      itemName: _getDateKey(item, false),
                      onTap: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return _showWhileDateSelectBottomModal(
                              context,
                              item,
                              false,
                              modalKey,
                            );
                          },
                        );
                      },
                    ),
                ],
              )
            : const SizedBox.shrink();
      },
    );
  }

  // 날짜 선택 Tile
  Widget selectDateTile({
    String? label,
    Function()? onTap,
    String? itemName,
    String? modalKey,
    CmSearchType? type,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(cmSearchModelProvider(modalKey ?? ""));

        // 날짜 값 가져오기 (itemName을 사용하여 searchState에서 값을 가져옴)
        String displayDate = "0000-00-00";

        final dateStr = state.searchState[itemName].toString();

        // 월 표시인 경우 "2024-04" 형식으로 표시
        if (dateStr.length >= 6 &&
            (type == CmSearchType.monthDate ||
                type == CmSearchType.rangeMonthDate)) {
          displayDate = "${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}";
        } else if (dateStr.length == 8) {
          // 일자 표시인 경우 "2024-06-12" 형식으로 표시
          displayDate =
              "${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}";
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
            highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    label ?? "",
                    style: GlobalTextStyle.body01M.copyWith(
                      color: GlobalColor.bk01,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        displayDate,
                        style: GlobalTextStyle.body01M.copyWith(
                          color: GlobalColor.bk03,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 기간 선택 칩
  Widget getDateChip(
    SearchConfigItem item,
    CmSearchState state,
    CmSearchModel vm,
  ) {
    final configType = item.type;

    switch (configType) {
      case CmSearchType.dayDate:
        return _buildDayDateChip(item, state, vm);
      case CmSearchType.rangeDayDate:
        return _buildRangeDayDateChip(item, state, vm);
      case CmSearchType.monthDate:
        return _buildMonthDateChip(item, state, vm);
      case CmSearchType.rangeMonthDate:
        return _buildRangeMonthDateChip(item, state, vm);
      default:
        return const SizedBox.shrink();
    }
  }

  // 단일 날짜 칩 위젯
  Widget _buildDayDateChip(
    SearchConfigItem item,
    CmSearchState state,
    CmSearchModel vm,
  ) {
    final dayDate = state.searchState[item.name];
    final dayDateTime = _parseDateString(dayDate);
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final isToday = _isSameDate(dayDateTime, today);
    final isYesterday = _isSameDate(dayDateTime, yesterday);

    return _buildDateFilterButtons([
      DateFilterConfig(
        label: "오늘",
        isActive: isToday,
        onTap: () => _setSingleDate(item, vm, today),
      ),
      DateFilterConfig(
        label: "어제",
        isActive: isYesterday,
        onTap: () => _setSingleDate(item, vm, yesterday),
      ),
    ]);
  }

  // 범위 날짜 칩 위젯
  Widget _buildRangeDayDateChip(
    SearchConfigItem item,
    CmSearchState state,
    CmSearchModel vm,
  ) {
    final startDate = state.searchState[item.startDateKey];
    final endDate = state.searchState[item.endDateKey];

    final startDateTime = _parseDateString(startDate);
    final endDateTime = _parseDateString(endDate);

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final startWeek = today.subtract(Duration(days: today.weekday - 1));
    final endWeek = startWeek.add(const Duration(days: 6));
    final startMonth = DateTime(today.year, today.month, 1);
    final endMonth = DateTime(today.year, today.month + 1, 0);
    final startYear = DateTime(today.year, 1, 1);
    final endYear = DateTime(today.year, 12, 31);

    return _buildDateFilterButtons([
      DateFilterConfig(
        label: "오늘",
        isActive:
            _isSameDate(startDateTime, today) &&
            _isSameDate(endDateTime, today),
        onTap: () => _setRangeDate(item, vm, today, today),
      ),
      DateFilterConfig(
        label: "어제",
        isActive:
            _isSameDate(startDateTime, yesterday) &&
            _isSameDate(endDateTime, yesterday),
        onTap: () => _setRangeDate(item, vm, yesterday, yesterday),
      ),
      DateFilterConfig(
        label: "이번주",
        isActive:
            _isSameDate(startDateTime, startWeek) &&
            _isSameDate(endDateTime, endWeek),
        onTap: () => _setRangeDate(item, vm, startWeek, endWeek),
      ),
      DateFilterConfig(
        label: "이번달",
        isActive:
            _isSameDate(startDateTime, startMonth) &&
            _isSameDate(endDateTime, endMonth),
        onTap: () => _setRangeDate(item, vm, startMonth, endMonth),
      ),
      DateFilterConfig(
        label: "올해",
        isActive:
            _isSameDate(startDateTime, startYear) &&
            _isSameDate(endDateTime, endYear),
        onTap: () => _setRangeDate(item, vm, startYear, endYear),
      ),
    ]);
  }

  // 단일 월 칩 위젯
  Widget _buildMonthDateChip(
    SearchConfigItem item,
    CmSearchState state,
    CmSearchModel vm,
  ) {
    final monthDate = state.searchState[item.name];
    final today = DateTime.now();

    /// 오늘 날짜 기준으로 이전 월의 1일을 변수로 저장
    final prevMonth = today.month == 1
        ? DateTime(today.year - 1, 12, 1)
        : DateTime(today.year, today.month - 1, 1);

    final currentMonth = _formatMonthString(today);
    final prevMonthStr =
        "${prevMonth.year.toString().padLeft(4, '0')}${prevMonth.month.toString().padLeft(2, '0')}";
    final isThisMonth = monthDate == currentMonth;
    final isPrevMonth = monthDate == prevMonthStr;

    return _buildDateFilterButtons([
      DateFilterConfig(
        label: "이번달",
        isActive: isThisMonth,
        onTap: () => vm.setSearchState(name: item.name, value: currentMonth),
      ),
      DateFilterConfig(
        label: "저번달",
        isActive: isPrevMonth,
        onTap: () => vm.setSearchState(name: item.name, value: prevMonthStr),
      ),
    ]);
  }

  // 범위 월 칩 위젯
  Widget _buildRangeMonthDateChip(
    SearchConfigItem item,
    CmSearchState state,
    CmSearchModel vm,
  ) {
    final startMonth = state.searchState[item.startDateKey];
    final endMonth = state.searchState[item.endDateKey];

    final today = DateTime.now();
    final currentMonth = _formatMonthString(today);
    final currentYear = "${today.year.toString().padLeft(4, '0')}01";
    final currentYearEnd = "${today.year.toString().padLeft(4, '0')}12";
    final isThisMonth = startMonth == currentMonth && endMonth == currentMonth;
    final isThisYear = startMonth == currentYear && endMonth == currentYearEnd;
    final prevMonth = today.month == 1
        ? DateTime(today.year - 1, 12, 1)
        : DateTime(today.year, today.month - 1, 1);
    final prevMonthStr =
        "${prevMonth.year.toString().padLeft(4, '0')}${prevMonth.month.toString().padLeft(2, '0')}";
    final isPrevMonth = startMonth == prevMonthStr && endMonth == prevMonthStr;

    return _buildDateFilterButtons([
      DateFilterConfig(
        label: "이번달",
        isActive: isThisMonth,
        onTap: () {
          vm.setSearchState(name: item.startDateKey, value: currentMonth);
          vm.setSearchState(name: item.endDateKey, value: currentMonth);
        },
      ),
      DateFilterConfig(
        label: "저번달",
        isActive: isPrevMonth,
        onTap: () {
          vm.setSearchState(name: item.startDateKey, value: prevMonthStr);
          vm.setSearchState(name: item.endDateKey, value: prevMonthStr);
        },
      ),
      DateFilterConfig(
        label: "올해",
        isActive: isThisYear,
        onTap: () {
          vm.setSearchState(
            name: item.startDateKey,
            value: "${today.year.toString().padLeft(4, '0')}01",
          );
          vm.setSearchState(
            name: item.endDateKey,
            value: "${today.year.toString().padLeft(4, '0')}12",
          );
        },
      ),
    ]);
  }

  // 날짜 필터 버튼들을 생성하는 헬퍼 메서드
  Widget _buildDateFilterButtons(List<DateFilterConfig> configs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: configs
            .map(
              (config) => DateFilterButton(
                label: config.label,
                isActive: config.isActive,
                onTap: config.onTap,
              ),
            )
            .toList(),
      ),
    );
  }

  // 날짜 문자열을 DateTime으로 파싱
  DateTime _parseDateString(String dateStr) {
    return DateTime.parse(
      "${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}",
    );
  }

  // 두 날짜가 같은지 비교 (년, 월, 일만)
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 월 형식으로 포맷팅
  String _formatMonthString(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}";
  }

  // 날짜를 문자열로 포맷팅
  String _formatDateString(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";
  }

  // 단일 날짜 설정
  void _setSingleDate(SearchConfigItem item, CmSearchModel vm, DateTime date) {
    vm.setSearchState(name: item.name, value: _formatDateString(date));
  }

  // 범위 날짜 설정
  void _setRangeDate(
    SearchConfigItem item,
    CmSearchModel vm,
    DateTime startDate,
    DateTime endDate,
  ) {
    vm.setSearchState(
      name: item.startDateKey,
      value: _formatDateString(startDate),
    );
    vm.setSearchState(name: item.endDateKey, value: _formatDateString(endDate));
  }

  // range 타입인지 확인하는 헬퍼 메서드
  bool _isRangeType(CmSearchType configType) {
    return configType == CmSearchType.rangeDayDate ||
        configType == CmSearchType.rangeMonthDate;
  }

  /// 날짜 범위 유효성 검증
  bool _validateDateRange(
    SearchConfigItem item,
    CmSearchState state,
    BuildContext context,
  ) {
    final startValue = state.searchState[item.startDateKey];
    final endValue = state.searchState[item.endDateKey];

    final startDate = _parseDateOrMonth(startValue);
    final endDate = _parseDateOrMonth(endValue);

    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      _showConfirmDialog(context, "날짜를 잘못 지정하였습니다. 다시 시도하여 주세요.");
      return false;
    }

    return true;
  }

  /// 날짜 문자열을 DateTime으로 변환하는 헬퍼 함수
  DateTime? _parseDateOrMonth(String? value) {
    if (value == null || value.isEmpty) return null;

    if (value.length == 8) {
      // "yyyyMMdd" 형식
      return DateHelpers.parseYYYYMMDDToDateTime(value);
    } else if (value.length == 6) {
      // "yyyyMM" 형식 (1일로 고정)
      return DateHelpers.parseYYYYMMToDateTime(value);
    }
    return null;
  }

  // 날짜 키를 가져오는 헬퍼 메서드
  String _getDateKey(SearchConfigItem item, bool isStart) {
    if (_isRangeType(item.type)) {
      return isStart ? item.startDateKey : item.endDateKey;
    } else {
      return item.name;
    }
  }

  // Date 모달 제목을 가져오는 헬퍼 메서드
  String _getDateModalTitle(CmSearchType configType, bool isStart) {
    switch (configType) {
      case CmSearchType.dayDate:
      case CmSearchType.rangeDayDate:
      case CmSearchType.monthDate:
      case CmSearchType.rangeMonthDate:
      default:
        return isStart ? "시작일 설정" : "종료일 설정";
    }
  }

  // date타입의 타일 라벨을 가져오는 헬퍼 메서드
  String _getDateTileLabel(CmSearchType configType, bool isStart) {
    switch (configType) {
      case CmSearchType.dayDate:
      case CmSearchType.rangeDayDate:
      case CmSearchType.monthDate:
      case CmSearchType.rangeMonthDate:
      default:
        return isStart ? "시작일" : "종료일";
    }
  }

  // // selectDateItem  시작,종료 설정 모달
  Widget _showWhileDateSelectBottomModal(
    BuildContext context,
    SearchConfigItem item,
    bool isStart,
    String modalKey,
  ) {
    final dateKey = _getDateKey(item, isStart);
    final title = _getDateModalTitle(item.type, isStart);

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(cmSearchModelProvider(modalKey));
        final vm = ref.read(cmSearchModelProvider(modalKey).notifier);
        final currentValue = state.searchState[dateKey] ?? "";

        return DateTimeBottomModal(
          title: title,
          name: dateKey,
          value: currentValue,
          type: _getDateTimeType(item.type),
          onTapSave: (name, value) {
            vm.setSearchState(name: name, value: value);
          },
        );
      },
    );
  }

  // CmSearchType을 DateTimeType으로 변환하는 헬퍼 메서드
  DateTimeType _getDateTimeType(CmSearchType configType) {
    switch (configType) {
      case CmSearchType.monthDate:
      case CmSearchType.rangeMonthDate:
        return DateTimeType.month;
      case CmSearchType.dayDate:
      case CmSearchType.rangeDayDate:
      default:
        return DateTimeType.day;
    }
  }

  // 정산 구분 선택 모달
  Widget _showApprovalTypeSelectBottomModal(
    BuildContext context,
    SearchConfigItem item,
    Map<String, dynamic> initialSearchState,
  ) {
    // 모달별 고유 키 생성
    final modalKey = "approval_type_select_modal_${item.name}";

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(cmSearchModelProvider(modalKey));
        final vm = ref.read(cmSearchModelProvider(modalKey).notifier);

        // 모달이 처음 열릴 때 초기 상태 설정
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!state.isInitialized) {
            vm.initializeState(initialSearchState);
          }
        });

        return BottomModal(
          title: "정산구분",
          bottomWidget: ConfirmTwoButton(
            leftButtonText: '닫기',
            rightButtonText: '저장하기',
            onLeftButtonPressed: () {
              Navigator.of(context).pop();
            },
            onRightButtonPressed: () {
              searchSetState(state.searchState);
              Navigator.of(context).pop();
            },
          ),
          content: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
              child: Column(
                children: [
                  // 전체 옵션 추가
                  checkTile(
                    "전체",
                    state.searchState[item.name] == null ||
                        state.searchState[item.name].toString().isEmpty,
                    item.name,
                    "",
                    vm,
                  ),
                  // 기존 정산구분 목록
                  ...CommonFlag.PAY_TYPE_FLAG.map(
                    (approvalItem) => checkTile(
                      approvalItem.title,
                      state.searchState[item.name] == approvalItem.value,
                      item.name,
                      approvalItem.value,
                      vm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 선택 칩 라벨 생성
  String _getSelectChipLabel(
    SearchConfigItem item,
    Map<String, dynamic> searchState,
  ) {
    final value = searchState[item.name];

    // 값이 없거나 빈 문자열이면 "전체" 표시
    if (value == null || value.toString().isEmpty) {
      return "${item.label} : 전체";
    }

    // options에서 해당 값을 찾아서 title 반환
    final option = item.options.firstWhere(
      (option) => option.value == value,
      orElse: () => COption(title: '전체', value: ''),
    );
    return "${item.label} : ${option.title}";
  }

  // 선택 모달
  Widget _showSelectBottomModal(
    BuildContext context,
    SearchConfigItem item,
    Map<String, dynamic> initialSearchState,
  ) {
    // 모달별 고유 키 생성
    final modalKey = "select_modal_${item.name}";

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(cmSearchModelProvider(modalKey));
        final vm = ref.read(cmSearchModelProvider(modalKey).notifier);

        // 모달이 처음 열릴 때 초기 상태 설정
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!state.isInitialized) {
            vm.initializeState(initialSearchState);
          }
        });

        return BottomModal(
          title: item.label,
          bottomWidget: ConfirmTwoButton(
            leftButtonText: '닫기',
            rightButtonText: '저장하기',
            onLeftButtonPressed: () {
              Navigator.of(context).pop();
            },
            onRightButtonPressed: () {
              searchSetState(state.searchState);
              Navigator.of(context).pop();
            },
          ),
          content: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
              child: Column(
                children: [
                  // 전체 옵션 추가
                  checkTile(
                    "전체",
                    state.searchState[item.name] == null ||
                        state.searchState[item.name].toString().isEmpty,
                    item.name,
                    "",
                    vm,
                  ),
                  // 기존 옵션 목록
                  ...item.options
                      .where((option) => option.value.isNotEmpty)
                      .map(
                        (option) => checkTile(
                          option.title,
                          state.searchState[item.name] == option.value,
                          item.name,
                          option.value,
                          vm,
                        ),
                      ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 포스 선택 모달
  Widget _showPosSelectBottomModal(
    BuildContext context,
    SearchConfigItem item,
    Map<String, dynamic> initialSearchState,
  ) {
    // 모달별 고유 키 생성
    final modalKey = "pos_select_modal_${item.name}";

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(cmSearchModelProvider(modalKey));
        final vm = ref.read(cmSearchModelProvider(modalKey).notifier);

        // 모달이 처음 열릴 때 초기 상태 설정
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!state.isInitialized) {
            vm.initializeState(initialSearchState);
          }
        });

        return BottomModal(
          title: "포스 선택",
          bottomWidget: ConfirmTwoButton(
            leftButtonText: '닫기',
            rightButtonText: '저장하기',
            onLeftButtonPressed: () {
              Navigator.of(context).pop();
            },
            onRightButtonPressed: () {
              searchSetState(state.searchState);
              Navigator.of(context).pop();
            },
          ),
          content: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
              child: Column(
                children: [
                  // 전체 옵션 추가
                  checkTile(
                    "전체",
                    state.searchState["posNo"] == null ||
                        state.searchState["posNo"].toString().isEmpty,
                    item.name,
                    "",
                    vm,
                  ),
                  // 기존 포스 목록
                  ...Pos.posList.map((posItem) {
                    final cmCodeList = CmCode.getFindCmcodeList("629");
                    final deviceTypeNm = cmCodeList
                        .firstWhere(
                          (type) => type.code == posItem.deviceTypeCode,
                        )
                        .codeNm;
                    final displayName = "${posItem.posNm} ($deviceTypeNm)";

                    return checkTile(
                      displayName,
                      state.searchState["posNo"] == posItem.posNo,
                      item.name,
                      posItem.posNo,
                      vm,
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 체크 타일 위젯
  Widget checkTile(
    String label,
    bool isSelected,
    String name,
    String value,
    CmSearchModel vm,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: GlobalColor.brand01.withValues(alpha: 0.2),
        highlightColor: GlobalColor.brand01.withValues(alpha: 0.1),
        onTap: () {
          vm.setSearchState(name: name, value: value);
        },
        child: Container(
          alignment: Alignment.centerLeft,
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              if (isSelected) Icon(Symbols.check, color: GlobalColor.brand01),
            ],
          ),
        ),
      ),
    );
  }
}

// 날짜 필터 설정을 위한 데이터 클래스
class DateFilterConfig {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  DateFilterConfig({required this.label, required this.isActive, this.onTap});
}

void _showConfirmDialog(context, message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ConfirmDialog(
        title: '조회 오류',
        content: message,
        confirmBtnLabel: '확인',
      );
    },
  );
}
