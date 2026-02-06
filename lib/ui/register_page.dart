import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_watch/services/index.dart';
import 'package:smart_watch/routes/index.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;
  String? _error;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await context.read<AuthService>().register(
        email: _email,
        password: _password,
      );
      if (user != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.verifyEmail);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
              ],
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter email';
                  if (!v.contains('@')) return 'Enter valid email';
                  return null;
                },
                onSaved: (v) => _email = v!.trim(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter password';
                  if (v.length < 6) return 'Password must be ≥ 6 chars';
                  return null;
                },
                onSaved: (v) => _password = v!.trim(),
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
