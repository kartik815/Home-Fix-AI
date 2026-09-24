import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_radius.dart';
import 'screens/auth/login_register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const HomePilotOnboardingApp());
}

class HomePilotOnboardingApp extends StatelessWidget {
  const HomePilotOnboardingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HomePilot AI',
      theme: AppTheme.darkTheme,
      home: const OnboardingScreen(),
      routes: {
        '/login': (_) => const LoginRegisterScreen(),
      },
    );
  }
}

class _OnboardData {
  const _OnboardData({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
  });

  final String imageAsset;
  final String title;
  final String subtitle;
}

// The four onboarding slides, one per core feature.
const List<_OnboardData> _pages = [
  _OnboardData(
    imageAsset: 'assets/images/onboarding_diagnosis.png',
    title: 'Smart Diagnosis\nfor Every Home',
    subtitle: 'Describe your problem and get\nAI-powered solutions instantly',
  ),
  _OnboardData(
    imageAsset: 'assets/images/onboarding_cost.png',
    title: 'Know the Cost\nBefore You Commit',
    subtitle: 'Get an estimated repair price range\nso you never get overcharged',
  ),
  _OnboardData(
    imageAsset: 'assets/images/onboarding_professionals.png',
    title: 'Trusted Pros\nNear You',
    subtitle: 'Find verified electricians, plumbers\nand technicians nearby on the map',
  ),
  _OnboardData(
    imageAsset: 'assets/images/onboarding_history.png',
    title: 'Never Lose\nTrack Again',
    subtitle: 'Revisit past diagnoses and bookmark\nyour favorite service professionals',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  double _page = 0;
  int _index = 0;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      setState(() {
        _page = _controller.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLastPage => _index == _pages.length - 1;

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _next() {
    if (_isLastPage) {
      _goToLogin();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _isLastPage ? 0.0 : 1.0,
                    child: TextButton(
                      onPressed: _isLastPage ? null : _goToLogin,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sliding pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) {
                  setState(() {
                    _index = i;
                  });
                },
                itemBuilder: (context, i) {
                  final delta = _page - i;

                  final opacity = (1 - delta.abs()).clamp(0.0, 1.0);

                  final scale = (1 - (delta.abs() * 0.15))
                      .clamp(0.85, 1.0);

                  final slide = delta * 60;

                  return Opacity(
                    opacity: opacity,
                    child: Transform.translate(
                      offset: Offset(slide, 0),
                      child: Transform.scale(
                        scale: scale,
                        child: _OnboardPageContent(
                          data: _pages[i],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) {
                    final active = i == _index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(
                          AppRadius.sm,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppRadius.md,
                      ),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      key: ValueKey(_isLastPage),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLastPage ? 'Get Started' : 'Next',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _isLastPage
                              ? Icons.arrow_forward_rounded
                              : Icons.arrow_forward_ios_rounded,
                          size: _isLastPage ? 20 : 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _OnboardPageContent extends StatelessWidget {
  const _OnboardPageContent({
    required this.data,
  });

  final _OnboardData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(
                AppRadius.lg,
              ),
              border: Border.all(
                color: AppColors.border.withOpacity(0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppRadius.lg,
              ),
              child: Image.asset(
                data.imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 14),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

