import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';
import 'package:paytap_app/common/widget/date_time_bottom_modal/data/date_time_type.dart';
import 'package:wheel_picker/wheel_picker.dart';

class DateWheel extends StatefulWidget {
  final DateTimeType type;
  final String name;
  final DateTime value;
  final void Function(String, dynamic) onChange;

  const DateWheel({
    super.key,
    required this.value,
    required this.onChange,
    this.name = '',
    this.type = DateTimeType.time, // year,month,day,time
  });

  @override
  State<DateWheel> createState() => _DateWheelState();
}

class _DateWheelState extends State<DateWheel> {
  late final List<Map<String, dynamic>> months;
  late final List<Map<String, dynamic>> years;
  late List<Map<String, dynamic>> days;
  late final List<Map<String, dynamic>> hours;
  late final List<Map<String, dynamic>> minutes;

  late final WheelPickerController _yearWheel;
  late final WheelPickerController _monthsWheel;
  late final WheelPickerController _daysWheel;
  late final WheelPickerController _hoursWheel;
  late final WheelPickerController _minutesWheel;

  int _selectedYear = 0;
  int _selectedMonth = 0;
  int _selectedDay = 1;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeControllers();
  }

  void _initializeData() {
    final now = TimeOfDay.now();
    final nowDate = widget.value;

    _selectedYear = nowDate.year;
    _selectedMonth = nowDate.month;
    _selectedDay = nowDate.day;

    years = List.generate(
      100,
      (index) => {
        "title": "${nowDate.year - 50 + index}년",
        "value": nowDate.year - 50 + index,
      },
    );
    months = List.generate(
      12,
      (index) => {"title": "${index + 1}월", "value": index + 1},
    );
    days = _generateDaysForMonth(_selectedYear, _selectedMonth);
    _selectedDayIndex = (_selectedDay - 1).clamp(0, days.length - 1);
    hours = List.generate(
      24,
      (index) => {
        "title": "${index.toString().padLeft(2, '0')}시",
        "value": index,
      },
    );
    minutes = List.generate(
      60,
      (index) => {
        "title": "${index.toString().padLeft(2, '0')}분",
        "value": index,
      },
    );
  }

  List<Map<String, dynamic>> _generateDaysForMonth(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return List.generate(
      daysInMonth,
      (index) => {"title": "${index + 1}일", "value": index + 1},
    );
  }

  void _updateDaysForMonth(int year, int month) {
    final newDays = _generateDaysForMonth(year, month);
    setState(() {
      days = newDays;
      _selectedYear = year;
      _selectedMonth = month;
      // 인덱스가 범위를 벗어나면 마지막 일로 이동
      if (_selectedDayIndex >= newDays.length) {
        _selectedDayIndex = newDays.length - 1;
        _selectedDay = newDays.last['value'];
        // wheel도 마지막 일로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _daysWheel.setCurrent(_selectedDayIndex);
          }
        });
      }
    });
    _daysWheel.itemCount = newDays.length;
  }

  void _initializeControllers() {
    final now = TimeOfDay.now();
    final nowDate = widget.value;

    _yearWheel = WheelPickerController(
      itemCount: years.length,
      initialIndex: years.indexWhere((item) => item['value'] == nowDate.year),
    );

    _monthsWheel = WheelPickerController(
      itemCount: months.length,
      initialIndex: nowDate.month - 1,
    );

    // 일 wheel의 초기 인덱스를 안전하게 계산
    final initialDayIndex = (nowDate.day - 1).clamp(0, days.length - 1);
    _selectedDayIndex = initialDayIndex;
    _daysWheel = WheelPickerController(
      itemCount: days.length,
      initialIndex: initialDayIndex,
    );

    _hoursWheel = WheelPickerController(
      itemCount: hours.length,
      initialIndex: hours.indexWhere((item) => item['value'] == nowDate.hour),
    );

    _minutesWheel = WheelPickerController(
      itemCount: minutes.length,
      initialIndex: minutes.indexWhere(
        (item) => item['value'] == nowDate.minute,
      ),
      mounts: [_hoursWheel],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GlobalTextStyle.title04M.copyWith(
      fontWeight: FontWeight.w600,
    );
    final wheelStyle = WheelPickerStyle(
      itemExtent: 25,
      squeeze: 0.6,
      diameterRatio: 1.2,
      surroundingOpacity: .50,
    );

    Widget itemBuilder(
      BuildContext context,
      int index,
      List<Map<String, dynamic>> items,
    ) {
      return Text(items[index]['title'], style: textStyle);
    }

    Widget createWheel({
      required WheelPickerController controller,
      required List<Map<String, dynamic>> items,
      required bool looping,
      required DateTime Function(int) onDateUpdate,
    }) {
      return Expanded(
        child: WheelPicker(
          builder: (context, index) => itemBuilder(context, index, items),
          controller: controller,
          looping: looping,
          style: wheelStyle,
          selectedIndexColor: GlobalColor.brand01,
          onIndexChanged: (value) {
            HapticFeedback.selectionClick();
            final updatedDate = onDateUpdate(value);
            widget.onChange(widget.name, updatedDate);
          },
        ),
      );
    }

    List<Widget> getWheels() {
      switch (widget.type) {
        case DateTimeType.time:
          return [
            createWheel(
              controller: _hoursWheel,
              items: hours,
              looping: false,
              onDateUpdate: (value) => DateTime(
                widget.value.year,
                widget.value.month,
                widget.value.day,
                hours[value]['value'],
                widget.value.minute,
              ),
            ),
            SizedBox(
              width: 20,
              child: Center(child: Text(":", style: textStyle)),
            ),
            createWheel(
              controller: _minutesWheel,
              items: minutes,
              looping: true,
              onDateUpdate: (value) => DateTime(
                widget.value.year,
                widget.value.month,
                widget.value.day,
                widget.value.hour,
                minutes[value]['value'],
              ),
            ),
          ];
        case DateTimeType.month:
          return [
            createWheel(
              controller: _yearWheel,
              items: years,
              looping: false,
              onDateUpdate: (value) => DateTime(
                years[value]['value'],
                widget.value.month,
                widget.value.day,
              ),
            ),
            SizedBox(width: 10),
            createWheel(
              controller: _monthsWheel,
              items: months,
              looping: false,
              onDateUpdate: (value) {
                final newMonth = months[value]['value'];
                _updateDaysForMonth(_selectedYear, newMonth);
                // 월이 변경되면 일을 1일로 강제 초기화
                _selectedDay = 1;
                return DateTime(_selectedYear, newMonth, _selectedDay);
              },
            ),
          ];
        case DateTimeType.day:
          return [
            createWheel(
              controller: _yearWheel,
              items: years,
              looping: false,
              onDateUpdate: (value) {
                final newYear = years[value]['value'];
                _updateDaysForMonth(newYear, _selectedMonth);
                return DateTime(
                  newYear,
                  _selectedMonth,
                  days[_selectedDayIndex]['value'],
                );
              },
            ),
            SizedBox(width: 10),
            createWheel(
              controller: _monthsWheel,
              items: months,
              looping: false,
              onDateUpdate: (value) {
                final newMonth = months[value]['value'];
                _updateDaysForMonth(_selectedYear, newMonth);
                return DateTime(
                  _selectedYear,
                  newMonth,
                  days[_selectedDayIndex]['value'],
                );
              },
            ),
            SizedBox(width: 10),
            createWheel(
              controller: _daysWheel,
              items: days,
              looping: false,
              onDateUpdate: (value) {
                _selectedDayIndex = value;
                _selectedDay = days[value]['value'];
                return DateTime(_selectedYear, _selectedMonth, _selectedDay);
              },
            ),
          ];
        default: // year
          return [
            createWheel(
              controller: _yearWheel,
              items: years,
              looping: false,
              onDateUpdate: (value) => DateTime(
                years[value]['value'],
                widget.value.month,
                widget.value.day,
              ),
            ),
          ];
      }
    }

    return Stack(
      children: [
        _centerBar(context),
        Row(children: getWheels()),
      ],
    );
  }

  @override
  void dispose() {
    _yearWheel.dispose();
    _monthsWheel.dispose();
    _daysWheel.dispose();
    _hoursWheel.dispose();
    _minutesWheel.dispose();
    super.dispose();
  }

  Widget _centerBar(BuildContext context) {
    return Center(
      child: Container(
        height: 40.0,
        decoration: BoxDecoration(
          color: GlobalColor.bk05,
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }
}
