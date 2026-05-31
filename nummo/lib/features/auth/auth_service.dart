import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'user_model.dart';

class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  
  // SOLUCIÓN 1: Ahora se exige llamar a la instancia sin paréntesis
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final _authController = StreamController<User?>.broadcast();
  Stream<User?> get authStream => _authController.stream;

  Future<void> init() async {
    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      _authController.add(_userFromFirebase(firebaseUser));
    });
  }

  User? _userFromFirebase(fb_auth.User? firebaseUser) {
    if (firebaseUser == null) return null;
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? 'Usuario',
      balance: 0.0,
      password: '', 
    );
  }

  Future<User?> login(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _userFromFirebase(credential.user);
  }

  Future<User?> register(String email, String password, String name) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    return _userFromFirebase(credential.user);
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // --- GOOGLE SIGN-IN REAL (Adaptado a las reglas de la versión 7+) ---
  Future<User?> loginWithGoogle() async {
    try {
      // Se requiere inicializar antes de arrancar
      await _googleSignIn.initialize();

      // SOLUCIÓN 2: Ahora el método se llama authenticate()
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null; // El usuario canceló la ventana

      // SOLUCIÓN 3: Pedimos el accessToken por separado para que Firebase lo acepte
      final clientAuth = await googleUser.authorizationClient?.authorizeScopes(['email', 'profile']);
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final fb_auth.OAuthCredential credential = fb_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth?.accessToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return _userFromFirebase(userCredential.user);
    } catch (e) {
      return null;
    }
  }

  // LOGOUT REAL (Sin bloqueos)
  Future<void> logout() async {
    // Apagamos Firebase primero, que es el que de verdad importa
    await _firebaseAuth.signOut(); 
    
    // Y le decimos a Google que intente cerrar, pero sin bloquear la app
    try {
      _googleSignIn.signOut(); 
    } catch (e) {
      // Silenciamos cualquier error de Google
    }
  }

  User? get currentUser => _userFromFirebase(_firebaseAuth.currentUser);
  bool get isAuthenticated => currentUser != null;

  Future<void> dispose() async {
    await _authController.close();
  }
}