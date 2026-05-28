import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  String id;
  String titulo;
  bool isDone;
  String userId;

  TaskModel({
    required this.id,
    required this.titulo,
    this.isDone = false,
    required this.userId,
  });

  // Converte DocumentSnapshot do Firestore para o modelo Dart
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      titulo: data['title'] ?? '',
      isDone: data['isDone'] ?? false,
      userId: data['userId'] ?? '',
    );
  }

  // Converte o modelo Dart para JSON para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': titulo,
      'isDone': isDone,
      'userId': userId,
    };
  }
}