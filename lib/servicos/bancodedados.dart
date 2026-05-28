import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelos/task_models.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = 'tasks';

  // CREATE (Criar Tarefa)
  Future<void> addTask(String title, String userId) async {
    await _db.collection(collection).add({
      'title': title,
      'isDone': false,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // READ (Ler tarefas apenas do usuário logado)
  Stream<List<TaskModel>> getTasks(String userId) {
    return _db
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  // UPDATE (Atualizar status da tarefa)
  Future<void> toggleTaskStatus(String id, bool currentStatus) async {
    await _db.collection(collection).doc(id).update({'isDone': !currentStatus});
  }

  // DELETE (Deletar tarefa)
  Future<void> deleteTask(String id) async {
    await _db.collection(collection).doc(id).delete();
  }
}