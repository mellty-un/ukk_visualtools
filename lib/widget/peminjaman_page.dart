import 'package:flutter/material.dart';

class PeminjamanPage extends StatelessWidget {
  const PeminjamanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB9D7A1),
        title: const Text('Peminjaman'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // nanti bisa ke halaman tambah peminjaman
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEARCH
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: 'Cari.....',
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Daftar peminjaman',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // LIST PEMINJAMAN
            peminjamanCard(
              nama: 'Chella rohbatul',
              tanggal: '26/01/2026',
              status: 'Pengajuan',
              warna: Colors.lightBlueAccent,
            ),

            peminjamanCard(
              nama: 'Clarissa Aurelia',
              tanggal: '26/01/2026',
              status: 'Dipinjam',
              warna: Colors.orangeAccent,
            ),

            peminjamanCard(
              nama: 'Melati Tiara',
              tanggal: '26/01/2026',
              status: 'Ditolak',
              warna: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }

  // CARD PEMINJAMAN
  Widget peminjamanCard({
    required String nama,
    required String tanggal,
    required String status,
    required Color warna,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB9D7A1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nama,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                tanggal,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: warna,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}