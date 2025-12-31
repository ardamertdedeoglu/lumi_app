class PregnancyModel {
  final int currentWeek;
  final int currentDay;
  final int daysUntilBirth;
  final DateTime expectedDueDate;
  final String babySize;
  final String babySizeDescription;
  final String aiInsightMessage;

  const PregnancyModel({
    required this.currentWeek,
    required this.currentDay,
    required this.daysUntilBirth,
    required this.expectedDueDate,
    required this.babySize,
    required this.babySizeDescription,
    required this.aiInsightMessage,
  });

  String get weekLabel => '$currentWeek. Hafta';
  String get daysLabel => '$daysUntilBirth Gün';

  // Demo pregnancy data for testing
  static PregnancyModel demo = PregnancyModel(
    currentWeek: 16,
    currentDay: 3,
    daysUntilBirth: 165,
    expectedDueDate: DateTime.now().add(const Duration(days: 165)),
    babySize: 'avokado',
    babySizeDescription: '11.6 cm',
    aiInsightMessage:
        'Tebrikler Zeynep! Bebeğin şu an bir avokado büyüklüğünde (11.6 cm). Kemik gelişimi için süt ürünlerini ihmal etme.',
  );
}
