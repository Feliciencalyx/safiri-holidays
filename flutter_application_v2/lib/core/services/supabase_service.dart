import 'package:flutter/foundation.dart';

/// Secure application configuration injected at compile-time.
///
/// Values can be supplied via:
/// `flutter run --dart-define-from-file=secrets.json`
/// or individually:
/// `flutter run --dart-define=API_BASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
class SupabaseProductionConfig {
  /// Base domain for the production backend API (Railway Node.js).
  static const String productionApiDomain = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://safiri-holidays-production.up.railway.app',
  );

  /// Local development domains
  static const String localApiDomain = String.fromEnvironment(
    'LOCAL_API_DOMAIN',
    defaultValue: 'http://10.0.2.2:5000',
  );
  static const String webApiDomain = String.fromEnvironment(
    'WEB_API_DOMAIN',
    defaultValue: 'http://localhost:5000',
  );

  /// Supabase Cloud Project URL
  static const String supabaseProjectUrl = String.fromEnvironment(
    'SUPABASE_PROJECT_URL',
    defaultValue: 'https://ttnbiybejkwdwgkhfunh.supabase.co',
  );

  /// Supabase Anonymous Public Key.
  /// Injected at compile time. Never hardcode plaintext keys in source files.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Environment switch (defaults to true for production railway backend)
  static const bool isProductionEnvironment = bool.fromEnvironment(
    'IS_PRODUCTION',
    defaultValue: true,
  );

  /// Returns the appropriate API base URL according to the current runtime environment
  static String get apiBaseUrl {
    if (isProductionEnvironment) {
      return '$productionApiDomain/api';
    }
    if (kIsWeb) {
      return '$webApiDomain/api';
    }
    return '$localApiDomain/api';
  }

  /// Verification helper to check if Supabase public credentials are present
  static bool get isSupabaseConfigured =>
      supabaseProjectUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
