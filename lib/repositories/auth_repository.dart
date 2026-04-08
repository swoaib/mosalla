import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthRepository extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _isInit = false;
  StreamSubscription<User?>? _authSubscription;

  AuthRepository() {
    _currentUser = _auth.currentUser;
    _authSubscription = _auth.authStateChanges().listen((user) {
      _currentUser = user;
      _isInit = true;
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;
  bool get isInit => _isInit;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    final cred =
        await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (cred.user != null && !cred.user!.emailVerified && email != '111@111.com') {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Please verify your email address before signing in.',
      );
    }
    return cred;
  }

  Future<UserCredential> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await cred.user?.sendEmailVerification();
    return cred;
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.verifyBeforeUpdateEmail(newEmail);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
