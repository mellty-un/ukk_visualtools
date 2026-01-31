import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB9D7A1),
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== GRID MENU =====
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                dashboardCard(
                  context,
                  icon: Icons.people,
                  title: 'Pengguna',
                  route: '/pengguna',
                ),
                dashboardCard(
                  context,
                  icon: Icons.work,
                  title: 'Alat',
                  route: '/alat',
                ),
                dashboardCard(
                  context,
                  icon: Icons.category,
                  title: 'Kategori',
                  route: '/kategori',
                ),
                dashboardCard(
                  context,
                  icon: Icons.assignment,
                  title: 'Peminjaman',
                  route: '/peminjaman',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ===== LIST AKTIVITAS =====
            Expanded(
              child: ListView(
                children: const [
                  ActivityCard(
                    title: 'Meminjam kamera',
                    name: 'Chella Robiatul',
                    total: 'total 3',
                    date: '26/01/2026',
                  ),
                  ActivityCard(
                    title: 'Meminjam Gimbal',
                    name: 'Clarissa Aurelia',
                    total: 'total 3',
                    date: '26/01/2026',
                  ),
                  ActivityCard(
                    title: 'Mengembalikan kamera',
                    name: 'Melati Tiara',
                    total: 'total 3',
                    date: '26/01/2026',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== CARD MENU ATAS =====
  Widget dashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFB9D7A1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ===== CARD AKTIVITAS BAWAH =====
class ActivityCard extends StatelessWidget {
  final String title;
  final String name;
  final String total;
  final String date;

  const ActivityCard({
    super.key,
    required this.title,
    required this.name,
    required this.total,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB9D7A1)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // ===== ICON JAM =====
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF7DA453), width: 2),
            ),
            child: const Icon(
              Icons.access_time,
              color: Color(0xFF7DA453),
            ),
          ),

          const SizedBox(width: 12),

          // ===== TEKS KIRI =====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),

          // ===== TEKS KANAN =====
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                total,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}