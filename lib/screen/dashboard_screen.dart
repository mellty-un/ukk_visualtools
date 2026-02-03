import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  final List<String> menus = [
    'Dashboard',
    'Pengguna',
    'Alat',
    'Denda',
    'Riwayat',
    'Kategori',
    'Aktivitas',
    'Keluar',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ☰ DRAWER
      drawer: Drawer(
        backgroundColor: const Color(0xFFBFD9A8),
        child: SafeArea(
          child: Column(
            children: [
              /// PROFILE
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Admin',
                          style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              /// MENU LIST
              Expanded(
                child: ListView.builder(
                  itemCount: menus.length,
                  itemBuilder: (context, i) {
                    final active = selectedIndex == i;

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedIndex = i);

                        Navigator.pop(context);

                        // CONTOH NAVIGASI
                        if (menus[i] == 'Pengguna') {
                          Navigator.pushNamed(context, '/pengguna');
                        }
                        if (menus[i] == 'Kategori') {
                          Navigator.pushNamed(context, '/kategori');
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF6FAF6B)
                              : const Color(0xFF8FB57A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          menus[i],
                          style: TextStyle(
                            color: active
                                ? Colors.white
                                : Colors.black,
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
      ),

      /// APPBAR
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFD9A8),
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      /// BODY
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// GRID MENU ATAS
            Row(
              children: [
                _menuCard(
                  icon: Icons.work,
                  title: 'Alat',
                ),
                const SizedBox(width: 12),
                _menuCard(
                  icon: Icons.assignment,
                  title: 'Peminjam',
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// RIWAYAT CONTOH
            _riwayatItem(
              title: 'Meminjam gimbal',
              name: 'Clarissa Aurelia',
            ),
            _riwayatItem(
              title: 'Mengembalikan kamera',
              name: 'Melati Tiara',
            ),
          ],
        ),
      ),
    );
  }

  /// CARD MENU
  Widget _menuCard({required IconData icon, required String title}) {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFDDECCB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }

  /// RIWAYAT ITEM
  Widget _riwayatItem({required String title, required String name}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6FAF6B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle,
              color: Color(0xFF6FAF6B)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                Text(name, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const Text(
            '26/01/2026',
            style: TextStyle(fontSize: 11),
          )
        ],
      ),
    );
  }
}