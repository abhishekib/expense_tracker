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

  Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  /*   Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      if (photoUrl != null) {
        await _auth.currentUser?.updatePhotoURL(photoUrl);
      }
      _user = _auth.currentUser;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  } */

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
