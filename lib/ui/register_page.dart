import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  String _email = '';
  String _password = '';
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1. Create the user
      final user = await context.read<AuthService>().register(
            email: _email,
            password: _password,
          );

      if (user != null && mounted) {
        // 2. Try to Send the email
        // We wrap this in its own try-catch so it doesn't stop the flow
        try {
          await context.read<AuthService>().sendEmailVerification();
        } catch (emailError) {
          debugPrint("Email trigger failed: $emailError");
          // Ignore this error, the user can click "Resend" on the next page
        }

        // 3. FORCE Navigation to verify page regardless of email success
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.verifyEmail,
            (route) => false,
          );
        }
      }
    } catch (e) {
      // 4. This catch block now ONLY catches Registration errors (like email in use)
      if (mounted) {
        setState(() {
          _error = e.toString().contains('email-already-in-use') ? 'Email is already registered. Please Login.' : 'Registration failed. Try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _buildDecoration(String label, String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      labelStyle: const TextStyle(color: Colors.blueGrey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.black87);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        automaticallyImplyLeading: false, // REMOVED BACK BUTTON HERE
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.blue.shade500],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.person_add_rounded, size: 70, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Create Account",
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Join us to get started",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),

                    // Email Field
                    TextFormField(
                      style: textStyle,
                      decoration: _buildDecoration('Email Address', 'Enter your email', Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter email';
                        if (!v.contains('@')) return 'Enter valid email';
                        return null;
                      },
                      onSaved: (v) => _email = v!.trim(),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      style: textStyle,
                      obscureText: _obscurePassword,
                      decoration: _buildDecoration(
                        'Password',
                        'Enter your password',
                        Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter password';
                        if (v.length < 6) return 'Password must be ≥ 6 chars';
                        return null;
                      },
                      onSaved: (v) => _password = v!.trim(),
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    TextFormField(
                      style: textStyle,
                      obscureText: _obscureConfirmPassword,
                      decoration: _buildDecoration(
                        'Confirm Password',
                        'Re-type your password',
                        Icons.lock_reset_outlined,
                        suffix: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please confirm your password';
                        if (v != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('SIGN UP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Back to Login Button
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          children: [
                            const TextSpan(text: "Already have an account? "),
                            TextSpan(
                              text: "Login",
                              style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
