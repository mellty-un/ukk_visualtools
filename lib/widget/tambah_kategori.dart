import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahKategoriDialog extends StatefulWidget {
  const TambahKategoriDialog({super.key});

  @override
  State<TambahKategoriDialog> createState() =>
      _TambahKategoriDialogState();
}

class _TambahKategoriDialogState
    extends State<TambahKategoriDialog> {
  final supabase = Supabase.instance.client;
  final namaC = TextEditingController();
  final ketC = TextEditingController();

  Future<void> simpan() async {
    if (namaC.text.trim().isEmpty) return;

    await supabase.from('kategori').insert({
      'nama_kategori': namaC.text.trim(),
      'keterangan': ketC.text.trim(),
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tambah alat',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: namaC,
              decoration: InputDecoration(
                hintText: 'nama :',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: ketC,
              decoration: InputDecoration(
                hintText: 'keterangan :',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal',
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  onPressed: simpan,
                  child: const Text('Simpan',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}