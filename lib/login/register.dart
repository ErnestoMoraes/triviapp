// import 'package:estudo/auth/auth.dart';
// import 'package:estudo/login/home.dart';
// import 'package:flutter/material.dart';

// class RegisterScreen extends StatefulWidget {
//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final AuthService _authService = AuthService();

//   void _register() async {
//     final user = await _authService.registerWithEmailAndPassword(
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
//         SnackBar(content: Text('Erro ao cadastrar!')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Cadastro")),
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
//             ElevatedButton(onPressed: _register, child: Text("Cadastrar")),
//           ],
//         ),
//       ),
//     );
//   }
// }
