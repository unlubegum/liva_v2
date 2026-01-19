/// Travel Repository - PowerSync backed
///
/// Provides reactive data access for travel-related entities:
/// - Trips (trips table)
/// - Packing items (packing_items table)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/data.dart';
import '../../family/data/family_repository.dart';
import '../domain/travel_models.dart';

const _uuid = Uuid();

/// ─────────────────────────────────────────────────────────────────────────────
/// REPOSITORY PROVIDER
/// ─────────────────────────────────────────────────────────────────────────────

final travelRepositoryProvider = Provider<TravelRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TravelRepository(db);
});

/// ─────────────────────────────────────────────────────────────────────────────
/// TRAVEL REPOSITORY
/// ─────────────────────────────────────────────────────────────────────────────

class TravelRepository {
  final AppDatabase _db;

  TravelRepository(this._db);

  // ─────────────────────────────────────────────────────────────────────────
  // TRIPS
  // ─────────────────────────────────────────────────────────────────────────

  /// Watch all trips for a family
  Stream<List<Trip>> watchTrips(String familyId) {
    return _db.watch(
      'SELECT * FROM trips WHERE family_id = ? ORDER BY start_date ASC',
      [familyId],
    ).asyncMap((tripRows) async {
      final trips = <Trip>[];
      for (final row in tripRows) {
        final packingItems = await _getPackingItems(row['id'] as String);
        trips.add(_tripFromRow(row, packingItems));
      }
      return trips;
    });
  }

  /// Get a single trip by ID with packing items
  Future<Trip?> getTripById(String tripId) async {
    final rows = await _db.query(
      'SELECT * FROM trips WHERE id = ?',
      [tripId],
    );
    if (rows.isEmpty) return null;
    
    final packingItems = await _getPackingItems(tripId);
    return _tripFromRow(rows.first, packingItems);
  }

