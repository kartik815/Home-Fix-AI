import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/professional_model.dart';

/// Centralized service to manage and persist saved/bookmarked professionals
/// across app reloads, restarts, and navigation.
class SavedProfessionalsService {
  static const String _storageKey = 'saved_professional_ids_v1';
  static const String _initializedKey = 'saved_professionals_seeded_v1';

  static final Set<String> _savedIds = <String>{};
  static bool _isInitialized = false;

  /// Notifier to listen to changes in saved IDs anywhere across the app
  static final ValueNotifier<Set<String>> savedNotifier =
      ValueNotifier<Set<String>>(<String>{});

  /// Initialize from persistent storage (called in main.dart on startup)
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool alreadySeeded = prefs.getBool(_initializedKey) ?? false;

      if (!alreadySeeded) {
        // First run ever: seed with initial default saved items from sample data
        final defaultSaved = ProfessionalModel.sampleProfessionals
            .where((p) => p.isSaved)
            .map((p) => p.id)
            .toSet();
        _savedIds.clear();
        _savedIds.addAll(defaultSaved);
        await prefs.setStringList(_storageKey, _savedIds.toList());
        await prefs.setBool(_initializedKey, true);
      } else {
        // Subsequent runs / reloads: load exact user preferences from storage
        final stored = prefs.getStringList(_storageKey) ?? [];
        _savedIds.clear();
        _savedIds.addAll(stored);
      }

      _isInitialized = true;
      _syncSampleModels();
      savedNotifier.value = Set<String>.from(_savedIds);
    } catch (e) {
      debugPrint('Error initializing SavedProfessionalsService: $e');
      if (!_isInitialized) {
        _savedIds.addAll(
          ProfessionalModel.sampleProfessionals
              .where((p) => p.isSaved)
              .map((p) => p.id),
        );
        _isInitialized = true;
      }
    }
  }

  /// Synchronize the in-memory ProfessionalModel.sampleProfessionals list
  static void _syncSampleModels() {
    for (final pro in ProfessionalModel.sampleProfessionals) {
      pro.isSaved = _savedIds.contains(pro.id);
    }
  }

  /// Check whether a given professional is saved
  static bool isSaved(String id) {
    if (!_isInitialized) {
      final pro = ProfessionalModel.sampleProfessionals
          .where((p) => p.id == id)
          .firstOrNull;
      return pro?.isSaved ?? _savedIds.contains(id);
    }
    return _savedIds.contains(id);
  }

  /// Get the list of currently saved professionals
  static List<ProfessionalModel> getSavedProfessionals() {
    _syncSampleModels();
    return ProfessionalModel.sampleProfessionals
        .where((p) => _savedIds.contains(p.id))
        .toList();
  }

  /// Toggle saved state for a professional ID and persist immediately
  static Future<bool> toggleBookmark(String id) async {
    final willBeSaved = !_savedIds.contains(id);
    return await setSaved(id, willBeSaved);
  }

  /// Explicitly set saved state for a professional ID and persist immediately
  static Future<bool> setSaved(String id, bool save) async {
    if (save) {
      _savedIds.add(id);
    } else {
      _savedIds.remove(id);
    }

    _syncSampleModels();
    savedNotifier.value = Set<String>.from(_savedIds);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _savedIds.toList());
      await prefs.setBool(_initializedKey, true);
    } catch (e) {
      debugPrint('Error writing to SharedPreferences: $e');
    }

    return save;
  }

  /// Clear all saved professionals (for testing/resetting)
  static Future<void> clearAll() async {
    _savedIds.clear();
    _syncSampleModels();
    savedNotifier.value = <String>{};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, []);
      await prefs.setBool(_initializedKey, true);
    } catch (e) {
      debugPrint('Error clearing saved professionals: $e');
    }
  }
}
