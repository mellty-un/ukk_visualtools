import 'package:supabase_flutter/supabase_flutter.dart';

class DendaService {
  final SupabaseClient _db;

  DendaService(this._db);

  // ================= GET ALL =================
  Future<List<Map<String, dynamic>>> getAllDenda() async {
    try {
      // Ambil semua data dari tabel denda sesuai schema
      final res = await _db
          .from('denda')
          .select('id_denda, id_pengembalian, jenis_denda, total_denda, status_bayar, created_at')
          .order('created_at', ascending: false);

      // Pastikan hasil berupa List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw 'Gagal mengambil data denda: $e';
    }
  }

  // ================= INSERT =================
  Future<void> addDenda(Map<String, dynamic> data) async {
    try {
      final res = await _db
          .from('denda')
          .insert({
            'id_pengembalian': data['id_pengembalian'], 
            'jenis_denda': data['jenis_denda'], 
            'total_denda': data['total_denda'] ?? 0, 
            'status_bayar': data['status_bayar'] ?? 'belum_bayar',
          })
          .select();

      if (res.isEmpty) {
        throw 'Gagal menambahkan denda.';
      }
    } catch (e) {
      throw 'Insert error: $e';
    }
  }

  // ================= UPDATE =================
  Future<void> updateDenda(int id, Map<String, dynamic> data) async {
    try {
      final res = await _db
          .from('denda')
          .update({
            'id_pengembalian': data['id_pengembalian'], 
            'jenis_denda': data['jenis_denda'], 
            'total_denda': data['total_denda'], 
            'status_bayar': data['status_bayar'],
          })
          .eq('id_denda', id)
          .select();

      if (res.isEmpty) {
        throw 'Gagal mengupdate denda. ID tidak ditemukan.';
      }
    } catch (e) {
      throw 'Update error: $e';
    }
  }

  // ================= DELETE =================
  Future<void> deleteDenda(int id) async {
    try {
      final res = await _db
          .from('denda')
          .delete()
          .eq('id_denda', id)
          .select();

      if (res.isEmpty) {
        throw 'Denda tidak ditemukan atau gagal dihapus.';
      }
    } catch (e) {
      throw 'Delete error: $e';
    }
  }
}
