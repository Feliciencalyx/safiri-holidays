import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_v2/providers/app_state.dart';
import 'package:flutter_application_v2/core/services/notification_service.dart';
import 'package:flutter_application_v2/core/localization/app_translations.dart';
import 'package:flutter_application_v2/screens/home/home_screen.dart';

void main() {
  group('3 Primary Services Streamlining Tests', () {
    test('AppTranslations contains all 3 primary services in all 6 locales', () {
      final locales = ['en', 'rw', 'fr', 'sw', 'es', 'ar'];
      for (final loc in locales) {
        expect(AppTranslations.get('flight_bookings', loc), isNotEmpty);
        expect(AppTranslations.get('visa_application', loc), isNotEmpty);
        expect(AppTranslations.get('holidays_hotel_booking', loc), isNotEmpty);
      }
    });

    testWidgets('HomeScreen renders exactly the 3 core primary service cards and quick actions', (WidgetTester tester) async {
      final appState = AppState();
      appState.updateUserAvatarUrl('');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: appState),
            ChangeNotifierProvider<NotificationService>(create: (_) => NotificationService()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Flight Booking Card
      expect(find.text('Flight Bookings'), findsWidgets);
      // 2. Visa Application Card
      expect(find.text('Visa Application'), findsWidgets);
      // 3. Holidays and Hotel booking Card
      expect(find.text('Holidays and Hotel booking'), findsOneWidget);

      // Unrelated services must NOT exist
      expect(find.text('Bus Express'), findsNothing);
      expect(find.text('Bus'), findsNothing);
    });
  });
}
