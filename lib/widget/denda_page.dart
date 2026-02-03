import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/denda_service.dart';

class DendaScreen extends StatefulWidget {
  const DendaScreen({super.key});

  @override
  State<DendaScreen> createState() => _DendaScreenState();
}

class _DendaScreenState extends State<DendaScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> dendaList = [];
  late final DendaService dendaService;

  @override
  void initState() {
    super.initState();
    dendaService = DendaService(Supabase.instance.client);
    fetchDenda();
  }

  // ================= LOAD DATA =================
  Future<void> fetchDenda() async {
    try {
      final data = await dendaService.getAllDenda();
      setState(() {
        dendaList = data;
      });
    } catch (e) {
      debugPrint('Fetch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get filteredList {
    if (searchController.text.isEmpty) return dendaList;
    return dendaList
        .where((item) => (item['jenis_denda'] ?? '')
            .toString()
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
        .toList();
  }

  // ================= FORM =================
  void openForm({Map<String, dynamic>? data}) {
    final idPengembaC =
        TextEditingController(text: data?['id_pengembalian']?.toString() ?? '');
    final jenisC = TextEditingController(text: data?['jenis_denda'] ?? '');
    final totalC =
        TextEditingController(text: data?['total_denda']?.toString() ?? '');

    String status = data?['status_bayar'] ?? 'belum_bayar';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data == null ? 'Tambah Denda' : 'Edit Denda',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: idPengembaC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ID Pengembalian',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: jenisC,
                decoration: const InputDecoration(
                  labelText: 'Jenis Denda',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: totalC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Denda (Rp)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(
                      value: 'belum_bayar', child: Text('Belum Bayar')),
                  DropdownMenuItem(value: 'lunas', child: Text('Lunas')),
                ],
                onChanged: (v) {
                  setState(() => status = v!);
                },
                decoration: const InputDecoration(
                  labelText: 'Status Bayar',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final payload = {
                        'id_pengembalian': int.tryParse(idPengembaC.text),
                        'jenis_denda': jenisC.text.trim(),
                        'total_denda': int.tryParse(totalC.text) ?? 0,
                        'status_bayar': status,
                      };
                      try {
                        if (data == null) {
                          await dendaService.addDenda(payload);
                        } else {
                          await dendaService.updateDenda(
                              data['id_denda'], payload);
                        }
                        Navigator.pop(context);
                        fetchDenda();
                      } catch (e) {
                        debugPrint('ERROR: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menyimpan: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ================= DELETE =================
  Future<void> deleteDenda(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Denda'),
        content: const Text('Yakin ingin menghapus denda ini?'),
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
      await dendaService.deleteDenda(id);
      fetchDenda();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Denda berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus denda: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // full putih seperti halaman lain
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFD9A8),
        elevation: 0,
        title: const Text(
          'Denda',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search + Tombol Tambah (dipisah)
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
                      controller: searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Cari jenis denda...',
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

            // List atau pesan kosong
            Expanded(
              child: dendaList.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.money_off_csred_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada data denda',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tambahkan denda baru dengan tombol + di atas',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return buildCard(
                          item,
                          onEdit: () => openForm(data: item),
                          onDelete: () => deleteDenda(item['id_denda']),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget buildCard(
    Map<String, dynamic> data, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final status = data['status_bayar'].toString().toLowerCase();
    final warna = status.contains('lunas')
        ? const Color(0xFFA5D6A7)
        : const Color(0xFFFFAB91);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data['jenis_denda'] ?? "-",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, color: Colors.black),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.black),
                tooltip: 'Hapus',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Total: Rp ${data['total_denda'] ?? 0}",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: warna,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                data['status_bayar'] ?? "-",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}