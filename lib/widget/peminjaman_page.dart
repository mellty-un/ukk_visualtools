import 'package:flutter/material.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final List<Map<String, dynamic>> peminjamanList = [
    {
      "nama": "Chella robiatul",
      "tgl": "26/01/2026",
      "status": "Pengajuan",
    },
    {
      "nama": "Clarissa Aurelia",
      "tgl": "26/01/2026",
      "status": "Dipinjam",
    },
    {
      "nama": "Melati Tiara",
      "tgl": "26/01/2026",
      "status": "Ditolak",
    },
  ];

  Color statusColor(String status) {
    switch (status) {
      case 'Pengajuan':
        return const Color(0xFFC1F1FF);
      case 'Dipinjam':
        return const Color(0xFFFFAB76);
      case 'Ditolak':
        return const Color(0xFFFF4D4D);
      default:
        return Colors.grey;
    }
  }

  Color borderColor(String status) {
    return status == 'Pengajuan'
        ? const Color.fromARGB(255, 233, 233, 233)
        : Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 26),
              decoration: const BoxDecoration(
                color: Color(0xFFB8D8A0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.more_vert, size: 26),
                      SizedBox(width: 6),
                      Text(
                        "Peminjaman",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // SEARCH + ADD
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.search,
                                  color: Colors.grey, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Cari.....",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // ➕ TOMBOL PLUS (LEBIH KECIL)
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 191, 236, 187),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // JUDUL
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Daftar peminjaman",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ================= LIST =================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: peminjamanList.length,
                itemBuilder: (context, index) {
                  final item = peminjamanList[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white, // 🔥 SEMUA PUTIH
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: borderColor(item['status']),
                        width: item['status'] == 'Pengajuan' ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nama'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['tgl'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor(item['status']),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              item['status'],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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