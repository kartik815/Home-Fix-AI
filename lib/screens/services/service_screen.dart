import 'package:flutter/material.dart';

import '../../core/constants/app_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../diagnosis/diagnosis_screen.dart';

class ServiceScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ServiceScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  List<Map<String, String>> get _services {
    switch (title) {
      case 'Electrical':
        return [
          {
            'title': 'Fan repair',
            'problem': 'My ceiling fan is not working properly',
          },
          {
            'title': 'Light and switch repair',
            'problem': 'My lights or switches are not working properly',
          },
          {
            'title': 'Wiring issues',
            'problem': 'There may be a wiring problem in my home',
          },
          {
            'title': 'Power problems',
            'problem': 'I am having power or electricity problems in my home',
          },
        ];

      case 'Plumbing':
        return [
          {
            'title': 'Water leakage',
            'problem': 'There is a water leakage problem in my home',
          },
          {
            'title': 'Tap and faucet repair',
            'problem': 'My tap or faucet is not working properly',
          },
          {
            'title': 'Sink and drain issues',
            'problem': 'My sink or drain is clogged or not draining properly',
          },
          {
            'title': 'Pipe problems',
            'problem': 'There is a problem with a water pipe in my home',
          },
        ];

      case 'AC Repair':
        return [
          {
            'title': 'AC not cooling',
            'problem': 'My AC is running but not cooling properly',
          },
          {
            'title': 'AC servicing',
            'problem': 'My AC needs servicing or maintenance',
          },
          {
            'title': 'Water leakage',
            'problem': 'My AC is leaking water',
          },
          {
            'title': 'Unusual noise',
            'problem': 'My AC is making an unusual or strange noise',
          },
        ];

      case 'Appliances':
        return [
          {
            'title': 'Refrigerator repair',
            'problem': 'My refrigerator is not working properly',
          },
          {
            'title': 'Washing machine repair',
            'problem': 'My washing machine is not working properly',
          },
          {
            'title': 'TV and display issues',
            'problem': 'My TV or display is not working properly',
          },
          {
            'title': 'Other appliance problems',
            'problem': 'My home appliance is not working properly',
          },
        ];

      default:
        return [];
    }
  }

  void _openDiagnosis(BuildContext context, String problem) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DiagnosisScreen(
          problem: problem,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: AppTextStyles.heading.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            _buildHeader(),

            const SizedBox(height: 28),

            Text(
              'Choose a problem',
              style: AppTextStyles.heading.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Select an issue to get an AI diagnosis',
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 14),

            ..._services.map(
              (service) => _buildServiceItem(
                context,
                service['title']!,
                service['problem']!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    String service,
    String problem,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.35),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openDiagnosis(context, problem),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    color: AppColors.primary,
                    size: 19,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Tap to diagnose',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary,
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}