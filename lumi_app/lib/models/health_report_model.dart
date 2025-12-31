import 'package:flutter/material.dart';

class WeightEntry {
  final int week;
  final double weight;
  final DateTime date;

  const WeightEntry({
    required this.week,
    required this.weight,
    required this.date,
  });
}

enum HealthEventType {
  doctorVisit,
  labResult,
  note,
  ultrasound,
}

class HealthEvent {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final HealthEventType type;
  final Color accentColor;

  const HealthEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.type,
    required this.accentColor,
  });
}

class HealthReportModel {
  final List<WeightEntry> weightHistory;
  final double currentWeight;
  final double startWeight;
  final int todayWaterGlasses;
  final int waterGoal;
  final int todayKickCount;
  final List<HealthEvent> healthEvents;

  const HealthReportModel({
    required this.weightHistory,
    required this.currentWeight,
    required this.startWeight,
    required this.todayWaterGlasses,
    required this.waterGoal,
    required this.todayKickCount,
    required this.healthEvents,
  });

  double get totalWeightGain => currentWeight - startWeight;

  // Demo data
  static HealthReportModel demo = HealthReportModel(
    currentWeight: 62.5,
    startWeight: 58.0,
    todayWaterGlasses: 5,
    waterGoal: 8,
    todayKickCount: 12,
    weightHistory: [
      WeightEntry(week: 8, weight: 58.5, date: DateTime.now().subtract(const Duration(days: 56))),
      WeightEntry(week: 10, weight: 59.0, date: DateTime.now().subtract(const Duration(days: 42))),
      WeightEntry(week: 12, weight: 59.8, date: DateTime.now().subtract(const Duration(days: 28))),
      WeightEntry(week: 14, weight: 61.0, date: DateTime.now().subtract(const Duration(days: 14))),
      WeightEntry(week: 16, weight: 62.5, date: DateTime.now()),
    ],
    healthEvents: [
      HealthEvent(
        id: '1',
        title: 'Ultrason Kontrolü',
        subtitle: 'Dr. Ayşe Yılmaz - Detaylı ultrason',
        date: DateTime.now().subtract(const Duration(days: 3)),
        type: HealthEventType.ultrasound,
        accentColor: const Color(0xFFA855F7),
      ),
      HealthEvent(
        id: '2',
        title: 'Kan Tahlili',
        subtitle: 'Hemogram, Demir, B12 - Sonuçlar normal',
        date: DateTime.now().subtract(const Duration(days: 10)),
        type: HealthEventType.labResult,
        accentColor: const Color(0xFF0EA5E9),
      ),
      HealthEvent(
        id: '3',
        title: 'Doktor Kontrolü',
        subtitle: 'Rutin kontrol - Her şey yolunda',
        date: DateTime.now().subtract(const Duration(days: 17)),
        type: HealthEventType.doctorVisit,
        accentColor: const Color(0xFFEC4899),
      ),
      HealthEvent(
        id: '4',
        title: 'Kişisel Not',
        subtitle: 'İlk bebek hareketlerini hissettim!',
        date: DateTime.now().subtract(const Duration(days: 21)),
        type: HealthEventType.note,
        accentColor: const Color(0xFF22C55E),
      ),
    ],
  );
}
