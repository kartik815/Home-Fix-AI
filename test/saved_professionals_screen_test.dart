import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/screens/saved_professionals/saved_professionals_screen.dart';
import 'package:test_app/services/saved_professionals_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('End-to-end unmark, reload persistence, and empty state verification',
      (WidgetTester tester) async {
    // 1. Initial app launch
    await SavedProfessionalsService.init();

    await tester.pumpWidget(
      const MaterialApp(
        home: SavedProfessionalsScreen(showBackButton: false),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial state has 3 saved professionals
    expect(find.text('Sharma Electricals & Cooling'), findsOneWidget);
    expect(find.text('R.K. Quick Plumbing Services'), findsOneWidget);
    expect(find.text('CoolCare AC Solutions'), findsOneWidget);
    expect(find.text('3 professionals saved for future home repairs'), findsOneWidget);

    // 2. User unmarks Sharma Electricals
    final firstBookmarkFinder = find.byTooltip('Remove bookmark').first;
    await tester.tap(firstBookmarkFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2500));

    // Verify Sharma Electricals is removed immediately from UI
    expect(find.text('Sharma Electricals & Cooling'), findsNothing);
    expect(find.text('2 professionals saved for future home repairs'), findsOneWidget);

    // 3. User reloads the app / browser (simulated by re-initializing and mounting afresh)
    await SavedProfessionalsService.init();

    await tester.pumpWidget(
      const MaterialApp(
        home: SavedProfessionalsScreen(showBackButton: false),
      ),
    );
    await tester.pumpAndSettle();

    // Verify after reload: Sharma Electricals did NOT return!
    expect(find.text('Sharma Electricals & Cooling'), findsNothing);
    expect(find.text('R.K. Quick Plumbing Services'), findsOneWidget);
    expect(find.text('CoolCare AC Solutions'), findsOneWidget);
    expect(find.text('2 professionals saved for future home repairs'), findsOneWidget);

    // 4. Remove all remaining professionals
    final secondBookmark = find.byTooltip('Remove bookmark').first;
    await tester.tap(secondBookmark);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2500));

    final thirdBookmark = find.byTooltip('Remove bookmark').first;
    await tester.tap(thirdBookmark);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2500));

    // Verify Empty State is shown
    expect(find.text('No Saved Professionals Yet'), findsOneWidget);

    // 5. User reloads again
    await SavedProfessionalsService.init();

    await tester.pumpWidget(
      const MaterialApp(
        home: SavedProfessionalsScreen(showBackButton: false),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Empty State persists across reload
    expect(find.text('No Saved Professionals Yet'), findsOneWidget);
  });
}
