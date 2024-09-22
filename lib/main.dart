import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:blood_link_app/auth/login.dart';  // Import LoginScreen
import 'package:blood_link_app/splash_screen.dart';  // Import SplashScreen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCvuMMS41RCPViVjljGsUq5zg6lwHp5E9M",
      appId: "1:578246023044:android:806beb9d8a27f1376eefd1",
      messagingSenderId: "578246023044",
      projectId: "bloodlinkapp-9f18b",
      storageBucket: 'gs://bloodlinkapp-9f18b.appspot.com',
    ),
  );

  runApp(const BloodLinkApp());
}

class BloodLinkApp extends StatelessWidget {
  const BloodLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BloodLink',
      theme: ThemeData(
        primarySwatch: Colors.red, // Match app theme
      ),
      home: const SplashScreen(), // Start with SplashScreen
      debugShowCheckedModeBanner: false,
    );
  }
}