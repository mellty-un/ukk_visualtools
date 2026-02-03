import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlatService {
  static final SupabaseClient _client =
      Supabase.instance.client;

  // HARUS SAMA DENGAN NAMA BUCKET DI SUPABASE
  static const String _bucket = 'alat';

  // ================= UPLOAD GAMBAR =================
  static Future<String?> uploadImage({
    File? mobileFile,
    Uint8List? webBytes,
    required String namaAlat,
  }) async {
    try {
      if (mobileFile == null && webBytes == null) {
        return null;
      }

      final safeName = namaAlat
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '_');

      final fileName =
          '${safeName}_${DateTime.now().millisecondsSinceEpoch}.png';

      final storage = _client.storage.from(_bucket);

      if (mobileFile != null) {
        await storage.upload(
          fileName,
          mobileFile,
          fileOptions: const FileOptions(
            contentType: 'image/png',
            upsert: false,
          ),
        );
      } else {
        await storage.uploadBinary(
          fileName,
          webBytes!,
          fileOptions: const FileOptions(
            contentType: 'image/png',
            upsert: false,
          ),
        );
      }

      return storage.getPublicUrl(fileName);
    } on StorageException catch (e) {
      print('STORAGE ERROR: ${e.message}');
      return null;
    } catch (e) {
      print('UPLOAD IMAGE ERROR: $e');
      return null;
    }
  }

  // ================= GET DATA =================
  static Future<List<Map<String, dynamic>>> getAlat() async {
    try {
      final response = await _client
          .from('alat')
          .select(
              'id_alat, id_kategori, nama_alat, kondisi, status, image_url')
          .order('id_alat', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('GET ALAT ERROR: $e');
      return [];
    }
  }

  // ================= INSERT =================
  static Future<void> insertAlat({
    required int idKategori,
    required String nama,
    required int jumlah,
    required String kondisi,
    required String status,
    int denda = 0,
    String? imageUrl,
  }) async {
    try {
      await _client.from('alat').insert({
        'id_kategori': idKategori,
        'nama_alat': nama,
        'jumlah_total': jumlah,
        'kondisi': kondisi,
        'status': status,
        'denda_per_hari': denda,
        'image_url': imageUrl,
      });
    } catch (e) {
      print('INSERT ALAT ERROR: $e');
      rethrow;
    }
  }

  // ================= UPDATE (EDIT BARIS YANG SAMA) =================
  static Future<void> updateAlat({
    required int idAlat,
    required int idKategori,
    required String nama,
    required int jumlah,
    required String kondisi,
    required String status,
    int denda = 0,
    String? imageUrl,
  }) async {
    try {
      await _client.from('alat').update({
        'id_kategori': idKategori,
        'nama_alat': nama,
        'jumlah_total': jumlah,
        'kondisi': kondisi,
        'status': status,
        'denda_per_hari': denda,
        'image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_alat', idAlat);
    } catch (e) {
      print('UPDATE ALAT ERROR: $e');
      rethrow;
    }
  }

  // ================= DELETE DB + GAMBAR =================
  static Future<void> deleteAlat({
    required int idAlat,
    String? imageUrl,
  }) async {
    try {
      // Hapus file dari bucket kalau ada
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final uri = Uri.parse(imageUrl);
        final path = uri.pathSegments.last;

        await _client.storage.from(_bucket).remove([path]);
      }

      // Hapus dari tabel
      await _client.from('alat').delete().eq('id_alat', idAlat);
    } catch (e) {
      print('DELETE ALAT ERROR: $e');
      rethrow;
    }
  }
}
