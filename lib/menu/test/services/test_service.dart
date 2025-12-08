import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 테스트 화면의 비즈니스 로직을 처리하는 서비스
class TestService {
  /// 비동기 작업 수행
  /// 실제 환경에서는 API 호출이나 데이터베이스 작업 등을 수행
  Future<void> performAsyncTask() async {
    // 2초간 대기하여 비동기 작업 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));

    // 랜덤하게 에러 발생 (테스트용)
    if (DateTime.now().millisecond % 3 == 0) {
      throw Exception('테스트 에러가 발생했습니다.');
    }
  }

  /// 데이터 가져오기 (예시)
  Future<Map<String, dynamic>> fetchData() async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'message': '테스트 데이터입니다.',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// TestService Provider
final testServiceProvider = Provider<TestService>((ref) {
  return TestService();
});
