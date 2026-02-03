import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../widget/tambah_alat.dart';

class AlatScreen extends StatefulWidget {
  const AlatScreen({super.key});

  @override
  State<AlatScreen> createState() => _AlatScreenState();
}

class _AlatScreenState extends State<AlatScreen> {
  final TextEditingController searchController = TextEditingController();

  /// 🔥 DATA DUMMY DENGAN ASSET IMAGE
  List<Alat> alatList = [
    Alat('Camera Sony', 'Alat Digital', StatusAlat.bagus, 'assets/images/camera.png', null),
    Alat('Gimbal Stabilizer', 'Alat Digital', StatusAlat.bagus, 'assets/images/stabilizer.png', null),
    Alat('Cat Warna', 'Alat Gambar', StatusAlat.rusak, 'assets/images/catwarna.png', null),
    Alat('Sketch Book', 'Alat Gambar', StatusAlat.rusak, 'assets/images/sketchbook.png', null),
    Alat('Drawing Pen', 'Alat Gambar', StatusAlat.rusak, 'assets/images/drawingpen.png', null),
    Alat('Cutting Mat', 'Alat Gambar', StatusAlat.bagus, 'assets/images/cuttingmat.png', null),
  ];

  List<Alat> get filteredAlat {
    if (searchController.text.isEmpty) return alatList;
    return alatList.where((a) =>
        a.name.toLowerCase().contains(searchController.text.toLowerCase()) ||
        a.category.toLowerCase().contains(searchController.text.toLowerCase())).toList();
  }

  void _addAlat(Alat alat) {
    setState(() => alatList.add(alat));
  }

  void _editAlat(int index, Alat alat) {
    setState(() => alatList[index] = alat);
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
              const Text('Alat', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => TambahEditDialog(
                          isEdit: false,
                          onSave: _addAlat,
                        ),
                      );
                    },
                  )
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: GridView.builder(
                  itemCount: filteredAlat.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemBuilder: (context, index) {
                    final alat = filteredAlat[index];
                    return AlatCard(
                      alat: alat,
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (_) => TambahEditDialog(
                            isEdit: true,
                            initialAlat: alat,
                            onSave: (updated) => _editAlat(index, updated),
                          ),
                        );
                      },
                      onDelete: () => setState(() => alatList.removeAt(index)),
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

/* ================= DIALOG ================= */

class TambahEditDialog extends StatefulWidget {
  final bool isEdit;
  final Alat? initialAlat;
  final Function(Alat) onSave;

  const TambahEditDialog({
    super.key,
    required this.isEdit,
    this.initialAlat,
    required this.onSave,
  });

  @override
  State<TambahEditDialog> createState() => _TambahEditDialogState();
}

class _TambahEditDialogState extends State<TambahEditDialog> {
  late TextEditingController namaC;
  late TextEditingController kategoriC;
  late TextEditingController kondisiC;

  XFile? mobileImage;
  Uint8List? webImage;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(text: widget.initialAlat?.name ?? '');
    kategoriC = TextEditingController(text: widget.initialAlat?.category ?? '');
    kondisiC = TextEditingController(
      text: widget.initialAlat?.status == StatusAlat.bagus ? 'Baik' : 'Rusak',
    );
  }

  Future<void> pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) webImage = result.files.single.bytes;
    } else {
      mobileImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.isEdit ? 'Edit Alat' : 'Tambah Alat',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextField(controller: namaC, decoration: const InputDecoration(hintText: 'Nama')),
            TextField(controller: kategoriC, decoration: const InputDecoration(hintText: 'Kategori')),
            TextField(controller: kondisiC, decoration: const InputDecoration(hintText: 'Baik / Rusak')),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pilih Gambar'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                final status = kondisiC.text.toLowerCase().contains('baik')
                    ? StatusAlat.bagus
                    : StatusAlat.rusak;

                widget.onSave(
                  Alat(
                    namaC.text,
                    kategoriC.text,
                    status,
                    mobileImage?.path,
                    webImage,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= MODEL ================= */

enum StatusAlat { bagus, rusak }

class Alat {
  final String name;
  final String category;
  final StatusAlat status;
  final String? imagePath; // asset / mobile
  final Uint8List? imageBytes; // web

  Alat(this.name, this.category, this.status, this.imagePath, this.imageBytes);
}

/* ================= CARD ================= */

class AlatCard extends StatelessWidget {
  final Alat alat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AlatCard({
    super.key,
    required this.alat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (alat.imageBytes != null) {
      imageWidget = Image.memory(alat.imageBytes!, fit: BoxFit.cover);
    } else if (alat.imagePath != null) {
      imageWidget = alat.imagePath!.startsWith('assets/')
          ? Image.asset(alat.imagePath!, fit: BoxFit.cover)
          : Image.file(File(alat.imagePath!), fit: BoxFit.cover);
    } else {
      imageWidget = const Icon(Icons.image_not_supported, size: 60);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: imageWidget)),
          const SizedBox(height: 8),
          Text(alat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(alat.category, style: const TextStyle(fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete)),
            ],
          )
        ],
      ),
    );
  }
}