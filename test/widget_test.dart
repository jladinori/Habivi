import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habivi/app.dart';

void main() {
  testWidgets('HabiviApp muestra la pantalla de inicio', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HabiviApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Neutral'), findsOneWidget);
    expect(find.text('Inicio'), findsWidgets);
  });
}
