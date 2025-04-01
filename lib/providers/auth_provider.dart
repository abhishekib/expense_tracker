import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _authService.user.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password) async {
    try {
      _user = await _authService.signUpWithEmail(email, password);
      // Send email verification
      await _user?.sendEmailVerification();
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw FirebaseAuthException(code: e.code, message: e.message);
      }
      throw Exception('Signup failed');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _user = await _authService.signInWithEmail(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _user = await _authService.signInWithGoogle();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
