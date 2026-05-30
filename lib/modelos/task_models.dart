import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title; // ◄─ Padronizado para 'title'
  final bool isDone;
  final String userId;
  final String priority;

  TaskModel({
    required this.id,
    required this.title, // ◄─ Padronizado aqui
    required this.isDone,
    required this.userId,
    required this.priority,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '', // ◄─ Sincronizado com o Firebase
      isDone: data['isDone'] ?? false,
      userId: data['userId'] ?? '',
      priority: data['priority'] ?? 'Baixa',
    );
  }
}