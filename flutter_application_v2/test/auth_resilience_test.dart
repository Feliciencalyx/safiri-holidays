import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_v2/core/services/auth_service.dart';
import 'package:flutter_application_v2/providers/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Auth Resilience & Account Creation Tests', () {
    test('AuthService.register creates an active account with fallback resilience', () async {
      final res = await AuthService.register(
        name: 'Mubark Explorer',
        email: 'mubark@gmail.com',
        password: 'Password123',
        phone: '+2500780156224',
        passportNumber: 'A12345678',
      );

      expect(res.success, isTrue);
      expect(res.user, isNotNull);
      expect(res.user!.name, equals('Mubark Explorer'));
      expect(res.user!.email, equals('mubark@gmail.com'));
      expect(res.user!.phone, equals('+2500780156224'));
      expect(res.user!.passportNumber, equals('A12345678'));
      expect(res.user!.isPassportVerified, isTrue);
    });

    test('AppState saves registered user and allows lookup in registeredUsers', () {
      final appState = AppState();

      appState.setAuthData(
        token: 'mock_jwt_test',
        name: 'Mubark Test',
        email: 'mubark.test@gmail.com',
        role: 'customer',
        phone: '+250780156224',
        passportNumber: 'PC9920148X',
        isPassportVerified: true,
        passportCountry: 'Rwanda',
      );

      expect(appState.isAuthenticated, isTrue);
      expect(appState.currentUserName, equals('Mubark Test'));
      expect(appState.currentUserEmail, equals('mubark.test@gmail.com'));
      expect(appState.currentUserPassportNumber, equals('PC9920148X'));
      expect(appState.isPassportVerified, isTrue);

      final foundUser = appState.registeredUsers.firstWhere(
        (u) => u.email.toLowerCase() == 'mubark.test@gmail.com',
      );

      expect(foundUser.name, equals('Mubark Test'));
      expect(foundUser.phone, equals('+250780156224'));
      expect(foundUser.passportNumber, equals('PC9920148X'));
    });
  });
}
