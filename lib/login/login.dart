// import 'package:estudo/auth/auth.dart';
// import 'package:estudo/login/home.dart';
// import 'package:estudo/login/register.dart';
// import 'package:flutter/material.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final AuthService _authService = AuthService();

//   void _login() async {
//     final user = await _authService.signInWithEmailAndPassword(
//       _emailController.text,
//       _passwordController.text,
//     );

//     if (user != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Erro ao fazer login!')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Login")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(labelText: "Email")),
//             TextField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(labelText: "Senha"),
//                 obscureText: true),
//             SizedBox(height: 20),
//             ElevatedButton(onPressed: _login, child: Text("Login")),
//             TextButton(
//               onPressed: () => Navigator.push(context,
//                   MaterialPageRoute(builder: (context) => RegisterScreen())),
//               child: Text("Não tem conta? Cadastre-se"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
