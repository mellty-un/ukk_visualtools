import 'package:flutter/material.dart';

// IMPORT DIALOG
import '../widget/tambah_pengguna.dart';
import '../widget/edit_pengguna_dialog.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFB9D7A1),
        elevation: 0,
        title: const Text(
          'Pengguna',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== SEARCH + ADD =====
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ===== ADD BUTTON =====
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const TambahPenggunaDialog(),
                    );
                  },
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA8C98A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ===== USER LIST =====
            Expanded(
              child: ListView(
                children: const [
                  UserCard(
                    name: 'Chella',
                    role: 'Admin',
                    email: 'chella@email.com',
                  ),
                  UserCard(
                    name: 'Clarissa',
                    role: 'Petugas',
                    email: 'clarissa@email.com',
                  ),
                  UserCard(
                    name: 'Erviliyan',
                    role: 'Peminjam',
                    email: 'ervi@email.com',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= CARD USER =================
class UserCard extends StatelessWidget {
  final String name;
  final String role;
  final String email;

  const UserCard({
    super.key,
    required this.name,
    required this.role,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF6B8F71),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  role,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          // ===== EDIT =====
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => EditPenggunaDialog(
                  namaAwal: name,
                  roleAwal: role,
                  emailAwal: email,
                ),
              );
            },
          ),

          // ===== DELETE =====
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}