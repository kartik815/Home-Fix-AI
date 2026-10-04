import 'package:flutter/material.dart';

import '../../models/professional_model.dart';
import '../maps/professional_details_screen.dart';

class ProfessionalCard extends StatelessWidget {
  final ProfessionalModel? professional;
  final String name;
  final double rating;
  final String distance;
  final int trustScore;
  final String service;
  final bool isSaved;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onAfterDetails;

  const ProfessionalCard({
    super.key,
    this.professional,
    required this.name,
    required this.rating,
    required this.distance,
    required this.trustScore,
    required this.service,
    this.isSaved = true,
    this.onBookmarkToggle,
    this.onAfterDetails,
  });

  ProfessionalModel get _resolvedModel {
    if (professional != null) return professional!;
    return ProfessionalModel.sampleProfessionals.firstWhere(
      (p) => p.name.toLowerCase().contains(name.toLowerCase()),
      orElse: () => ProfessionalModel(
        id: 'custom_${name.hashCode}',
        name: name,
        category: service.contains('Plumb') ? 'Plumbing' : 'Electrical',
        specialty: service,
        rating: rating,
        reviewCount: 95,
        trustScore: trustScore,
        completedRepairs: 120,
        distance: distance,
        latitude: 28.6139,
        longitude: 77.2090,
        phoneNumber: '+91 98112 34567',
        address: 'Local Service Partner',
        experienceYears: 6,
        pricingStartingAt: '₹299',
        aiReviewSummary:
            'AI verified for consistently meeting quality benchmarks and prompt home repair resolution.',
        isSaved: isSaved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF444444),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Professional icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.build_outlined,
                  color: Color(0xFF8B80FF),
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              // Name and service
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      service,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Interactive bookmark toggle
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBookmarkToggle,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        key: ValueKey<bool>(isSaved),
                        color: isSaved
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFFAAAAAA),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Details
          Row(
            children: [
              _InfoItem(
                icon: Icons.star_rounded,
                value: rating.toString(),
                iconColor: const Color(0xFFFFC857),
              ),

              const SizedBox(width: 20),

              _InfoItem(
                icon: Icons.location_on_outlined,
                value: distance,
                iconColor: const Color(0xFF8B80FF),
              ),

              const SizedBox(width: 20),

              _InfoItem(
                icon: Icons.verified_outlined,
                value: 'Trust $trustScore',
                iconColor: const Color(0xFF6C63FF),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // View professional button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () async {
                final match = _resolvedModel;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfessionalDetailsScreen(
                      professional: match,
                    ),
                  ),
                );
                onAfterDetails?.call();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFF6C63FF),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'View Professional',
                style: TextStyle(
                  color: Color(0xFF8B80FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color iconColor;

  const _InfoItem({
    required this.icon,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: iconColor,
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFB5B5B5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}