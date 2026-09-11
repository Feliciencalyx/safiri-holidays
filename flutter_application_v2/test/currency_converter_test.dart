import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_v2/core/data/worldwide_currencies.dart';
import 'package:flutter_application_v2/providers/app_state.dart';
import 'package:flutter_application_v2/screens/currency/currency_converter_screen.dart';

void main() {
  group('WorldwideCurrencies Catalog Tests', () {
    test('Contains key world and African currencies', () {
      expect(WorldwideCurrencies.all.length, greaterThanOrEqualTo(50));

      final rwf = WorldwideCurrencies.findByCode('RWF');
      expect(rwf.code, 'RWF');
      expect(rwf.name, 'Rwandan Franc');
      expect(rwf.flag, '🇷🇼');

      final usd = WorldwideCurrencies.findByCode('USD');
      expect(usd.code, 'USD');
      expect(usd.defaultRateToUsd, 1.0);

      final eur = WorldwideCurrencies.findByCode('EUR');
      expect(eur.code, 'EUR');
      expect(eur.symbol, '€');
    });

    test('Search finds currencies by code, country, or name', () {
      final rwandaSearch = WorldwideCurrencies.search('Rwanda');
      expect(rwandaSearch.any((c) => c.code == 'RWF'), isTrue);

      final yenSearch = WorldwideCurrencies.search('yen');
      expect(yenSearch.any((c) => c.code == 'JPY'), isTrue);

      final euroSearch = WorldwideCurrencies.search('eur');
      expect(euroSearch.any((c) => c.code == 'EUR'), isTrue);
    });

    test('Popular currencies list returns verified items', () {
      final popular = WorldwideCurrencies.popularCurrencies;
      expect(popular.isNotEmpty, isTrue);
      expect(popular.any((c) => c.code == 'USD'), isTrue);
      expect(popular.any((c) => c.code == 'EUR'), isTrue);
      expect(popular.any((c) => c.code == 'RWF'), isTrue);
      expect(popular.any((c) => c.code == 'KES'), isTrue);
    });
  });

  group('AppState Currency Conversion Tests', () {
    test('convertCurrency accurately computes cross-rates', () {
      final appState = AppState();

      // Same currency returns exact amount
      expect(appState.convertCurrency(100.0, 'USD', 'USD'), 100.0);

      // Conversion from RWF to USD
      final usdFromRwf = appState.convertCurrency(1.0, 'RWF', 'USD');
      expect(usdFromRwf, greaterThan(0.0005));
      expect(usdFromRwf, lessThan(0.001));

      // Symmetrical conversion: 100 USD to RWF back to USD
      final rwfAmount = appState.convertCurrency(100.0, 'USD', 'RWF');
      final backToUsd = appState.convertCurrency(rwfAmount, 'RWF', 'USD');
      expect((backToUsd - 100.0).abs(), lessThan(0.0001));
    });

    test('formatPrice formats with correct symbol and locale separator', () {
      final appState = AppState();
      appState.setCurrency('USD');
      expect(appState.formatPrice(50.0), '\$50.00');

      appState.setCurrency('RWF');
      final rwfFormatted = appState.formatPrice(10.0);
      expect(rwfFormatted.contains('FRw'), isTrue);
    });
  });

  group('CurrencyConverterScreen Widget Tests', () {
    testWidgets('Renders Google Finance style converter with header and chart', (tester) async {
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: CurrencyConverterScreen(
              initialFromCode: 'RWF',
              initialToCode: 'USD',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Google-style header text
      expect(find.textContaining('1.00 Rwandan Franc equals'), findsOneWidget);
      expect(find.textContaining('US Dollar'), findsWidgets);

      // Verify inputs
      expect(find.byType(TextField), findsNWidgets(2));

      // Verify timeframe chips
      expect(find.text('1D'), findsOneWidget);
      expect(find.text('5D'), findsOneWidget);
      expect(find.text('1M'), findsOneWidget);
      expect(find.text('1Y'), findsOneWidget);
      expect(find.text('5Y'), findsOneWidget);

      // Verify custom painter chart
      expect(find.byType(CustomPaint), findsWidgets);

      // Verify cheat sheet table
      expect(find.text('Conversion Cheat Sheet'), findsOneWidget);

      // Verify Swap button exists and can be tapped
      final swapButton = find.byIcon(Icons.swap_vert_rounded);
      expect(swapButton, findsOneWidget);
      await tester.tap(swapButton);
      await tester.pumpAndSettle();

      // After swap, header shows 1.00 US Dollar equals
      expect(find.textContaining('1.00 US Dollar equals'), findsOneWidget);
    });
  });
}
