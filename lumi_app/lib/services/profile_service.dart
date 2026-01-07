import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'auth_service.dart';

class ProfileService {
  final AuthService _authService = AuthService();

  String get baseUrl => AuthService.baseUrl;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authService.accessToken != null)
      'Authorization': 'Bearer ${_authService.accessToken}',
  };

  // Singleton pattern
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  /// Tam profil bilgilerini getir (profil + hamilelik)
  Future<ProfileResult<FullProfile>> getFullProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/full/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProfileResult.success(FullProfile.fromJson(data));
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final refreshed = await _authService.refreshAccessToken();
        if (refreshed) {
          return getFullProfile(); // Retry with new token
        }
        return ProfileResult.error(
          'Oturum süresi doldu. Lütfen tekrar giriş yapın.',
        );
      } else {
        return ProfileResult.error('Profil bilgileri alınamadı');
      }
    } catch (e) {
      return ProfileResult.error('Bağlantı hatası: $e');
    }
  }

  /// Profil resmi yükle
  Future<ProfileResult<UserProfileData>> uploadProfileImage(
    File imageFile,
  ) async {
    try {
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/profile/'),
      );

      request.headers.addAll({
        if (_authService.accessToken != null)
          'Authorization': 'Bearer ${_authService.accessToken}',
      });

      // Dosya uzantısını belirle
      final extension = imageFile.path.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'png' : 'jpeg';

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image',
          imageFile.path,
          contentType: MediaType('image', mimeType),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProfileResult.success(UserProfileData.fromJson(data));
      } else if (response.statusCode == 401) {
        final refreshed = await _authService.refreshAccessToken();
        if (refreshed) {
          return uploadProfileImage(imageFile);
        }
        return ProfileResult.error('Oturum süresi doldu.');
      } else {
        try {
          final data = jsonDecode(response.body);
          return ProfileResult.error(
            data['detail'] ?? 'Resim yüklenemedi: ${response.statusCode}',
          );
        } catch (e) {
          return ProfileResult.error(
            'Resim yüklenemedi: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e) {
      return ProfileResult.error('Bağlantı hatası: $e');
    }
  }

  /// Profil bilgilerini güncelle
  Future<ProfileResult<UserProfileData>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? birthDate,
    bool? notificationsEnabled,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (phone != null) body['phone'] = phone;
      if (birthDate != null) {
        body['birth_date'] = birthDate.toIso8601String().split('T')[0];
      }
      if (notificationsEnabled != null) {
        body['notifications_enabled'] = notificationsEnabled;
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/profile/'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProfileResult.success(UserProfileData.fromJson(data));
      } else {
        final data = jsonDecode(response.body);
        return ProfileResult.error(data['detail'] ?? 'Profil güncellenemedi');
      }
    } catch (e) {
      return ProfileResult.error('Bağlantı hatası: $e');
    }
  }

  /// Hamilelik bilgisi oluştur
  Future<ProfileResult<PregnancyData>> createPregnancy({
    required DateTime lastPeriodDate,
    required DateTime expectedDueDate,
    String? doctorName,
    String? hospitalName,
    String? bloodType,
    String? notes,
  }) async {
    try {
      final body = {
        'last_period_date': lastPeriodDate.toIso8601String().split('T')[0],
        'expected_due_date': expectedDueDate.toIso8601String().split('T')[0],
        if (doctorName != null) 'doctor_name': doctorName,
        if (hospitalName != null) 'hospital_name': hospitalName,
        if (bloodType != null) 'blood_type': bloodType,
        if (notes != null) 'notes': notes,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/pregnancy/'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ProfileResult.success(PregnancyData.fromJson(data));
      } else {
        final data = jsonDecode(response.body);
        return ProfileResult.error(
          data['detail'] ?? 'Hamilelik bilgisi oluşturulamadı',
        );
      }
    } catch (e) {
      return ProfileResult.error('Bağlantı hatası: $e');
    }
  }

  /// Hamilelik bilgisini güncelle
  Future<ProfileResult<PregnancyData>> updatePregnancy({
    DateTime? lastPeriodDate,
    DateTime? expectedDueDate,
    String? doctorName,
    String? hospitalName,
    String? bloodType,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (lastPeriodDate != null) {
        body['last_period_date'] = lastPeriodDate.toIso8601String().split(
          'T',
        )[0];
      }
      if (expectedDueDate != null) {
        body['expected_due_date'] = expectedDueDate.toIso8601String().split(
          'T',
        )[0];
      }
      if (doctorName != null) body['doctor_name'] = doctorName;
      if (hospitalName != null) body['hospital_name'] = hospitalName;
      if (bloodType != null) body['blood_type'] = bloodType;
      if (notes != null) body['notes'] = notes;

      final response = await http.patch(
        Uri.parse('$baseUrl/pregnancy/'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProfileResult.success(PregnancyData.fromJson(data));
      } else {
        final data = jsonDecode(response.body);
        return ProfileResult.error(
          data['detail'] ?? 'Hamilelik bilgisi güncellenemedi',
        );
      }
    } catch (e) {
      return ProfileResult.error('Bağlantı hatası: $e');
    }
  }

  /// Hamilelik bilgisini sil
  Future<ProfileResult<void>> deletePregnancy() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/pregnancy/'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        return ProfileResult.success(null);
      } else {
        return ProfileResult.error('Hamilelik bilgisi silinemedi');
      }
    } catch (e) {
      return ProfileResult.error('Bağlantı hatası: $e');
    }
  }

  /// Aile eşleşme kodu oluştur
  Future<ProfileResult<String>> generateFamilyCode() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/family/generate-code/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProfileResult.success(data['code']);
      } else {
        final data = jsonDecode(response.body);
        return ProfileResult.error(data['detail'] ?? 'Kod oluşturulamadı');
      }
    } catch (e) {
      return ProfileResult.error('Bağlantı hatası: $e');
    }
  }

  /// Partner ile eşleş
  Future<ProfileResult<void>> linkPartner(String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/family/link-partner/'),
        headers: _headers,
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        return ProfileResult.success(null);
      } else {
        final data = jsonDecode(response.body);
        return ProfileResult.error(data['detail'] ?? 'Eşleşme başarısız');
      }
    } catch (e) {
      return ProfileResult.error('Bağlantı hatası: $e');
    }
  }
}

