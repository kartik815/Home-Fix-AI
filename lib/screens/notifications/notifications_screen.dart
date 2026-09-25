import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),

        title: const Text(
          'Notifications',
          style: AppTextStyles.title,
        ),

        actions: [
          IconButton(
            onPressed: () {
              // left this place to add required backend later 
            },
            icon: const Icon(
              Icons.done_all_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          // Today
          Text(
            'Today',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          NotificationCard(
            icon: Icons.local_offer_outlined,
            title: 'New offer available',
            message:
                'Get 10% off on AC repair from a nearby professional.',
            time: '2h ago',
            isUnread: true,
          ),

          const SizedBox(height: 12),

          NotificationCard(
            icon: Icons.check_circle_outline_rounded,
            title: 'Diagnosis saved',
            message:
                'Your AC not cooling diagnosis has been saved to your history.',
            time: '4h ago',
            isUnread: true,
          ),

          const SizedBox(height: 28),

          // Earlier
          Text(
            'Earlier',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          NotificationCard(
            icon: Icons.person_search_outlined,
            title: 'New professional available',
            message:
                'A trusted appliance repair professional is now available near you.',
            time: '1d ago',
          ),

          const SizedBox(height: 12),

          NotificationCard(
            icon: Icons.bookmark_outline_rounded,
            title: 'Professional saved',
            message:
                'CoolCare AC Services has been added to your saved professionals.',
            time: '2d ago',
          ),

          const SizedBox(height: 12),

          NotificationCard(
            icon: Icons.notifications_active_outlined,
            title: 'Service reminder',
            message:
                'Remember to service your AC before the summer season.',
            time: '3d ago',
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final bool isUnread;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.border.withValues(alpha: 0.35),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: AppColors.primary,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    if (isUnread)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(
                          top: 5,
                          left: 6,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  message,
                  style: AppTextStyles.bodySecondary.copyWith(
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  time,
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}