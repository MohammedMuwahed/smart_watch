import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;
  bool _isVerified = false;
  bool _resending = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    final authService = context.read<AuthService>();

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      setState(() => _checking = true);
      await authService.reloadUser();
      final user = authService.currentUser;
      if (user != null && user.emailVerified) {
        setState(() {
          _isVerified = true;
        });
        timer.cancel();
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
      setState(() => _checking = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    setState(() => _resending = true);
    try {
      await context.read<AuthService>().sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email sent again.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = context.read<AuthService>().currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("Verify Your Email")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_unread,
              size: 100,
              color: Colors.tealAccent,
            ),
            const SizedBox(height: 24),
            Text(
              "A verification link has been sent to:",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              userEmail,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _checking
                ? const CircularProgressIndicator()
                : _isVerified
                ? const Text("Email verified! Redirecting...")
                : const Text(
                    "Please verify your email by clicking the link in your inbox.",
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Resend Verification Email"),
              onPressed: _resending ? null : _resendEmail,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await context.read<AuthService>().signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
              child: const Text("Back to Login"),
            ),
          ],
        ),
      ),
    );
  }
}
