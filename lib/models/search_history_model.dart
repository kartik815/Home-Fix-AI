import 'package:flutter/foundation.dart';

class SearchHistoryItem {
  final String id;
  final String problem;
  final String category;
  final String diagnosisSummary;
  final String urgency;
  final String estimatedCost;
  final DateTime timestamp;
  final List<String> causes;
  final String solution;

  SearchHistoryItem({
    required this.id,
    required this.problem,
    required this.category,
    required this.diagnosisSummary,
    required this.urgency,
    required this.estimatedCost,
    required this.timestamp,
    required this.causes,
    required this.solution,
  });

  static final List<SearchHistoryItem> sampleHistory = [
    SearchHistoryItem(
      id: 'hist_1',
      problem: 'AC is running but not cooling properly',
      category: 'AC Repair',
      diagnosisSummary:
          'Dirty air filter & potential refrigerant undercharge',
      urgency: 'Medium',
      estimatedCost: '₹800 - ₹2,500',
      timestamp:
          DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      causes: [
        'Clogged dust filter reducing airflow',
        'Low Freon/refrigerant gas pressure',
        'Condenser coil heat dissipation issue',
      ],
      solution:
          'Wash mesh air filter first. If air remains warm, arrange technician coil pressure test and refill.',
    ),
    SearchHistoryItem(
      id: 'hist_2',
      problem: 'Kitchen sink pipe is leaking water continuously',
      category: 'Plumbing',
      diagnosisSummary:
          'Worn P-trap washer gasket or joint fracture',
      urgency: 'High',
      estimatedCost: '₹500 - ₹1,500',
      timestamp:
          DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      causes: [
        'Degraded rubber seal at slip-nut',
        'Corrosion or crack along drainage elbow',
        'High back-pressure from partial drain clog',
      ],
      solution:
          'Place bucket beneath P-trap and turn off sink stop valve. Replace gasket or reseal with plumber tape.',
    ),
    SearchHistoryItem(
      id: 'hist_3',
      problem: 'Ceiling fan making vibrating humming sound',
      category: 'Electrical',
      diagnosisSummary:
          'Worn ball-bearing or unbalanced rotor blades',
      urgency: 'Medium',
      estimatedCost: '₹300 - ₹1,200',
      timestamp:
          DateTime.now().subtract(const Duration(days: 3, hours: 8)),
      causes: [
        'Dry or worn motor bearings requiring lubrication',
        'Loose canopy or blade mounting screws',
        'Faulty capacitor causing humming buzz',
      ],
      solution:
          'Tighten blade bracket screws. If humming persists, lubricate bearing or replace starter capacitor.',
    ),
    SearchHistoryItem(
      id: 'hist_4',
      problem: 'Washing machine drum vibrates violently during spin',
      category: 'Appliances',
      diagnosisSummary:
          'Damaged suspension shock absorber springs',
      urgency: 'High',
      estimatedCost: '₹1,200 - ₹3,500',
      timestamp: DateTime.now().subtract(const Duration(days: 6)),
      causes: [
        'Unbalanced leveling feet',
        'Worn damper shock absorbers',
        'Broken drum counterweight or spider arm',
      ],
      solution:
          'Check spirit level on top of washer and adjust rubber feet. If loud thumping continues, replace shock dampers.',
    ),
    SearchHistoryItem(
      id: 'hist_5',
      problem: 'Main MCB switch tripped when geyser was turned on',
      category: 'Electrical',
      diagnosisSummary:
          'Water heater heating element short to ground',
      urgency: 'Urgent',
      estimatedCost: '₹600 - ₹2,000',
      timestamp: DateTime.now().subtract(const Duration(days: 9)),
      causes: [
        'Corroded geyser heating element with mineral deposits',
        'Water leakage inside electrical thermostat compartment',
        'Overloaded circuit branch',
      ],
      solution:
          'DO NOT turn breaker back on while geyser is plugged in. Electrician must inspect element insulation resistance.',
    ),
  ];

  // Shared history for the entire app.
  static final ValueNotifier<List<SearchHistoryItem>> historyNotifier =
      ValueNotifier<List<SearchHistoryItem>>(
    List<SearchHistoryItem>.from(sampleHistory),
  );

  // Add a new search to history.
  static void addHistory({
    required String problem,
    String category = 'Recent Diagnosis',
  }) {
    final current = List<SearchHistoryItem>.from(historyNotifier.value);

    // Don't add the exact same search twice.
    current.removeWhere(
      (item) => item.problem.toLowerCase() == problem.toLowerCase(),
    );

    final newItem = SearchHistoryItem(
      id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
      problem: problem,
      category: category,
      diagnosisSummary: 'Diagnosis will be available after analysis.',
      urgency: 'Pending',
      estimatedCost: 'To be estimated',
      timestamp: DateTime.now(),
      causes: const [],
      solution: 'Open the diagnosis to view the recommended solution.',
    );

    current.insert(0, newItem);

    // Keep latest 20 searches.
    if (current.length > 20) {
      current.removeLast();
    }

    historyNotifier.value = current;
  }

  // Delete one history item.
  static void deleteHistory(SearchHistoryItem item) {
    final current = List<SearchHistoryItem>.from(historyNotifier.value);
    current.remove(item);
    historyNotifier.value = current;
  }

  // Clear all history.
  static void clearHistory() {
    historyNotifier.value = [];
  }

  // Restore an item, useful for Undo.
  static void restoreHistory(
    SearchHistoryItem item,
    int index,
  ) {
    final current = List<SearchHistoryItem>.from(historyNotifier.value);

    if (!current.contains(item)) {
      final safeIndex = index.clamp(0, current.length);
      current.insert(safeIndex, item);
      historyNotifier.value = current;
    }
  }
}