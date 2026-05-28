import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para monitorar o estado da autenticação (Logado ou não)
  Stream<User?> get userState => _auth.authStateChanges();

  // Cadastro com Email e Senha
  Future<String?> registerWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      return _translateError(e.code);
    }
  }

  // Login com Email e Senha
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      return _translateError(e.code);
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Tratamento de erros básico
  String _translateError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      default:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
}