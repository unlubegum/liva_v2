/// App Database - PowerSync Database Wrapper
///
/// Centralized database access with offline-first sync capabilities.
/// Uses singleton pattern for consistent database access across the app.
library;

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';

import '../connectors/supabase_connector.dart';
import '../schema/powersync_schema.dart';

/// App database wrapper providing typed access to PowerSync database
class AppDatabase {
  AppDatabase._();
  
  static AppDatabase? _instance;
  static PowerSyncDatabase? _db;
  static SupabaseConnector? _connector;

  /// Get the singleton instance
  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  /// Get the raw PowerSync database for advanced queries
  PowerSyncDatabase get db {
    if (_db == null) {
      throw StateError('Database not initialized. Call AppDatabase.initialize() first.');
    }
    return _db!;
  }

  /// Get the Supabase connector
  SupabaseConnector get connector {
    _connector ??= SupabaseConnector();
    return _connector!;
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// INITIALIZATION
  /// ─────────────────────────────────────────────────────────────────────────

  /// Initialize the database (call once at app startup)
  static Future<AppDatabase> initialize() async {
    if (_db != null) return instance;

    // Get the database file path
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'liva_v2.db');

    // Create the PowerSync database
    _db = PowerSyncDatabase(
      schema: schema,
      path: dbPath,
    );

    // Initialize the database
    await _db!.initialize();

    return instance;
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// CONNECTION MANAGEMENT
  /// ─────────────────────────────────────────────────────────────────────────

  /// Connect to PowerSync service (call after user logs in)
  Future<void> connect() async {
    if (!connector.isLoggedIn) {
      // Don't connect if not logged in - work offline only
      return;
    }
    await db.connect(connector: connector);
  }

  /// Disconnect from PowerSync service (call on logout)
  Future<void> disconnect() async {
    await db.disconnect();
  }

  /// Check if currently connected
  bool get isConnected => db.connected;

  /// ─────────────────────────────────────────────────────────────────────────
  /// SYNC STATUS
  /// ─────────────────────────────────────────────────────────────────────────

  /// Stream of sync status updates
  Stream<SyncStatus> get syncStatusStream => db.statusStream;

  /// Current sync status
  SyncStatus get syncStatus => db.currentStatus;

  /// ─────────────────────────────────────────────────────────────────────────
  /// QUERY HELPERS
  /// ─────────────────────────────────────────────────────────────────────────

  /// Execute a raw SQL query and return results
  Future<List<Map<String, dynamic>>> query(String sql, [List<Object?> args = const []]) {
    return db.getAll(sql, args);
  }

  /// Watch a query and return a stream of results
  Stream<List<Map<String, dynamic>>> watch(String sql, [List<Object?> args = const []]) {
    return db.watch(sql, parameters: args).map((results) => results.toList());
  }

  /// Execute a write operation (INSERT, UPDATE, DELETE)
  Future<void> execute(String sql, [List<Object?> args = const []]) {
    return db.execute(sql, args);
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// TRANSACTION HELPERS
  /// ─────────────────────────────────────────────────────────────────────────

  /// Run multiple operations in a transaction
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await db.writeTransaction((tx) async {
      return await action();
    });
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// CLEANUP
  /// ─────────────────────────────────────────────────────────────────────────

  /// Close the database connection
  Future<void> close() async {
    await disconnect();
    await _db?.close();
    _db = null;
    _instance = null;
    _connector = null;
  }

  /// Delete all local data (for logout/reset)
  Future<void> deleteLocalData() async {
    await disconnect();
    
    // Get all table names and delete data
    for (final table in schema.tables) {
      await db.execute('DELETE FROM ${table.name}');
    }
  }
}
