import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Premium Onboarding Screen - 3 Slide PageView
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      icon: Icons.timeline_rounded,
      title: 'Hayatını Yönet',
      subtitle: 'Tüm önemli anlarını tek bir yerden takip et. Akıllı hatırlatmalar ve kişiselleştirilmiş önerilerle hayatını kolaylaştır.',
      gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
    ),
    _OnboardingSlide(
      icon: Icons.family_restroom_rounded,
      title: 'Ailenle Senkronize Ol',
      subtitle: 'Aile üyeleriyle ortak takvimler, görevler ve hatırlatmalar paylaş. Herkes aynı sayfada kalsın.',
      gradient: [Color(0xFFf093fb), Color(0xFFf5576c)],
    ),
    _OnboardingSlide(
      icon: Icons.auto_awesome_rounded,
      title: 'Sana Özel Asistan',
      subtitle: 'Yapay zeka destekli kişisel asistanın rutin işlerini otomatikleştirir ve sana zaman kazandırır.',
      gradient: [Color(0xFF4facfe), Color(0xFF00f2fe)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _goToSetup() {
    context.go('/setup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _goToSetup,
                  child: Text(
                    'Atla',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(slide: _slides[index]);
                },
              ),
            ),
            
            // Page Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            
            // Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _goToSetup();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1 ? 'Başlayalım' : 'Devam Et',
                    style: AppTextStyles.buttonLarge,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single onboarding page widget
class _OnboardingPage extends StatelessWidget {
  final _OnboardingSlide slide;

  const _OnboardingPage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: slide.gradient,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: slide.gradient[0].withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              slide.icon,
              size: 64,
              color: Colors.white,
            ),
          ).animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            slide.title,
            style: AppTextStyles.headlineLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            slide.subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

/// Data class for onboarding slides
class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
