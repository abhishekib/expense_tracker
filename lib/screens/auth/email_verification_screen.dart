import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  bool _isEmailSent = false;

  Future<void> _sendVerificationEmail() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      setState(() => _isEmailSent = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.email, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Verify Your Email Address',
              // style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 20),
            Text(
              'We\'ve sent a verification email to your email address. '
              'Please check your inbox and verify your email to continue.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendVerificationEmail,
              child:
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(_isEmailSent ? 'Email Resent' : 'Resend Email'),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: _checkEmailVerified,
              child: Text('I\'ve Verified My Email'),
            ),
            TextButton(
              onPressed:
                  () =>
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).signOut(),
              child: Text('Use different email'),
            ),
          ],
        ),
      ),
    );
  }
}
