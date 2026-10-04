import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'add_service_provider_screen.dart';

class ServiceProviderManagementScreen extends StatelessWidget {
  const ServiceProviderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Service Providers'),
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
              'Manage Service Providers',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Add and manage professionals available in HomePilot AI.',
              style: AppTextStyles.bodySecondary.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 54,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const AddServiceProviderScreen(),
                    ),
                  );
                },

                icon: const Icon(Icons.add),

                label: const Text(
                  'Add Service Provider',
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('professionals')
                    .snapshots(),

                builder: (context, snapshot) {
                  // Loading
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Error
                  if (snapshot.hasError) {
                    return _buildMessage(
                      icon: Icons.error_outline,
                      title: 'Unable to load providers',
                      message: snapshot.error.toString(),
                    );
                  }

                  final documents = snapshot.data?.docs ?? [];

                  // No providers
                  if (documents.isEmpty) {
                    return _buildMessage(
                      icon: Icons.people_outline,
                      title: 'No service providers added yet',
                      message:
                          'Add your first service provider to make them available to users.',
                    );
                  }

                  // Providers exist
                  return ListView.separated(
                    itemCount: documents.length,

                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),

                    itemBuilder: (context, index) {
                      final document = documents[index];

                      final data = document.data();

                      return _buildProviderCard(
                        context,
                        document.id,
                        data,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(
    BuildContext context,
    String providerId,
    Map<String, dynamic> data,
  ) {
    final name =
        data['name']?.toString() ?? 'Unknown Provider';

    final category =
        data['category']?.toString() ?? 'Service Provider';

    final specialty =
        data['specialty']?.toString() ?? '';

    final phone =
        data['phoneNumber']?.toString() ?? '';

    final address =
        data['address']?.toString() ?? '';

    final experience =
        data['experienceYears']?.toString() ?? '0';

    final pricing =
        data['pricingStartingAt']?.toString() ?? '0';

    final isVerified =
        data['isVerified'] == true;

    return Card(
      color: AppColors.card,
      margin: EdgeInsets.zero,
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.border.withValues(alpha: 0.35),
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Icon(
                    _getCategoryIcon(category),
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        category,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if (specialty.isNotEmpty) ...[
                        const SizedBox(height: 3),

                        Text(
                          specialty,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.green.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            Divider(
              color: AppColors.border.withValues(alpha: 0.25),
              height: 1,
            ),

            const SizedBox(height: 14),

            _buildInfoRow(
              Icons.phone_outlined,
              phone,
            ),

            const SizedBox(height: 8),

            _buildInfoRow(
              Icons.location_on_outlined,
              address,
            ),

            const SizedBox(height: 8),

            _buildInfoRow(
              Icons.work_outline,
              '$experience years experience',
            ),

            const SizedBox(height: 8),

            _buildInfoRow(
              Icons.currency_rupee,
              'Starting from ₹$pricing',
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Edit provider will be added next.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                    ),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _deleteProvider(
                        context,
                        providerId,
                        name,
                      );
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                    ),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.35),
          ),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.primary,
            ),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electrical':
        return Icons.electrical_services_outlined;

      case 'plumbing':
        return Icons.plumbing_outlined;

      case 'ac repair':
        return Icons.ac_unit_outlined;

      case 'appliances':
        return Icons.kitchen_outlined;

      case 'carpentry':
        return Icons.handyman_outlined;

      case 'painting':
        return Icons.format_paint_outlined;

      case 'cleaning':
        return Icons.cleaning_services_outlined;

      default:
        return Icons.build_outlined;
    }
  }

  Future<void> _deleteProvider(
    BuildContext context,
    String providerId,
    String providerName,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,

          title: Text(
            'Delete Provider?',
            style: TextStyle(
              color: AppColors.textPrimary,
            ),
          ),

          content: Text(
            'Are you sure you want to delete "$providerName"?',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('professionals')
          .doc(providerId)
          .delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Service provider deleted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete provider: $e',
          ),
        ),
      );
    }
  }
}