import 'package:flutter/material.dart';

import 'professional_card.dart';

class SavedProfessionalsScreen extends StatelessWidget {
  const SavedProfessionalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B1B),
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),

        title: const Text(
          'Saved Professionals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        children: [
          const Text(
            'Your Saved Professionals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Professionals you saved for future home repairs',
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

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