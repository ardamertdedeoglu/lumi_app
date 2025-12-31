import '../models/pregnancy_model.dart';

class PregnancyService {
  /// Calculate pregnancy week from last menstrual period
  static int calculateWeek(DateTime lastMenstrualPeriod) {
    final now = DateTime.now();
    final difference = now.difference(lastMenstrualPeriod);
    return (difference.inDays / 7).floor();
  }

  /// Calculate days until expected due date
  static int calculateDaysUntilBirth(DateTime expectedDueDate) {
    final now = DateTime.now();
    final difference = expectedDueDate.difference(now);
    return difference.inDays;
  }

  /// Get expected due date from last menstrual period
  /// (Naegele's rule: LMP + 280 days)
  static DateTime calculateDueDate(DateTime lastMenstrualPeriod) {
    return lastMenstrualPeriod.add(const Duration(days: 280));
  }

  /// Get baby size comparison for given week
  static String getBabySizeComparison(int week) {
    final sizes = {
      4: 'haşhaş tohumu',
      5: 'susam tohumu',
      6: 'mercimek',
      7: 'yaban mersini',
      8: 'fasulye',
      9: 'üzüm',
      10: 'zeytin',
      11: 'incir',
      12: 'limon',
      13: 'mandalina',
      14: 'şeftali',
      15: 'elma',
      16: 'avokado',
      17: 'armut',
      18: 'dolmalık biber',
      19: 'domates',
      20: 'muz',
      21: 'havuç',
      22: 'hindistan cevizi',
      23: 'mango',
      24: 'mısır koçanı',
      25: 'kabak',
      26: 'lahana',
      27: 'karnabahar',
      28: 'patlıcan',
      29: 'balkabağı',
      30: 'salatalık',
      31: 'ananas',
      32: 'kavun',
      33: 'karpuz dilimi',
      34: 'kıvırcık',
      35: 'bal kabağı',
      36: 'marul',
      37: 'pazı',
      38: 'pırasa',
      39: 'karpuz',
      40: 'küçük balkabağı',
    };
    return sizes[week] ?? 'bilinmiyor';
  }

  /// Create a demo pregnancy model for testing
  static PregnancyModel createDemoPregnancy() {
    return PregnancyModel.demo;
  }
}
