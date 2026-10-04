import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'service_provider_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'Welcome, Admin',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Manage HomePilot AI service providers',
              style: AppTextStyles.bodySecondary.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              color: AppColors.card,

              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),

                leading: Icon(
                  Icons.people_alt_outlined,
                  color: AppColors.primary,
                  size: 30,
                ),

                title: Text(
                  'Service Providers',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),

                subtitle: Text(
                  'Add and manage service professionals',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),

                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),

                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const ServiceProviderManagementScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}