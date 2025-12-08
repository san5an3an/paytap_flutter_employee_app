import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//애플리케이션의 전역적인 설정을 관리합니다. 예를 들어, API 엔드포인트, 환경 설정 등.
class AppConfig {
  static bool _initialized = false;

  // 초기화 메서드
  static Future<void> initialize() async {
    if (!_initialized) {
      await dotenv.load(fileName: ".env");
      _initialized = true;
    }
  }

  // API Base URL getter
  static String get apiBaseUrl {
    if (!_initialized) {
      throw Exception(
          'AppConfig가 초기화되지 않았습니다. main()에서 AppConfig.initialize()를 호출하세요.');
    }

    // 디버그 모드에서는 개발 API를, 릴리즈 모드에서는 프로덕션 API를 사용
    return kDebugMode
        ? dotenv.env['API_BASE_URL_DEV'] ?? 'https://api-dev.paytap.co.kr'
        : dotenv.env['API_BASE_URL_PROD'] ?? 'https://api.paytap.co.kr';
  }

  // 로그인 복호화 키 getter
  static String get loginDecryptKey {
    if (!_initialized) {
      throw Exception(
          'AppConfig가 초기화되지 않았습니다. main()에서 AppConfig.initialize()를 호출하세요.');
    }

    return dotenv.env['LOGIN_DECRYPT_KEY'] ?? 'secret_paytap_key_3377!!';
  }

  // 앱스토어 URL getter
  static String get appStoreUrl {
    if (!_initialized) {
      throw Exception(
          'AppConfig가 초기화되지 않았습니다. main()에서 AppConfig.initialize()를 호출하세요.');
    }

    return dotenv.env['APP_STORE_URL'] ?? 'https://apps.apple.com/kr/search';
  }

  // 구글플레이 URL getter
  static String get googlePlayUrl {
    if (!_initialized) {
      throw Exception(
          'AppConfig가 초기화되지 않았습니다. main()에서 AppConfig.initialize()를 호출하세요.');
    }

    return dotenv.env['GOOGLE_PLAY_URL'] ??
        'https://play.google.com/store/apps';
  }
}
