import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_v2/providers/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppState Tests', () {
    test('Initial currency formatting works for USD, RWF, and EUR', () {
      final appState = AppState();

      // Default is USD
      final usdPrice = appState.formatPrice(100.0);
      expect(usdPrice, equals('\$100.00'));

      // Switch to RWF
      appState.setCurrency('RWF');
      final rwfPrice = appState.formatPrice(100.0);
      expect(rwfPrice, contains('FRw'));

      // Switch to EUR
      appState.setCurrency('EUR');
      final eurPrice = appState.formatPrice(100.0);
      expect(eurPrice, contains('€'));
    });

    test('Theme toggling flips light and dark mode', () {
      final appState = AppState();
      expect(appState.themeMode, equals(ThemeMode.light));

      appState.toggleTheme();
      expect(appState.themeMode, equals(ThemeMode.dark));

      appState.toggleTheme();
      expect(appState.themeMode, equals(ThemeMode.light));
    });

    test('Adding and updating a booking modifies state properly', () {
      final appState = AppState();
      final initialCount = appState.bookings.length;

      final newBooking = BookingItem(
        id: '#TEST-9999',
        title: 'Test Safari Booking',
        userName: 'Test Traveler',
        userTier: 'Standard',
        status: 'Pending',
        type: 'Safari',
        dateRange: 'Dec 01 - Dec 05, 2026',
        priceUsd: 500.0,
        qrCodeData: 'TEST-QR-DATA',
      );

      appState.addBooking(newBooking);
      expect(appState.bookings.length, equals(initialCount + 1));
      expect(appState.bookings.first.id, equals('#TEST-9999'));

      appState.updateBookingStatus('#TEST-9999', 'Confirmed');
      expect(appState.bookings.first.status, equals('Confirmed'));
    });

    test('Authentication and logout updates credentials correctly', () {
      final appState = AppState();

      appState.setAuthData(
        token: 'test_jwt_token_123',
        name: 'Test Customer',
        email: 'customer@safiri.com',
        role: 'customer',
        phone: '+250788111222',
        passportNumber: 'PC9920148X',
      );

      expect(appState.isAuthenticated, isTrue);
      expect(appState.currentUserName, equals('Test Customer'));
      expect(appState.userRole, equals('customer'));
      expect(appState.isAdmin, isFalse);

      appState.logout();
      expect(appState.isAuthenticated, isFalse);
      expect(appState.authToken, isNull);
      expect(appState.currentUserName, equals('Guest'));
    });
  });
}
