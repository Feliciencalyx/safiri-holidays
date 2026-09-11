import 'dart:convert';
import 'package:http/http.dart' as http;
import 'supabase_service.dart';
import '../data/worldwide_currencies.dart';

class CurrencyApiService {
  static String get _baseUrl => SupabaseProductionConfig.apiBaseUrl;

  /// Fetches live exchange rates relative to USD.
  /// Falls back to direct public Forex API if backend server is unreachable.
  static Future<Map<String, double>> fetchLiveRates() async {
    // Start with complete worldwide baseline rates
    final Map<String, double> rates = {};
    for (final c in WorldwideCurrencies.all) {
      rates[c.code] = c.defaultRateToUsd;
    }

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/currency/rates'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['rates'] != null) {
          final rawRates = data['rates'] as Map<String, dynamic>;
          rawRates.forEach((key, value) {
            if (value is num) {
              rates[key] = value.toDouble();
            }
          });
          return rates;
        }
      }
    } catch (_) {
      // Backend unreachable, attempt direct public endpoint
    }

    try {
      final directRes = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
          .timeout(const Duration(seconds: 4));
      if (directRes.statusCode == 200) {
        final data = json.decode(directRes.body);
        if (data['rates'] != null) {
          final rawRates = data['rates'] as Map<String, dynamic>;
          rawRates.forEach((key, value) {
            if (value is num) {
              rates[key] = value.toDouble();
            }
          });
          return rates;
        }
      }
    } catch (_) {
      // Offline fallback
    }

    return rates;
  }
}

