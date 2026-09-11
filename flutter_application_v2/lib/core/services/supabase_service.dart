import 'package:flutter/foundation.dart';

class SupabaseProductionConfig {
  static const String productionApiDomain = 'https://safiri-holidays-production.up.railway.app';
  static const String localApiDomain = 'http://10.0.2.2:5000';
  static const String webApiDomain = 'http://localhost:5000';

  static const String supabaseProjectUrl = 'https://ttnbiybejkwdwgkhfunh.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0bmJpeWJlamt3ZHdna2hmdW5oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc3NDA2MzQsImV4cCI6MjEwMzMxNjYzNH0.HEvj0DQBY04QLbOELc6P8A10aCf579iXjv9sRkqx0pE';

  static bool isProductionEnvironment = true;

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
