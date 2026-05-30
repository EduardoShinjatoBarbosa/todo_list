import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelos/task_models.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = 'tasks';

  // CREATE (Criar Tarefa com Prioridade)
  Future<void> addTask(String title, String userId, String priority) async {
    await _db.collection(collection).add({
      'title': title,
      'isDone': false,
      'userId': userId,
      'priority': priority, 
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // READ (Ler tarefas do usuário logado)
  Stream<List<TaskModel>> getTasks(String userId) {
    return _db
        .collection(collection)
        .where('userId', isEqualTo: userId)
        // Nota: Se mantiver o orderBy abaixo sem o índice composto no console do Firebase, 
        // remova-o temporariamente se o app travar as leituras.
        //.orderBy('createdAt', descending: true) 
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  // UPDATE (Inverter status de conclusão - Checkbox)
  Future<void> toggleTaskStatus(String id, bool currentStatus) async {
    await _db.collection(collection).doc(id).update({'isDone': !currentStatus});
  }

  // UPDATE (Editar o título da tarefa - Padronizado para updateTaskTitle)
  Future<void> updateTask(String id, String newTitle,String newPriority) async {
    await _db.collection(collection).doc(id).update({
      'title': newTitle,
      'priority': newPriority,
    });
  }

  // DELETE (Deletar tarefa)
  Future<void> deleteTask(String id) async {
    await _db.collection(collection).doc(id).delete();
  }
}