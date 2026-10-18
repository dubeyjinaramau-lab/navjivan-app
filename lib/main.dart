
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/id_verify_screen.dart';
import 'screens/matches_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SecondShadiApp());
}

class SecondShadiApp extends StatelessWidget {
  const SecondShadiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Second Shadi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF81C784),
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/id_verify': (context) => const IdVerifyScreen(),
        '/matches': (context) => const MatchesScreen(),
        '/chat': (context) => const ChatScreen(
          partnerName: 'User',
        ),
        '/profile': (context) => const ProfileScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
