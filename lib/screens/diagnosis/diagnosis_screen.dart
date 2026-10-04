import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../maps/nearby_professionals_map_screen.dart';

class DiagnosisScreen extends StatefulWidget {
  final String problem;

  const DiagnosisScreen({
    super.key,
    required this.problem,
  });

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  bool _notificationCreated = false;

  // Simple demo diagnosis logic.
  // Later this can be replaced with APIs that we want
  Map<String, dynamic> _getDiagnosis() {
    final text = widget.problem.toLowerCase();

    if (text.contains('ac') ||
        text.contains('air conditioner') ||
        text.contains('cooling')) {
      return {
        'diagnosis': 'AC cooling problem',
        'urgency': 'Medium',
        'cost': '₹800 - ₹2,500',
        'causes': [
          'Dirty or blocked air filter',
          'Low refrigerant level',
          'Dirty condenser coils',
          'Possible compressor issue',
        ],
        'solution':
            'Check and clean the air filter first. If the problem continues, a professional should inspect the refrigerant and cooling system.',
      };
    }

    if (text.contains('leak') ||
        text.contains('pipe') ||
        text.contains('tap') ||
        text.contains('water')) {
      return {
        'diagnosis': 'Possible plumbing issue',
        'urgency': 'High',
        'cost': '₹500 - ₹1,500',
        'causes': [
          'Loose pipe connection',
          'Damaged pipe',
          'Worn-out seal',
          'Blocked drainage',
        ],
        'solution':
            'Turn off the water supply if the leak is severe and have a plumber inspect the affected pipe or connection.',
      };
    }

    if (text.contains('fan') ||
        text.contains('light') ||
        text.contains('switch') ||
        text.contains('electric') ||
        text.contains('power')) {
      return {
        'diagnosis': 'Possible electrical issue',
        'urgency': 'High',
        'cost': '₹300 - ₹2,000',
        'causes': [
          'Loose electrical connection',
          'Faulty switch',
          'Damaged wiring',
          'Circuit breaker issue',
        ],
        'solution':
            'Avoid touching exposed wires. Turn off the power supply if necessary and contact a qualified electrician.',
      };
    }

    return {
      'diagnosis': 'General household problem',
      'urgency': 'Medium',
      'cost': '₹500 - ₹2,500',
      'causes': [
        'Component wear or damage',
        'Loose connection',
        'Blocked or dirty component',
        'Requires professional inspection',
      ],
      'solution':
          'A professional inspection is recommended to identify the exact cause and provide the appropriate repair.',
    };
  }

  // Creates a notification in Firestore for the logged-in user.
  Future<void> _createDiagnosisNotification(
    Map<String, dynamic> diagnosis,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('No logged-in user. Notification not created.');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
        'title': 'Diagnosis Complete',
        'message':
            'Your ${diagnosis['diagnosis']} diagnosis is ready.',
        'type': 'diagnosis',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Diagnosis notification created successfully.');
    } catch (e) {
      debugPrint('Failed to create diagnosis notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagnosis = _getDiagnosis();

    // Create the notification only once.
    if (!_notificationCreated) {
      _notificationCreated = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createDiagnosisNotification(diagnosis);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Diagnosis',
          style: AppTextStyles.title,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              _buildProblemCard(),

              const SizedBox(height: 18),

              _buildDiagnosisCard(diagnosis),

              const SizedBox(height: 18),

              _buildUrgencyCard(
                diagnosis['urgency'] as String,
              ),

              const SizedBox(height: 18),

              _buildSectionTitle('Possible Causes'),

              const SizedBox(height: 10),

              _buildCausesCard(
                List<String>.from(diagnosis['causes']),
              ),

              const SizedBox(height: 18),

              _buildSectionTitle('Suggested Solution'),

              const SizedBox(height: 10),

              _buildSolutionCard(
                diagnosis['solution'] as String,
              ),

              const SizedBox(height: 24),

              _buildFindProfessionalsButton(context, diagnosis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Here’s what we found',
          style: AppTextStyles.heading,
        ),
        const SizedBox(height: 6),
        Text(
          'Our AI analyzed the problem you described.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildProblemCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.home_repair_service_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Problem',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.problem.isEmpty
                      ? 'No problem described'
                      : widget.problem,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard(Map<String, dynamic> diagnosis) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.20),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Diagnosis',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            diagnosis['diagnosis'],
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _infoItem(
                  Icons.currency_rupee_rounded,
                  'Estimated Cost',
                  diagnosis['cost'],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoItem(
                  Icons.warning_amber_rounded,
                  'Urgency',
                  diagnosis['urgency'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyCard(String urgency) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            urgency == 'High'
                ? Icons.priority_high_rounded
                : Icons.info_outline_rounded,
            color: urgency == 'High'
                ? Colors.orange
                : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              urgency == 'High'
                  ? 'This problem may require attention soon.'
                  : 'This problem does not appear immediately critical.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCausesCard(List<String> causes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: causes.map((cause) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cause,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSolutionCard(String solution) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              solution,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindProfessionalsButton(
    BuildContext context,
    Map<String, dynamic> diagnosis,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          String category = 'All';
          final diagText = (diagnosis['diagnosis'] as String? ?? '').toLowerCase();
          if (diagText.contains('ac')) {
            category = 'AC Repair';
          } else if (diagText.contains('plumb')) {
            category = 'Plumbing';
          } else if (diagText.contains('electr')) {
            category = 'Electrical';
          } else {
            category = 'Appliances';
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NearbyProfessionalsMapScreen(
                category: category,
                initialProblem: widget.problem,
              ),
            ),
          );
        },
        icon: const Icon(
          Icons.location_on_rounded,
        ),
        label: const Text(
          'Find Nearby Professionals',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}