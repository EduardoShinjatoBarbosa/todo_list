import 'package:flutter/material.dart';
import '../../servicos/autenticacao.dart';

class TelaRegistro extends StatefulWidget {
  const TelaRegistro({super.key});

  @override
  State<TelaRegistro> createState() => _TelaRegistroState();
}

class _TelaRegistroState extends State<TelaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      String? result = await _authService.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      setState(() => _isLoading = false);

      if (result == null) {
        if (mounted) Navigator.of(context).pop(); // Volta para a tela de login
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Digite um e-mail válido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha (mínimo 6 caracteres)', border: OutlineInputBorder()),
                validator: (val) => val!.length < 6 ? 'Senha muito curta' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                      child: const Text('Cadastrar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}