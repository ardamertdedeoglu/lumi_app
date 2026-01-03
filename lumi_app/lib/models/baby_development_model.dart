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

  /// Belirli bir hafta için gelişim verisini döndür
  static BabyDevelopmentModel getForWeek(int week) {
    // Geçerli aralık kontrolü
    if (week < 4) week = 4;
    if (week > 40) week = 40;

    // Tam eşleşme varsa döndür
    if (weeklyData.containsKey(week)) {
      return weeklyData[week]!;
    }

    // Tam eşleşme yoksa en yakın haftayı bul
    final sortedWeeks = weeklyData.keys.toList()..sort();
    int closestWeek = sortedWeeks.first;

    for (final w in sortedWeeks) {
      if (w <= week) {
        closestWeek = w;
      } else {
        break;
      }
    }

    return weeklyData[closestWeek]!;
  }

  // Weekly development data - comprehensive data for all weeks
  static Map<int, BabyDevelopmentModel> weeklyData = {
    4: const BabyDevelopmentModel(
      week: 4,
      sizeComparison: 'Haşhaş Tohumu',
      sizeEmoji: '🌱',
      length: '0.1 cm',
      weight: '< 1 gram',
      heartRate: 'Oluşuyor',
      movements: 'Yok',
      milestones: [
        'Embriyo oluştu',
        'Plasenta gelişmeye başladı',
        'Sinir sistemi temelleri atıldı',
      ],
      tips: [
        'Folik asit takviyesi almaya başlayın',
        'Sigara ve alkolden uzak durun',
        'Doktorunuzla ilk randevunuzu planlayın',
      ],
    ),
    5: const BabyDevelopmentModel(
      week: 5,
      sizeComparison: 'Susam Tohumu',
      sizeEmoji: '🫘',
      length: '0.2 cm',
      weight: '< 1 gram',
      heartRate: 'Oluşuyor',
      movements: 'Yok',
      milestones: [
        'Kalp atışı başladı',
        'Beyin ve omurilik şekilleniyor',
        'Kol ve bacak tomurcukları oluştu',
      ],
      tips: [
        'Sabah bulantısı normal, küçük öğünler yiyin',
        'Bol su için',
        'Yorgunluk normal, dinlenin',
      ],
    ),
    6: const BabyDevelopmentModel(
      week: 6,
      sizeComparison: 'Mercimek',
      sizeEmoji: '🟤',
      length: '0.5 cm',
      weight: '< 1 gram',
      heartRate: '100-160 bpm',
      movements: 'Yok',
      milestones: [
        'Yüz özellikleri belirmeye başladı',
        'İç kulak oluşuyor',
        'Beyin hızla gelişiyor',
      ],
      tips: [
        'Kafein tüketimini azaltın',
        'İlk ultrason için hazırlanın',
        'Vitamin takviyelerinizi düzenli alın',
      ],
    ),
    7: const BabyDevelopmentModel(
      week: 7,
      sizeComparison: 'Yaban Mersini',
      sizeEmoji: '🫐',
      length: '1 cm',
      weight: '1 gram',
      heartRate: '120-160 bpm',
      movements: 'Küçük kıpırdanmalar',
      milestones: [
        'Eller ve ayaklar kürek şeklinde',
        'Böbrekler çalışmaya başladı',
        'Ağız ve burun açıklıkları belirdi',
      ],
      tips: [
        'Protein alımınızı artırın',
        'Rahat giysiler tercih edin',
        'Duygusal değişimler normaldir',
      ],
    ),
    8: const BabyDevelopmentModel(
      week: 8,
      sizeComparison: 'Böğürtlen',
      sizeEmoji: '🫐',
      length: '1.6 cm',
      weight: '1 gram',
      heartRate: '140-170 bpm',
      movements: 'Refleks hareketleri',
      milestones: [
        'Parmaklar ayrışmaya başladı',
        'Göz kapakları oluşuyor',
        'Kuyruk kaybolmaya başladı',
        'Tüm ana organlar oluştu',
      ],
      tips: [
        'Hamilelik belirtileri yoğunlaşabilir',
        'Bol meyve ve sebze tüketin',
        'Düzenli uyku rutini oluşturun',
      ],
    ),
    9: const BabyDevelopmentModel(
      week: 9,
      sizeComparison: 'Üzüm',
      sizeEmoji: '🍇',
      length: '2.3 cm',
      weight: '2 gram',
      heartRate: '140-170 bpm',
      movements: 'Kol ve bacak hareketleri',
      milestones: [
        'Embriyo artık fetüs olarak adlandırılıyor',
        'Kaslar oluşmaya başladı',
        'Diş tomurcukları belirdi',
      ],
      tips: [
        'İlk trimester taramalarını planlayın',
        'Stres yönetimi önemli',
        'Hafif yürüyüşler yapın',
      ],
    ),
    10: const BabyDevelopmentModel(
      week: 10,
      sizeComparison: 'Çilek',
      sizeEmoji: '🍓',
      length: '3.1 cm',
      weight: '4 gram',
      heartRate: '140-170 bpm',
      movements: 'Aktif kıpırdanmalar',
      milestones: [
        'Tüm vücut organları yerinde',
        'Parmaklar tamamen ayrıştı',
        'Kemikler sertleşmeye başladı',
      ],
      tips: [
        'Kan tahlillerinizi yaptırın',
        'Göğüsleriniz hassaslaşabilir',
        'Dengeli beslenmeye devam edin',
      ],
    ),
    11: const BabyDevelopmentModel(
      week: 11,
      sizeComparison: 'İncir',
      sizeEmoji: '🫒',
      length: '4.1 cm',
      weight: '7 gram',
      heartRate: '140-170 bpm',
      movements: 'Tekme ve yumruklar',
      milestones: [
        'Baş vücudun yarısı kadar',
        'Tırnaklar oluşmaya başladı',
        'Dış genital organlar belirginleşiyor',
      ],
      tips: [
        'Ense kalınlığı ölçümü için hazırlanın',
        'Kabızlık sorunu için lifli gıdalar tüketin',
        'Cilt değişimleri başlayabilir',
      ],
    ),
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
        'Sindirim sistemi çalışıyor',
      ],
      tips: [
        'Folik asit almaya devam edin',
        'Kafein tüketimini sınırlayın',
        '1. trimester sona eriyor, düşük riski azalıyor',
      ],
    ),
    13: const BabyDevelopmentModel(
      week: 13,
      sizeComparison: 'Bezelye Kabı',
      sizeEmoji: '🫛',
      length: '7.4 cm',
      weight: '23 gram',
      heartRate: '155 bpm',
      movements: 'Başparmak emme',
      milestones: [
        'Ses telleri oluştu',
        'Parmak izleri şekilleniyor',
        'Baş büyümeyi yavaşlattı',
      ],
      tips: [
        '2. trimester başladı - enerji artabilir',
        'Hamilelere özel egzersiz sınıflarına bakın',
        'Beslenme danışmanından destek alın',
      ],
    ),
    14: const BabyDevelopmentModel(
      week: 14,
      sizeComparison: 'Nektarin',
      sizeEmoji: '🍑',
      length: '8.7 cm',
      weight: '43 gram',
      heartRate: '155 bpm',
      movements: 'Yüz ifadeleri',
      milestones: [
        'Kaşları ve saçları çıkıyor',
        'Prostat veya yumurtalık gelişiyor',
        'Boyun uzuyor',
      ],
      tips: [
        'Günlük protein ihtiyacınız arttı',
        'Pelvik taban egzersizlerine başlayın',
        'Hamilelik yogası deneyin',
      ],
    ),
    15: const BabyDevelopmentModel(
      week: 15,
      sizeComparison: 'Elma',
      sizeEmoji: '🍎',
      length: '10.1 cm',
      weight: '70 gram',
      heartRate: '155 bpm',
      movements: 'Aktif hareketler',
      milestones: [
        'Bebek ışığa tepki verebiliyor',
        'Kemikler sertleşmeye devam ediyor',
        'Tat tomurcukları gelişiyor',
      ],
      tips: [
        'Kalsiyum alımını artırın',
        'Burun kanaması ve diş eti kanaması olabilir',
        'Bol su için - idrar yolu enfeksiyonlarını önleyin',
      ],
    ),
    16: demo,
    17: const BabyDevelopmentModel(
      week: 17,
      sizeComparison: 'Armut',
      sizeEmoji: '🍐',
      length: '13 cm',
      weight: '140 gram',
      heartRate: '150 bpm',
      movements: 'Hafif hareketler hissedilebilir',
      milestones: [
        'Yağ birikimi başlıyor',
        'Ter bezleri gelişiyor',
        'Göbek kordonu güçleniyor',
      ],
      tips: [
        'İlk bebek hareketlerini hissedebilirsiniz',
        'Sol tarafınıza yatarak uyuyun',
        'Doğum hazırlık kurslarını araştırın',
      ],
    ),
    18: const BabyDevelopmentModel(
      week: 18,
      sizeComparison: 'Dolmalık Biber',
      sizeEmoji: '🫑',
      length: '14.2 cm',
      weight: '190 gram',
      heartRate: '150 bpm',
      movements: 'Net hareketler',
      milestones: [
        'Kulaklar son konumuna yerleşti',
        'Miyelin kılıf oluşuyor',
        'Cinsiyet ultrasonla belirlenebilir',
      ],
      tips: [
        '20. hafta detaylı ultrasona hazırlanın',
        'Sırt ağrıları için duruşunuza dikkat edin',
        'Bebek odası planlamasına başlayabilirsiniz',
      ],
    ),
    19: const BabyDevelopmentModel(
      week: 19,
      sizeComparison: 'Mango',
      sizeEmoji: '🥭',
      length: '15.3 cm',
      weight: '240 gram',
      heartRate: '145 bpm',
      movements: 'Düzenli hareketler',
      milestones: [
        'Verniks caseosa (koruyucu tabaka) oluşuyor',
        'Beyin hızla büyüyor',
        'Duyular gelişiyor',
      ],
      tips: [
        'Bacak kramplarına dikkat edin - magnezyum alın',
        'Gebelik çizgileri için nemlendirici kullanın',
        'Dengeli kilo alımına dikkat edin',
      ],
    ),
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
        'Yarısına geldiniz, tebrikler!',
      ],
    ),
    21: const BabyDevelopmentModel(
      week: 21,
      sizeComparison: 'Havuç',
      sizeEmoji: '🥕',
      length: '26.7 cm',
      weight: '360 gram',
      heartRate: '140 bpm',
      movements: 'Güçlü tekme ve yumruklar',
      milestones: [
        'Kaşlar ve kirpikler büyüyor',
        'Bebek yutkunabiliyor',
        'Bağırsaklar mekonyum biriktirmeye başladı',
      ],
      tips: [
        'Bebeğinizin hareket düzenini öğrenin',
        'Hamilelere özel yastık kullanın',
        'Düzenli doktor kontrollerine devam edin',
      ],
    ),
    22: const BabyDevelopmentModel(
      week: 22,
      sizeComparison: 'Papaya',
      sizeEmoji: '🥝',
      length: '27.8 cm',
      weight: '430 gram',
      heartRate: '140 bpm',
      movements: 'Çok aktif',
      milestones: [
        'Gözler tam oluştu (kapaklar kapalı)',
        'Pankreas gelişiyor',
        'Dudaklar belirginleşti',
      ],
      tips: [
        'Demir eksikliğine dikkat edin',
        'Şeker yüklemesi testi yaklaşıyor',
        'Doğum planı yapmaya başlayın',
      ],
    ),
    23: const BabyDevelopmentModel(
      week: 23,
      sizeComparison: 'Greyfurt',
      sizeEmoji: '🍊',
      length: '28.9 cm',
      weight: '500 gram',
      heartRate: '140 bpm',
      movements: 'Ritimli hıçkırıklar',
      milestones: [
        'Akciğerler sürfaktan üretmeye başladı',
        'Deri hala kırışık ama dolgunlaşıyor',
        'Ses algılama gelişiyor',
      ],
      tips: [
        'Bebek hayatta kalma şansı artmaya başladı',
        'Sırt ve kalça ağrıları için egzersiz yapın',
        'Doğum öncesi kurslarına kaydolun',
      ],
    ),
    24: const BabyDevelopmentModel(
      week: 24,
      sizeComparison: 'Mısır Koçanı',
      sizeEmoji: '🌽',
      length: '30 cm',
      weight: '600 gram',
      heartRate: '140 bpm',
      movements: 'Düzenli tekme düzeni',
      milestones: [
        'Akciğerler gelişmeye devam ediyor',
        'Yüz özellikleri tamamlandı',
        'Uyku döngüleri düzenleniyor',
        'Hayatta kalma şansı %50+',
      ],
      tips: [
        'Şeker tarama testi yaptırın',
        'Preeklampsi belirtilerini öğrenin',
        'Bebek alışverişi listesi yapın',
      ],
    ),
    25: const BabyDevelopmentModel(
      week: 25,
      sizeComparison: 'Rutabaga',
      sizeEmoji: '🥔',
      length: '34.6 cm',
      weight: '660 gram',
      heartRate: '140 bpm',
      movements: 'Güçlü hareketler',
      milestones: [
        'Burun delikleri açılıyor',
        'Derinin rengi değişiyor',
        'Ses siniri olgunlaşıyor',
      ],
      tips: [
        '3. trimester yaklaşıyor',
        'Bebek eşyalarını hazırlamaya başlayın',
        'Hastane çantası listesi yapın',
      ],
    ),
    26: const BabyDevelopmentModel(
      week: 26,
      sizeComparison: 'Kabak',
      sizeEmoji: '🥒',
      length: '35.6 cm',
      weight: '760 gram',
      heartRate: '140 bpm',
      movements: 'Uyku-hareket döngüsü',
      milestones: [
        'Gözler açılmaya başlıyor',
        'Beyaz kan hücreleri üretiliyor',
        'Akciğerler gelişmeye devam ediyor',
      ],
      tips: [
        'Rh faktörü kontrolü',
        'Gebelik diyabeti testi sonuçlarını değerlendirin',
        'Düzenli tekme sayımı yapın',
      ],
    ),
    27: const BabyDevelopmentModel(
      week: 27,
      sizeComparison: 'Karnabahar',
      sizeEmoji: '🥬',
      length: '36.6 cm',
      weight: '875 gram',
      heartRate: '140 bpm',
      movements: 'Net hareket hissedilir',
      milestones: [
        'Beyin aktivitesi artıyor',
        'Göz retinası olgunlaşıyor',
        'Akciğerler sürfaktan üretiyor',
      ],
      tips: [
        '3. trimester başlıyor',
        'Erken doğum belirtilerini öğrenin',
        'Pelvik taban egzersizlerine devam edin',
      ],
    ),
    28: const BabyDevelopmentModel(
      week: 28,
      sizeComparison: 'Büyük Patlıcan',
      sizeEmoji: '🍆',
      length: '37.6 cm',
      weight: '1 kg',
      heartRate: '140 bpm',
      movements: 'REM uykusu dönemleri',
      milestones: [
        'Gözler tam açılabilir',
        'Beyin olukları derinleşiyor',
        'Rüya görmeye başlıyor',
        'Hayatta kalma şansı %90+',
      ],
      tips: [
        'Anti-D aşısı (Rh negatif ise)',
        'Doğum planınızı detaylandırın',
        'Bebek odası hazırlığına hız verin',
      ],
    ),
    29: const BabyDevelopmentModel(
      week: 29,
      sizeComparison: 'Balkabağı',
      sizeEmoji: '🎃',
      length: '38.6 cm',
      weight: '1.15 kg',
      heartRate: '140 bpm',
      movements: 'Yer değiştirme hareketleri',
      milestones: [
        'Kaslar ve akciğerler olgunlaşıyor',
        'Baş büyüyor (beyin gelişimi için)',
        'Kemikler güçleniyor',
      ],
      tips: [
        'Uyku pozisyonuna dikkat edin',
        'Nefes darlığı normal olabilir',
        'Hastane kayıt işlemlerini tamamlayın',
      ],
    ),
    30: const BabyDevelopmentModel(
      week: 30,
      sizeComparison: 'Lahana',
      sizeEmoji: '🥬',
      length: '39.9 cm',
      weight: '1.3 kg',
      heartRate: '140 bpm',
      movements: 'Alan daralıyor',
      milestones: [
        'Lanugo (ince tüyler) dökülmeye başlıyor',
        'Kemik iliği kırmızı kan hücresi üretiyor',
        'Görme keskinleşiyor',
      ],
      tips: [
        'Hastane çantanızı hazırlayın',
        'Doğum partneri ile iletişimi güçlendirin',
        'Bebek bakımı hakkında bilgilenin',
      ],
    ),
    31: const BabyDevelopmentModel(
      week: 31,
      sizeComparison: 'Hindistan Cevizi',
      sizeEmoji: '🥥',
      length: '41.1 cm',
      weight: '1.5 kg',
      heartRate: '140 bpm',
      movements: 'Sınırlı ama güçlü',
      milestones: [
        'Beş duyu aktif',
        'Beyin hızla gelişiyor',
        'Vücut ısısını düzenlemeye başlıyor',
      ],
      tips: [
        'Braxton Hicks kasılmaları artabilir',
        'Bol dinlenin',
        'Doğum sonrası planlar yapın',
      ],
    ),
    32: const BabyDevelopmentModel(
      week: 32,
      sizeComparison: 'Jicama',
      sizeEmoji: '🥔',
      length: '42.4 cm',
      weight: '1.7 kg',
      heartRate: '140 bpm',
      movements: 'Baş aşağı dönüyor',
      milestones: [
        'Tırnaklar parmaklara ulaştı',
        'Deri pürüzsüzleşiyor',
        'Saç büyüyor',
      ],
      tips: [
        'NST (non-stress test) başlayabilir',
        'Bebek bakımı eğitimi alın',
        'Anne sütü hakkında bilgilenin',
      ],
    ),
    33: const BabyDevelopmentModel(
      week: 33,
      sizeComparison: 'Ananas',
      sizeEmoji: '🍍',
      length: '43.7 cm',
      weight: '1.9 kg',
      heartRate: '140 bpm',
      movements: 'Yoğun ama sınırlı',
      milestones: [
        'Kemikler sertleşmeye devam ediyor',
        'Bağışıklık sistemi gelişiyor',
        'Akciğerler neredeyse olgun',
      ],
      tips: [
        'Doğum sancısı belirtilerini öğrenin',
        'Acil durum numaralarını hazırlayın',
        'Araba koltuğunu takın',
      ],
    ),
    34: const BabyDevelopmentModel(
      week: 34,
      sizeComparison: 'Kavun',
      sizeEmoji: '🍈',
      length: '45 cm',
      weight: '2.1 kg',
      heartRate: '140 bpm',
      movements: 'Belirgin itme ve tekme',
      milestones: [
        'Akciğerler neredeyse tam olgun',
        'Merkezi sinir sistemi olgunlaşıyor',
        'Yağ birikimi artıyor',
      ],
      tips: [
        'Erken doğum durumunda bebek genellikle sağlıklı',
        'Son kontrollerinizi aksatmayın',
        'Doğum çantanızı kontrol edin',
      ],
    ),
    35: const BabyDevelopmentModel(
      week: 35,
      sizeComparison: 'Bal Kabağı',
      sizeEmoji: '🍯',
      length: '46.2 cm',
      weight: '2.4 kg',
      heartRate: '140 bpm',
      movements: 'Dönme hareketleri azalıyor',
      milestones: [
        'Böbrekler tam gelişti',
        'Karaciğer işlev görmeye başladı',
        'Çoğu organ olgunlaştı',
      ],
      tips: [
        'Haftalık doktor kontrolü başlayabilir',
        'Doğum planını gözden geçirin',
        'Emzirme pozisyonlarını öğrenin',
      ],
    ),
    36: const BabyDevelopmentModel(
      week: 36,
      sizeComparison: 'Kış Kavunu',
      sizeEmoji: '🍈',
      length: '47.4 cm',
      weight: '2.6 kg',
      heartRate: '140 bpm',
      movements: 'Baş pelvise yerleşiyor',
      milestones: [
        'Lanugo dökülmeye devam ediyor',
        'Yağ tabakası kalınlaşıyor',
        'Dolaşım ve bağışıklık sistemi hazır',
      ],
      tips: [
        'GBS testi yapılacak',
        'Doğum belirtilerini yakından izleyin',
        'Bebek gereçlerini son kez kontrol edin',
      ],
    ),
    37: const BabyDevelopmentModel(
      week: 37,
      sizeComparison: 'Kış Balkabağı',
      sizeEmoji: '🎃',
      length: '48.6 cm',
      weight: '2.9 kg',
      heartRate: '140 bpm',
      movements: 'Sınırlı hareket alanı',
      milestones: [
        'Bebek artık term (zamanında) sayılır',
        'Organlar hazır',
        'Göğüs emme refleksi güçlü',
      ],
      tips: [
        'Doğum her an gerçekleşebilir',
        'Su kesesinin açılmasına dikkat edin',
        'Sakin ve hazırlıklı olun',
      ],
    ),
    38: const BabyDevelopmentModel(
      week: 38,
      sizeComparison: 'Pırasa',
      sizeEmoji: '🥬',
      length: '49.8 cm',
      weight: '3 kg',
      heartRate: '140 bpm',
      movements: 'Basınç hissi',
      milestones: [
        'Göz rengi henüz belirsiz (doğumda değişebilir)',
        'Tüm organlar çalışıyor',
        'Verniks azalıyor',
      ],
      tips: [
        'Rahat pozisyon bulmak zorlaşabilir',
        'Sık idrara çıkma normal',
        'Doğum sancısı ve yalancı sancı ayrımını bilin',
      ],
    ),
    39: const BabyDevelopmentModel(
      week: 39,
      sizeComparison: 'Karpuz',
      sizeEmoji: '🍉',
      length: '50.7 cm',
      weight: '3.3 kg',
      heartRate: '140 bpm',
      movements: 'Minimal hareket',
      milestones: [
        'Akciğerler olgun',
        'Beyin gelişimi devam ediyor',
        'Doğuma hazır',
      ],
      tips: [
        'Sıkışma hissi normal',
        'Nişane geldiğinde hastaneyi arayın',
        'Dinlenmeye çalışın',
      ],
    ),
    40: const BabyDevelopmentModel(
      week: 40,
      sizeComparison: 'Küçük Kabak',
      sizeEmoji: '🎃',
      length: '51.2 cm',
      weight: '3.5 kg',
      heartRate: '140 bpm',
      movements: 'Basınç ve itme',
      milestones: [
        'Tam zamanlı bebek',
        'Göğüs emmeye hazır',
        'Tüm sistemler çalışır durumda',
        'Doğuma hazır!',
      ],
      tips: [
        'Tahmini doğum tarihi geldi',
        'Bebek hafta sonuna kadar gelmezse doktorunuzu arayın',
        'Sabırlı olun, bebek kendi zamanında gelecek',
        'Tebrikler, çok yakında annesiniz!',
      ],
    ),
  };
}
