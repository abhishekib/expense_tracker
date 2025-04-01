import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).signIn(_emailController.text.trim(), _passwordController.text.trim());
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter email';
                  if (!value.contains('@')) return 'Please enter valid email';
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter password';
                  if (value.length < 6) return 'Password too short';
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _signIn, child: Text('Sign In')),
              TextButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => SignupScreen()),
                    ),
                child: Text('Create Account'),
              ),
              // Add Google/Facebook sign-in buttons here
            ],
          ),
        ),
      ),
    );
  }
}
