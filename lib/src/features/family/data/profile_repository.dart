import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/database_provider.dart';
import 'family_repository.dart';

// --- MODEL ---
class Profile {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? role;

  Profile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.role,
  });

  factory Profile.fromRow(Map<String, dynamic> row) {
    return Profile(
      id: row['id'] as String,
      fullName: row['full_name'] as String?,
      avatarUrl: row['avatar_url'] as String?,
      role: row['role'] as String?,
    );
  }
  
  String get displayName => fullName ?? 'Üye';
  String get initial => displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
}

// --- REPOSITORY ---
class ProfileRepository {
  final AppDatabase _db;
  
  ProfileRepository(this._db);

  /// Watch all family members
  Stream<List<Profile>> watchFamilyMembers(String familyId) {
    return _db.watch(
      'SELECT * FROM profiles WHERE family_id = ? ORDER BY created_at ASC',
      [familyId],
    ).map((rows) => rows.map((row) => Profile.fromRow(row)).toList());
  }
  
  /// Get single profile by ID
  Future<Profile?> getProfileById(String id) async {
    final rows = await _db.query('SELECT * FROM profiles WHERE id = ?', [id]);
    if (rows.isEmpty) return null;
    return Profile.fromRow(rows.first);
  }
}

// --- PROVIDERS ---
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProfileRepository(db);
});

/// Stream of family members
final familyMembersProvider = StreamProvider.autoDispose<List<Profile>>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId == null) return Stream.value([]);
  return ref.watch(profileRepositoryProvider).watchFamilyMembers(familyId);
});

/// Selected user filter for task list (null = show all)
final selectedUserFilterProvider = StateProvider<String?>((ref) => null);
