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
      backgroundColor: const Color(0xFFB9D7A1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Pengguna',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchC,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Cari...',
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => openForm(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (_, i) {
                          final u = filteredUsers[i];

                          return ListTile(
                            title: Text(u['nama'] ?? '-'),
                            subtitle:
                                Text('${u['role']} • ${u['username']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => openForm(data: u),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      deleteUser(u['id_user']),
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
      ),
    );
  }
}
