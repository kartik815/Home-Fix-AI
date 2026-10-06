import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/models/professional_model.dart';
import 'package:test_app/services/saved_professionals_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Initial launch seeds default saved professionals', () async {
    await SavedProfessionalsService.init();

    final saved = SavedProfessionalsService.getSavedProfessionals();
    expect(saved.isNotEmpty, isTrue);
    expect(SavedProfessionalsService.isSaved('pro_1'), isTrue);
    expect(SavedProfessionalsService.isSaved('pro_2'), isTrue);
    expect(SavedProfessionalsService.isSaved('pro_3'), isTrue);
  });

  test('Unmarking a professional removes it and persists across reloads', () async {
    // 1. Initial launch
    await SavedProfessionalsService.init();
    expect(SavedProfessionalsService.isSaved('pro_1'), isTrue);

    // 2. User unmarks pro_1
    final savedStatus = await SavedProfessionalsService.toggleBookmark('pro_1');
    expect(savedStatus, isFalse);
    expect(SavedProfessionalsService.isSaved('pro_1'), isFalse);

    final savedListAfterRemoval = SavedProfessionalsService.getSavedProfessionals();
    expect(savedListAfterRemoval.any((p) => p.id == 'pro_1'), isFalse);

    // 3. User reloads app / browser (simulated by re-initializing the service)
    await SavedProfessionalsService.init();

    // 4. Verify pro_1 is STILL NOT saved (does NOT return upon reload)
    expect(SavedProfessionalsService.isSaved('pro_1'), isFalse);
    final reloadedList = SavedProfessionalsService.getSavedProfessionals();
    expect(reloadedList.any((p) => p.id == 'pro_1'), isFalse);
  });

  test('Unmarking all professionals persists empty state across reloads', () async {
    await SavedProfessionalsService.init();

    await SavedProfessionalsService.clearAll();
    expect(SavedProfessionalsService.getSavedProfessionals(), isEmpty);

    // Re-initialize (simulating full page refresh)
    await SavedProfessionalsService.init();
    expect(SavedProfessionalsService.getSavedProfessionals(), isEmpty);
  });

  test('Bookmarking a new professional persists across reloads', () async {
    await SavedProfessionalsService.init();
    expect(SavedProfessionalsService.isSaved('pro_4'), isFalse);

    // User bookmarks pro_4
    await SavedProfessionalsService.setSaved('pro_4', true);
    expect(SavedProfessionalsService.isSaved('pro_4'), isTrue);

    // Simulate page refresh
    await SavedProfessionalsService.init();
    expect(SavedProfessionalsService.isSaved('pro_4'), isTrue);
  });
}
