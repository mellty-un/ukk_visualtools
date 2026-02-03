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
        .where((item) => item['jenis_denda']
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
              const SizedBox(height: 12),
              TextField(
                controller: idPengembaC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ID Pengembalian'),
              ),
              TextField(
                controller: jenisC,
                decoration: const InputDecoration(labelText: 'Jenis Denda'),
              ),
              TextField(
                controller: totalC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Denda'),
              ),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(
                      value: 'belum_bayar', child: Text('Belum Bayar')),
                  DropdownMenuItem(value: 'lunas', child: Text('Lunas')),
                ],
                onChanged: (v) => status = v!,
                decoration: const InputDecoration(labelText: 'Status Bayar'),
              ),
              const SizedBox(height: 16),
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
                        'jenis_denda': jenisC.text,
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
    try {
      await dendaService.deleteDenda(id);
      fetchDenda();
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
      backgroundColor: const Color(0xFFB9D7A1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: const [
                  Icon(Icons.more_vert, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Denda',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SEARCH + ADD
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9E9E9),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: TextField(
                                controller: searchController,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  hintText: 'Cari jenis denda...',
                                  prefixIcon: Icon(Icons.search),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => openForm(),
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFA8C98A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 30),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Daftar Denda',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 15),
                      // LIST
                      Expanded(
                        child: ListView.builder(
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
    Color warna = status.contains('lunas')
        ? const Color(0xFFA5D6A7)
        : const Color(0xFFFFAB91);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
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
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, size: 20)),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, size: 20)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Total: Rp ${data['total_denda'] ?? 0}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: warna,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black45, width: 0.5),
              ),
              child: Text(
                data['status_bayar'] ?? "-",
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
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
