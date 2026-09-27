import 'package:flutter/material.dart';

class ProfessionalCard extends StatelessWidget {
  final String name;
  final double rating;
  final String distance;
  final int trustScore;
  final String service;

  const ProfessionalCard({
    super.key,
    required this.name,
    required this.rating,
    required this.distance,
    required this.trustScore,
    required this.service,
  });

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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      service,
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Saved icon
              const Icon(
                Icons.bookmark_rounded,
                color: Color(0xFF6C63FF),
                size: 23,
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
              onPressed: () {
                // Professional details can be connected later.
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