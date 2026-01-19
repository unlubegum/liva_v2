/// Auth Helpers
/// 
/// Utility functions for authentication-related tasks.
library;

import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/family/data/family_repository.dart';

/// Fetches the current user's family_id from Supabase and sets it in the provider
/// 
/// This should be called:
/// 1. After successful login
/// 2. When the app starts (if user is already logged in)
Future<void> fetchAndSetFamilyId(WidgetRef ref) async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      dev.log('[Auth] No user logged in, skipping family ID fetch');
      return;
    }

    dev.log('[Auth] Fetching family_id for user: ${user.id}');

    // Profiles tablosundan family_id'yi çek
    final data = await Supabase.instance.client
        .from('profiles')
        .select('family_id')
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      dev.log('[Auth] No profile found for user, creating one...');
      // Profil yoksa oluştur (yeni kayıt olmuşsa)
      return;
    }

    final familyId = data['family_id'] as String?;

    if (familyId != null) {
      // Provider'ı güncelle! Artık tüm uygulama bu ID'yi bilecek.
      ref.read(currentFamilyIdProvider.notifier).state = familyId;
      dev.log('✅ [Auth] Family ID set: $familyId');
    } else {
      dev.log('[Auth] User has no family_id assigned yet');
    }
  } catch (e) {
    dev.log('❌ [Auth] Error fetching family ID: $e');
  }
}

/// Clears the family ID when logging out
void clearFamilyId(WidgetRef ref) {
  ref.read(currentFamilyIdProvider.notifier).state = null;
  dev.log('[Auth] Family ID cleared');
}
