// import 'package:estudo/auth/auth.dart';
// import 'package:estudo/screens/home_screen.dart';
// import 'package:estudo/login/login.dart';
// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   final AuthService _authService = AuthService();

//   void _logout(BuildContext context) {
//     _authService.signOut();
//     Navigator.pushReplacement(
//         context, MaterialPageRoute(builder: (context) => LoginScreen()));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Bem-vindo"),
//         actions: [
//           IconButton(
//               onPressed: () => _logout(context), icon: Icon(Icons.logout)),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             Text("Você está logado!"),
//             ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(builder: (context) => HomePage()),
//                   );
//                 },
//                 child: Text('Hoem App'))
//           ],
//         ),
//       ),
//     );
//   }
// }
