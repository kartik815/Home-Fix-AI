import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Theme state
  String _selectedTheme = 'Dark Mode';
  final String _selectedLanguage = 'English (US)';
  String _selectedRadius = '5 km';

  // Toggle states
  bool _pushNotifications = true;
  bool _diagnosisAlerts = true;
  bool _promotions = false;
  bool _locationServices = true;
  bool _highAccuracyGps = true;
  bool _biometricLock = false;

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Choose Theme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...['Dark Mode (Recommended)', 'Light Mode', 'System Default'].map(
                  (theme) => RadioListTile<String>(
                    activeColor: AppColors.primary,
                    title: Text(theme, style: const TextStyle(color: Colors.white)),
                    value: theme.split(' ').first,
                    groupValue: _selectedTheme.split(' ').first,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedTheme = theme);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRadiusSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Default Search Radius',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...['2 km', '5 km (Optimal)', '10 km', '25 km'].map(
                  (radius) => RadioListTile<String>(
                    activeColor: AppColors.primary,
                    title: Text(radius, style: const TextStyle(color: Colors.white)),
                    value: radius.split(' ').first,
                    groupValue: _selectedRadius.split(' ').first,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedRadius = radius);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Clear Search History?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This will erase all past home diagnoses from this device.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Search history cleared successfully.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('App cache cleared (18.4 MB freed).'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLegalSheet(String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(
                        content,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: AppTextStyles.title,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [
          // Section: General
          _sectionHeader('General'),
          _settingsContainer([
            _selectionTile(
              icon: Icons.palette_outlined,
              title: 'App Theme',
              subtitle: _selectedTheme,
              onTap: _showThemeSelector,
            ),
            _divider(),
            _selectionTile(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Language is set to English (US). More languages coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 22),

          // Section: Notifications
          _sectionHeader('Notifications'),
          _settingsContainer([
            _switchTile(
              icon: Icons.notifications_active_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive real-time alerts and diagnosis status',
              value: _pushNotifications,
              onChanged: (val) => setState(() => _pushNotifications = val),
            ),
            _divider(),
            _switchTile(
              icon: Icons.lightbulb_outline_rounded,
              title: 'AI Diagnosis & Cost Alerts',
              subtitle: 'Alerts when cost estimates update',
              value: _diagnosisAlerts,
              onChanged: (val) => setState(() => _diagnosisAlerts = val),
            ),
            _divider(),
            _switchTile(
              icon: Icons.local_offer_outlined,
              title: 'Promotions & Discounts',
              subtitle: 'Partner technician discounts & seasonal vouchers',
              value: _promotions,
              onChanged: (val) => setState(() => _promotions = val),
            ),
          ]),
          const SizedBox(height: 22),

          // Section: Location & Google Maps
          _sectionHeader('Location & Google Maps Integration'),
          _settingsContainer([
            _switchTile(
              icon: Icons.location_on_outlined,
              title: 'Location Services',
              subtitle: 'Enables Google Maps to find technicians near you',
              value: _locationServices,
              onChanged: (val) => setState(() => _locationServices = val),
            ),
            _divider(),
            _switchTile(
              icon: Icons.gps_fixed_rounded,
              title: 'High Precision GPS',
              subtitle: 'Accurate distance calculation for technician routes',
              value: _highAccuracyGps,
              onChanged: (val) => setState(() => _highAccuracyGps = val),
            ),
            _divider(),
            _selectionTile(
              icon: Icons.radar_rounded,
              title: 'Default Search Radius',
              subtitle: _selectedRadius,
              onTap: _showRadiusSelector,
            ),
          ]),
          const SizedBox(height: 22),

          // Section: Security & Privacy
          _sectionHeader('Security & Storage'),
          _settingsContainer([
            _switchTile(
              icon: Icons.fingerprint_rounded,
              title: 'Biometric App Lock',
              subtitle: 'Protect app with Fingerprint or Face ID',
              value: _biometricLock,
              onChanged: (val) => setState(() => _biometricLock = val),
            ),
            _divider(),
            _actionTile(
              icon: Icons.history_toggle_off_rounded,
              title: 'Clear Search History',
              subtitle: 'Erase all recent diagnostic searches',
              iconColor: AppColors.warning,
              onTap: _showClearHistoryDialog,
            ),
            _divider(),
            _actionTile(
              icon: Icons.cleaning_services_outlined,
              title: 'Clear Temporary Cache',
              subtitle: 'Free up 18.4 MB of stored images & map data',
              iconColor: AppColors.secondary,
              onTap: _clearCache,
            ),
          ]),
          const SizedBox(height: 22),

          // Section: About & Legal
          _sectionHeader('About HomePilot AI'),
          _settingsContainer([
            _infoTile(
              icon: Icons.info_outline_rounded,
              title: 'App Version',
              trailingText: 'v1.0.0 (Build 1)',
            ),
            _divider(),
            _selectionTile(
              icon: Icons.gavel_outlined,
              title: 'Terms of Service',
              subtitle: 'Read terms & user obligations',
              onTap: () => _showLegalSheet(
                'Terms of Service',
                'Welcome to HomePilot AI!\n\n1. Purpose\nHomePilot AI is designed to assist homeowners with AI-guided diagnosis of common household issues and recommendations for trusted local service professionals.\n\n2. Cost Estimates\nEstimates provided are approximate guidelines based on historical repair rates and do not guarantee final technician invoices.\n\n3. Verification\nAll professionals listed are screened for basic credentials. Users are advised to confirm quotes prior to commencement of physical labor.',
              ),
            ),
            _divider(),
            _selectionTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How your data is kept safe',
              onTap: () => _showLegalSheet(
                'Privacy Policy',
                'Your privacy is critical to us.\n\n1. Location Data\nLocation is accessed solely to calculate distance to nearby electricians, plumbers, and technicians on Google Maps. We do not sell your location coordinates.\n\n2. AI Diagnostics\nProblem descriptions entered into HomePilot AI are processed to deliver accurate diagnostic recommendations and cost estimates.\n\n3. Authentication\nAuthentication is securely handled using Google Firebase.',
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _settingsContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(
      color: AppColors.border.withValues(alpha: 0.25),
      height: 1,
      indent: 56,
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      secondary: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.secondary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }

  Widget _selectionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.secondary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.textSecondary,
        size: 14,
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
        size: 20,
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String trailingText,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.secondary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: Text(
        trailingText,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
