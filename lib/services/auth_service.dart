import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================
  // Register dengan Email/Password
  // =========================
  Future<UserCredential?> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // print('Register error: $e');
      return null;
    }
  }

  // =========================
  // Login dengan Email/Password
  // =========================
  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // print('Login error: $e');
      return null;
    }
  }

  // =========================
  // Login / Sign-Up dengan Google
  // =========================
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // user batal login

      // 2. Dapatkan auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Buat credential untuk Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in ke Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // print('Google Sign-In error: $e');
      return null;
    }
  }

  // =========================
  // Logout
  // =========================
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut(); // logout Google juga
    } catch (e) {
      // print('Logout error: $e');
    }
  }

  // =========================
  // Ambil user saat ini
  // =========================
  User? get currentUser => _auth.currentUser;
}
