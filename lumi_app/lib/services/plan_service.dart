import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PlanService {
  final AuthService _authService = AuthService();

  String get baseUrl => AuthService.baseUrl;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authService.accessToken != null)
      'Authorization': 'Bearer ${_authService.accessToken}',
  };

  // Singleton pattern
  static final PlanService _instance = PlanService._internal();
  factory PlanService() => _instance;
  PlanService._internal();

  /// Bugünün planlarını getir
  Future<PlanResult<List<PlanData>>> getTodayPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plans/today/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final plans = data.map((e) => PlanData.fromJson(e)).toList();
        return PlanResult.success(plans);
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final refreshed = await _authService.refreshAccessToken();
        if (refreshed) {
          return getTodayPlans(); // Retry with new token
        }
        return PlanResult.error(
          'Oturum süresi doldu. Lütfen tekrar giriş yapın.',
        );
      } else if (response.statusCode == 404) {
        // Endpoint yoksa boş liste döndür
        return PlanResult.success([]);
      } else {
        return PlanResult.error('Planlar alınamadı');
      }
    } catch (e) {
      // Backend'de henüz endpoint yoksa boş liste döndür
      return PlanResult.success([]);
    }
  }

  /// Tüm planları getir
  Future<PlanResult<List<PlanData>>> getAllPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plans/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final plans = data.map((e) => PlanData.fromJson(e)).toList();
        return PlanResult.success(plans);
      } else if (response.statusCode == 404) {
        return PlanResult.success([]);
      } else {
        return PlanResult.error('Planlar alınamadı');
      }
    } catch (e) {
      return PlanResult.success([]);
    }
  }

  /// Yeni plan oluştur
  Future<PlanResult<PlanData>> createPlan({
    required String title,
    String? description,
    required DateTime scheduledTime,
    PlanCategory category = PlanCategory.other,
    bool isRecurring = false,
  }) async {
    try {
      final body = {
        'title': title,
        if (description != null) 'description': description,
        'scheduled_time': scheduledTime.toIso8601String(),
        'category': category.name,
        'is_recurring': isRecurring,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/plans/'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PlanResult.success(PlanData.fromJson(data));
      } else {
        final data = jsonDecode(response.body);
        return PlanResult.error(data['detail'] ?? 'Plan oluşturulamadı');
      }
    } catch (e) {
      return PlanResult.error('Bağlantı hatası: $e');
    }
  }

  /// Plan güncelle
  Future<PlanResult<PlanData>> updatePlan({
    required int planId,
    String? title,
    String? description,
    DateTime? scheduledTime,
    PlanCategory? category,
    bool? isCompleted,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (scheduledTime != null){
        body['scheduled_time'] = scheduledTime.toIso8601String().split('T')[0];
      }
      if (category != null){
        body['category'] = category.name;
      }
      if (isCompleted != null){
        body['is_completed'] = isCompleted;
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/plans/$planId/'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PlanResult.success(PlanData.fromJson(data));
      } else {
        return PlanResult.error('Plan güncellenemedi');
      }
    } catch (e) {
      return PlanResult.error('Bağlantı hatası: $e');
    }
  }

  /// Planı tamamlandı olarak işaretle
  Future<PlanResult<PlanData>> togglePlanCompletion(
    int planId,
    bool isCompleted,
  ) async {
    return updatePlan(planId: planId, isCompleted: isCompleted);
  }

  /// Plan sil
  Future<PlanResult<void>> deletePlan(int planId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/plans/$planId/'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        return PlanResult.success(null);
      } else {
        return PlanResult.error('Plan silinemedi');
      }
    } catch (e) {
      return PlanResult.error('Bağlantı hatası: $e');
    }
  }
}

/// Plan kategorileri
enum PlanCategory {
  medication, // İlaç
  appointment, // Randevu
  exercise, // Egzersiz
  nutrition, // Beslenme
  checkup, // Kontrol
  other, // Diğer
}

extension PlanCategoryExtension on PlanCategory {
  String get displayName {
    switch (this) {
      case PlanCategory.medication:
        return 'İlaç';
      case PlanCategory.appointment:
        return 'Randevu';
      case PlanCategory.exercise:
        return 'Egzersiz';
      case PlanCategory.nutrition:
        return 'Beslenme';
      case PlanCategory.checkup:
        return 'Kontrol';
      case PlanCategory.other:
        return 'Diğer';
    }
  }

  Color get color {
    switch (this) {
      case PlanCategory.medication:
        return const Color(0xFFEC4899); // Pink
      case PlanCategory.appointment:
        return const Color(0xFFA855F7); // Purple
      case PlanCategory.exercise:
        return const Color(0xFF0EA5E9); // Blue
      case PlanCategory.nutrition:
        return const Color(0xFF22C55E); // Green
      case PlanCategory.checkup:
        return const Color(0xFFF59E0B); // Orange
      case PlanCategory.other:
        return const Color(0xFF6B7280); // Gray
    }
  }

  static PlanCategory fromString(String value) {
    return PlanCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PlanCategory.other,
    );
  }
}

/// Plan işlem sonucu
class PlanResult<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;

  PlanResult._({required this.isSuccess, this.data, this.errorMessage});

  factory PlanResult.success(T? data) =>
      PlanResult._(isSuccess: true, data: data);
  factory PlanResult.error(String message) =>
      PlanResult._(isSuccess: false, errorMessage: message);
}

/// Plan verisi
class PlanData {
  final int id;
  final String title;
  final String? description;
  final DateTime scheduledTime;
  final PlanCategory category;
  final bool isCompleted;
  final bool isRecurring;
  final DateTime createdAt;

  PlanData({
    required this.id,
    required this.title,
    this.description,
    required this.scheduledTime,
    required this.category,
    required this.isCompleted,
    required this.isRecurring,
    required this.createdAt,
  });

  factory PlanData.fromJson(Map<String, dynamic> json) {
    return PlanData(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      scheduledTime: DateTime.parse(json['scheduled_time']),
      category: PlanCategoryExtension.fromString(json['category'] ?? 'other'),
      isCompleted: json['is_completed'] ?? false,
      isRecurring: json['is_recurring'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get timeLabel {
    final hour = scheduledTime.hour.toString().padLeft(2, '0');
    final minute = scheduledTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  PlanData copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? scheduledTime,
    PlanCategory? category,
    bool? isCompleted,
    bool? isRecurring,
    DateTime? createdAt,
  }) {
    return PlanData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
