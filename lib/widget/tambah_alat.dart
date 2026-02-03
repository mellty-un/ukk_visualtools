import 'package:flutter/material.dart';

class TambahAlatDialog extends StatefulWidget {
  final Function(String nama, String kategori, String kondisi) onSimpan;

  const TambahAlatDialog({super.key, required this.onSimpan});

  @override
  State<TambahAlatDialog> createState() => _TambahAlatDialogState();
}

class _TambahAlatDialogState extends State<TambahAlatDialog> {
  final TextEditingController namaC = TextEditingController();
  final TextEditingController kategoriC = TextEditingController();
  final TextEditingController kondisiC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 370,
          child: Column(
            children: [
              const Text(
                'Tambah Alat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _inputField(namaC, 'Nama alat'),
              const SizedBox(height: 12),
              _inputField(kategoriC, 'Kategori alat'),
              const SizedBox(height: 12),
              _inputField(kondisiC, 'Kondisi alat'),

              const SizedBox(height: 20),

              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: Color(0xFFA8C98A),
                ),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        if (namaC.text.isEmpty ||
                            kategoriC.text.isEmpty ||
                            kondisiC.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Semua field wajib diisi'),
                            ),
                          );
                          return;
                        }

                        widget.onSimpan(
                          namaC.text,
                          kategoriC.text,
                          kondisiC.text,
                        );
                      },
                      child: const Text(
                        'Simpan',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}