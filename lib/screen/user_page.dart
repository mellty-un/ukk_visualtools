import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<Map<String, dynamic>> users = [];
  final searchC = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final res = await supabase.from('users').select().order('nama');
    setState(() => users = List<Map<String, dynamic>>.from(res));
  }

  List<Map<String, dynamic>> get filteredUsers {
    if (searchC.text.isEmpty) return users;
    return users
        .where((u) =>
            u['nama'].toLowerCase().contains(searchC.text.toLowerCase()))
        .toList();
  }

  void showSuccess(String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Berhasil'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void openForm({Map<String, dynamic>? data}) {
    showDialog(
      context: context,
      builder: (_) => UserForm(
        data: data,
        onSuccess: () {
          Navigator.pop(context);
          fetchUsers();
          showSuccess(data == null
              ? 'Pengguna berhasil ditambahkan'
              : 'Pengguna berhasil diubah');
        },
      ),
    );
  }

  Future<void> deleteUser(String id) async {
    await supabase.from('users').delete().eq('id', id);
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB9D7A1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Pengguna',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchC,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.add, size: 30),
                    onPressed: () => openForm(),
                  )
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final u = filteredUsers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u['nama'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(u['role'],
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => openForm(data: u),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteUser(u['id']),
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

/* ================= FORM ================= */

class UserForm extends StatefulWidget {
  final Map<String, dynamic>? data;
  final VoidCallback onSuccess;

  const UserForm({super.key, this.data, required this.onSuccess});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final namaC = TextEditingController();
  final kelasC = TextEditingController();
  final jurusanC = TextEditingController();
  final passC = TextEditingController();
  String role = 'Peminjam';

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      namaC.text = widget.data!['nama'];
      kelasC.text = widget.data!['kelas'];
      jurusanC.text = widget.data!['jurusan'];
      passC.text = widget.data!['password'];
      role = widget.data!['role'];
    }
  }

  Future<void> save() async {
    final payload = {
      'nama': namaC.text,
      'kelas': kelasC.text,
      'jurusan': jurusanC.text,
      'role': role,
      'password': passC.text,
    };

    if (widget.data == null) {
      await supabase.from('users').insert(payload);
    } else {
      await supabase
          .from('users')
          .update(payload)
          .eq('id', widget.data!['id']);
    }

    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.data == null ? 'Tambah Pengguna' : 'Edit Pengguna',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextField(controller: namaC, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: kelasC, decoration: const InputDecoration(labelText: 'Kelas')),
            TextField(controller: jurusanC, decoration: const InputDecoration(labelText: 'Jurusan')),

            DropdownButtonFormField<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                DropdownMenuItem(value: 'Petugas', child: Text('Petugas')),
                DropdownMenuItem(value: 'Peminjam', child: Text('Peminjam')),
              ],
              onChanged: (v) => setState(() => role = v!),
              decoration: const InputDecoration(labelText: 'Role'),
            ),

            TextField(
              controller: passC,
              decoration: const InputDecoration(labelText: 'Kata Sandi'),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: save,
                  child: const Text('Simpan'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}