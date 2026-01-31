import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<bool> login(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  User? get currentUser => _supabase.auth.currentUser;

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}