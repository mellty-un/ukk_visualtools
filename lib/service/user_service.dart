import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final _db = Supabase.instance.client;

  // ================= GET =================
  Future<List<Map<String, dynamic>>> getUsers() async {
    final res = await _db
        .from('users')
        .select('id_user, nama, role, username, kelas, jurusan')
        .order('nama');

    return List<Map<String, dynamic>>.from(res);
  }

  // ================= INSERT =================
  Future<void> addUser(Map<String, dynamic> data) async {
    final res = await _db.from('users').insert(data).select();

    if (res.isEmpty) {
      throw 'Insert gagal. Data tidak masuk ke database.';
    }
  }

  // ================= UPDATE =================
  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    final res = await _db
        .from('users')
        .update(data)
        .eq('id_user', id)
        .select();

    if (res.isEmpty) {
      throw 'Update gagal. ID tidak ditemukan atau data tidak berubah.';
    }
  }

  // ================= DELETE =================
 Future<void> deleteUser(int id) async {
  final _db = Supabase.instance.client;

  try {
    // 1. Hapus peminjaman yang terkait user ini
    await _db
        .from('peminjaman')
        .delete()
        .eq('id_user', id)
        .select();

    // 2. Hapus user sendiri
    final res = await _db
        .from('users')
        .delete()
        .eq('id_user', id)
        .select();

    if (res.isEmpty) {
      throw 'Delete gagal. ID tidak ditemukan atau diblok RLS.';
    }
  } catch (e) {
    throw 'Delete error: $e';
  }
}

}
