import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class MyAuthProvider with ChangeNotifier {
  final _authService = AuthService();
  User? user;

  MyAuthProvider() {
    _authService.authState.listen((u) {
      user = u;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    try {
      await _authService.login(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _authService.signUp(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() => _authService.logout();
}
