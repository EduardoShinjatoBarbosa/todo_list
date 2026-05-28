# 📝 Sistema de Gerenciamento de Tarefas (To-Do List)

Um aplicativo mobile para gerenciamento pessoal de tarefas diárias, desenvolvido em **Flutter** e integrado ao **Google Firebase** para autenticação e armazenamento de dados em tempo real.

---

## 🚀 Funcionalidades Principais

* **Autenticação Segura:** Cadastro de novos usuários e login com validação de e-mail e senha via *Firebase Authentication*.
* **CRUD de Tarefas:** Criação, leitura, atualização (marcar como concluída) e exclusão de tarefas em tempo real.
* **Isolamento de Dados:** Cada usuário autenticado visualiza e gerencia estritamente as suas próprias tarefas, garantindo total privacidade.
* **Interface Reativa:** Sincronização assíncrona automática com o banco de dados (as alterações refletem no app instantaneamente).

---

## 🛠️ Tecnologias Utilizadas

* [Flutter](https://flutter.dev/) - SDK de desenvolvimento mobile.
* [Dart](https://dart.dev/) - Linguagem de programação do ecossistema.
* [Firebase Authentication](https://firebase.google.com/docs/auth) - Gerenciamento de usuários e segurança de acesso.
* [Cloud Firestore](https://firebase.google.com/docs/firestore) - Banco de dados NoSQL orientado a documentos.

---

## 📦 Estrutura de Pastas Simples

O projeto foi organizado separando as responsabilidades de interface (`screens`), dados (`models`) e comunicação externa (`services`):

```text
lib/
├── firebase_options.dart  # Chaves de API geradas automaticamente
├── main.dart              # Inicialização do Firebase e ponto de partida do app
├── models/
│   └── tarefa_model.dart  # Molde do objeto de dados da tarefa
├── screens/
│   ├── login_screen.dart  # Tela de login
│   ├── register_screen.dart # Tela de cadastro de novas contas
│   └── home_screen.dart   # Painel com a listagem de tarefas
└── services/
    ├── auth_service.dart  # Lógica de login/cadastro no Firebase
    └── database_service.dart # Operações do banco de dados Cloud Firestore