/// Profil işlem sonucu
class ProfileResult<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;

  ProfileResult._({required this.isSuccess, this.data, this.errorMessage});

  factory ProfileResult.success(T? data) =>
      ProfileResult._(isSuccess: true, data: data);
  factory ProfileResult.error(String message) =>
      ProfileResult._(isSuccess: false, errorMessage: message);
}

/// Tam profil verisi
class FullProfile {
  final UserProfileData profile;
  final PregnancyData? pregnancy;

  FullProfile({required this.profile, this.pregnancy});

  factory FullProfile.fromJson(Map<String, dynamic> json) {
    return FullProfile(
      profile: UserProfileData.fromJson(json['profile']),
      pregnancy: json['pregnancy'] != null
          ? PregnancyData.fromJson(json['pregnancy'])
          : null,
    );
  }
}

/// Kullanıcı profil verisi
class UserProfileData {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String role;
  final String? phone;
  final DateTime? birthDate;
  final String? profileImage;
  final bool notificationsEnabled;
  final bool hasPregnancy;
  final bool hasPartner;
  final Map<String, dynamic>? partnerInfo;

  UserProfileData({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.role,
    this.phone,
    this.birthDate,
    this.profileImage,
    required this.notificationsEnabled,
    required this.hasPregnancy,
    this.hasPartner = false,
    this.partnerInfo,
  });

  String? get fullProfileImageUrl {
    if (profileImage == null) return null;
    if (profileImage!.startsWith('http')) return profileImage;
    // Eğer relative path ise baseUrl ekle (başına / ekleyerek)
    final path = profileImage!.startsWith('/')
        ? profileImage
        : '/$profileImage';
    return '${AuthService.baseUrl}$path';
  }

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'],
      role: json['role'] ?? 'mother',
      phone: json['phone'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      profileImage: json['profile_image'],
      notificationsEnabled: json['notifications_enabled'] ?? true,
      hasPregnancy: json['has_pregnancy'] ?? false,
      hasPartner: json['has_partner'] ?? false,
      partnerInfo: json['partner_info'],
    );
  }

  bool get isMother => role == 'mother';
  bool get isFather => role == 'father';
}

/// Hamilelik verisi
class PregnancyData {
  final int id;
  final DateTime lastPeriodDate;
  final DateTime expectedDueDate;
  final String? doctorName;
  final String? hospitalName;
  final String? bloodType;
  final String? notes;
  final bool isActive;
  final int currentWeek;
  final int currentDay;
  final int daysUntilBirth;
  final int trimester;
  final String babySize;
  final String babySizeDescription;

  PregnancyData({
    required this.id,
    required this.lastPeriodDate,
    required this.expectedDueDate,
    this.doctorName,
    this.hospitalName,
    this.bloodType,
    this.notes,
    required this.isActive,
    required this.currentWeek,
    required this.currentDay,
    required this.daysUntilBirth,
    required this.trimester,
    required this.babySize,
    required this.babySizeDescription,
  });

  factory PregnancyData.fromJson(Map<String, dynamic> json) {
    return PregnancyData(
      id: json['id'],
      lastPeriodDate: DateTime.parse(json['last_period_date']),
      expectedDueDate: DateTime.parse(json['expected_due_date']),
      doctorName: json['doctor_name'],
      hospitalName: json['hospital_name'],
      bloodType: json['blood_type'],
      notes: json['notes'],
      isActive: json['is_active'] ?? true,
      currentWeek: json['current_week'] ?? 0,
      currentDay: json['current_day'] ?? 0,
      daysUntilBirth: json['days_until_birth'] ?? 0,
      trimester: json['trimester'] ?? 1,
      babySize: json['baby_size'] ?? '',
      babySizeDescription: json['baby_size_description'] ?? '',
    );
  }

  String get weekLabel => '$currentWeek. Hafta';
  String get daysLabel => '$daysUntilBirth Gün';
}
