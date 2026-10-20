import 'package:flutter_test/flutter_test.dart';
import 'package:ignite_couple_games/main.dart';

void main() {
  testWidgets('IGNITE launches with five main destinations', (tester) async {
    await tester.pumpWidget(const IgniteApp());
    expect(find.text('IGNITE'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Memories'), findsOneWidget);
    expect(find.text('Bond'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Truth or Dare can start a round', (tester) async {
    await tester.pumpWidget(const IgniteApp());
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Truth or Dare'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih Truth atau Dare untuk memulai ronde kalian.'), findsOneWidget);
    await tester.tap(find.text('💗 Truth'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih Truth atau Dare untuk memulai ronde kalian.'), findsNothing);
    expect(find.text('ROUND 2'), findsOneWidget);
  });
}
