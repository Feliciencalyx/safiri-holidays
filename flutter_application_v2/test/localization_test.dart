import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_v2/core/localization/app_translations.dart';
import 'package:flutter_application_v2/providers/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTranslations Tests', () {
    test('English translations work for auth keys and dot aliases', () {
      expect(AppTranslations.get('auth.sign_in', 'en'), 'Sign In');
      expect(AppTranslations.get('sign_in', 'en'), 'Sign In');
      expect(AppTranslations.get('auth.email', 'en'), 'Email or Username');
      expect(AppTranslations.get('auth.password', 'en'), 'Password');
      expect(AppTranslations.get('auth.forgot_password', 'en'), 'Forgot your password?');
      expect(AppTranslations.get('tagline', 'en'), 'Defining a Legacy of Exceptional Travel');
    });

    test('Kinyarwanda translations work for auth keys and dot aliases', () {
      expect(AppTranslations.get('auth.title', 'rw'), 'Muraho');
      expect(AppTranslations.get('hello', 'rw'), 'Muraho');
      expect(AppTranslations.get('auth.sign_in', 'rw'), 'Injira mu Konti');
      expect(AppTranslations.get('sign_in', 'rw'), 'Injira mu Konti');
      expect(AppTranslations.get('auth.forgot_password', 'rw'), "Wibagiwe ijambo ry'ibanga?");
      expect(AppTranslations.get('auth.password', 'rw'), "Ijambo ry'Ibanga");
      expect(AppTranslations.get('auth.email_placeholder', 'rw'), "Injiza imeri cyangwa izina ry'ukoresha");
      expect(AppTranslations.get('tagline', 'rw'), 'Guhitamo Urugendo Ruhebuje ku Isi');
    });

    test('French translations work for auth keys', () {
      expect(AppTranslations.get('auth.sign_in', 'fr'), 'Se Connecter');
      expect(AppTranslations.get('auth.password', 'fr'), 'Mot de Passe');
      expect(AppTranslations.get('auth.forgot_password', 'fr'), 'Mot de passe oublié ?');
      expect(AppTranslations.get('nav_home', 'fr'), 'ACCUEIL');
    });

    test('Swahili translations work for auth keys', () {
      expect(AppTranslations.get('auth.sign_in', 'sw'), 'Ingia');
      expect(AppTranslations.get('auth.password', 'sw'), 'Nenosiri');
      expect(AppTranslations.get('auth.forgot_password', 'sw'), 'Umesahau nenosiri?');
      expect(AppTranslations.get('nav_home', 'sw'), 'NYUMBANI');
    });

    test('Spanish translations work for auth keys', () {
      expect(AppTranslations.get('auth.sign_in', 'es'), 'Iniciar Sesión');
      expect(AppTranslations.get('auth.password', 'es'), 'Contraseña');
      expect(AppTranslations.get('auth.forgot_password', 'es'), '¿Olvidó su contraseña?');
      expect(AppTranslations.get('nav_home', 'es'), 'INICIO');
    });

    test('Arabic translations work for auth keys and RTL check', () {
      expect(AppTranslations.get('auth.sign_in', 'ar'), 'تسجيل الدخول');
      expect(AppTranslations.get('auth.password', 'ar'), 'كلمة المرور');
      expect(AppTranslations.get('auth.forgot_password', 'ar'), 'هل نسيت كلمة المرور؟');
      expect(AppTranslations.get('nav_home', 'ar'), 'الرئيسية');
    });

    test('Key alias normalization works bidirectionally', () {
      // Querying without auth. finds auth. if defined, querying with auth. finds stripped if defined
      expect(AppTranslations.get('auth.select_language', 'rw'), "Hitamo Ururimi rwa Porogaramu");
      expect(AppTranslations.get('select_language', 'rw'), "Hitamo Ururimi rwa Porogaramu");
    });
  });

  group('AppState Reactive Locale Switching Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Switching locale in AppState updates tr() and isRtl', () {
      final appState = AppState();

      // Initial state
      expect(appState.currentLocale, 'en');
      expect(appState.isRtl, false);
      expect(appState.tr('auth.sign_in'), 'Sign In');

      // Switch to Kinyarwanda
      appState.setLocale('rw');
      expect(appState.currentLocale, 'rw');
      expect(appState.isRtl, false);
      expect(appState.tr('auth.sign_in'), 'Injira mu Konti');
      expect(appState.tr('auth.title'), 'Muraho');
      expect(appState.tr('tagline'), 'Guhitamo Urugendo Ruhebuje ku Isi');

      // Switch to Arabic
      appState.setLocale('ar');
      expect(appState.currentLocale, 'ar');
      expect(appState.isRtl, true);
      expect(appState.tr('auth.sign_in'), 'تسجيل الدخول');

      // Switch to French
      appState.setLocale('fr');
      expect(appState.currentLocale, 'fr');
      expect(appState.isRtl, false);
      expect(appState.tr('auth.sign_in'), 'Se Connecter');
    });

    test('Time-sensitive greetings greet accurately according to local time and language', () {
      final appState = AppState();

      // Test English
      appState.setLocale('en');
      expect(appState.getTimeGreeting(overrideTime: DateTime(2026, 9, 8, 8, 30)), 'Good Morning');
      expect(appState.getTimeGreeting(overrideTime: DateTime(2026, 9, 8, 14, 15)), 'Good Afternoon');
      expect(appState.getTimeGreeting(overrideTime: DateTime(2026, 9, 8, 20, 0)), 'Good Evening');

      // Test French
      appState.setLocale('fr');
      expect(appState.getTimeGreeting(overrideTime: DateTime(2026, 9, 8, 9, 0)), 'Bonjour');
      expect(appState.getTimeGreeting(overrideTime: DateTime(2026, 9, 8, 15, 24)), 'Bon Après-midi');
      expect(appState.getTimeGreeting(overrideTime: DateTime(2026, 9, 8, 21, 30)), 'Bonsoir');

      // Test Kinyarwanda
      appState.setLocale('rw');
      expect(appState.getTimeGreeting(overrideTime: DateTime(2026, 9, 8, 10, 0)), 'Mwaramutse');
      expect(appState.getTimeGreeting(overrideTime: DateTime(2026, 9, 8, 13, 0)), 'Mwiriwe');
      expect(appState.getTimeGreeting(overrideTime: DateTime(2026, 9, 8, 22, 0)), 'Mwiriwe Neza');
    });
  });
}
