import 'package:flutter/material.dart';
import 'package:smart_watch/ui/login_page.dart';
import 'package:smart_watch/ui/register_page.dart';
import 'package:smart_watch/ui/home_page.dart';
import 'package:smart_watch/ui/settings_page.dart';
import 'package:smart_watch/ui/verify_email_page.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const home = '/';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    verifyEmail: (_) => const VerifyEmailPage(),
    home: (_) => const HomePage(),
    settings: (_) => const SettingsPage(),
  };
}
