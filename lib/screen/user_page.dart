import 'package:flutter/material.dart';
import 'package:krpl/service/user_service.dart';
import 'package:krpl/widget/user_form.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _service = UserService();

  List<Map<String, dynamic>> users = [];
  final searchC = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void showSnack(String text, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // ================= FETCH =================
  Future<void> fetchUsers() async {
    try {
      if (!mounted) return;
      setState(() => isLoading = true);

      final data = await _service.getUsers();

      if (!mounted) return;
      setState(() => users = data);
    } catch (e) {
      if (mounted) {
        showSnack('Gagal memuat pengguna', success: false);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ================= DELETE =================
  Future<void> deleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: const Text('Yakin ingin menghapus pengguna ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.deleteUser(id);
      await fetchUsers();
      showSnack('Pengguna berhasil dihapus');
    } catch (e) {
      showSnack('Gagal menghapus pengguna', success: false);
    }
  }

  // ================= FILTER =================
  List<Map<String, dynamic>> get filteredUsers {
    if (searchC.text.isEmpty) return users;

    return users.where((u) {
      return (u['nama'] ?? '')
          .toString()
          .toLowerCase()
          .contains(searchC.text.toLowerCase());
    }).toList();
  }

  // ================= FORM =================
  void openForm({Map<String, dynamic>? data}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => UserForm(
        data: data,
        onSuccess: (isEdit) async {
          Navigator.pop(context);

          await Future.delayed(const Duration(milliseconds: 100));
          if (!mounted) return;

          await fetchUsers();

          showSnack(
            isEdit
                ? 'Pengguna berhasil diubah'
                : 'Pengguna berhasil ditambahkan',
          );
        },
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // full putih dari atas sampai bawah
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFD9A8),
        elevation: 0,
        title: const Text(
          'Pengguna',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search + Tombol Tambah (full putih)
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
                      controller: searchC,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Cari nama...',
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
                    onPressed: () => openForm(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // List atau pesan kosong (full putih)
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF6FAF6B)))
                  : filteredUsers.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Belum ada pengguna',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tambahkan dengan tombol + di atas',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredUsers.length,
                          itemBuilder: (_, i) {
                            final u = filteredUsers[i];
                            final nama = u['nama'] ?? '-';
                            final role = u['role'] ?? 'Peminjam';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
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
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: const Color(0xFF6FAF6B),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nama,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          role,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: Colors.black, // diubah jadi hitam
                                        ),
                                        onPressed: () => openForm(data: u),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.black, // diubah jadi hitam
                                        ),
                                        onPressed: () => deleteUser(u['id_user']),
                                      ),
                                    ],
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