import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../modelos/task_models.dart';
import '../servicos/autenticacao.dart';
import '../servicos/bancodedados.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  HomeScreen({super.key, required this.user});

  final _dbService = DatabaseService();
  final _authService = AuthService();
  final _taskController = TextEditingController();

  void _showTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Tarefa'),
        content: TextField(
          controller: _taskController,
          decoration: const InputDecoration(hintText: 'Digite o nome da tarefa'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (_taskController.text.isNotEmpty) {
                await _dbService.addTask(_taskController.text, user.uid);
                _taskController.clear();
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _authService.logout(),
          ),
        ],
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _dbService.getTasks(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa cadastrada.'));
          }

          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(
                  task.titulo,
                  style: TextStyle(
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                leading: Checkbox(
                  value: task.isDone,
                  onChanged: (_) => _dbService.toggleTaskStatus(task.id, task.isDone),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _dbService.deleteTask(task.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}