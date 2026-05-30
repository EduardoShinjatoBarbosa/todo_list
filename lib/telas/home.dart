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

  // Cores mais suaves e modernas para as prioridades
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Alta':
        return Colors.redAccent;
      case 'Média':
        return Colors.orangeAccent;
      case 'Baixa':
      default:
        return Colors.teal;
    }
  }

  int _getPriorityWeight(String priority) {
    switch (priority) {
      case 'Alta':
        return 3;
      case 'Média':
        return 2;
      case 'Baixa':
      default:
        return 1;
    }
  }

  void _showTaskDialog(BuildContext context) {
    String selectedPriority = 'Baixa';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white, // Fundo do dialog branco
          title: const Text('Nova Tarefa', style: TextStyle(color: Colors.black87)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  hintText: 'Digite o nome da tarefa',
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                dropdownColor: Colors.white,
                items: ['Baixa', 'Média', 'Alta'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setDialogState(() {
                    selectedPriority = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () async {
                if (_taskController.text.isNotEmpty) {
                  await _dbService.addTask(_taskController.text, user.uid, selectedPriority);
                  _taskController.clear();
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, TaskModel task) {
  final editController = TextEditingController(text: task.title);
  String selectedPriority = task.priority; // ◄─ Pega a prioridade atual da tarefa como padrão

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder( // ◄─ StatefulBuilder adicionado para atualizar o Dropdown na tela
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Editar Tarefa', style: TextStyle(color: Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editController,
              decoration: const InputDecoration(hintText: 'Digite o novo nome da tarefa'),
            ),
            const SizedBox(height: 16),
            // DROPDOWN PARA MUDAR A PRIORIDADE NA EDIÇÃO
            DropdownButtonFormField<String>(
              value: selectedPriority,
              decoration: const InputDecoration(labelText: 'Prioridade'),
              dropdownColor: Colors.white,
              items: ['Baixa', 'Média', 'Alta'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setDialogState(() {
                  selectedPriority = newValue!; // ◄─ Atualiza o estado interno do Dialog
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              if (editController.text.trim().isNotEmpty) {
                // ◄─ Chama o método atualizado passando o ID, o novo Título e a nova Prioridade
                await _dbService.updateTask(task.id, editController.text.trim(), selectedPriority);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    )
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Define o fundo de toda a tela como Branco Puro
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove a sombra feia da barra superior
        centerTitle: true,
        title: const Text(
          'Minhas Tarefas',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.black87),
            onPressed: () => _authService.logout(),
          ),
        ],
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _dbService.getTasks(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro no Stream: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhuma tarefa cadastrada.', style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          final tasks = snapshot.data!;
          tasks.sort((a, b) => _getPriorityWeight(b.priority).compareTo(_getPriorityWeight(a.priority)));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final priorityColor = _getPriorityColor(task.priority);

              // TRANSFORMAÇÃO EM CAIXAS (Cards individuais com bordas e sombras leves)
             return Container(
  margin: const EdgeInsets.only(bottom: 12), // Espaço entre as caixas
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12), // Bordas arredondadas modernas
    border: Border.all(color: Colors.grey.shade200, width: 1.5), // Linha sutil ao redor
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 8,
        offset: const Offset(0, 4), // Sombra leve
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(
      // CORRIGIDO: A borda lateral de prioridade agora está dentro do BoxDecoration correto!
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: priorityColor, width: 6),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          task.title,
          style: TextStyle(
            color: task.isDone ? Colors.grey : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task.priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        leading: Checkbox(
          activeColor: Colors.blueAccent,
          checkColor: Colors.white,
          value: task.isDone,
          onChanged: (_) => _dbService.toggleTaskStatus(task.id, task.isDone),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
              onPressed: () => _showEditTaskDialog(context, task),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _dbService.deleteTask(task.id),
            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showTaskDialog(context),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}