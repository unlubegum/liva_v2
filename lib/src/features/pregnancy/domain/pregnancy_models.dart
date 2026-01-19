import 'package:flutter/material.dart';

/// Hamilelik haftası bilgisi
class PregnancyWeek {
  final int week;
  final String babySize; // Karşılaştırma
  final double babyWeight; // gram
  final double babyLength; // cm
  final String babyDevelopment;
  final List<String> tips;
  final List<String> symptoms;

  const PregnancyWeek({
    required this.week,
    required this.babySize,
    required this.babyWeight,
    required this.babyLength,
    required this.babyDevelopment,
    this.tips = const [],
    this.symptoms = const [],
  });
}

/// Trimester
enum Trimester { first, second, third }

/// Randevu türleri
enum AppointmentType { checkup, ultrasound, bloodTest, glucose, other }

/// Randevu
class Appointment {
  final String id;
  final AppointmentType type;
  final DateTime date;
  final String doctor;
  final String? location;
  final String? note;
  final bool isCompleted;

  const Appointment({
    required this.id,
    required this.type,
    required this.date,
    required this.doctor,
    this.location,
    this.note,
    this.isCompleted = false,
  });

  String get typeLabel => switch (type) {
    AppointmentType.checkup => 'Kontrol',
    AppointmentType.ultrasound => 'Ultrason',
    AppointmentType.bloodTest => 'Kan Testi',
    AppointmentType.glucose => 'Şeker Yükleme',
    AppointmentType.other => 'Diğer',
  };

  IconData get typeIcon => switch (type) {
    AppointmentType.checkup => Icons.medical_services_rounded,
    AppointmentType.ultrasound => Icons.pregnant_woman_rounded,
    AppointmentType.bloodTest => Icons.bloodtype_rounded,
    AppointmentType.glucose => Icons.science_rounded,
    AppointmentType.other => Icons.event_rounded,
  };

  Color get typeColor => switch (type) {
    AppointmentType.checkup => const Color(0xFF3498DB),
    AppointmentType.ultrasound => const Color(0xFFE879F9),
    AppointmentType.bloodTest => const Color(0xFFE74C3C),
    AppointmentType.glucose => const Color(0xFFFBBF24),
    AppointmentType.other => const Color(0xFF9B59B6),
  };
}

/// Hamilelik durumu
class PregnancyStatus {
  final DateTime dueDate;
  final DateTime lastPeriod;
  final int currentWeek;
  final int currentDay;
  final List<Appointment> appointments;

  const PregnancyStatus({
    required this.dueDate,
    required this.lastPeriod,
    required this.currentWeek,
    required this.currentDay,
    this.appointments = const [],
  });

  Trimester get trimester {
    if (currentWeek <= 12) return Trimester.first;
    if (currentWeek <= 27) return Trimester.second;
    return Trimester.third;
  }

  String get trimesterLabel => switch (trimester) {
    Trimester.first => '1. Trimester',
    Trimester.second => '2. Trimester',
    Trimester.third => '3. Trimester',
  };

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  int get weeksUntilDue => (daysUntilDue / 7).floor();
  double get progress => currentWeek / 40;

  Appointment? get nextAppointment {
    final upcoming = appointments.where((a) => !a.isCompleted && a.date.isAfter(DateTime.now())).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }
}

/// Haftalık veri
const pregnancyWeeksData = <int, PregnancyWeek>{
  16: PregnancyWeek(
    week: 16,
    babySize: 'Avokado',
    babyWeight: 100,
    babyLength: 11.6,
    babyDevelopment: 'Bebeğiniz artık yüz ifadeleri yapabiliyor! Gözleri hareket etmeye başladı.',
    tips: ['Rahat kıyafetler giyin', 'Düzenli yürüyüşler yapın', 'Bol su için'],
    symptoms: ['Burun tıkanıklığı', 'Artan enerji', 'Bebek hareketleri'],
  ),
  20: PregnancyWeek(
    week: 20,
    babySize: 'Muz',
    babyWeight: 300,
    babyLength: 16.4,
    babyDevelopment: 'Yarı yoldasınız! Bebek artık sesleri duyabiliyor.',
    tips: ['Detaylı ultrason yaptırın', 'Bebek odası planlamaya başlayın'],
    symptoms: ['Bebek tekmeleri', 'Kramplar', 'Sırt ağrısı'],
  ),
  24: PregnancyWeek(
    week: 24,
    babySize: 'Mısır Koçanı',
    babyWeight: 600,
    babyLength: 30,
    babyDevelopment: 'Akciğerler gelişiyor. Bebek uyku-uyanıklık döngüsüne başladı.',
    tips: ['Şeker yükleme testi yaptırın', 'Doğum hazırlık kursuna yazılın'],
    symptoms: ['Yorgunluk', 'Şişkinlik', 'Bacak krampları'],
  ),
};
