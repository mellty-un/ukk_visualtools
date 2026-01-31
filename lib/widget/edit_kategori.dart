import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const KategoriPage(),
    );
  }
}

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  // Data list kategori
  List<Map<String, dynamic>> categories = [
    {'nama': 'Alat Gambar', 'stok': 4},
    {'nama': 'Alat Digital', 'stok': 3},
    {'nama': 'Alat Video', 'stok': 2},
  ];

  // Controller untuk menangkap input teks
  final TextEditingController _nameController = TextEditingController();

  // 1. FUNGSI POPUP EDIT ALAT
  void _tampilkanPopupEdit(int index) {
    // Isi field dengan nama yang sudah ada sebelum diedit
    _nameController.text = categories[index]['nama'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: const BorderSide(color: Colors.black, width: 0.5),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit alat',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'nama :',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tombol Batal
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4D4D), // Merah cerah figma
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Batal', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    // Tombol Simpan
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            categories[index]['nama'] = _nameController.text;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400], // Abu-abu figma
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Simpan', style: TextStyle(color: Colors.black)),
                      ),
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

  // 2. FUNGSI TAMBAH ALAT (Hanya sebagai pelengkap)
  void _tampilkanPopupTambah() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) => _buildSimpleDialog("Tambah alat", () {
        setState(() {
          categories.add({'nama': _nameController.text, 'stok': 0});
        });
        Navigator.pop(context);
      }),
    );
  }

  // Helper widget untuk dialog agar kode lebih bersih
  Widget _buildSimpleDialog(String title, VoidCallback onSave) {
    return Dialog( /* ... sama dengan struktur edit ... */ );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB4CF99),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: const [
                  Icon(Icons.more_vert),
                  SizedBox(width: 10),
                  Text('Kategori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: [
                    // Search & Add Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari....',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: _tampilkanPopupTambah,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFB4CF99), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    // List Kategori
                    Expanded(
                      child: ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(categories[index]['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('Alat : ${categories[index]['stok']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // TOMBOL EDIT DI SINI
                                    GestureDetector(
                                      onTap: () => _tampilkanPopupEdit(index),
                                      child: const Icon(Icons.edit_outlined, size: 22),
                                    ),
                                    const SizedBox(width: 15),
                                    const Icon(Icons.delete_outline, size: 22),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}