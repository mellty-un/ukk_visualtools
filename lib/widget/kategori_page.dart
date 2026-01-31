import 'dart:async';
import 'package:flutter/material.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final TextEditingController _namaController = TextEditingController();

  final List<Map<String, dynamic>> kategoriList = [
    {"title": "Alat Gambar", "count": 4},
    {"title": "Alat Digital", "count": 3},
    {"title": "Alat Videografi", "count": 2},
  ];

  // --- 1. FUNGSI TAMBAH ---
  void _showTambahDialog() {
    _namaController.clear();
    _showFormDialog(
      title: "Tambah alat",
      onSave: () {
        if (_namaController.text.isEmpty) return;
        setState(() {
          kategoriList.add({"title": _namaController.text, "count": 0});
        });
        Navigator.pop(context);
        _showBerhasilPopup("Kategori berhasil ditambahkan");
      },
    );
  }

  // --- 2. FUNGSI EDIT ---
  void _showEditDialog(int index) {
    _namaController.text = kategoriList[index]["title"];
    _showFormDialog(
      title: "Edit alat",
      onSave: () {
        if (_namaController.text.isEmpty) return;
        setState(() {
          kategoriList[index]["title"] = _namaController.text;
        });
        Navigator.pop(context);
        _showBerhasilPopup("Kategori berhasil diubah");
      },
    );
  }

  // --- 3. FUNGSI HAPUS (SESUAI GAMBAR FIGMA) ---
  void _showHapusDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Anda yakin ingin\nmenghapus ini ?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tombol Batal
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4D4D),
                        shape: StadiumBorder(),
                        minimumSize: const Size(100, 40),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal", style: TextStyle(color: Colors.white)),
                    ),
                    // Tombol Simpan (Aksi Hapus)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        foregroundColor: Colors.black,
                        shape: StadiumBorder(),
                        minimumSize: const Size(100, 40),
                      ),
                      onPressed: () {
                        setState(() {
                          kategoriList.removeAt(index);
                        });
                        Navigator.pop(context);
                        _showBerhasilPopup("Data berhasil dihapus");
                      },
                      child: const Text("Simpan"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // --- REUSABLE FORM DIALOG (INPUT FIELD) ---
  void _showFormDialog({required String title, required VoidCallback onSave}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green.shade300),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _namaController,
                    decoration: const InputDecoration(hintText: "nama :", border: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4D4D), shape: StadiumBorder(), minimumSize: const Size(100, 40)),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal", style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade400, foregroundColor: Colors.black, shape: StadiumBorder(), minimumSize: const Size(100, 40)),
                      onPressed: onSave,
                      child: const Text("Simpan"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBerhasilPopup(String pesan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Timer(const Duration(seconds: 1), () => Navigator.pop(context));
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 10),
                Text(pesan, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFB8D8A0),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Kategori", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: const TextField(
                            decoration: InputDecoration(hintText: "Cari...", border: InputBorder.none, icon: Icon(Icons.search)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: IconButton(icon: const Icon(Icons.add), onPressed: _showTambahDialog),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // LIST VIEW
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: kategoriList.length,
                itemBuilder: (context, index) {
                  return KategoriCard(
                    title: kategoriList[index]["title"],
                    count: kategoriList[index]["count"],
                    onEdit: () => _showEditDialog(index),
                    onDelete: () => _showHapusDialog(index), // Memanggil dialog hapus
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KategoriCard extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const KategoriCard({super.key, required this.title, required this.count, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Alat : $count", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.black), onPressed: onDelete),
        ],
      ),
    );
  }
}