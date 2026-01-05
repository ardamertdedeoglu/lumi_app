import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Backend URL - Duruma göre ayarlayın:
  // Android emulator için: 10.0.2.2
  // iOS simulator için: localhost
  // Windows'ta Chrome/Edge için: localhost
  // Gerçek cihaz için: Bilgisayarın yerel IP'si (örn: 192.168.1.x)
  //
  // IP adresinizi bulmak için: Windows'ta cmd'de "ipconfig" yazın
  // "IPv4 Address" satırındaki adresi kullanın
  static const String baseUrl =
      'https://lumiappbackend-production.up.railway.app/api';

  // Alternatif URL'ler (test için):
  // static const String baseUrl = 'http://localhost:80/api';  // Web/Windows için
  // static const String baseUrl = 'http://192.168.1.X:80/api'; // Gerçek cihaz için

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _userData;

  /// Kayıtlı token'ları yükle
  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      _userData = jsonDecode(userDataString);
    }
  }

  /// Token'ları kaydet
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  /// Kullanıcı verilerini kaydet
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
    _userData = userData;
  }

  /// Token'ları ve kullanıcı verilerini sil
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
    _accessToken = null;
    _refreshToken = null;
    _userData = null;
  }

  /// Kullanıcı giriş yapmış mı kontrol et
  bool get isLoggedIn => _accessToken != null;

  /// Access token getter
  String? get accessToken => _accessToken;

  /// Kullanıcı verileri getter
  Map<String, dynamic>? get userData => _userData;

  /// Giriş yap
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveTokens(data['access'], data['refresh']);
        if (data['user'] != null) {
          await _saveUserData(data['user']);
        }
        return AuthResult(success: true, message: 'Giriş başarılı');
      } else {
        String errorMessage = 'Giriş başarısız';
        if (data['non_field_errors'] != null) {
          errorMessage = data['non_field_errors'][0];
        } else if (data['detail'] != null) {
          errorMessage = data['detail'];
        }
        return AuthResult(success: false, message: errorMessage);
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Bağlantı hatası: $e');
    }
  }

  /// Kayıt ol
  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String role = 'mother',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/registration/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password1': password,
          'password2': password,
          'role': role,
        }),
      );

      // HTML yanıtı kontrolü (sunucu hatası)
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html') ||
          response.body.trim().startsWith('<HTML')) {
        return AuthResult(
          success: false,
          message:
              'Sunucu hatası (${response.statusCode}). Backend çalışıyor mu kontrol edin.',
        );
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Kayıt başarılı, token'ları kaydet
        if (data['access'] != null && data['refresh'] != null) {
          await _saveTokens(data['access'], data['refresh']);
        }
        if (data['user'] != null) {
          await _saveUserData(data['user']);
        }
        return AuthResult(success: true, message: 'Kayıt başarılı');
      } else {
        String errorMessage = 'Kayıt başarısız';
        if (data['email'] != null) {
          errorMessage = data['email'][0];
        } else if (data['password1'] != null) {
          errorMessage = data['password1'][0];
        } else if (data['non_field_errors'] != null) {
          errorMessage = data['non_field_errors'][0];
        }
        return AuthResult(success: false, message: errorMessage);
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Bağlantı hatası: $e');
    }
  }

  /// Çıkış yap
  Future<void> logout() async {
    try {
      if (_accessToken != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
        );
      }
    } catch (e) {
      // Çıkış yapılamasa bile token'ları sil
    }
    await clearTokens();
  }

  /// Token'ı yenile
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['access'], data['refresh'] ?? _refreshToken!);
        return true;
      }
    } catch (e) {
      // Token yenileme başarısız
    }
    return false;
  }

  /// Email'in kayıtlı olup olmadığını kontrol et
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check-email/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] ?? false;
      }
    } catch (e) {
      // Hata durumunda false döndür
    }
    return false;
  }
}

/// Authentication sonuç sınıfı
class AuthResult {
  final bool success;
  final String message;

  AuthResult({required this.success, required this.message});
}
