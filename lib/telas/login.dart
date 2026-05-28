import 'package:flutter/material.dart';
import '../../servicos/autenticacao.dart';
import '../../telas/cadastro.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _controleEmail = TextEditingController();
  final _controleSenha = TextEditingController();
  final _servicoAutenticacao = AuthService();
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      String? result = await _servicoAutenticacao.loginWithEmail(
        _controleEmail.text.trim(),
        _controleSenha.text.trim(),
      );
      setState(() => _isLoading = false);

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _controleEmail,
                decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Digite seu e-mail' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controleSenha,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Digite sua senha' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                      child: const Text('Entrar'),
                    ),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TelaRegistro())),
                child: const Text('Não tem uma conta? Cadastre-se'),
              )
            ],
          ),
        ),
      ),
    );
  }
}