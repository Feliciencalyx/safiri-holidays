import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: const SafiriHolidaysApp(),
    ),
  );
}

class SafiriHolidaysApp extends StatelessWidget {
  const SafiriHolidaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      title: 'Safiri Holidays',
      debugShowCheckedModeBanner: false,
      theme: MajesticHorizonTheme.lightTheme,
      darkTheme: MajesticHorizonTheme.darkTheme,
      themeMode: appState.themeMode,
      locale: Locale(appState.currentLocale),
      supportedLocales: AppState.supportedLocales.keys.map((c) => Locale(c)).toList(),
      localizationsDelegates: const [
        _RwandaMaterialLocalizationsDelegate(),
        _RwandaWidgetsLocalizationsDelegate(),
        _RwandaCupertinoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        for (final supported in supportedLocales) {
          if (supported.languageCode == appState.currentLocale) {
            return supported;
          }
        }
        return const Locale('en');
      },
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
      builder: (context, child) {
        return Directionality(
          textDirection: appState.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}

/// Fallback localizations delegate for Kinyarwanda ('rw') which is not built into standard Flutter SDK
class _RwandaMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _RwandaMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(const DefaultMaterialLocalizations());
  }

  @override
  bool shouldReload(_RwandaMaterialLocalizationsDelegate old) => false;
}

class _RwandaWidgetsLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const _RwandaWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    return SynchronousFuture<WidgetsLocalizations>(const DefaultWidgetsLocalizations());
  }

  @override
  bool shouldReload(_RwandaWidgetsLocalizationsDelegate old) => false;
}

class _RwandaCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _RwandaCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(const DefaultCupertinoLocalizations());
  }

  @override
  bool shouldReload(_RwandaCupertinoLocalizationsDelegate old) => false;
}
