import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/database_provider.dart';
import 'family_repository.dart';

// --- MODEL ---
class FamilyNote {
  final String id;
  final String content;
  final String? authorId;
  final DateTime createdAt;

  FamilyNote({
    required this.id,
    required this.content,
    this.authorId,
    required this.createdAt,
  });

  factory FamilyNote.fromRow(Map<String, dynamic> row) {
    return FamilyNote(
      id: row['id'] as String,
      content: row['content'] as String,
      authorId: row['author_id'] as String?,
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

// --- REPOSITORY ---
class WallRepository {
  final AppDatabase _db;
  
  WallRepository(this._db);

  /// Watch all notes for a family
  Stream<List<FamilyNote>> watchNotes(String familyId) {
    return _db.watch(
      'SELECT * FROM family_wall WHERE family_id = ? ORDER BY created_at DESC',
      [familyId],
    ).map((rows) => rows.map((row) => FamilyNote.fromRow(row)).toList());
  }

  /// Add a new note
  Future<void> addNote(String familyId, String content) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();
    
    await _db.execute(
      'INSERT INTO family_wall (id, family_id, content, created_at) VALUES (?, ?, ?, ?)',
      [id, familyId, content, now],
    );
  }
  
  /// Delete a note
  Future<void> deleteNote(String id) async {
    await _db.execute('DELETE FROM family_wall WHERE id = ?', [id]);
  }
}

// --- PROVIDERS ---
final wallRepositoryProvider = Provider<WallRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return WallRepository(db);
});

final wallStreamProvider = StreamProvider.autoDispose<List<FamilyNote>>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId == null) return Stream.value([]);
  return ref.watch(wallRepositoryProvider).watchNotes(familyId);
});
