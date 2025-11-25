import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smart_watch/firebase_options.dart';
import 'package:smart_watch/services/api_service.dart';
import 'package:smart_watch/utils/index.dart';
import 'package:smart_watch/services/auth_service.dart';
import 'package:smart_watch/providers/sleep_provider.dart';
import 'package:smart_watch/ui/login_page.dart';
import 'package:smart_watch/ui/home_page.dart';
import 'package:smart_watch/ui/verify_email_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SleepProvider()),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => ApiService()),
      ],
      child: const SmartSleepApp(),
    ),
  );
}

class SmartSleepApp extends StatelessWidget {
  const SmartSleepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Sleep Control',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(), // 👈 This decides the start page automatically
    );
  }
}

/// 🧠 AuthGate Widget
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) return const LoginPage();
        if (!user.emailVerified) return const VerifyEmailPage();
        return const HomePage();
      },
    );
  }
}
