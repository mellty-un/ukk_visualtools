import 'dart:io';
import 'dart:typed_data'; // untuk Uint8List di web
import 'package:flutter/foundation.dart' show kIsWeb; // cek platform
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class AlatScreen extends StatefulWidget {
  const AlatScreen({super.key});

  @override
  State<AlatScreen> createState() => _AlatScreenState();
}

class _AlatScreenState extends State<AlatScreen> {
  final TextEditingController searchController = TextEditingController();

  List<Alat> alatList = [
    Alat('Camera Sony', 'Alat Digital', StatusAlat.bagus, null, null),
    Alat('Gimbal Stabilizer', 'Alat Digital', StatusAlat.bagus, null, null),
    Alat('Cat Warna', 'Alat Gambar', StatusAlat.rusak, null, null),
    Alat('Sketch Book', 'Alat Gambar', StatusAlat.rusak, null, null),
    Alat('Drawing Pen', 'Alat Gambar', StatusAlat.rusak, null, null),
    Alat('Cutting Mat', 'Alat Gambar', StatusAlat.bagus, null, null),
  ];

  List<Alat> get filteredAlat {
    if (searchController.text.isEmpty) return alatList;

    return alatList.where((a) =>
            a.name.toLowerCase().contains(searchController.text.toLowerCase()) ||
            a.category.toLowerCase().contains(searchController.text.toLowerCase()))
        .toList();
  }

  void _addAlat(Alat newAlat) {
    setState(() {
      alatList.add(newAlat);
    });
    _showSuccessPopup("Alat berhasil ditambahkan");
  }

  void _updateAlat(int index, Alat updatedAlat) {
    setState(() {
      alatList[index] = updatedAlat;
    });
    _showSuccessPopup("Alat berhasil diubah");
  }

  void _showSuccessPopup(String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 50),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (Navigator.canPop(context)) Navigator.pop(context);
    });
  }

  void _showTambahAlatDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TambahEditDialog(
        isEdit: false,
        onSave: _addAlat,
      ),
    );
  }

  void _showEditAlatDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TambahEditDialog(
        isEdit: true,
        initialAlat: alatList[index],
        onSave: (updated) => _updateAlat(index, updated),
      ),
    );
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
              const Row(
                children: [
                  Text(
                    'Alat',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ],
              ),
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
                  GestureDetector(
                    onTap: _showTambahAlatDialog,
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
              Expanded(
                child: GridView.builder(
                  itemCount: filteredAlat.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final alat = filteredAlat[index];
                    return AlatCard(
                      alat: alat,
                      onEdit: () => _showEditAlatDialog(index),
                      onDelete: () {
                        setState(() {
                          alatList.removeAt(index);
                        });
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

// ================= DIALOG =================
class _TambahEditDialog extends StatefulWidget {
  final bool isEdit;
  final Alat? initialAlat;
  final void Function(Alat) onSave;

  const _TambahEditDialog({
    required this.isEdit,
    this.initialAlat,
    required this.onSave,
  });

  @override
  State<_TambahEditDialog> createState() => __TambahEditDialogState();
}

class __TambahEditDialogState extends State<_TambahEditDialog> {
  late TextEditingController namaController;
  late TextEditingController kategoriController;
  late TextEditingController kondisiController;

  // Untuk mobile (path)
  XFile? _selectedImageMobile;
  // Untuk web (bytes)
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.initialAlat?.name ?? '');
    kategoriController = TextEditingController(text: widget.initialAlat?.category ?? '');
    kondisiController = TextEditingController(
      text: widget.initialAlat != null
          ? (widget.initialAlat!.status == StatusAlat.bagus ? 'Baik' : 'Rusak')
          : '',
    );
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Web: pakai file_picker
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.single.bytes != null) {
          setState(() {
            _selectedImageBytes = result.files.single.bytes;
            _selectedImageName = result.files.single.name;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Pemilihan dibatalkan")),
            );
          }
        }
      } catch (e) {
        debugPrint("File Picker Web Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal memilih gambar: $e"), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      // Mobile: pakai image_picker
      final ImagePicker picker = ImagePicker();
      try {
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);

        if (image != null) {
          setState(() {
            _selectedImageMobile = image;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Pemilihan dibatalkan")),
            );
          }
        }
      } catch (e) {
        debugPrint("Image Picker Mobile Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal membuka galeri: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = kIsWeb ? _selectedImageBytes != null : _selectedImageMobile != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 300,
          height: 450,
          child: Column(
            children: [
              Text(
                widget.isEdit ? "Edit Alat" : "Tambah Alat",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _inputField(controller: namaController, hint: "Nama alat"),
              const SizedBox(height: 12),
              _inputField(controller: kategoriController, hint: "Kategori alat"),
              const SizedBox(height: 12),
              _inputField(controller: kondisiController, hint: "Kondisi alat (baik/rusak)"),

              const SizedBox(height: 24),

              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(12),
                splashColor: Colors.green.withOpacity(0.4),
                highlightColor: Colors.green.withOpacity(0.2),
                child: Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2.5),
                    color: Colors.green.withOpacity(0.08),
                  ),
                  child: Center(
                    child: !hasImage
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.add_photo_alternate_rounded,
                                  size: 48, color: Colors.green),
                              SizedBox(height: 4),
                              Text(
                                "Tambah Foto",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: kIsWeb
                                ? Image.memory(
                                    _selectedImageBytes!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.broken_image,
                                      color: Colors.red,
                                      size: 48,
                                    ),
                                  )
                                : Image.file(
                                    File(_selectedImageMobile!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.broken_image,
                                      color: Colors.red,
                                      size: 48,
                                    ),
                                  ),
                          ),
                  ),
                ),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (namaController.text.trim().isEmpty ||
                            kategoriController.text.trim().isEmpty ||
                            kondisiController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Lengkapi semua field terlebih dahulu"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final status = kondisiController.text.toLowerCase().contains("baik")
                            ? StatusAlat.bagus
                            : StatusAlat.rusak;

                        final alatBaru = Alat(
                          namaController.text.trim(),
                          kategoriController.text.trim(),
                          status,
                          kIsWeb ? null : _selectedImageMobile?.path,
                          kIsWeb ? _selectedImageBytes : null,
                        );

                        widget.onSave(alatBaru);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA8C98A),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("Simpan"),
                    ),
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

// ================= MODEL =================
enum StatusAlat { bagus, rusak }

class Alat {
  final String name;
  final String category;
  final StatusAlat status;
  final String? imagePath;     // untuk mobile
  final Uint8List? imageBytes; // untuk web

  Alat(this.name, this.category, this.status, this.imagePath, this.imageBytes);
}

// ================= CARD WIDGET =================
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

  Color get statusColor => alat.status == StatusAlat.bagus ? Colors.greenAccent : Colors.redAccent;

  String get statusText => alat.status == StatusAlat.bagus ? "Baik" : "Rusak";

  @override
  Widget build(BuildContext context) {
    final bool hasImage = alat.imagePath != null || alat.imageBytes != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 6),

          if (hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: kIsWeb && alat.imageBytes != null
                  ? Image.memory(
                      alat.imageBytes!,
                      height: 90,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                    )
                  : (alat.imagePath != null
                      ? Image.file(
                          File(alat.imagePath!),
                          height: 90,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                        )
                      : const SizedBox.shrink()),
            )
          else
            const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),

          const SizedBox(height: 8),

          Text(
            alat.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            alat.category,
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black54),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
              IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}