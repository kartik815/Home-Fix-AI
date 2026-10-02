import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/professional_model.dart';
import '../maps/nearby_professionals_map_screen.dart';
import 'professional_card.dart';

class SavedProfessionalsScreen extends StatefulWidget {
  final bool showBackButton;

  const SavedProfessionalsScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<SavedProfessionalsScreen> createState() =>
      _SavedProfessionalsScreenState();
}

class _SavedProfessionalsScreenState extends State<SavedProfessionalsScreen> {
  void _toggleBookmark(ProfessionalModel pro) {
    setState(() {
      pro.isSaved = !pro.isSaved;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pro.isSaved
              ? 'Saved ${pro.name} to bookmarks'
              : 'Removed ${pro.name} from saved',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          textColor: const Color(0xFF8B80FF),
          onPressed: () {
            setState(() {
              pro.isSaved = !pro.isSaved;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedList =
        ProfessionalModel.sampleProfessionals.where((p) => p.isSaved).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: (widget.showBackButton && Navigator.canPop(context))
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
      body: savedList.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              children: [
                const Text(
                  'Your Saved Professionals',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${savedList.length} professional${savedList.length == 1 ? '' : 's'} saved for future home repairs',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                ...savedList.map((pro) {
                  return ProfessionalCard(
                    key: ValueKey(pro.id),
                    professional: pro,
                    name: pro.name,
                    service: pro.specialty,
                    rating: pro.rating,
                    distance: pro.distance,
                    trustScore: pro.trustScore,
                    isSaved: pro.isSaved,
                    onBookmarkToggle: () => _toggleBookmark(pro),
                    onAfterDetails: () => setState(() {}),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                color: Color(0xFF8B80FF),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Saved Professionals Yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Professionals you bookmark from the map or technician details will appear here for quick access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NearbyProfessionalsMapScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Explore Nearby Pros'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}