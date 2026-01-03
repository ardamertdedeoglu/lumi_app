import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_service.dart';
import 'auth_service.dart';

/// Uygulama genelinde paylaşılan state - ChangeNotifier ile Provider'a bağlı
class AppState extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();

  // State variables
  FullProfile? _fullProfile;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  List<LocalPlan> _localPlans = [];

  // Getters
  FullProfile? get fullProfile => _fullProfile;
  UserProfileData? get profile => _fullProfile?.profile;
  PregnancyData? get pregnancy => _fullProfile?.pregnancy;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get hasData => _fullProfile != null;
  bool get hasPregnancy => _fullProfile?.pregnancy != null;
  List<LocalPlan> get localPlans => _localPlans;

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

  /// Bugünün planlarını getir
  List<LocalPlan> get todayPlans {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _localPlans.where((plan) {
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

    // Lokal planları yükle
    await _loadLocalPlans();

    // Profil verilerini yükle
    await loadProfile();

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
    _localPlans = [];
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

    _isLoading = false;
    notifyListeners();
  }

  // ==================== LOKAL PLAN YÖNETİMİ ====================

  static const String _plansKey = 'local_plans';

  /// Lokal planları SharedPreferences'dan yükle
  Future<void> _loadLocalPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = prefs.getString(_plansKey);
      if (plansJson != null) {
        final List<dynamic> plansList = jsonDecode(plansJson);
        _localPlans = plansList.map((e) => LocalPlan.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Planlar yüklenemedi: $e');
    }
  }

  /// Lokal planları SharedPreferences'a kaydet
  Future<void> _saveLocalPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = jsonEncode(_localPlans.map((e) => e.toJson()).toList());
      await prefs.setString(_plansKey, plansJson);
    } catch (e) {
      debugPrint('Planlar kaydedilemedi: $e');
    }
  }

  /// Yeni plan ekle
  Future<void> addPlan({
    required String title,
    String? description,
    required DateTime scheduledTime,
    required String category,
  }) async {
    final newPlan = LocalPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      scheduledTime: scheduledTime,
      category: category,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    _localPlans.add(newPlan);
    await _saveLocalPlans();
    notifyListeners();
  }

  /// Plan durumunu değiştir (tamamlandı/tamamlanmadı)
  Future<void> togglePlanCompletion(String planId) async {
    final index = _localPlans.indexWhere((p) => p.id == planId);
    if (index != -1) {
      _localPlans[index] = _localPlans[index].copyWith(
        isCompleted: !_localPlans[index].isCompleted,
      );
      await _saveLocalPlans();
      notifyListeners();
    }
  }

  /// Plan sil
  Future<void> deletePlan(String planId) async {
    _localPlans.removeWhere((p) => p.id == planId);
    await _saveLocalPlans();
    notifyListeners();
  }

  /// Plan güncelle
  Future<void> updatePlan(LocalPlan updatedPlan) async {
    final index = _localPlans.indexWhere((p) => p.id == updatedPlan.id);
    if (index != -1) {
      _localPlans[index] = updatedPlan;
      await _saveLocalPlans();
      notifyListeners();
    }
  }
}

/// Lokal plan modeli
class LocalPlan {
  final String id;
  final String title;
  final String? description;
  final DateTime scheduledTime;
  final String category;
  final bool isCompleted;
  final DateTime createdAt;

  LocalPlan({
    required this.id,
    required this.title,
    this.description,
    required this.scheduledTime,
    required this.category,
    required this.isCompleted,
    required this.createdAt,
  });

  factory LocalPlan.fromJson(Map<String, dynamic> json) {
    return LocalPlan(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      scheduledTime: DateTime.parse(json['scheduled_time']),
      category: json['category'] ?? 'other',
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduled_time': scheduledTime.toIso8601String(),
      'category': category,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get timeLabel {
    final hour = scheduledTime.hour.toString().padLeft(2, '0');
    final minute = scheduledTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  LocalPlan copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledTime,
    String? category,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return LocalPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
