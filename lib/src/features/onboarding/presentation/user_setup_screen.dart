import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/providers/module_config_provider.dart';

/// User Setup Screen - İsim ve Cinsiyet Seçimi
class UserSetupScreen extends ConsumerStatefulWidget {
  const UserSetupScreen({super.key});

  @override
  ConsumerState<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends ConsumerState<UserSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  Gender _selectedGender = Gender.notSelected;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _nameController.text.trim().isNotEmpty && _selectedGender != Gender.notSelected;

  Future<void> _completeSetup() async {
    if (!_canContinue) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Save user name
      await ref.read(userNameProvider.notifier).setName(_nameController.text.trim());
      
      // Save gender
      await ref.read(userGenderProvider.notifier).setGender(_selectedGender);
      
      // Apply gender-based module defaults
      await ref.read(moduleConfigProvider.notifier).applyGenderDefaults(_selectedGender);
      
      // Mark onboarding as complete
      await ref.read(isFirstTimeProvider.notifier).completeOnboarding();
      
      // Navigate to home
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Welcome text
              Text(
                'Hoş Geldin! 👋',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
              
              const SizedBox(height: 8),
              
              Text(
                'Seni daha iyi tanımak için birkaç bilgiye ihtiyacımız var.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              
              const SizedBox(height: 48),
              
              // Name Input
              Text(
                'İsminiz?',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 12),
              
              TextField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                textCapitalization: TextCapitalization.words,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Adınızı girin...',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 40),
              
              // Gender Selection
              Text(
                'Cinsiyet Seçimi',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 400.ms),
              
              const SizedBox(height: 8),
              
              Text(
                'Bu seçim, sana özel modülleri etkinleştirmemize yardımcı olur.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 450.ms),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  // Female Card
                  Expanded(
                    child: _GenderCard(
                      icon: Icons.female_rounded,
                      label: 'Kadın',
                      description: 'Döngü takibi, moda, ev yönetimi',
                      isSelected: _selectedGender == Gender.female,
                      gradient: const [Color(0xFFF8BBD9), Color(0xFFF48FB1)],
                      onTap: () {
                        setState(() {
                          _selectedGender = Gender.female;
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Male Card
                  Expanded(
                    child: _GenderCard(
                      icon: Icons.male_rounded,
                      label: 'Erkek',
                      description: 'Araba, fitness, teknoloji',
                      isSelected: _selectedGender == Gender.male,
                      gradient: const [Color(0xFF90CAF9), Color(0xFF64B5F6)],
                      onTap: () {
                        setState(() {
                          _selectedGender = Gender.male;
                        });
                      },
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 16),
              
              // Info text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tüm modülleri daha sonra Ayarlar\'dan değiştirebilirsin.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms),
              
              const SizedBox(height: 48),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canContinue && !_isLoading ? _completeSetup : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Devam Et',
                          style: AppTextStyles.buttonLarge,
                        ),
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gender selection card
class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? gradient[0].withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? gradient[1] : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: AppTextStyles.cardTitle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? gradient[1] : AppColors.surface,
                border: Border.all(
                  color: isSelected ? gradient[1] : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
