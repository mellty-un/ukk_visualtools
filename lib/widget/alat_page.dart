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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TambahEditDialog(
        isEdit: alat != null,
        initialAlat: alat,
      ),
    ).then((result) {
      if (result == true) {
        _loadAlat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F0), // Background hijau muda
      body: CustomScrollView(
        slivers: [
          // Header dengan gradient hijau
          SliverAppBar(
            backgroundColor: const Color(0xFF2E7D32), // Hijau gelap
            expandedHeight: 200,
            pinned: true,
            floating: false,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF2E7D32)),
                    onPressed: () => _openDialog(),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Daftar Alat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF4CAF50).withOpacity(0.9),
                      const Color(0xFF2E7D32),
                      const Color(0xFF1B5E20),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.inventory_rounded,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            sliver: SliverToBoxAdapter(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFC8E6C9), width: 2),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(
                      Icons.search_rounded,
                      color: const Color(0xFF4CAF50),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Cari alat...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF81C784),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    if (searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: const Color(0xFF4CAF50),
                        ),
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Stats Cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  _buildStatCard(
                    'Total Alat',
                    alatList.length.toString(),
                    Icons.inventory_2_rounded,
                    const Color(0xFF4CAF50),
                    const Color(0xFFE8F5E9),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Tersedia',
                    alatList.where((a) => a.status == StatusAlat.bagus).length.toString(),
                    Icons.check_circle_rounded,
                    const Color(0xFF2E7D32),
                    const Color(0xFFC8E6C9),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Rusak',
                    alatList.where((a) => a.status == StatusAlat.rusak).length.toString(),
                    Icons.warning_rounded,
                    const Color(0xFFE53935),
                    const Color(0xFFFFEBEE),
                  ),
                ],
              ),
            ),
          ),

          // Grid Title
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'SEMUA ALAT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E7D32),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${filteredAlat.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grid View atau Empty/Loading
          isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(
                            color: Color(0xFF2E7D32),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Memuat data alat...',
                          style: TextStyle(
                            color: const Color(0xFF2E7D32),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : filteredAlat.isEmpty
                  ? SliverFillRemaining(
                      child: _buildEmptyState(),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final alat = filteredAlat[index];
                            return AlatCard(
                              alat: alat,
                              onEdit: () => _openDialog(alat: alat),
                              onDelete: () async {
                                await _showDeleteDialog(alat);
                              },
                            );
                          },
                          childCount: filteredAlat.length,
                        ),
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, size: 24),
        ),
        label: const Text(
          'Tambah Alat',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Belum ada alat',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tambahkan alat pertama Anda dengan menekan tombol di bawah',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF81C784),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _openDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              shadowColor: const Color(0xFF2E7D32).withOpacity(0.5),
            ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'Tambah Alat Pertama',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(Alat alat) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Color(0xFFE53935),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Hapus Alat?',
                style: TextStyle(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus alat "${alat.name}"? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4CAF50),
              side: const BorderSide(color: Color(0xFF4CAF50)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AlatService.deleteAlat(
                idAlat: alat.idAlat,
                imageUrl: alat.imageUrl,
              );
              Navigator.pop(context);
              _loadAlat();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Alat "${alat.name}" berhasil dihapus'),
                  backgroundColor: const Color(0xFF4CAF50),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Hapus'),
          ),
        ],
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
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          webImage = result.files.first.bytes;
        });
      }
    } else {
      final result = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (result != null) {
        setState(() {
          mobileImage = result;
        });
      }
    }
  }

  Future<void> _simpan() async {
    if (namaC.text.isEmpty || kategoriC.text.isEmpty || kondisiC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Harap isi semua field'),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

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
    Navigator.pop(context, true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEdit ? 'Alat berhasil diperbarui' : 'Alat berhasil ditambahkan',
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header dengan gradient hijau
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF4CAF50),
                      const Color(0xFF2E7D32),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        widget.isEdit ? Icons.edit_rounded : Icons.add_circle_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEdit ? 'Edit Alat' : 'Tambah Alat Baru',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.isEdit
                                ? 'Perbarui informasi alat'
                                : 'Tambahkan alat baru ke inventaris',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Nama Alat
                    _buildTextField(
                      controller: namaC,
                      label: 'Nama Alat',
                      hintText: 'Masukkan nama alat',
                      icon: Icons.inventory_2_rounded,
                    ),
                    const SizedBox(height: 20),
                    
                    // Kategori
                    _buildTextField(
                      controller: kategoriC,
                      label: 'Kategori',
                      hintText: 'Contoh: Elektronik, Perkakas',
                      icon: Icons.category_rounded,
                    ),
                    const SizedBox(height: 20),
                    
                    // Kondisi
                    _buildConditionDropdown(),
                    const SizedBox(height: 20),
                    
                    // Gambar
                    _buildImagePicker(),
                    const SizedBox(height: 32),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                            ),
                            child: Text(
                              'Batal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _simpan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              shadowColor: const Color(0xFF2E7D32).withOpacity(0.5),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        widget.isEdit
                                            ? Icons.check_circle_rounded
                                            : Icons.add_circle_rounded,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        widget.isEdit ? 'Simpan' : 'Tambah',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: const Color(0xFFC8E6C9), width: 2),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFF81C784)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF4CAF50),
                size: 24,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kondisi',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: const Color(0xFFC8E6C9), width: 2),
          ),
          child: DropdownButtonFormField<String>(
            value: kondisiC.text,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              prefixIcon: Icon(
                Icons.health_and_safety_rounded,
                color: const Color(0xFF4CAF50),
                size: 24,
              ),
            ),
            items: ['Baik', 'Rusak'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: value == 'Baik'
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE53935),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                kondisiC.text = value ?? 'Baik';
              });
            },
            borderRadius: BorderRadius.circular(15),
            dropdownColor: Colors.white,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    final hasImage = mobileImage != null || webImage != null;
    final initialImage = widget.initialAlat?.imageUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gambar Alat',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: pickImage,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFC8E6C9),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: hasImage
                  ? Stack(
                      children: [
                        kIsWeb && webImage != null
                            ? Image.memory(
                                webImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : mobileImage != null
                                ? Image.file(
                                    File(mobileImage!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : const SizedBox(),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Ubah Gambar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : initialImage != null
                      ? Stack(
                          children: [
                            Image.network(
                              initialImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildImagePlaceholder();
                              },
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Ubah Gambar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : _buildImagePlaceholder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.image_rounded,
              color: Color(0xFF4CAF50),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ketuk untuk memilih gambar',
            style: TextStyle(
              color: const Color(0xFF4CAF50),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Format: JPG, PNG | Maks. 5MB',
            style: TextStyle(
              color: const Color(0xFF81C784),
              fontSize: 13,
            ),
          ),
        ],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8F5E9), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section with gradient overlay
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  // Image or placeholder
                  Container(
                    color: const Color(0xFFF0F7F0),
                    child: alat.imageUrl != null
                        ? Image.network(
                            alat.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: const Color(0xFF4CAF50),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                          )
                        : _buildImagePlaceholder(),
                  ),

                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF2E7D32).withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),

                  // Status Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: alat.status == StatusAlat.bagus
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            alat.status == StatusAlat.bagus
                                ? Icons.check_circle_rounded
                                : Icons.warning_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            alat.status == StatusAlat.bagus ? 'BAIK' : 'RUSAK',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        alat.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ID: ${alat.idAlat}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.category_rounded,
                      size: 18,
                      color: const Color(0xFF81C784),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      alat.category,
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onEdit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text(
                            'Edit',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE53935).withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_rounded,
                            size: 22,
                            color: Color(0xFFE53935),
                          ),
                          padding: const EdgeInsets.all(12),
                          tooltip: 'Hapus',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Color(0xFF4CAF50),
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No Image',
            style: TextStyle(
              color: const Color(0xFF81C784),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}