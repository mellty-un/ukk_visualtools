import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditKategoriDialog extends StatefulWidget {
  final int id;
  final String nama;
  final String keterangan;

  const EditKategoriDialog({
    super.key,
    required this.id,
    required this.nama,
    required this.keterangan,
  });

  @override
  State<EditKategoriDialog> createState() =>
      _EditKategoriDialogState();
}

class _EditKategoriDialogState
    extends State<EditKategoriDialog> {
  final supabase = Supabase.instance.client;
  late TextEditingController namaC;
  late TextEditingController ketC;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(text: widget.nama);
    ketC = TextEditingController(text: widget.keterangan);
  }

  Future<void> simpan() async {
    await supabase.from('kategori').update({
      'nama_kategori': namaC.text.trim(),
      'keterangan': ketC.text.trim(),
    }).eq('id_kategori', widget.id);

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
              'Edit alat',
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