import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:krpl/service/alat_service.dart';

class AlatScreen extends StatefulWidget {
  const AlatScreen({super.key});

  @override
  State<AlatScreen> createState() => _AlatScreenState();
}

class _AlatScreenState extends State<AlatScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Alat> alatList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAlat();
  }

  Future<void> _loadAlat() async {
    setState(() => isLoading = true);
    final data = await AlatService.getAlat();

    setState(() {
      alatList = data.map((e) {
        return Alat(
          idAlat: e['id_alat'],
          name: e['nama_alat'],
          category: e['id_kategori'].toString(),
          status:
              e['status'] == 'tersedia' ? StatusAlat.bagus : StatusAlat.rusak,
          imageUrl: e['image_url'],
        );
      }).toList();
      isLoading = false;
    });
  }

  List<Alat> get filteredAlat {
    if (searchController.text.isEmpty) return alatList;
    return alatList.where((a) {
      final q = searchController.text.toLowerCase();
      return a.name.toLowerCase().contains(q) ||
          a.category.toLowerCase().contains(q);
    }).toList();
  }

  void _openDialog({Alat? alat}) {
    showDialog(
      context: context,
      builder: (_) => TambahEditDialog(
        isEdit: alat != null,
        initialAlat: alat,
      ),
    ).then((result) {
      if (result == true) {
        _loadAlat(); // 🔥 Reload dari Supabase
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB9D7A1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB9D7A1),
        elevation: 0,
        title: const Text('Alat', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// SEARCH + ADD
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
                    onPressed: () => _openDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// GRID
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        itemCount: filteredAlat.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemBuilder: (context, index) {
                          final alat = filteredAlat[index];
                          return AlatCard(
                            alat: alat,
                            onEdit: () => _openDialog(alat: alat),
                            onDelete: () async {
                              await AlatService.deleteAlat(
                                idAlat: alat.idAlat,
                                imageUrl: alat.imageUrl,
                              );
                              _loadAlat(); // 🔥 reload setelah delete
                            },
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

  const TambahEditDialog({
    super.key,
    required this.isEdit,
    this.initialAlat,
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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(text: widget.initialAlat?.name ?? '');
    kategoriC =
        TextEditingController(text: widget.initialAlat?.category ?? '');
    kondisiC = TextEditingController(
      text: widget.initialAlat?.status == StatusAlat.bagus
          ? 'Baik'
          : 'Rusak',
    );
  }

  Future<void> pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        webImage = result.files.single.bytes;
      }
    } else {
      mobileImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
    }
    setState(() {});
  }

  Future<void> _simpan() async {
    setState(() => isLoading = true);

    final status = kondisiC.text.toLowerCase().contains('baik')
        ? 'tersedia'
        : 'rusak';

    String? imageUrl = widget.initialAlat?.imageUrl;

    if (mobileImage != null || webImage != null) {
      imageUrl = await AlatService.uploadImage(
        mobileFile: mobileImage != null ? File(mobileImage!.path) : null,
        webBytes: webImage,
        namaAlat: namaC.text,
      );
    }

    if (widget.isEdit) {
      await AlatService.updateAlat(
        idAlat: widget.initialAlat!.idAlat,
        idKategori: 1,
        nama: namaC.text,
        jumlah: 1,
        kondisi: kondisiC.text,
        status: status,
        imageUrl: imageUrl,
      );
    } else {
      await AlatService.insertAlat(
        idKategori: 1,
        nama: namaC.text,
        jumlah: 1,
        kondisi: kondisiC.text,
        status: status,
        imageUrl: imageUrl,
      );
    }

    setState(() => isLoading = false);
    Navigator.pop(context, true); // 🔥 trigger reload
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isEdit ? 'Edit Alat' : 'Tambah Alat',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: namaC,
              decoration: const InputDecoration(hintText: 'Nama'),
            ),
            TextField(
              controller: kategoriC,
              decoration: const InputDecoration(hintText: 'Kategori'),
            ),
            TextField(
              controller: kondisiC,
              decoration: const InputDecoration(hintText: 'Baik / Rusak'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pilih Gambar'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isLoading ? null : _simpan,
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
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
  final int idAlat;
  final String name;
  final String category;
  final StatusAlat status;
  final String? imageUrl;

  Alat({
    required this.idAlat,
    required this.name,
    required this.category,
    required this.status,
    this.imageUrl,
  });
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
    final imageWidget = alat.imageUrl != null
        ? Image.network(
            alat.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, size: 60),
          )
        : const Icon(Icons.image_not_supported, size: 60);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageWidget,
            ),
          ),
          const SizedBox(height: 8),
          Text(alat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(alat.category, style: const TextStyle(fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete)),
            ],
          ),
        ],
      ),
    );
  }
}
