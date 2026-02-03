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
    'Peminjaman',
    'Kategori',
    'Aktivitas',
    'Keluar',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// DRAWER / Sidebar
      drawer: Drawer(
        backgroundColor: const Color(0xFFBFD9A8),
        child: SafeArea(
          child: Column(
            children: [
              /// Profile section
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

              /// Menu list
              Expanded(
                child: ListView.builder(
                  itemCount: menus.length,
                  itemBuilder: (context, i) {
                    final active = selectedIndex == i;

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedIndex = i);
                        Navigator.pop(context);

                        switch (menus[i]) {
                          case 'Pengguna':
                            Navigator.pushNamed(context, '/pengguna');
                            break;
                          case 'Alat':
                            Navigator.pushNamed(context, '/alat');
                            break;
                          case 'Kategori':
                            Navigator.pushNamed(context, '/kategori');
                            break;
                          case 'Peminjam':
                          case 'Peminjaman':
                            Navigator.pushNamed(context, '/peminjaman');
                            break;
                          case 'Denda':
                          case 'Riwayat':
                            Navigator.pushNamed(context, '/riwayat');
                            break;
                          case 'Keluar':
                            Navigator.pushReplacementNamed(context, '/login');
                            break;
                          // Tambahkan case 'Aktivitas' nanti jika sudah ada halamannya
                          default:
                            break;
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF6FAF6B)
                              : const Color(0xFF8FB57A),
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
      ),

      /// AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFD9A8),
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      /// Body
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Grid 2×2: Pengguna - Alat - Kategori - Peminjam
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _menuCard(
                  icon: Icons.person,
                  title: 'Pengguna',
                  color: const Color(0xFFDDECCB),
                  onTap: () => Navigator.pushNamed(context, '/pengguna'),
                ),
                const SizedBox(width: 12),
                _menuCard(
                  icon: Icons.work,
                  title: 'Alat',
                  color: const Color(0xFFDDECCB),
                  onTap: () => Navigator.pushNamed(context, '/alat'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _menuCard(
                  icon: Icons.category,
                  title: 'Kategori',
                  color: const Color(0xFFDDECCB),
                  onTap: () => Navigator.pushNamed(context, '/kategori'),
                ),
                const SizedBox(width: 12),
                _menuCard(
                  icon: Icons.people,
                  title: 'Peminjam',
                  color: const Color(0xFFDDECCB),
                  onTap: () => Navigator.pushNamed(context, '/peminjaman'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Bagian Aktivitas / Riwayat Terbaru
            const Text(
              'Aktivitas Terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _activityItem(
              icon: Icons.schedule,
              title: 'Meminjam kamera',
              name: 'Chella Robiatul',
              date: '26/01/2026',
              total: 'total 3jam',
            ),
            _activityItem(
              icon: Icons.schedule,
              title: 'Meminjam Gimbal',
              name: 'Clarissa Aurelia',
              date: '26/01/2026',
              total: 'total 3jam',
            ),
            _activityItem(
              icon: Icons.check_circle,
              title: 'Mengembalikan kamera',
              name: 'Melati Tiara',
              date: '26/01/2026',
              total: 'total 3',
              isReturn: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityItem({
    required IconData icon,
    required String title,
    required String name,
    required String date,
    required String total,
    bool isReturn = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6FAF6B)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isReturn ? const Color(0xFF6FAF6B) : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  name,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                total,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}