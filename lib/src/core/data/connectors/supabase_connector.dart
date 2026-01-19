/// Supabase Connector for PowerSync
/// 
/// Handles authentication credentials and data upload to Supabase.
/// This connector bridges PowerSync's offline-first database with Supabase backend.
library;

import 'dart:developer' as dev;
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';

/// Supabase connector that provides credentials and handles uploads
class SupabaseConnector extends PowerSyncBackendConnector {
  SupabaseConnector();

  /// Get the Supabase client instance
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Current user session
  Session? get _session => _supabase.auth.currentSession;

  /// Check if user is authenticated
  bool get isLoggedIn => _session != null;

  /// User ID for the current session
  String? get userId => _session?.user.id;

  /// ─────────────────────────────────────────────────────────────────────────
  /// POWERSYNC CREDENTIALS
  /// ─────────────────────────────────────────────────────────────────────────
  
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    // 1. Session var mı kontrol et
    final session = _supabase.auth.currentSession;
    if (session == null) {
      dev.log('[PowerSync] No session - running in local-only mode');
      return null;
    }

    // 2. Token'ı al
    final token = session.accessToken;
    
    dev.log('[PowerSync] Sending credentials:');
    dev.log('  - Endpoint: $powersyncUrl');
    dev.log('  - UserId: ${session.user.id}');
    dev.log('  - Token (first 50 chars): ${token.substring(0, 50)}...');

    // 3. Credentials dön
    return PowerSyncCredentials(
      endpoint: powersyncUrl,
      token: token,
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// UPLOAD DATA TO SUPABASE
  /// ─────────────────────────────────────────────────────────────────────────
  
  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;

    try {
      for (final op in transaction.crud) {
        await _processOperation(op);
      }
      await transaction.complete();
    } catch (e) {
      // Log error but don't throw - data will retry on next sync
      // In production, implement proper error handling/retry logic
      rethrow;
    }
  }

  /// Process a single CRUD operation
  Future<void> _processOperation(CrudEntry op) async {
    final table = op.table;
    final data = Map<String, dynamic>.from(op.opData ?? {});
    
    // Add the ID to the data for upserts
    data['id'] = op.id;

    switch (op.op) {
      case UpdateType.put:
        // Upsert - insert or update
        await _supabase.from(table).upsert(data);
        break;
        
      case UpdateType.patch:
        // Update existing record
        await _supabase.from(table).update(data).eq('id', op.id);
        break;
        
      case UpdateType.delete:
        // Delete record
        await _supabase.from(table).delete().eq('id', op.id);
        break;
    }
  }
}
