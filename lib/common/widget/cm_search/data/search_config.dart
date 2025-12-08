import 'package:paytap_app/common/models/c_option.dart';
import 'package:paytap_app/common/widget/cm_search/data/cm_search_type.dart';

class SearchConfigItem {
  final String label;
  final CmSearchType type;
  final String name;
  final List<COption> options;
  final bool isAll;
  final String startDateKey;
  final String endDateKey;
  SearchConfigItem({
    required this.label,
    required this.type,
    this.name = "",
    this.options = const [],
    this.isAll = false,
    this.startDateKey = "",
    this.endDateKey = "",
  });

  factory SearchConfigItem.fromJson(Map<String, dynamic> json) {
    return SearchConfigItem(
      label: json['label'],
      name: json['name'],
      type: json['type'],
      options: json['options']
          .map(
            (option) => COption(title: option['title'], value: option['value']),
          )
          .toList(),
      isAll: json['isAll'],
      startDateKey: json['startDateKey'],
      endDateKey: json['endDateKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'name': name,
      'type': type,
      'options': options,
      'isAll': isAll,
      'startDateKey': startDateKey,
      'endDateKey': endDateKey,
    };
  }
}

class SearchConfig {
  final List<SearchConfigItem> list;
  SearchConfig({required this.list});
}
