import 'package:estudo/firebase_options.dart';
import 'package:estudo/screens/home_screen.dart';
import 'package:estudo/screens/login_screen.dart';
import 'package:estudo/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TriviApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: user == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}
