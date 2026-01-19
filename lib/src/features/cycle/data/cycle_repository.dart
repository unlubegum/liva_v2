import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cycle_models.dart';

/// Cycle Repository Provider
final cycleRepositoryProvider = Provider<CycleRepository>((ref) => CycleRepository());

class CycleRepository {
  CycleStats getStats() {
    final now = DateTime.now();
    return CycleStats(
      averageCycleLength: 28,
      averagePeriodLength: 5,
      nextPeriodDate: now.add(const Duration(days: 12)),
      ovulationDate: now.subtract(const Duration(days: 2)),
      fertileWindow: List.generate(6, (i) => now.subtract(Duration(days: 5 - i))),
    );
  }

  Cycle getCurrentCycle() {
    final now = DateTime.now();
    return Cycle(
      id: 'cycle1',
      startDate: now.subtract(const Duration(days: 16)),
      lengthDays: 28,
    );
  }

  List<DailyLog> getRecentLogs() {
    final now = DateTime.now();
    return [
      DailyLog(date: now, mood: Mood.calm, symptoms: [SymptomType.fatigue]),
      DailyLog(date: now.subtract(const Duration(days: 1)), mood: Mood.happy),
      DailyLog(date: now.subtract(const Duration(days: 2)), mood: Mood.energetic),
      DailyLog(date: now.subtract(const Duration(days: 14)), isFlowDay: true, flowIntensity: 4, mood: Mood.tired, symptoms: [SymptomType.cramps, SymptomType.headache]),
      DailyLog(date: now.subtract(const Duration(days: 15)), isFlowDay: true, flowIntensity: 5, mood: Mood.irritated, symptoms: [SymptomType.cramps, SymptomType.backPain, SymptomType.moodSwings]),
      DailyLog(date: now.subtract(const Duration(days: 16)), isFlowDay: true, flowIntensity: 3, mood: Mood.sad, symptoms: [SymptomType.cramps]),
    ];
  }
}

/// Mevcut döngü provider
final currentCycleProvider = Provider<Cycle>((ref) {
  final repo = ref.watch(cycleRepositoryProvider);
  return repo.getCurrentCycle();
});

/// İstatistikler provider
final cycleStatsProvider = Provider<CycleStats>((ref) {
  final repo = ref.watch(cycleRepositoryProvider);
  return repo.getStats();
});

/// Günlük kayıtlar provider
final dailyLogsProvider = StateNotifierProvider<DailyLogsNotifier, List<DailyLog>>((ref) {
  final repo = ref.watch(cycleRepositoryProvider);
  return DailyLogsNotifier(repo.getRecentLogs());
});

class DailyLogsNotifier extends StateNotifier<List<DailyLog>> {
  DailyLogsNotifier(super.initial);

  void addLog(DailyLog log) {
    // Aynı gün için log varsa güncelle
    final existing = state.indexWhere((l) => _isSameDay(l.date, log.date));
    if (existing >= 0) {
      state = [...state]..[ existing] = log;
    } else {
      state = [log, ...state];
    }
  }

  void toggleFlowDay(DateTime date) {
    final existing = state.indexWhere((l) => _isSameDay(l.date, date));
    if (existing >= 0) {
      final log = state[existing];
      state = [...state]..[existing] = log.copyWith(isFlowDay: !log.isFlowDay, flowIntensity: log.isFlowDay ? 0 : 3);
    } else {
      state = [DailyLog(date: date, isFlowDay: true, flowIntensity: 3), ...state];
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Bugünün logu
final todayLogProvider = Provider<DailyLog?>((ref) {
  final logs = ref.watch(dailyLogsProvider);
  final now = DateTime.now();
  try {
    return logs.firstWhere((l) => DailyLogsNotifier._isSameDay(l.date, now));
  } catch (_) {
    return null;
  }
});
