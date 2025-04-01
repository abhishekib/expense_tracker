import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email & Password Sign Up
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw _parseAuthError(e);
    }
  }

  Exception _parseAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return Exception('Please enter a valid email address');
        case 'user-disabled':
          return Exception('This account has been disabled');
        case 'user-not-found':
          return Exception('No account found for this email');
        case 'wrong-password':
          return Exception('Incorrect password');
        case 'email-already-in-use':
          return Exception('Email already in use');
        case 'operation-not-allowed':
          return Exception('Email/password accounts are not enabled');
        case 'weak-password':
          return Exception('Password is too weak');
        default:
          return Exception(e.message ?? 'Authentication failed');
      }
    }
    return Exception('Authentication failed');
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut(); // If using Google Sign-In
  }

  // Auth State Stream
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
