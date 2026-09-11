import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_v2/providers/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Passport Vault & Scan Tests', () {
    test('Default passport details are properly initialized', () {
      final appState = AppState();
      expect(appState.currentUserPassportNumber, isNotEmpty);
      expect(appState.passportExpiryDate, equals('14 Nov 2031'));
      expect(appState.isPassportVerified, isTrue);
      expect(appState.scannedPassportPath, isNull);
    });

    test('Updating scanned passport updates state and verifies credentials', () {
      final appState = AppState();

      appState.updateScannedPassport(
        imagePath: '/data/user/0/com.safiri.app/scans/passport_photo.jpg',
        passportNumber: 'PC8810294X',
        country: 'Republic of Rwanda',
        expiryDate: '15 Dec 2032',
        isVerified: true,
      );

      expect(appState.scannedPassportPath, equals('/data/user/0/com.safiri.app/scans/passport_photo.jpg'));
      expect(appState.currentUserPassportNumber, equals('PC8810294X'));
      expect(appState.passportCountry, equals('Republic of Rwanda'));
      expect(appState.passportExpiryDate, equals('15 Dec 2032'));
      expect(appState.isPassportVerified, isTrue);
    });

    test('Simulated scan path updates cleanly without overwriting passport number if unspecified', () {
      final appState = AppState();
      final originalNumber = appState.currentUserPassportNumber;

      appState.updateScannedPassport(
        imagePath: 'simulated_passport_scan',
        isVerified: true,
      );

      expect(appState.scannedPassportPath, equals('simulated_passport_scan'));
      expect(appState.currentUserPassportNumber, equals(originalNumber));
      expect(appState.isPassportVerified, isTrue);
    });
  });
}
