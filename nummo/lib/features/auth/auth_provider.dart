import 'dart:async';
import 'package:flutter/material.dart';
import 'user_model.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  User? _user;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider(this._service) {
    _init();
  }

  Future<void> _init() async {
    _setLoading(true);
    await _service.init();
    _user = _service.currentUser;
    _subscription = _service.authStream.listen((user) {
      _user = user;
      notifyListeners();
    });
    _setLoading(false);
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _service.login(email, password);
      if (user != null) {
        _user = user;
        _setLoading(false);
        return true;
      } else {
        _error = 'Credenciales inválidas';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _service.register(email, password, name);
      if (user != null) {
        _user = user;
        _setLoading(false);
        return true;
      } else {
        _error = 'El email ya está registrado';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _service.dispose();
    super.dispose();
  }
}