  /// Add a new trip
  Future<String> addTrip({
    required String familyId,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String emoji = '✈️',
    String? accentColorHex,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    
    await _db.execute('''
      INSERT INTO trips (id, family_id, destination, emoji, start_date, end_date, accent_color_hex, notes, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      id,
      familyId,
      destination,
      emoji,
      startDate.toIso8601String(),
      endDate.toIso8601String(),
      accentColorHex ?? '#80DEEA',
      notes,
      now,
      now,
    ]);

    return id;
  }

  /// Update a trip
  Future<void> updateTrip(String tripId, {
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? emoji,
    String? accentColorHex,
    String? notes,
  }) async {
    final updates = <String>[];
    final values = <Object?>[];

    if (destination != null) {
      updates.add('destination = ?');
      values.add(destination);
    }
    if (startDate != null) {
      updates.add('start_date = ?');
      values.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      updates.add('end_date = ?');
      values.add(endDate.toIso8601String());
    }
    if (emoji != null) {
      updates.add('emoji = ?');
      values.add(emoji);
    }
    if (accentColorHex != null) {
      updates.add('accent_color_hex = ?');
      values.add(accentColorHex);
    }
    if (notes != null) {
      updates.add('notes = ?');
      values.add(notes);
    }

    if (updates.isEmpty) return;

    updates.add('updated_at = ?');
    values.add(DateTime.now().toIso8601String());
    values.add(tripId);

    await _db.execute(
      'UPDATE trips SET ${updates.join(', ')} WHERE id = ?',
      values,
    );
  }

  /// Delete a trip and its packing items
  Future<void> deleteTrip(String tripId) async {
    await _db.execute('DELETE FROM packing_items WHERE trip_id = ?', [tripId]);
    await _db.execute('DELETE FROM trips WHERE id = ?', [tripId]);
  }

  Trip _tripFromRow(Map<String, dynamic> row, List<PackingItem> packingItems) {
    return Trip(
      id: row['id'] as String,
      destination: row['destination'] as String,
      startDate: DateTime.parse(row['start_date'] as String),
      endDate: DateTime.parse(row['end_date'] as String),
      notes: row['notes'] as String?,
      accentColor: _parseColor(row['accent_color_hex'] as String?),
      packingList: packingItems,
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF80DEEA);
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF80DEEA);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PACKING ITEMS
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<PackingItem>> _getPackingItems(String tripId) async {
    final rows = await _db.query(
      'SELECT * FROM packing_items WHERE trip_id = ? ORDER BY category, name',
      [tripId],
    );
    return rows.map(_packingItemFromRow).toList();
  }

  /// Watch packing items for a trip
  Stream<List<PackingItem>> watchPackingItems(String tripId) {
    return _db.watch(
      'SELECT * FROM packing_items WHERE trip_id = ? ORDER BY category, name',
      [tripId],
    ).map((rows) => rows.map(_packingItemFromRow).toList());
  }

  /// Add a packing item
  Future<void> addPackingItem({
    required String tripId,
    required String name,
    PackingCategory category = PackingCategory.other,
    bool isAiGenerated = false,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    
    await _db.execute('''
      INSERT INTO packing_items (id, trip_id, name, category, is_packed, is_ai_generated, created_at, updated_at)
      VALUES (?, ?, ?, ?, 0, ?, ?, ?)
    ''', [id, tripId, name, category.name, isAiGenerated ? 1 : 0, now, now]);
  }

  /// Toggle packing item packed status
  Future<void> togglePackingItem(String itemId) async {
    await _db.execute('''
      UPDATE packing_items 
      SET is_packed = CASE WHEN is_packed = 1 THEN 0 ELSE 1 END,
          updated_at = ?
      WHERE id = ?
    ''', [DateTime.now().toIso8601String(), itemId]);
  }

  /// Delete a packing item
  Future<void> deletePackingItem(String itemId) async {
    await _db.execute('DELETE FROM packing_items WHERE id = ?', [itemId]);
  }

  PackingItem _packingItemFromRow(Map<String, dynamic> row) {
    return PackingItem(
      id: row['id'] as String,
      name: row['name'] as String,
      category: _parseCategory(row['category'] as String?),
      isPacked: (row['is_packed'] as int?) == 1,
      isAutoGenerated: (row['is_ai_generated'] as int?) == 1,
    );
  }

  PackingCategory _parseCategory(String? name) {
    return PackingCategory.values.firstWhere(
      (c) => c.name == name,
      orElse: () => PackingCategory.other,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AI PACKING LIST GENERATOR
  // ─────────────────────────────────────────────────────────────────────────

  /// Generate AI packing list for a trip
  Future<void> generateAIPackingList(String tripId, String destination) async {
    final suggestions = _getPackingSuggestions(destination);
    
    // Get existing items to avoid duplicates
    final existing = await _getPackingItems(tripId);
    final existingNames = existing.map((i) => i.name.toLowerCase()).toSet();
    
    for (final item in suggestions) {
      if (!existingNames.contains(item.name.toLowerCase())) {
        await addPackingItem(
          tripId: tripId,
          name: item.name,
          category: item.category,
          isAiGenerated: true,
        );
      }
    }
  }

  List<PackingItem> _getPackingSuggestions(String destination) {
    final base = <PackingItem>[
      const PackingItem(id: '', name: 'Pasaport', category: PackingCategory.documents),
      const PackingItem(id: '', name: 'Kimlik', category: PackingCategory.documents),
      const PackingItem(id: '', name: 'Sigorta Belgesi', category: PackingCategory.documents),
      const PackingItem(id: '', name: 'Telefon Şarjı', category: PackingCategory.tech),
      const PackingItem(id: '', name: 'Powerbank', category: PackingCategory.tech),
      const PackingItem(id: '', name: 'Diş Fırçası', category: PackingCategory.toiletries),
      const PackingItem(id: '', name: 'Iç Çamaşırı (5x)', category: PackingCategory.clothes),
      const PackingItem(id: '', name: 'Çorap (5 çift)', category: PackingCategory.clothes),
    ];

    final d = destination.toLowerCase();
    
    // Winter destinations
    if (d.contains('winter') || d.contains('kış') || d.contains('ski') || d.contains('kayak')) {
      base.addAll([
        const PackingItem(id: '', name: 'Eldiven', category: PackingCategory.accessories),
        const PackingItem(id: '', name: 'Atkı', category: PackingCategory.accessories),
        const PackingItem(id: '', name: 'Bere', category: PackingCategory.accessories),
        const PackingItem(id: '', name: 'Bot', category: PackingCategory.clothes),
        const PackingItem(id: '', name: 'Kalın Ceket', category: PackingCategory.clothes),
      ]);
    }
    
    // Summer destinations
    if (d.contains('summer') || d.contains('yaz') || d.contains('beach') || d.contains('plaj')) {
      base.addAll([
        const PackingItem(id: '', name: 'Mayo', category: PackingCategory.clothes),
        const PackingItem(id: '', name: 'Güneş Kremi SPF50', category: PackingCategory.toiletries),
        const PackingItem(id: '', name: 'Güneş Gözlüğü', category: PackingCategory.accessories),
        const PackingItem(id: '', name: 'Şapka', category: PackingCategory.accessories),
      ]);
    }

    // Cappadocia
    if (d.contains('cappadocia') || d.contains('kapadokya')) {
      base.addAll([
        const PackingItem(id: '', name: 'Fotoğraf Makinesi', category: PackingCategory.tech),
        const PackingItem(id: '', name: 'Rahat Yürüyüş Ayakkabısı', category: PackingCategory.clothes),
      ]);
    }

    return base;
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// STATE PROVIDERS
/// ─────────────────────────────────────────────────────────────────────────────

/// Watch all trips stream
final tripsStreamProvider = StreamProvider<List<Trip>>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId == null) return Stream.value([]);
  
  final repo = ref.watch(travelRepositoryProvider);
  return repo.watchTrips(familyId);
});

/// Upcoming trip (next trip chronologically)
final upcomingTripProvider = Provider<Trip?>((ref) {
  final tripsAsync = ref.watch(tripsStreamProvider);
  return tripsAsync.when(
    data: (trips) {
      final upcoming = trips.where((t) => t.isUpcoming).toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
      return upcoming.isNotEmpty ? upcoming.first : null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Past trips
final pastTripsProvider = Provider<List<Trip>>((ref) {
  final tripsAsync = ref.watch(tripsStreamProvider);
  return tripsAsync.when(
    data: (trips) => trips.where((t) => t.isPast).toList()
      ..sort((a, b) => b.endDate.compareTo(a.endDate)),
    loading: () => [],
    error: (_, __) => [],
  );
});
