/// Base Repository Interface
///
/// Abstract interface defining standard CRUD operations for all repositories.
/// Provides type-safe, consistent API across all feature repositories.
library;

import '../database/app_database.dart';

/// Base repository with common CRUD operations
abstract class BaseRepository<T> {
  final AppDatabase db;

  BaseRepository(this.db);

  /// Table name for this repository
  String get tableName;

  /// Convert a database row to entity
  T fromRow(Map<String, dynamic> row);

  /// Convert entity to database row
  Map<String, dynamic> toRow(T entity);

  /// Get ID from entity
  String getId(T entity);

  // ─────────────────────────────────────────────────────────────────────────
  // READ OPERATIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all items
  Future<List<T>> getAll() async {
    final rows = await db.query('SELECT * FROM $tableName');
    return rows.map(fromRow).toList();
  }

  /// Watch all items as a stream
  Stream<List<T>> watchAll() {
    return db.watch('SELECT * FROM $tableName').map(
      (rows) => rows.map(fromRow).toList(),
    );
  }

  /// Get item by ID
  Future<T?> getById(String id) async {
    final rows = await db.query(
      'SELECT * FROM $tableName WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return fromRow(rows.first);
  }

  /// Watch item by ID
  Stream<T?> watchById(String id) {
    return db.watch(
      'SELECT * FROM $tableName WHERE id = ?',
      [id],
    ).map((rows) => rows.isEmpty ? null : fromRow(rows.first));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WRITE OPERATIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Insert or update an item
  Future<void> upsert(T entity) async {
    final row = toRow(entity);
    final id = getId(entity);
    
    // Build column names and placeholders
    final columns = row.keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    final updates = columns.map((c) => '$c = excluded.$c').join(', ');
    
    final sql = '''
      INSERT INTO $tableName (id, ${columns.join(', ')})
      VALUES (?, $placeholders)
      ON CONFLICT(id) DO UPDATE SET $updates
    ''';
    
    await db.execute(sql, [id, ...row.values]);
  }

  /// Insert a new item
  Future<void> insert(T entity) async {
    final row = toRow(entity);
    final id = getId(entity);
    
    final columns = row.keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    
    final sql = '''
      INSERT INTO $tableName (id, ${columns.join(', ')})
      VALUES (?, $placeholders)
    ''';
    
    await db.execute(sql, [id, ...row.values]);
  }

  /// Update an existing item
  Future<void> update(T entity) async {
    final row = toRow(entity);
    final id = getId(entity);
    
    final updates = row.keys.map((k) => '$k = ?').join(', ');
    
    final sql = 'UPDATE $tableName SET $updates WHERE id = ?';
    await db.execute(sql, [...row.values, id]);
  }

  /// Delete an item by ID
  Future<void> delete(String id) async {
    await db.execute('DELETE FROM $tableName WHERE id = ?', [id]);
  }

  /// Delete all items
  Future<void> deleteAll() async {
    await db.execute('DELETE FROM $tableName');
  }
}

/// Repository with family scope
/// Automatically filters queries by the current user's family
abstract class FamilyScopedRepository<T> extends BaseRepository<T> {
  final String familyId;

  FamilyScopedRepository(super.db, this.familyId);

  /// Get all items for the current family
  @override
  Future<List<T>> getAll() async {
    final rows = await db.query(
      'SELECT * FROM $tableName WHERE family_id = ?',
      [familyId],
    );
    return rows.map(fromRow).toList();
  }

  /// Watch all items for the current family
  @override
  Stream<List<T>> watchAll() {
    return db.watch(
      'SELECT * FROM $tableName WHERE family_id = ?',
      [familyId],
    ).map((rows) => rows.map(fromRow).toList());
  }
}
