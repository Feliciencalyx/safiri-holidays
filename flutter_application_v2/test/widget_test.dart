import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_v2/main.dart';
import 'package:flutter_application_v2/providers/app_state.dart';
import 'package:flutter_application_v2/core/services/notification_service.dart';

void main() {
  testWidgets('Safiri Holidays App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => NotificationService()),
        ],
        child: const SafiriHolidaysApp(),
      ),
    );

    expect(find.byType(SafiriHolidaysApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
