import 'package:flutter/material.dart';
import 'package:krpl/service/user_service.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserForm extends StatefulWidget {
  final Map<String, dynamic>? data;
  final Function(bool isEdit) onSuccess;

  const UserForm({
    super.key,
    this.data,
    required this.onSuccess,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _service = UserService();

  final namaC = TextEditingController();
  final kelasC = TextEditingController();
  final jurusanC = TextEditingController();
  final usernameC = TextEditingController();
  final passC = TextEditingController();

  String role = 'siswa';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.data != null) {
      namaC.text = widget.data!['nama']?.toString() ?? '';
      kelasC.text = widget.data!['kelas']?.toString() ?? '';
      jurusanC.text = widget.data!['jurusan']?.toString() ?? '';
      usernameC.text = widget.data!['username']?.toString() ?? '';

      final dbRole = widget.data!['role']?.toString();
      if (dbRole == 'admin' ||
          dbRole == 'guru' ||
          dbRole == 'siswa') {
        role = dbRole!;
      }
    }
  }

  @override
  void dispose() {
    namaC.dispose();
    kelasC.dispose();
    jurusanC.dispose();
    usernameC.dispose();
    passC.dispose();
    super.dispose();
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ================= HASH PASSWORD =================
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // ================= SAVE =================
  Future<void> save() async {
    if (namaC.text.trim().isEmpty ||
        usernameC.text.trim().isEmpty ||
        (widget.data == null && passC.text.trim().isEmpty)) {
      showError('Nama, Username, dan Password wajib diisi');
      return;
    }

    setState(() => isLoading = true);

    final payload = {
      'nama': namaC.text.trim(),
      'kelas': kelasC.text.trim(),
      'jurusan': jurusanC.text.trim(),
      'role': role,
      'username': usernameC.text.trim(),
    };

    // Kalau tambah user atau password diisi → update password
    if (passC.text.trim().isNotEmpty) {
      payload['password_hash'] =
          hashPassword(passC.text.trim());
    }

    try {
      if (widget.data == null) {
        // ================= INSERT =================
        await _service.addUser(payload);
      } else {
        // ================= UPDATE =================
        final id = widget.data!['id_user'];

        if (id == null) {
          throw 'ID user tidak ditemukan';
        }

        await _service.updateUser(id, payload);
      }

      widget.onSuccess(widget.data != null);
    } catch (e) {
      showError('Gagal menyimpan data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.data == null
                    ? 'Tambah Pengguna'
                    : 'Edit Pengguna',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: namaC,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: usernameC,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: kelasC,
                decoration: const InputDecoration(
                  labelText: 'Kelas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: jurusanC,
                decoration: const InputDecoration(
                  labelText: 'Jurusan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: role,
                items: const [
                  DropdownMenuItem(
                      value: 'admin',
                      child: Text('Admin')),
                  DropdownMenuItem(
                      value: 'guru',
                      child: Text('Guru')),
                  DropdownMenuItem(
                      value: 'siswa',
                      child: Text('Siswa')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => role = v);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: passC,
                decoration: InputDecoration(
                  labelText: widget.data == null
                      ? 'Password'
                      : 'Password (kosongkan jika tidak diubah)',
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: isLoading
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : save,
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
