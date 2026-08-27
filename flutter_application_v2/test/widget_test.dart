import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_v2/main.dart';
import 'package:flutter_application_v2/providers/app_state.dart';

void main() {
  testWidgets('Safiri Holidays App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const SafiriHolidaysApp(),
      ),
    );

    expect(find.text('Safiri Holidays'), findsWidgets);
  });
}
