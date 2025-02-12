import 'package:flutter/material.dart';
import 'package:estudo/auth/auth.dart';
import 'package:estudo/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  // Método de login com Google
  void _loginWithGoogle() async {
    final user = await _authService.signGoogleAuth();
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao fazer login com Google!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Login e Cadastro")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Estou logado: ${_authService.currentUser == null ? 'não' : 'sim'}",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              child: const Text("Atualizar"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginWithGoogle,
              child: const Text("Login com Google"),
            ),
          ],
        ),
      ),
    );
  }
}
