import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../servicos/autenticacao.dart';
import '../../telas/login.dart';
import '../../telas/home.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // OBRIGATÓRIO: Passar as opções aqui dentro
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trabalho Flutter Tasks',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AuthWrapper(), // Decisor de rota protegida
    );
  }
}

// Componente de proteção de rotas
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.userState,
      builder: (context, snapshot) {
        // Se estiver carregando o estado de login
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // Se o usuário estiver autenticado, vai para a Home
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(user: snapshot.data!);
        }
        // Se não estiver autenticado, vai para o Login
        return const TelaLogin();
      },
    );
  }
}