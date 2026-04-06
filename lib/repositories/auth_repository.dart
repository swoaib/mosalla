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

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
