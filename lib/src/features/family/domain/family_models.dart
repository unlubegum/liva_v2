import 'dart:ui';

/// Family domain models

/// Aile üyesi modeli
class FamilyMember {
  final String id;
  final String name;
  final String avatarUrl;
  final String role;
  final Color avatarColor;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.role,
    required this.avatarColor,
  });
}

/// Aile görevi modeli
class FamilyTask {
  final String id;
  final String? familyId;
  final String title;
  final bool isCompleted;
  final String assignedToId;
  final DateTime? dueDate;

  const FamilyTask({
    required this.id,
    this.familyId,
    required this.title,
    this.isCompleted = false,
    required this.assignedToId,
    this.dueDate,
  });

  /// Veritabanından (SQL Row) gelen veriyi Dart objesine çevir
  factory FamilyTask.fromRow(Map<String, dynamic> row) {
    return FamilyTask(
      id: row['id'] as String,
      familyId: row['family_id'] as String?,
      title: row['title'] as String,
      isCompleted: (row['is_completed'] as int?) == 1,
      assignedToId: row['assigned_to_id'] as String? ?? '',
      dueDate: row['due_date'] != null 
          ? DateTime.tryParse(row['due_date'] as String) 
          : null,
    );
  }

  /// Dart objesini veritabanına kaydetmek için Map'e çevir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'family_id': familyId,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
      'assigned_to_id': assignedToId,
      'due_date': dueDate?.toIso8601String(),
    };
  }

  FamilyTask copyWith({
    String? id,
    String? familyId,
    String? title,
    bool? isCompleted,
    String? assignedToId,
    DateTime? dueDate,
  }) {
    return FamilyTask(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      assignedToId: assignedToId ?? this.assignedToId,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

/// Alışveriş listesi öğesi
class ShoppingItem {
  final String id;
  final String name;
  final bool isCompleted;

  const ShoppingItem({
    required this.id,
    required this.name,
    this.isCompleted = false,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? isCompleted,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Pano notu modeli
class WallNote {
  final String id;
  final String content;
  final Color color;
  final DateTime createdAt;

  const WallNote({
    required this.id,
    required this.content,
    required this.color,
    required this.createdAt,
  });
}
