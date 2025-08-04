import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Email & password signup
  Future<void> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } finally {
      _setLoading(false);
    }
  }

  /// Email & password login
  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ Google Sign-In for mobile & web
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      if (kIsWeb) {
        // Web sign-in flow
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) throw FirebaseAuthException(code: 'ERROR_ABORTED_BY_USER', message: 'Login canceled');
        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        await _auth.signInWithCredential(credential);
      } else {
        // Android/iOS sign-in
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) throw FirebaseAuthException(code: 'ERROR_ABORTED_BY_USER', message: 'Login canceled');
        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        await _auth.signInWithCredential(credential);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
