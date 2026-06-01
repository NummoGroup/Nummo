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
      _error = 'Error al iniciar sesión. Revisa tus datos.';
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
        _setLoading(false);
        return true;
      } else {
        _error = 'El email ya está registrado';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error al registrar. El correo ya existe o es inválido.';
      _setLoading(false);
      return false;
    }
  }

  // --- LAS FUNCIONES NUEVAS QUE FALTABAN ESTÁN ACÁ ---

  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _service.loginWithGoogle();
      if (user != null) {
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false; 
    } catch (e) {
      _error = 'Error al conectar con Google.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = null;
    try {
      await _service.resetPassword(email);
      _setLoading(false);
      return true; 
    } catch (e) {
      _error = 'No se encontró una cuenta con ese correo.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfileName(String name) async {
    _setLoading(true);
    _error = null;
    try {
      await _service.updateProfileName(name);
      if (_user != null) {
        _user = _user!.copyWith(name: name); // Actualiza la UI inmediatamente
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Error al actualizar el nombre.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    _error = null;
    try {
      await _service.updatePassword(newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Error al actualizar la contraseña. Puede que necesites volver a iniciar sesión.';
      _setLoading(false);
      return false;
    }
  }

  // ----------------------------------------------------

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