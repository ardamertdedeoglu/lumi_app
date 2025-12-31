class BabyDevelopmentModel {
  final int week;
  final String sizeComparison;
  final String sizeEmoji;
  final String length;
  final String weight;
  final String heartRate;
  final String movements;
  final List<String> milestones;
  final List<String> tips;

  const BabyDevelopmentModel({
    required this.week,
    required this.sizeComparison,
    required this.sizeEmoji,
    required this.length,
    required this.weight,
    required this.heartRate,
    required this.movements,
    required this.milestones,
    required this.tips,
  });

  // Demo data for week 16
  static const BabyDevelopmentModel demo = BabyDevelopmentModel(
    week: 16,
    sizeComparison: 'Avokado',
    sizeEmoji: '🥑',
    length: '11.6 cm',
    weight: '100 gram',
    heartRate: '150 bpm',
    movements: 'Aktif',
    milestones: [
      'Göz kapakları tamamen oluştu',
      'Parmak izleri belirginleşmeye başladı',
      'İskelet sistemi güçleniyor',
      'Yüz kasları hareket edebiliyor',
      'Saç kökleri oluşmaya başladı',
    ],
    tips: [
      'Kalsiyum alımını artırın - süt ürünleri tüketin',
      'Günde en az 8 bardak su için',
      'Hafif egzersizler yapın (yürüyüş, yüzme)',
      'Demir açısından zengin gıdalar tüketin',
    ],
  );

  // Weekly development data
  static Map<int, BabyDevelopmentModel> weeklyData = {
    12: const BabyDevelopmentModel(
      week: 12,
      sizeComparison: 'Limon',
      sizeEmoji: '🍋',
      length: '5.4 cm',
      weight: '14 gram',
      heartRate: '160 bpm',
      movements: 'Başlangıç',
      milestones: [
        'Tüm organlar oluştu',
        'Refleksler gelişmeye başladı',
        'Tırnaklar oluşmaya başladı',
      ],
      tips: [
        'Folik asit almaya devam edin',
        'Kafein tüketimini sınırlayın',
      ],
    ),
    16: demo,
    20: const BabyDevelopmentModel(
      week: 20,
      sizeComparison: 'Muz',
      sizeEmoji: '🍌',
      length: '16.4 cm',
      weight: '300 gram',
      heartRate: '140 bpm',
      movements: 'Hissedilir',
      milestones: [
        'Cinsiyet ultrasonla belirlenebilir',
        'Bebek sesleri duyabiliyor',
        'Uyku-uyanıklık döngüsü oluştu',
        'Deri verniks ile kaplanıyor',
      ],
      tips: [
        'Bebeğinizle konuşun ve müzik dinletin',
        'Yan yatarak uyumaya başlayın',
        'Demir takviyesi alın',
      ],
    ),
  };
}
