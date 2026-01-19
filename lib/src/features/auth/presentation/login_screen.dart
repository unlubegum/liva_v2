import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/utils/auth_helpers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _webClientId = '293343940680-h0flba6c8n1fl4f21l0uust1q6gcuf31.apps.googleusercontent.com';
  
  final _emailController = TextEditingController(text: 'begumdusmez@gmail.com');
  final _passwordController = TextEditingController(text: '123456');
  bool _isLoading = false;
  bool _obscurePassword = true;

  // ─────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleAuthSuccess() async {
    if (mounted) await fetchAndSetFamilyId(ref);
    if (mounted) context.go('/hub');
  }

  // ─────────────────────────────────────────────────────────────────
  // Auth Methods
  // ─────────────────────────────────────────────────────────────────

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _handleAuthSuccess();
    } on AuthException catch (e) {
      _showSnackBar(e.message);
    } catch (_) {
      _showSnackBar('Beklenmedik bir hata oluştu');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _showSnackBar('Hesap oluşturuldu! Giriş yapabilirsiniz.', isError: false);
    } on AuthException catch (e) {
      _showSnackBar(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn(serverClientId: _webClientId);
      final googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Google ID Token alınamadı');
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
      
      await _handleAuthSuccess();
    } on Exception catch (e) {
      _showSnackBar('Google Giriş Hatası: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(colorScheme),
                const SizedBox(height: 32),
                _buildTitle(theme),
                const SizedBox(height: 48),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(colorScheme),
                const SizedBox(height: 32),
                _buildLoginButton(theme),
                const SizedBox(height: 16),
                _buildSignUpButton(colorScheme),
                const SizedBox(height: 24),
                _buildDivider(theme),
                const SizedBox(height: 24),
                _buildGoogleButton(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // UI Components
  // ─────────────────────────────────────────────────────────────────

  Widget _buildLogo(ColorScheme colorScheme) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.home_rounded, size: 48, color: Colors.white),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Liva',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Yaşam Yönetim Sistemi',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email_outlined),
      ),
    );
  }

  Widget _buildPasswordField(ColorScheme colorScheme) {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Şifre',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  Widget _buildLoginButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signIn,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('Giriş Yap'),
      ),
    );
  }

  Widget _buildSignUpButton(ColorScheme colorScheme) {
    return TextButton(
      onPressed: _isLoading ? null : _signUp,
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: 'Hesabın yok mu? ',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
            TextSpan(
              text: 'Kayıt ol',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'veya',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _googleSignIn,
        icon: Image.network(
          'https://www.google.com/favicon.ico',
          width: 24,
          height: 24,
          errorBuilder: (_, __, ___) => Icon(
            Icons.g_mobiledata,
            size: 28,
            color: theme.colorScheme.error,
          ),
        ),
        label: const Text('Google ile devam et'),
      ),
    );
  }
}
