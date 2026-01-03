import 'package:flutter/foundation.dart';
import 'profile_service.dart';
import 'auth_service.dart';

/// Uygulama genelinde paylaşılan state
class AppState extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();

  // Singleton pattern
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // State variables
  FullProfile? _fullProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  FullProfile? get fullProfile => _fullProfile;
  UserProfileData? get profile => _fullProfile?.profile;
  PregnancyData? get pregnancy => _fullProfile?.pregnancy;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _fullProfile != null;
  bool get hasPregnancy => _fullProfile?.pregnancy != null;

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

  /// Profil verilerini yükle
  Future<void> loadProfile() async {
    if (_isLoading) return;

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
    notifyListeners();
  }

  /// Profil verilerini yenile
  Future<void> refreshProfile() async {
    await loadProfile();
  }
}
