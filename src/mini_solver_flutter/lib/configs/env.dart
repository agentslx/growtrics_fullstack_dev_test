import 'dart:ui';

import '../flavors.dart';


class AppEnv {
  static String get apiBaseUrl {
    switch (F.appFlavor) {
      case Flavor.dev:
        return 'http://192.168.1.11:8000';
      case Flavor.production:
        return 'http://192.168.1.11:8000';
      default:
        return 'http://192.168.1.11:8000';
    }
  }

  static const appName = 'Mini Solver';

  static const supportedLocales = [Locale('en')];

  static const String i18nPath = 'assets/i18n';
  static const mainLocale = Locale('en');

  static const String kPrefAccessToken = 'access_token';
  static const String kPrefRefreshToken = 'refresh_token';
}