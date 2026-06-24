import 'package:flutter_test/flutter_test.dart';
import 'package:klinika_ai/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders first-run onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const KlinikaApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
        find.text('Une fiche qui ecoute avant de demander.'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
  });
}
