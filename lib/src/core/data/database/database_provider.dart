/// Database Providers for Riverpod
///
/// Centralized providers for database access and sync status.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';

import 'app_database.dart';

/// Provider for the AppDatabase instance
/// Must be overridden in main.dart after initialization
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden after AppDatabase.initialize()',
  );
});

/// Provider for sync status stream
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.syncStatusStream;
});

/// Provider to check if syncing is in progress
final isSyncingProvider = Provider<bool>((ref) {
  final statusAsync = ref.watch(syncStatusProvider);
  return statusAsync.when(
    data: (status) => status.downloading || status.uploading,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider to check if connected to PowerSync
final isConnectedProvider = Provider<bool>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.isConnected;
});

/// Provider for pending upload count
final pendingUploadsProvider = Provider<int>((ref) {
  final statusAsync = ref.watch(syncStatusProvider);
  return statusAsync.when(
    data: (status) => status.uploadError != null ? 1 : 0,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
