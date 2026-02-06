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
import 'routes/app_routes.dart';

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
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
