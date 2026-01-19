import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _inviteCode;
  String? _familyName;
  bool _isLoadingFn = true;

  @override
  void initState() {
    super.initState();
    _fetchFamilyInfo();
  }

  Future<void> _fetchFamilyInfo() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // 1. Get User Profile to find family_id
      final profile = await supabase
          .from('profiles')
          .select('family_id')
          .eq('id', userId)
          .single();

      final familyId = profile['family_id'];

      if (familyId != null) {
        // 2. Get Family Info
        final family = await supabase
            .from('families')
            .select('invite_code, name')
            .eq('id', familyId)
            .single();

        if (mounted) {
          setState(() {
            _inviteCode = family['invite_code'];
            _familyName = family['name'];
            _isLoadingFn = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingFn = false);
      }
    } catch (e) {
      debugPrint('Error fetching family info: $e');
      if (mounted) setState(() => _isLoadingFn = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Çıkış yapılırken hata: $e')),
        );
      }
    }
  }

  void _copyInviteCode() {
    if (_inviteCode == null) return;
    Clipboard.setData(ClipboardData(text: _inviteCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Davet kodu kopyalandı!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'kullanici@liva.app';
    final userImage = user?.userMetadata?['avatar_url'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Ayarlar',
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
            ),
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
          ),

          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // 1. Profil Kartı
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: userImage != null
                              ? ClipOval(child: Image.network(userImage, fit: BoxFit.cover))
                              : Center(
                                  child: Text(
                                    email[0].toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _familyName ?? 'Liva Ailesi',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                email,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Davet Kartı
                  if (_isLoadingFn)
                    const Center(child: CircularProgressIndicator())
                  else if (_inviteCode != null)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AİLE DAVET KODU',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.8),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _inviteCode!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: _copyInviteCode,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  padding: const EdgeInsets.all(12),
                                ),
                                icon: const Icon(Icons.copy_rounded, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Bu kodu eşinle paylaşarak onu ailene dahil et.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 48),

                  // 3. Çıkış Yap Butonu
                  ElevatedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('ÇIKIŞ YAP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  Center(
                    child: Text(
                      'Liva V2 • v1.0.0',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
