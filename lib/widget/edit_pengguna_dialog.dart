import 'package:flutter/material.dart';

class EditPenggunaDialog extends StatelessWidget {
  final String namaAwal;
  final String roleAwal;
  final String emailAwal;

  const EditPenggunaDialog({
    super.key,
    required this.namaAwal,
    required this.roleAwal,
    required this.emailAwal,
  });

  @override
  Widget build(BuildContext context) {
    final namaController = TextEditingController(text: namaAwal);
    final roleController = TextEditingController(text: roleAwal);
    final emailController = TextEditingController(text: emailAwal);
    final passwordController = TextEditingController();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Pengguna',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _inputField(label: 'Nama', controller: namaController),
            _inputField(label: 'Role', controller: roleController),
            _inputField(label: 'Email', controller: emailController),
            _inputField(
              label: 'Kata sandi',
              controller: passwordController,
              obscure: true,
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ===== BATAL =====
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),

                // ===== SIMPAN =====
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    // 🔑 SIMPAN ROOT CONTEXT
                    final rootContext =
                        Navigator.of(context, rootNavigator: true).context;

                    // 1️⃣ Tutup dialog edit
                    Navigator.pop(context);

                    // 2️⃣ Tampilkan popup berhasil
                    Future.microtask(() {
                      showDialog(
                        context: rootContext,
                        barrierDismissible: false,
                        builder: (_) => const EditSuccessDialog(),
                      );

                      // 3️⃣ Tutup otomatis
                      Future.delayed(const Duration(milliseconds: 1500), () {
                        Navigator.of(rootContext).pop();
                      });
                    });
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

// ================= POPUP BERHASIL EDIT =================
class EditSuccessDialog extends StatelessWidget {
  const EditSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 40),
              SizedBox(height: 8),
              Text(
                'Berhasil',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}