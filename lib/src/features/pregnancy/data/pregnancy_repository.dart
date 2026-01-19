import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/pregnancy_models.dart';

/// Pregnancy Repository Provider
final pregnancyRepositoryProvider = Provider<PregnancyRepository>((ref) => PregnancyRepository());

class PregnancyRepository {
  PregnancyStatus getStatus() {
    final now = DateTime.now();
    return PregnancyStatus(
      dueDate: now.add(const Duration(days: 168)), // 24 hafta sonra
      lastPeriod: now.subtract(const Duration(days: 112)), // 16 hafta önce
      currentWeek: 16,
      currentDay: 3,
      appointments: [
        Appointment(id: '1', type: AppointmentType.ultrasound, date: now.add(const Duration(days: 7)), doctor: 'Dr. Ayşe Yılmaz', location: 'Özel Hastane', note: '20. hafta detaylı ultrason'),
        Appointment(id: '2', type: AppointmentType.bloodTest, date: now.add(const Duration(days: 14)), doctor: 'Dr. Mehmet Demir', location: 'Laboratuvar'),
        Appointment(id: '3', type: AppointmentType.glucose, date: now.add(const Duration(days: 56)), doctor: 'Dr. Ayşe Yılmaz', note: 'Şeker yükleme testi'),
        Appointment(id: '4', type: AppointmentType.checkup, date: now.subtract(const Duration(days: 7)), doctor: 'Dr. Ayşe Yılmaz', isCompleted: true),
      ],
    );
  }

  PregnancyWeek? getWeekInfo(int week) => pregnancyWeeksData[week];
}

/// Hamilelik durumu provider
final pregnancyStatusProvider = Provider<PregnancyStatus>((ref) {
  final repo = ref.watch(pregnancyRepositoryProvider);
  return repo.getStatus();
});

/// Mevcut hafta bilgisi provider
final currentWeekInfoProvider = Provider<PregnancyWeek?>((ref) {
  final status = ref.watch(pregnancyStatusProvider);
  final repo = ref.watch(pregnancyRepositoryProvider);
  return repo.getWeekInfo(status.currentWeek);
});

/// Yaklaşan randevular provider
final upcomingAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final status = ref.watch(pregnancyStatusProvider);
  return status.appointments.where((a) => !a.isCompleted && a.date.isAfter(DateTime.now())).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});
