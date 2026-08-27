import 'package:flutter/material.dart';
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
