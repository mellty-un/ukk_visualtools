import 'package:flutter/material.dart';

class PeminjamanScreen extends StatefulWidget {
  const PeminjamanScreen({super.key});

  @override
  State<PeminjamanScreen> createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends State<PeminjamanScreen> {
  final TextEditingController searchController = TextEditingController();

  // Data dummy untuk simulasi tampilan
  final List<Map<String, dynamic>> _daftarPeminjaman = [
    {
      "nama": "Chella robiatul",
      "tanggal": "26/01/2026",
      "status": "Pengajuan",
      "color": const Color(0xFFC1F0F6)
    },
    {
      "nama": "Clarissa Aurelia",
      "tanggal": "26/01/2026",
      "status": "Dipinjam",
      "color": const Color(0xFFF9A36F)
    },
    {
      "nama": "Melati Tiara",
      "tanggal": "26/01/2026",
      "status": "Ditolak",
      "color": const Color(0xFFFF4D4D)
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna background hijau muda sesuai header di gambar
      backgroundColor: const Color(0xFFB9D7A1),
      body: SafeArea(
        child: Column(
          children: [
            // Header: Judul "Peminjaman"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  const Icon(Icons.more_vert, color: Colors.black),
                  const SizedBox(width: 8),
                  const Text(
                    'Peminjaman',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Konten Utama dengan Background Putih melengkung
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar & Add Button
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9E9E9),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: TextField(
                                controller: searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Cari.......',
                                  prefixIcon: Icon(Icons.search),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFA8C98A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 30),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        'Daftar peminjaman',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // List Peminjaman
                      Expanded(
                        child: ListView.builder(
                          itemCount: _daftarPeminjaman.length,
                          itemBuilder: (context, index) {
                            final item = _daftarPeminjaman[index];
                            return _buildPeminjamanCard(item);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Card Peminjaman
  Widget _buildPeminjamanCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['nama'] ?? "User",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            data['tanggal'] ?? "-",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: data['color'],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black45, width: 0.5),
              ),
              child: Text(
                data['status'] ?? "-",
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}