/// Family Repository - PowerSync backed
///
/// Provides reactive data access for family-related entities:
/// - Family tasks (family_tasks table)
/// - Shopping items (shopping_items table)
/// - Family members via profiles (profiles table)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/data.dart';
import '../domain/family_models.dart';

const _uuid = Uuid();

/// ─────────────────────────────────────────────────────────────────────────────
/// REPOSITORY PROVIDER
/// ─────────────────────────────────────────────────────────────────────────────

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FamilyRepository(db);
});

/// ─────────────────────────────────────────────────────────────────────────────
/// FAMILY REPOSITORY
/// ─────────────────────────────────────────────────────────────────────────────

class FamilyRepository {
  final AppDatabase _db;

  FamilyRepository(this._db);

  // ─────────────────────────────────────────────────────────────────────────
  // FAMILY MEMBERS (from profiles table)
  // ─────────────────────────────────────────────────────────────────────────

  /// Watch all family members (profiles with same family_id as current user)
  Stream<List<FamilyMember>> watchMembers(String familyId) {
    return _db.watch(
      'SELECT * FROM profiles WHERE family_id = ?',
      [familyId],
    ).map((rows) => rows.map(_memberFromRow).toList());
  }

  /// Get member by ID
  Future<FamilyMember?> getMemberById(String id) async {
    final rows = await _db.query(
      'SELECT * FROM profiles WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return _memberFromRow(rows.first);
  }

  FamilyMember _memberFromRow(Map<String, dynamic> row) {
    return FamilyMember(
      id: row['id'] as String,
      name: row['full_name'] as String? ?? 'Üye',
      avatarUrl: row['avatar_url'] as String? ?? '',
      role: row['role'] as String? ?? 'member',
      avatarColor: _colorFromRole(row['role'] as String?),
    );
  }

  Color _colorFromRole(String? role) {
    switch (role) {
      case 'admin':
        return const Color(0xFFF48FB1);
      case 'parent':
        return const Color(0xFF64B5F6);
      case 'child':
        return const Color(0xFFFFCC80);
      default:
        return const Color(0xFFB39DDB);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FAMILY TASKS
  // ─────────────────────────────────────────────────────────────────────────

  /// Watch all tasks for a family
  Stream<List<FamilyTask>> watchTasks(String familyId) {
    return _db.watch(
      'SELECT * FROM family_tasks WHERE family_id = ? ORDER BY created_at DESC',
      [familyId],
    ).map((rows) => rows.map(_taskFromRow).toList());
  }

  /// Add a new task
  Future<void> addTask({
    required String familyId,
    required String title,
    String? description,
    String? assignedToId,
    DateTime? dueDate,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    
    await _db.execute('''
      INSERT INTO family_tasks (id, family_id, title, description, assigned_to_id, due_date, is_completed, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, 0, ?, ?)
    ''', [id, familyId, title, description, assignedToId, dueDate?.toIso8601String(), now, now]);
  }

  /// Toggle task completion
  Future<void> toggleTask(String taskId) async {
    await _db.execute('''
      UPDATE family_tasks 
      SET is_completed = CASE WHEN is_completed = 1 THEN 0 ELSE 1 END,
          updated_at = ?
      WHERE id = ?
    ''', [DateTime.now().toIso8601String(), taskId]);
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    await _db.execute('DELETE FROM family_tasks WHERE id = ?', [taskId]);
  }

  FamilyTask _taskFromRow(Map<String, dynamic> row) {
    return FamilyTask(
      id: row['id'] as String,
      title: row['title'] as String,
      isCompleted: (row['is_completed'] as int?) == 1,
      assignedToId: row['assigned_to_id'] as String? ?? '',
      dueDate: row['due_date'] != null 
          ? DateTime.tryParse(row['due_date'] as String) 
          : null,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHOPPING ITEMS
  // ─────────────────────────────────────────────────────────────────────────

  /// Watch all shopping items for a family
  Stream<List<ShoppingItem>> watchShoppingItems(String familyId) {
    return _db.watch(
      'SELECT * FROM shopping_items WHERE family_id = ? ORDER BY created_at DESC',
      [familyId],
    ).map((rows) => rows.map(_shoppingItemFromRow).toList());
  }

  /// Add a shopping item
  Future<void> addShoppingItem({
    required String familyId,
    required String name,
    int quantity = 1,
    String? addedById,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    
    await _db.execute('''
      INSERT INTO shopping_items (id, family_id, name, quantity, is_purchased, added_by_id, created_at, updated_at)
      VALUES (?, ?, ?, ?, 0, ?, ?, ?)
    ''', [id, familyId, name, quantity, addedById, now, now]);
  }

  /// Toggle shopping item purchased status
  Future<void> toggleShoppingItem(String itemId) async {
    await _db.execute('''
      UPDATE shopping_items 
      SET is_purchased = CASE WHEN is_purchased = 1 THEN 0 ELSE 1 END,
          updated_at = ?
      WHERE id = ?
    ''', [DateTime.now().toIso8601String(), itemId]);
  }

  /// Delete a shopping item
  Future<void> deleteShoppingItem(String itemId) async {
    await _db.execute('DELETE FROM shopping_items WHERE id = ?', [itemId]);
  }

  ShoppingItem _shoppingItemFromRow(Map<String, dynamic> row) {
    return ShoppingItem(
      id: row['id'] as String,
      name: row['name'] as String,
      isCompleted: (row['is_purchased'] as int?) == 1,
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// STATE NOTIFIER PROVIDERS (for UI state management)
/// ─────────────────────────────────────────────────────────────────────────────

/// Provider for current user's family ID
/// This should be populated from auth state or set manually for testing
final currentFamilyIdProvider = StateProvider<String?>((ref) {
  // ══════════════════════════════════════════════════════════════════════════
  // 🧪 TEST MODE: Supabase'den aldığın family ID'yi buraya yaz!
  // Supabase Dashboard > Table Editor > families > herhangi bir satırın id'si
  // Örnek: 'd290f1ee-6c54-4b01-90e6-d701748f0851'
  // ══════════════════════════════════════════════════════════════════════════
  return null; // null = demo mode (dummy data)
});

/// Watch family tasks stream
final familyTasksStreamProvider = StreamProvider.autoDispose<List<FamilyTask>>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  final repo = ref.watch(familyRepositoryProvider);
  
  // Eğer family ID yoksa demo data göster
  if (familyId == null) {
    return Stream.value([
      const FamilyTask(id: '1', title: 'Çöp atmak', isCompleted: false, assignedToId: 'dad'),
      const FamilyTask(id: '2', title: 'Bulaşıkları yıkamak', isCompleted: true, assignedToId: 'mom'),
      const FamilyTask(id: '3', title: 'Ödev yapmak', isCompleted: false, assignedToId: 'child'),
    ]);
  }
  
  // Gerçek family ID varsa veritabanından çek
  return repo.watchTasks(familyId);
});

/// Watch shopping items stream
final shoppingItemsStreamProvider = StreamProvider<List<ShoppingItem>>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId == null) return Stream.value([]);
  
  final repo = ref.watch(familyRepositoryProvider);
  return repo.watchShoppingItems(familyId);
});

/// Watch family members stream
final familyMembersStreamProvider = StreamProvider<List<FamilyMember>>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId == null) return Stream.value([]);
  
  final repo = ref.watch(familyRepositoryProvider);
  return repo.watchMembers(familyId);
});

// ═══════════════════════════════════════════════════════════════════════════════
// BACKWARD COMPATIBILITY - Legacy sync methods for gradual migration
// These will be removed once all screens are updated to use stream providers
// ═══════════════════════════════════════════════════════════════════════════════

/// Legacy: Get members synchronously (returns demo data when offline)
extension FamilyRepositoryLegacy on FamilyRepository {
  /// Demo family members for offline/demo mode
  List<FamilyMember> getMembers() {
    return const [
      FamilyMember(
        id: 'mom',
        name: 'Anne',
        avatarUrl: '',
        role: 'Aile Reisi',
        avatarColor: Color(0xFFF48FB1),
      ),
      FamilyMember(
        id: 'dad',
        name: 'Baba',
        avatarUrl: '',
        role: 'Aile Reisi',
        avatarColor: Color(0xFF64B5F6),
      ),
      FamilyMember(
        id: 'child',
        name: 'Elif',
        avatarUrl: '',
        role: 'Çocuk',
        avatarColor: Color(0xFFFFCC80),
      ),
      FamilyMember(
        id: 'cat',
        name: 'Pamuk',
        avatarUrl: '',
        role: 'Kedi 🐱',
        avatarColor: Color(0xFFB39DDB),
      ),
    ];
  }

  /// Demo wall notes for offline/demo mode
  List<WallNote> getWallNotes() {
    return [
      WallNote(
        id: '1',
        content: '📶 WiFi Şifresi:\nYilmaz2024!',
        color: const Color(0xFFFFF59D),
        createdAt: DateTime.now(),
      ),
      WallNote(
        id: '2',
        content: '🍽️ Akşam yemeği saat 8\'de!',
        color: const Color(0xFFFFCC80),
        createdAt: DateTime.now(),
      ),
      WallNote(
        id: '3',
        content: '📞 Doktor randevusu:\nCuma 14:00',
        color: const Color(0xFFA5D6A7),
        createdAt: DateTime.now(),
      ),
      WallNote(
        id: '4',
        content: '🎂 Elif\'in doğum günü:\n25 Ocak',
        color: const Color(0xFFF8BBD9),
        createdAt: DateTime.now(),
      ),
      WallNote(
        id: '5',
        content: '🏠 Kira ödemesi:\nHer ayın 5\'i',
        color: const Color(0xFF90CAF9),
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Get member by ID from demo data
  FamilyMember? getMemberById(String id) {
    final members = getMembers();
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Legacy: Family tasks state notifier (demo mode)
final familyTasksProvider = StateNotifierProvider<FamilyTasksNotifier, List<FamilyTask>>((ref) {
  return FamilyTasksNotifier(_getDemoTasks());
});

List<FamilyTask> _getDemoTasks() {
  return const [
    FamilyTask(id: '1', title: 'Çöp atmak', isCompleted: false, assignedToId: 'dad'),
    FamilyTask(id: '2', title: 'Bulaşıkları yıkamak', isCompleted: true, assignedToId: 'mom'),
    FamilyTask(id: '3', title: 'Ödev yapmak', isCompleted: false, assignedToId: 'child'),
    FamilyTask(id: '4', title: 'Alışverişe gitmek', isCompleted: false, assignedToId: 'mom'),
    FamilyTask(id: '5', title: 'Araba yıkamak', isCompleted: false, assignedToId: 'dad'),
    FamilyTask(id: '6', title: 'Kedi mamasını değiştirmek', isCompleted: true, assignedToId: 'child'),
  ];
}

class FamilyTasksNotifier extends StateNotifier<List<FamilyTask>> {
  FamilyTasksNotifier(super.initial);

  void toggleTask(String taskId) {
    state = state.map((task) {
      if (task.id == taskId) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();
  }
}

/// Legacy: Shopping list state notifier (demo mode)
final shoppingListProvider = StateNotifierProvider<ShoppingListNotifier, List<ShoppingItem>>((ref) {
  return ShoppingListNotifier(_getDemoShoppingList());
});

List<ShoppingItem> _getDemoShoppingList() {
  return const [
    ShoppingItem(id: '1', name: 'Süt', isCompleted: false),
    ShoppingItem(id: '2', name: 'Ekmek', isCompleted: true),
    ShoppingItem(id: '3', name: 'Yumurta', isCompleted: false),
    ShoppingItem(id: '4', name: 'Pil', isCompleted: false),
    ShoppingItem(id: '5', name: 'Deterjan', isCompleted: true),
    ShoppingItem(id: '6', name: 'Kedi maması', isCompleted: false),
    ShoppingItem(id: '7', name: 'Meyve', isCompleted: false),
  ];
}

class ShoppingListNotifier extends StateNotifier<List<ShoppingItem>> {
  ShoppingListNotifier(super.initial);

  void toggleItem(String itemId) {
    state = state.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();
  }
}

