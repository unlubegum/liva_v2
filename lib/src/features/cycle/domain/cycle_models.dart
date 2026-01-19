import 'package:flutter/material.dart';

/// Döngü fazları
enum CyclePhase { menstruation, follicular, ovulation, luteal }

/// Semptom türleri
enum SymptomType { cramps, headache, fatigue, moodSwings, bloating, backPain, acne, breastTenderness }

/// Ruh hali
enum Mood { happy, calm, anxious, sad, irritated, energetic, tired }

/// Günlük kayıt
class DailyLog {
  final DateTime date;
  final bool isFlowDay;
  final int flowIntensity; // 1-5
  final List<SymptomType> symptoms;
  final Mood? mood;
  final String? note;
  final double? temperature; // Bazal vücut sıcaklığı

  const DailyLog({
    required this.date,
    this.isFlowDay = false,
    this.flowIntensity = 0,
    this.symptoms = const [],
    this.mood,
    this.note,
    this.temperature,
  });

  DailyLog copyWith({
    DateTime? date, bool? isFlowDay, int? flowIntensity,
    List<SymptomType>? symptoms, Mood? mood, String? note, double? temperature,
  }) => DailyLog(
    date: date ?? this.date, isFlowDay: isFlowDay ?? this.isFlowDay,
    flowIntensity: flowIntensity ?? this.flowIntensity, symptoms: symptoms ?? this.symptoms,
    mood: mood ?? this.mood, note: note ?? this.note, temperature: temperature ?? this.temperature,
  );
}

/// Döngü modeli
class Cycle {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int lengthDays;

  const Cycle({
    required this.id,
    required this.startDate,
    this.endDate,
    this.lengthDays = 28,
  });

  bool get isActive => endDate == null;
  int get currentDay => isActive ? DateTime.now().difference(startDate).inDays + 1 : lengthDays;
  double get progress => currentDay / lengthDays;

  CyclePhase get currentPhase {
    final day = currentDay;
    if (day <= 5) return CyclePhase.menstruation;
    if (day <= 13) return CyclePhase.follicular;
    if (day <= 16) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }
}

/// Döngü istatistikleri
class CycleStats {
  final int averageCycleLength;
  final int averagePeriodLength;
  final DateTime? nextPeriodDate;
  final DateTime? ovulationDate;
  final List<DateTime> fertileWindow;

  const CycleStats({
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.nextPeriodDate,
    this.ovulationDate,
    this.fertileWindow = const [],
  });

  int get daysUntilPeriod => nextPeriodDate?.difference(DateTime.now()).inDays ?? 0;
  bool get isInFertileWindow => fertileWindow.any((d) => _isSameDay(d, DateTime.now()));

  static bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Extension'lar
extension CyclePhaseExtension on CyclePhase {
  String get label => switch (this) {
    CyclePhase.menstruation => 'Adet Dönemi',
    CyclePhase.follicular => 'Foliküler Faz',
    CyclePhase.ovulation => 'Yumurtlama',
    CyclePhase.luteal => 'Luteal Faz',
  };

  Color get color => switch (this) {
    CyclePhase.menstruation => const Color(0xFFE74C3C),
    CyclePhase.follicular => const Color(0xFF3498DB),
    CyclePhase.ovulation => const Color(0xFF2ECC71),
    CyclePhase.luteal => const Color(0xFF9B59B6),
  };

  IconData get icon => switch (this) {
    CyclePhase.menstruation => Icons.water_drop_rounded,
    CyclePhase.follicular => Icons.spa_rounded,
    CyclePhase.ovulation => Icons.favorite_rounded,
    CyclePhase.luteal => Icons.nights_stay_rounded,
  };
}

extension SymptomExtension on SymptomType {
  String get label => switch (this) {
    SymptomType.cramps => 'Kramp',
    SymptomType.headache => 'Baş Ağrısı',
    SymptomType.fatigue => 'Yorgunluk',
    SymptomType.moodSwings => 'Duygu Değişimi',
    SymptomType.bloating => 'Şişkinlik',
    SymptomType.backPain => 'Bel Ağrısı',
    SymptomType.acne => 'Akne',
    SymptomType.breastTenderness => 'Göğüs Hassasiyeti',
  };

  IconData get icon => switch (this) {
    SymptomType.cramps => Icons.flash_on_rounded,
    SymptomType.headache => Icons.psychology_rounded,
    SymptomType.fatigue => Icons.battery_2_bar_rounded,
    SymptomType.moodSwings => Icons.mood_rounded,
    SymptomType.bloating => Icons.bubble_chart_rounded,
    SymptomType.backPain => Icons.accessibility_new_rounded,
    SymptomType.acne => Icons.face_rounded,
    SymptomType.breastTenderness => Icons.favorite_border_rounded,
  };
}

extension MoodExtension on Mood {
  String get label => switch (this) {
    Mood.happy => 'Mutlu',
    Mood.calm => 'Sakin',
    Mood.anxious => 'Endişeli',
    Mood.sad => 'Üzgün',
    Mood.irritated => 'Sinirli',
    Mood.energetic => 'Enerjik',
    Mood.tired => 'Yorgun',
  };

  String get emoji => switch (this) {
    Mood.happy => '😊',
    Mood.calm => '😌',
    Mood.anxious => '😰',
    Mood.sad => '😢',
    Mood.irritated => '😤',
    Mood.energetic => '💪',
    Mood.tired => '😴',
  };
}
