class QueryState {
  Map<String, dynamic> initialQuery;
  QueryState(this.initialQuery);

  // query State 변환하는 함수.
  void onChangeQuery(String name, value) {
    initialQuery[name] = value;
  }

  // initialQuery를 반환하는 메서드
  Map<String, dynamic> getAllQuery() {
    return {...initialQuery};
  }

  // name에 해당 되는 값을 반환하는 메서드
  dynamic getQueryValue(String name) {
    return initialQuery[name];
  }

  // 대괄호 표기법으로 값을 가져오는 operator
  dynamic operator [](String name) {
    return initialQuery[name];
  }

  // 대괄호 표기법으로 값을 설정하는 operator
  void operator []=(String name, dynamic value) {
    initialQuery[name] = value;
  }
}
