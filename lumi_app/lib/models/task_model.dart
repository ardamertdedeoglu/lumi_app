import 'package:flutter/material.dart';

enum TaskStatus { pending, completed, urgent }

class TaskModel {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final TaskStatus status;
  final Color accentColor;
  final bool isCompleted;

  const TaskModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    this.status = TaskStatus.pending,
    required this.accentColor,
    this.isCompleted = false,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? time,
    TaskStatus? status,
    Color? accentColor,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      status: status ?? this.status,
      accentColor: accentColor ?? this.accentColor,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Demo tasks for testing
  static List<TaskModel> demoTasks = [
    TaskModel(
      id: '1',
      title: 'Folik Asit & Demir',
      subtitle: 'Tok karnına • 1 Tablet',
      time: '09:00',
      status: TaskStatus.completed,
      accentColor: const Color(0xFFEC4899),
      isCompleted: true,
    ),
    TaskModel(
      id: '2',
      title: 'Doktor Kontrolü',
      subtitle: 'Dr. Ayşe Yılmaz ile Ultrason',
      time: '14:30',
      status: TaskStatus.urgent,
      accentColor: const Color(0xFFA855F7),
      isCompleted: false,
    ),
    TaskModel(
      id: '3',
      title: 'Hamile Yogası',
      subtitle: 'AI Önerisi: Sırt ağrıları için',
      time: '18:00',
      status: TaskStatus.pending,
      accentColor: const Color(0xFF0EA5E9),
      isCompleted: false,
    ),
  ];
}
