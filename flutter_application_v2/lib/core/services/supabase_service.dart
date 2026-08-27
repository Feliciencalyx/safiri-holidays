import 'package:flutter/foundation.dart';

class SupabaseProductionConfig {
  static const String productionApiDomain = 'https://api.safiriholidays.com';
  static const String localApiDomain = 'http://10.0.2.2:5000';
  static const String webApiDomain = 'http://localhost:5000';

  static const String supabaseProjectUrl = 'https://ttnbiybejkwdwgkhfunh.supabase.co';
  static const String supabaseAnonKey = 'your-supabase-anon-key';

  static bool isProductionEnvironment = false;

  static String get apiBaseUrl {
    if (isProductionEnvironment) {
      return '$productionApiDomain/api';
    }
    if (kIsWeb) {
      return '$webApiDomain/api';
    }
    return '$localApiDomain/api';
  }
}
