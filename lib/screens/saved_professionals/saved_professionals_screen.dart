import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'professional_card.dart';

class SavedProfessionalsScreen extends StatelessWidget {
  final bool showBackButton;

  const SavedProfessionalsScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: (showBackButton && Navigator.canPop(context))
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              )
            : null,
        title: const Text(
          'Saved Professionals',
          style: AppTextStyles.title,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: const [
          Text(
            'Your Saved Professionals',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Professionals you saved for future home repairs',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 20),
          ProfessionalCard(
            name: 'Sharma Electricals',
            service: 'Electrical & AC Repair',
            rating: 4.8,
            distance: '0.8 km',
            trustScore: 92,
          ),
          ProfessionalCard(
            name: 'R.K. Services',
            service: 'Plumbing & Appliance Repair',
            rating: 4.6,
            distance: '1.2 km',
            trustScore: 88,
          ),
          ProfessionalCard(
            name: 'CoolCare AC Services',
            service: 'AC & Cooling Services',
            rating: 4.7,
            distance: '2.1 km',
            trustScore: 90,
          ),
        ],
      ),
    );
  }
}