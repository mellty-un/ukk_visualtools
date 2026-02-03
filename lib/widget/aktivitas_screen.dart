import 'package:flutter/material.dart';

class AktivitasScreen extends StatefulWidget {
  const AktivitasScreen({super.key});

  @override
  State<AktivitasScreen> createState() => _AktivitasScreenState();
}

class _AktivitasScreenState extends State<AktivitasScreen> {
  final TextEditingController searchController = TextEditingController();
  String selectedFilter = "semua";

  final List<Map<String, dynamic>> _aktivitas = [
    {
      "nama": "Siti Umrotul",
      "deskripsi": "Mengembalikan drawing Pen",
      "status": "dikembalikan"
    },
    {
      "nama": "Marselia Kamelia",
      "deskripsi": "Mengembalikan Camera",
      "status": "dikembalikan"
    },
    {
      "nama": "Nadya Rapica",
      "deskripsi": "Meminjam Gimbal Stabilizer",
      "status": "dipinjam"
    },
    {
      "nama": "Melati Tiara",
      "deskripsi": "Meminjam Sketchbook",
      "status": "dipinjam"
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
            onPressed: () {
              setState(() {
                _aktivitas.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void _editItem(int index) {
    final namaC = TextEditingController(text: _aktivitas[index]['nama']);
    final deskC =
        TextEditingController(text: _aktivitas[index]['deskripsi']);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Edit Aktivitas",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: namaC,
                decoration: const InputDecoration(labelText: "Nama"),
              ),
              TextField(
                controller: deskC,
                decoration: const InputDecoration(labelText: "Deskripsi"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _aktivitas[index]['nama'] = namaC.text;
                    _aktivitas[index]['deskripsi'] = deskC.text;
                  });
                  Navigator.pop(context);
                },
                child: const Text("Simpan"),
              )
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
        setState(() {
          selectedFilter = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFA8C98A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black26),
        ),
        child: Text(
          text,
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
      drawer: _buildSidebar(context),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "Aktivitas",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// SEARCH
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E9E9),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: "Cari....",
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// FILTER BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _filterButton("semua"),
                  _filterButton("dipinjam"),
                  _filterButton("dikembalikan"),
                ],
              ),

              const SizedBox(height: 20),

              /// LIST
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredList.length,
                  itemBuilder: (context, index) {
                    final item = _filteredList[index];
                    return _buildCard(
                      item,
                      onEdit: () => _editItem(
                          _aktivitas.indexOf(item)),
                      onDelete: () => _hapusItem(
                          _aktivitas.indexOf(item)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// CARD
  Widget _buildCard(
    Map<String, dynamic> data, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFA8C98A)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['nama'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  data['deskripsi'],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  /// SIDEBAR
  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFA8C98A),
            child: const Text(
              "MENU",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Aktivitas"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AktivitasScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}