import 'package:flutter/foundation.dart';
import 'profile_service.dart';
import 'auth_service.dart';
import 'plan_service.dart';

/// Uygulama genelinde paylaşılan state - ChangeNotifier ile Provider'a bağlı
class AppState extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  final PlanService _planService = PlanService();

  // State variables
  FullProfile? _fullProfile;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  List<PlanData> _plans = [];

  // Getters
  FullProfile? get fullProfile => _fullProfile;
  UserProfileData? get profile => _fullProfile?.profile;
  PregnancyData? get pregnancy => _fullProfile?.pregnancy;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get hasData => _fullProfile != null;
  bool get hasPregnancy => _fullProfile?.pregnancy != null;
  List<PlanData> get plans => _plans;

  /// Kullanıcı tam adını döndür
  String get userFullName {
    if (_fullProfile?.profile != null) {
      return _fullProfile!.profile.fullName;
    }
    // AuthService'den kullanıcı verilerini dene
    final userData = _authService.userData;
    if (userData != null) {
      final firstName = userData['first_name'] ?? '';
      final lastName = userData['last_name'] ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
    }
    return 'Kullanıcı';
  }

  /// Gebelik haftasını döndür
  int get currentWeek => pregnancy?.currentWeek ?? 0;

  /// Doğuma kalan gün sayısını döndür
  int get daysUntilBirth => pregnancy?.daysUntilBirth ?? 0;

  /// Bugünün planlarını getir (API'den gelen verilerden filtrele)
  List<PlanData> get todayPlans {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _plans.where((plan) {
      final planDate = DateTime(
        plan.scheduledTime.year,
        plan.scheduledTime.month,
        plan.scheduledTime.day,
      );
      return planDate.isAtSameMomentAs(today);
    }).toList()..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  /// Uygulama başlatıldığında çağrılır
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    // Profil verilerini yükle
    await loadProfile();

    // API'den planları yükle
    await loadPlans();

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  /// Profil verilerini yükle
  Future<void> loadProfile() async {
    if (_isLoading && _isInitialized) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _profileService.getFullProfile();

      if (result.isSuccess && result.data != null) {
        _fullProfile = result.data;
        _errorMessage = null;
      } else {
        _errorMessage = result.errorMessage;
      }
    } catch (e) {
      _errorMessage = 'Veri yüklenirken hata oluştu: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Hamilelik verilerini güncelle
  void updatePregnancy(PregnancyData? pregnancyData) {
    if (_fullProfile != null) {
      _fullProfile = FullProfile(
        profile: _fullProfile!.profile,
        pregnancy: pregnancyData,
      );
      notifyListeners();
    }
  }

  /// Profil verilerini güncelle
  void updateProfile(UserProfileData profileData) {
    _fullProfile = FullProfile(
      profile: profileData,
      pregnancy: _fullProfile?.pregnancy,
    );
    notifyListeners();
  }

  /// State'i temizle (logout durumunda)
  void clear() {
    _fullProfile = null;
    _errorMessage = null;
    _isLoading = false;
    _isInitialized = false;
    _plans = [];
    notifyListeners();
  }

  /// Profil verilerini yenile
  Future<void> refreshProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _profileService.getFullProfile();

      if (result.isSuccess && result.data != null) {
        _fullProfile = result.data;
        _errorMessage = null;
      } else {
        _errorMessage = result.errorMessage;
      }
    } catch (e) {
      _errorMessage = 'Veri yüklenirken hata oluştu: $e';
    }

    // Planları da yenile
    await loadPlans();

    _isLoading = false;
    notifyListeners();
  }

  // ==================== PLAN YÖNETİMİ (API) ====================

  /// API'den planları yükle
  Future<void> loadPlans() async {
    try {
      final result = await _planService.getTodayPlans();
      if (result.isSuccess && result.data != null) {
        _plans = result.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Planlar yüklenemedi: $e');
    }
  }

  /// Tüm planları API'den yükle
  Future<void> loadAllPlans() async {
    try {
      final result = await _planService.getAllPlans();
      if (result.isSuccess && result.data != null) {
        _plans = result.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Planlar yüklenemedi: $e');
    }
  }

  /// Yeni plan ekle (API üzerinden)
  Future<bool> addPlan({
    required String title,
    String? description,
    required DateTime scheduledTime,
    required String category,
  }) async {
    try {
      final result = await _planService.createPlan(
        title: title,
        description: description,
        scheduledTime: scheduledTime,
        category: PlanCategoryExtension.fromString(category),
      );

      if (result.isSuccess && result.data != null) {
        _plans.add(result.data!);
        _plans.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
        notifyListeners();
        return true;
      } else {
        debugPrint('Plan oluşturulamadı: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      debugPrint('Plan oluşturulurken hata: $e');
      return false;
    }
  }

  /// Plan durumunu değiştir (tamamlandı/tamamlanmadı)
  Future<void> togglePlanCompletion(int planId) async {
    final index = _plans.indexWhere((p) => p.id == planId);
    if (index != -1) {
      final plan = _plans[index];
      final newStatus = !plan.isCompleted;

      // Optimistic update
      _plans[index] = plan.copyWith(isCompleted: newStatus);
      notifyListeners();

      // API çağrısı
      final result = await _planService.togglePlanCompletion(planId, newStatus);
      if (!result.isSuccess) {
        // Hata durumunda geri al
        _plans[index] = plan;
        notifyListeners();
        debugPrint('Plan durumu güncellenemedi: ${result.errorMessage}');
      }
    }
  }

  /// Plan sil (API üzerinden)
  Future<void> deletePlan(int planId) async {
    final index = _plans.indexWhere((p) => p.id == planId);
    if (index != -1) {
      final removedPlan = _plans[index];

      // Optimistic update
      _plans.removeAt(index);
      notifyListeners();

      // API çağrısı
      final result = await _planService.deletePlan(planId);
      if (!result.isSuccess) {
        // Hata durumunda geri ekle
        _plans.insert(index, removedPlan);
        notifyListeners();
        debugPrint('Plan silinemedi: ${result.errorMessage}');
      }
    }
  }

  /// Plan güncelle (API üzerinden)
  Future<bool> updatePlan({
    required int planId,
    String? title,
    String? description,
    DateTime? scheduledTime,
    String? category,
    bool? isCompleted,
  }) async {
    try {
      final result = await _planService.updatePlan(
        planId: planId,
        title: title,
        description: description,
        scheduledTime: scheduledTime,
        category: category != null
            ? PlanCategoryExtension.fromString(category)
            : null,
        isCompleted: isCompleted,
      );

      if (result.isSuccess && result.data != null) {
        final index = _plans.indexWhere((p) => p.id == planId);
        if (index != -1) {
          _plans[index] = result.data!;
          _plans.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Plan güncellenirken hata: $e');
      return false;
    }
  }
}
