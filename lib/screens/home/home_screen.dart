import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_radius.dart';
import '../diagnosis/diagnosis_screen.dart';
import '../history/search_history_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../saved_professionals/saved_professionals_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _problemController =
      TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  int _selectedIndex = 0;

  // ============================================================
  // QUICK SERVICES
  // ============================================================

  final List<Map<String, dynamic>> _quickServices = [
    {
      'title': 'Electrical',
      'subtitle': 'Fans, lights & wiring',
      'icon': Icons.electrical_services_rounded,
      'problem': 'There is an electrical problem in my home',
    },
    {
      'title': 'Plumbing',
      'subtitle': 'Leaks & water issues',
      'icon': Icons.water_drop_rounded,
      'problem': 'There is a plumbing or water leakage problem',
    },
    {
      'title': 'AC Repair',
      'subtitle': 'Cooling & maintenance',
      'icon': Icons.ac_unit_rounded,
      'problem': 'My AC is running but not cooling properly',
    },
    {
      'title': 'Appliances',
      'subtitle': 'TV, fridge & more',
      'icon': Icons.kitchen_rounded,
      'problem': 'My home appliance is not working properly',
    },
  ];

  // ============================================================
  // RECENT SEARCHES
  // ============================================================

  final List<Map<String, dynamic>> _recentProblems = [
    {
      'problem': 'AC is not cooling properly',
      'category': 'AC Repair',
      'icon': Icons.ac_unit_rounded,
    },
    {
      'problem': 'Kitchen sink is leaking',
      'category': 'Plumbing',
      'icon': Icons.water_drop_rounded,
    },
    {
      'problem': 'Ceiling fan is making noise',
      'category': 'Electrical',
      'icon': Icons.electrical_services_rounded,
    },
  ];

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  // ============================================================
  // USER NAME
  // ============================================================

  String get _userName {
    final user = FirebaseAuth.instance.currentUser;

    if (user?.displayName != null &&
        user!.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim().split(' ').first;
    }

    if (user?.email != null) {
      return user!.email!.split('@').first;
    }

    return 'there';
  }

  // ============================================================
  // OPEN DIAGNOSIS SCREEN
  // ============================================================

  void _openDiagnosis(String problem) {
    final trimmedProblem = problem.trim();

    if (trimmedProblem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please describe your home problem first.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Remove keyboard before navigating.
    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiagnosisScreen(
          problem: trimmedProblem,
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH / DIAGNOSE BUTTON
  // ============================================================

  void _searchProblem() {
    final problem = _problemController.text.trim();

    if (problem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please describe your home problem first.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    // Save to recent searches if it is not already there.
    final alreadyExists = _recentProblems.any(
      (item) =>
          item['problem'].toString().toLowerCase() ==
          problem.toLowerCase(),
    );

    if (!alreadyExists) {
      setState(() {
        _recentProblems.insert(
          0,
          {
            'problem': problem,
            'category': 'Recent Diagnosis',
            'icon': Icons.history_rounded,
          },
        );

        // Keep only the latest 5 searches.
        if (_recentProblems.length > 5) {
          _recentProblems.removeLast();
        }
      });
    }

    _openDiagnosis(problem);
  }

  // ============================================================
  // QUICK SERVICE
  // ============================================================

  void _selectQuickService(Map<String, dynamic> service) {
    final problem = service['problem'] as String;

    _problemController.text = problem;

    _openDiagnosis(problem);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContent(),
            const SearchHistoryScreen(showBackButton: false),
            const SavedProfessionalsScreen(showBackButton: false),
            const ProfileScreen(showBackButton: false),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            30,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildTopBar(),

                const SizedBox(height: 30),

                _buildGreeting(),

                const SizedBox(height: 22),

                _buildProblemCard(),

                const SizedBox(height: 30),

                _buildSectionHeader(
                  'Quick Services',
                  'Choose a common problem',
                ),

                const SizedBox(height: 14),

                _buildQuickServices(),

                const SizedBox(height: 30),

                _buildSectionHeader(
                  'Recent Searches',
                  'View all',
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                  },
                ),

                const SizedBox(height: 14),

                _buildRecentSearches(),

                const SizedBox(height: 26),

                _buildTrustBanner(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.home_repair_service_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HomePilot AI',
                style: AppTextStyles.heading.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                'Your smart home assistant',
                style: AppTextStyles.bodySecondary.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        _iconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            );
          },
        ),

        const SizedBox(width: 8),

        _iconButton(
          icon: Icons.person_outline_rounded,
          onTap: () {
            setState(() {
              _selectedIndex = 3;
            });
          },
        ),
      ],
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: 21,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GREETING
  // ============================================================

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $_userName 👋',
          style: AppTextStyles.heading.copyWith(
            fontSize: 29,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'What can we help you fix today?',
          style: AppTextStyles.bodySecondary.copyWith(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MAIN PROBLEM SEARCH
  // ============================================================

  Widget _buildProblemCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border.withOpacity(0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Home Diagnosis',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'Describe the problem in your own words',
                      style:
                          AppTextStyles.bodySecondary.copyWith(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          // ======================================================
          // WORKING SEARCH BOX
          // ======================================================

          Container(
            height: 128,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: AppColors.border.withOpacity(0.45),
              ),
            ),

            // Stack keeps the microphone completely separate
            // from the text input area.
            child: Stack(
              children: [
                TextField(
                  controller: _problemController,

                  keyboardType: TextInputType.multiline,

                  textInputAction:
                      TextInputAction.newline,

                  minLines: 3,
                  maxLines: 4,

                  cursorColor: AppColors.primary,

                  textCapitalization:
                      TextCapitalization.sentences,

                  autocorrect: true,

                  enableSuggestions: true,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),

                  decoration: InputDecoration(
                    hintText:
                        'Example: My AC is running but not cooling...',

                    hintStyle: TextStyle(
                      color: AppColors.textSecondary
                          .withOpacity(0.75),
                      fontSize: 13.5,
                      height: 1.4,
                    ),

                    border: InputBorder.none,

                    enabledBorder: InputBorder.none,

                    focusedBorder: InputBorder.none,

                    contentPadding:
                        const EdgeInsets.fromLTRB(
                      16,
                      15,
                      68,
                      15,
                    ),
                  ),

                  onSubmitted: (_) {
                    _searchProblem();
                  },
                ),

                // ==================================================
                // MICROPHONE BUTTON
                // ==================================================

                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Material(
                    color: AppColors.primary
                        .withOpacity(0.13),
                    borderRadius:
                        BorderRadius.circular(12),

                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Voice input will be connected soon.',
                            ),
                            behavior:
                                SnackBarBehavior.floating,
                          ),
                        );
                      },

                      borderRadius:
                          BorderRadius.circular(12),

                      child: const SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(
                          Icons.mic_none_rounded,
                          color: AppColors.primary,
                          size: 21,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ======================================================
          // DIAGNOSE BUTTON
          // ======================================================

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _searchProblem,

              icon: const Icon(
                Icons.auto_awesome_rounded,
                size: 19,
              ),

              label: const Text(
                'Diagnose My Problem',
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),

                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(
    String title,
    String action, {
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.heading.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        GestureDetector(
          onTap: onTap ??
              () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      '$title will be connected soon.',
                    ),
                    behavior:
                        SnackBarBehavior.floating,
                  ),
                );
              },
          child: Text(
            action,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK SERVICES
  // ============================================================

  Widget _buildQuickServices() {
    return SizedBox(
      height: 155,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        physics:
            const BouncingScrollPhysics(),

        itemCount: _quickServices.length,

        separatorBuilder: (_, __) =>
            const SizedBox(width: 12),

        itemBuilder: (context, index) {
          final service =
              _quickServices[index];

          return _buildServiceCard(
            title: service['title'] as String,
            subtitle: service['subtitle'] as String,
            icon: service['icon'] as IconData,

            onTap: () {
              _selectQuickService(service);
            },
          );
        },
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(20),

        child: Container(
          width: 145,

          padding:
              const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: AppColors.card,

            borderRadius:
                BorderRadius.circular(20),

            border: Border.all(
              color: AppColors.border
                  .withOpacity(0.4),
            ),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withOpacity(0.13),

                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),

              const Spacer(),

              Text(
                title,
                style: TextStyle(
                  color:
                      AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,

                style: TextStyle(
                  color:
                      AppColors.textSecondary,
                  fontSize: 10.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RECENT SEARCHES
  // ============================================================

  Widget _buildRecentSearches() {
    return Column(
      children: _recentProblems.map((item) {
        return Padding(
          padding:
              const EdgeInsets.only(bottom: 10),

          child: _buildRecentItem(
            problem:
                item['problem'] as String,

            category:
                item['category'] as String,

            icon:
                item['icon'] as IconData,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentItem({
    required String problem,
    required String category,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: () {
          _problemController.text =
              problem;

          _openDiagnosis(problem);
        },

        borderRadius:
            BorderRadius.circular(17),

        child: Container(
          padding:
              const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: AppColors.card,

            borderRadius:
                BorderRadius.circular(17),

            border: Border.all(
              color: AppColors.border
                  .withOpacity(0.35),
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withOpacity(0.10),

                  borderRadius:
                      BorderRadius.circular(13),
                ),

                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      problem,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style: TextStyle(
                        color:
                            AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      category,

                      style: TextStyle(
                        color:
                            AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color:
                    AppColors.textSecondary,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TRUST BANNER
  // ============================================================

  Widget _buildTrustBanner() {
    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary
                .withOpacity(0.20),
            AppColors.secondary
                .withOpacity(0.08),
          ],
        ),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: AppColors.primary
              .withOpacity(0.20),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: AppColors.primary
                  .withOpacity(0.15),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.primary,
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Find trusted professionals',

                  style: TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Get reliable pros near you after diagnosis.',

                  style: TextStyle(
                    color:
                        AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,

        border: Border(
          top: BorderSide(
            color: AppColors.border
                .withValues(alpha: 0.35),
          ),
        ),
      ),

      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,

            children: [
              _bottomNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
              ),

              _bottomNavItem(
                icon: Icons.history_rounded,
                label: 'History',
                index: 1,
              ),

              _bottomNavItem(
                icon:
                    Icons.bookmark_border_rounded,
                label: 'Saved',
                index: 2,
              ),

              _bottomNavItem(
                icon:
                    Icons.person_outline_rounded,
                label: 'Profile',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected =
        _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },

      behavior:
          HitTestBehavior.opaque,

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
                  .withValues(alpha: 0.12)
              : Colors.transparent,

          borderRadius:
              BorderRadius.circular(14),
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Icon(
              icon,
              size: 21,

              color: selected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),

            const SizedBox(height: 4),

            Text(
              label,

              style: TextStyle(
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,

                fontSize: 10,

                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}