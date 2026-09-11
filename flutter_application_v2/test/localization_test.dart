import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
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

    test('App-wide screen keys translate across all 6 supported locales', () {
      final appState = AppState();

      for (final locale in ['en', 'rw', 'fr', 'sw', 'es', 'ar']) {
        appState.setLocale(locale);

        // Profile keys
        expect(appState.tr('profile_relationships').isNotEmpty, isTrue);
        expect(appState.tr('linked_bookings').isNotEmpty, isTrue);
        expect(appState.tr('visa_apps_vault').isNotEmpty, isTrue);
        expect(appState.tr('biometric_passport_scan').isNotEmpty, isTrue);
        expect(appState.tr('included_privileges').isNotEmpty, isTrue);
        expect(appState.tr('app_settings').isNotEmpty, isTrue);

        // Bookings keys
        expect(appState.tr('my_passes_bookings').isNotEmpty, isTrue);
        expect(appState.tr('tab_all').isNotEmpty, isTrue);
        expect(appState.tr('tab_upcoming').isNotEmpty, isTrue);
        expect(appState.tr('no_bookings').isNotEmpty, isTrue);

        // Documents keys
        expect(appState.tr('documents_vault').isNotEmpty, isTrue);
        expect(appState.tr('find_facility').isNotEmpty, isTrue);
        expect(appState.tr('active_visa_apps').isNotEmpty, isTrue);
        expect(appState.tr('passport_scan').isNotEmpty, isTrue);

        // Home keys
        expect(appState.tr('quick_actions').isNotEmpty, isTrue);
        expect(appState.tr('flight_bookings_sub').isNotEmpty, isTrue);
      }
    });

    test('Specific translation accuracy across distinct languages', () {
      final appState = AppState();

      // French
      appState.setLocale('fr');
      expect(appState.tr('my_passes_bookings'), 'Mes Billets & Réservations');
      expect(appState.tr('documents_vault'), 'Documents & Coffre-fort');
      expect(appState.tr('profile_relationships'), 'Relations & Activité du Profil');

      // Kinyarwanda
      appState.setLocale('rw');
      expect(appState.tr('my_passes_bookings'), 'Amatike n\'Ibyafashwe Byanjye');
      expect(appState.tr('documents_vault'), 'Inyandiko n\'Ububiko');
      expect(appState.tr('profile_relationships'), 'Isano ry\'Umwirondoro n\'Ibikorwa');

      // Swahili
      appState.setLocale('sw');
      expect(appState.tr('my_passes_bookings'), 'Tiketi na Maagizo Yangu');
      expect(appState.tr('documents_vault'), 'Nyaraka na Hifadhi');
      expect(appState.tr('profile_relationships'), 'Mahusiano na Shughuli za Wasifu');

      // Spanish
      appState.setLocale('es');
      expect(appState.tr('my_passes_bookings'), 'Mis Pases y Reservas');
      expect(appState.tr('documents_vault'), 'Documentos y Bóveda');
      expect(appState.tr('profile_relationships'), 'Relaciones y Actividad del Perfil');

      // Arabic
      appState.setLocale('ar');
      expect(appState.tr('my_passes_bookings'), 'تذاكري وحجوزاتي');
      expect(appState.tr('documents_vault'), 'الوثائق والخزينة');
      expect(appState.tr('profile_relationships'), 'علاقات الملف الشخصي والنشاط');
    });

    testWidgets('TextField finds MaterialLocalizations in all 6 locales without throwing', (tester) async {
      final appState = AppState();

      for (final localeCode in ['en', 'fr', 'rw', 'sw', 'es', 'ar']) {
        appState.setLocale(localeCode);

        await tester.pumpWidget(
          ChangeNotifierProvider<AppState>.value(
            value: appState,
            child: Consumer<AppState>(
              builder: (context, state, _) {
                return MaterialApp(
                  locale: Locale(state.currentLocale),
                  supportedLocales: AppState.supportedLocales.keys.map((c) => Locale(c)).toList(),
                  localizationsDelegates: const [
                    _TestRwandaMaterialLocalizationsDelegate(),
                    _TestRwandaWidgetsLocalizationsDelegate(),
                    _TestRwandaCupertinoLocalizationsDelegate(),
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  home: Scaffold(
                    body: Form(
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: 'Test in $localeCode',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(TextFormField), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}

class _TestRwandaMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _TestRwandaMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(const DefaultMaterialLocalizations());
  }

  @override
  bool shouldReload(_TestRwandaMaterialLocalizationsDelegate old) => false;
}

class _TestRwandaWidgetsLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const _TestRwandaWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    return SynchronousFuture<WidgetsLocalizations>(const DefaultWidgetsLocalizations());
  }

  @override
  bool shouldReload(_TestRwandaWidgetsLocalizationsDelegate old) => false;
}

class _TestRwandaCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _TestRwandaCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(const DefaultCupertinoLocalizations());
  }

  @override
  bool shouldReload(_TestRwandaCupertinoLocalizationsDelegate old) => false;
}

