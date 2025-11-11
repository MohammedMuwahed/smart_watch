import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:smart_watch/routes/index.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Column(
        children: [
          const Text('A verification email has been sent to your email'),
          const Text('if you do not see it, please check your spam folder'),
          const Text(
            'If you did not receive a verification email, please click the button below to send one',
          ),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            },
            child: const Text('Send Email Verification'),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: Text('I already verify my email I want to login'),
          ),
        ],
      ),
    );
  }
}
