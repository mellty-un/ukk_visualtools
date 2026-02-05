import 'package:flutter/material.dart';

class AktivitasScreen extends StatefulWidget {
  const AktivitasScreen({super.key});

  @override
  State<AktivitasScreen> createState() => _AktivitasScreenState();
}

class _AktivitasScreenState extends State<AktivitasScreen> {
  final TextEditingController searchController = TextEditingController();
  String selectedFilter = "semua";

  // Data dummy sementara (ganti dengan fetch dari Supabase nanti)
  final List<Map<String, dynamic>> _aktivitas = [
    {
      "nama": "Siti Umrotul",
      "deskripsi": "Mengembalikan drawing Pen",
      "status": "dikembalikan",
      "tanggal": "26/01/2026",
    },
    {
      "nama": "Marselia Kamelia",
      "deskripsi": "Mengembalikan Camera",
      "status": "dikembalikan",
      "tanggal": "26/01/2026",
    },
    {
      "nama": "Nadya Rapica",
      "deskripsi": "Meminjam Gimbal Stabilizer",
      "status": "dipinjam",
      "tanggal": "26/01/2026",
    },
    {
      "nama": "Melati Tiara",
      "deskripsi": "Meminjam Sketchbook",
      "status": "dipinjam",
      "tanggal": "26/01/2026",
    },
  ];

  List<Map<String, dynamic>> get _filteredList {
    return _aktivitas.where((item) {
      final cocokStatus = selectedFilter == "semua"
          ? true
          : item['status'] == selectedFilter;

      final cocokSearch = item['nama']
          .toLowerCase()
          .contains(searchController.text.toLowerCase());

      return cocokStatus && cocokSearch;
    }).toList();
  }

  void _hapusItem(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Aktivitas"),
        content: const Text("Yakin ingin menghapus aktivitas ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _aktivitas.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Aktivitas berhasil dihapus'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void _editItem(int index) {
    final namaC = TextEditingController(text: _aktivitas[index]['nama']);
    final deskC = TextEditingController(text: _aktivitas[index]['deskripsi']);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Aktivitas",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: namaC,
                decoration: const InputDecoration(
                  labelText: "Nama Peminjam",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deskC,
                decoration: const InputDecoration(
                  labelText: "Deskripsi Aktivitas",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _aktivitas[index]['nama'] = namaC.text.trim();
                        _aktivitas[index]['deskripsi'] = deskC.text.trim();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Simpan"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterButton(String text) {
    final isActive = selectedFilter == text;
    return GestureDetector(
      onTap: () {
        setState(() => selectedFilter = text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6FAF6B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black26),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFD9A8),
        elevation: 0,
        title: const Text(
          'Aktivitas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search + Tombol Tambah (dipisah)
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Cari nama peminjam...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6FAF6B),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 28),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(minWidth: 52, minHeight: 52),
                    onPressed: () {
                      // TODO: Tambah aktivitas baru (bisa buka form dialog)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur tambah aktivitas belum diimplementasi')),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Filter buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterButton("semua"),
                  const SizedBox(width: 12),
                  _filterButton("dipinjam"),
                  const SizedBox(width: 12),
                  _filterButton("dikembalikan"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // List aktivitas
            Expanded(
              child: _filteredList.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada aktivitas',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Aktivitas akan muncul di sini',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredList.length,
                      itemBuilder: (context, index) {
                        final item = _filteredList[index];
                        final globalIndex = _aktivitas.indexOf(item);
                        return _buildCard(
                          item,
                          onEdit: () => _editItem(globalIndex),
                          onDelete: () => _hapusItem(globalIndex),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    Map<String, dynamic> data, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final status = data['status'].toString().toLowerCase();
    final warnaStatus = status == 'dikembalikan'
        ? const Color(0xFF6FAF6B)
        : const Color(0xFFFFAB91);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['nama'] ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['deskripsi'] ?? '-',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  data['tanggal'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: warnaStatus.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data['status'].toUpperCase(),
                  style: TextStyle(
                    color: warnaStatus,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.black),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.black),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Drawer sama seperti di Dashboard
  Widget _buildDrawer(BuildContext context) {
    final menus = [
      'Dashboard',
      'Pengguna',
      'Alat',
      'Denda',
      'Riwayat',
      'Kategori',
      'Aktivitas',
      'Keluar',
    ];

    return Drawer(
      backgroundColor: const Color(0xFFBFD9A8),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDDECCB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFF6FAF6B),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Egi Dwi Saputri',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: menus.length,
                itemBuilder: (context, i) {
                  final active = menus[i] == 'Aktivitas';

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);

                      switch (menus[i]) {
                        case 'Dashboard':
                          Navigator.pushReplacementNamed(context, '/dashboard');
                          break;
                        case 'Pengguna':
                          Navigator.pushNamed(context, '/pengguna');
                          break;
                        case 'Alat':
                          Navigator.pushNamed(context, '/alat');
                          break;
                        case 'Kategori':
                          Navigator.pushNamed(context, '/kategori');
                          break;
                        case 'Denda':
                          Navigator.pushNamed(context, '/riwayat'); // ke riwayat denda
                          break;
                        case 'Riwayat':
                          Navigator.pushNamed(context, '/riwayat');
                          break;
                        case 'Aktivitas':
                          // Tidak perlu navigasi, sudah di halaman ini
                          break;
                        case 'Keluar':
                          Navigator.pushReplacementNamed(context, '/login');
                          break;
                        default:
                          break;
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFF6FAF6B) : const Color(0xFF8FB57A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        menus[i],
                        style: TextStyle(
                          color: active ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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