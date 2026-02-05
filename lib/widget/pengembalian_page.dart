import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============== HALAMAN UTAMA ==============
class PengembalianPage extends StatefulWidget {
  final int idPeminjaman;
  final String tanggalRencanaKembali;

  const PengembalianPage({
    super.key,
    required this.idPeminjaman,
    required this.tanggalRencanaKembali,
  });

  @override
  State<PengembalianPage> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? peminjamanData;
  List<dynamic> riwayatPengembalian = [];
  List<dynamic> riwayatDenda = [];
  List<dynamic>? alatDipinjam;

  DateTime? _tanggalPengembalian;
  String _kondisiAlat = 'baik';

  bool _isLoading = true;
  bool _isSubmitting = false;

  int totalDenda = 0;
  int keterlambatanHari = 0;
  final int dendaPerHari = 10000;

  final List<String> _kondisiOptions = [
    'baik',
    'rusak_ringan',
    'rusak_berat'
  ];

  @override
  void initState() {
    super.initState();
    _tanggalPengembalian = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load data peminjaman
      final peminjamanResult = await supabase
          .from('peminjaman')
          .select()
          .eq('id_peminjaman', widget.idPeminjaman)
          .single();

      peminjamanData = peminjamanResult;

      // Load riwayat pengembalian
      final riwayatResult = await supabase
          .from('pengembalian')
          .select()
          .eq('id_peminjaman', widget.idPeminjaman)
          .order('tanggal_pengembalian', ascending: false);

      riwayatPengembalian = riwayatResult;

      // Load data denda dari pengembalian yang sudah ada
      if (riwayatPengembalian.isNotEmpty) {
        // Menggunakan cara manual untuk filter multiple id_pengembalian
        List<dynamic> semuaDenda = [];
        
        // Query untuk setiap id_pengembalian
        for (final riwayat in riwayatPengembalian) {
          final idPengembalian = riwayat['id_pengembalian'];
          final dendaResult = await supabase
              .from('denda')
              .select()
              .eq('id_pengembalian', idPengembalian);
          
          semuaDenda.addAll(dendaResult);
        }
        
        // Urutkan berdasarkan created_at
        riwayatDenda = semuaDenda;
        riwayatDenda.sort((a, b) {
          final dateA = DateTime.tryParse(a['created_at'] ?? '');
          final dateB = DateTime.tryParse(b['created_at'] ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA); // descending
        });
      }

      // Load alat yang dipinjam
      final alatResult = await supabase
          .from('detail_peminjaman')
          .select('id_alat')
          .eq('id_peminjaman', widget.idPeminjaman);

      alatDipinjam = alatResult;

      _hitungDenda();
    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _hitungDenda() {
    final rencana = DateTime.tryParse(widget.tanggalRencanaKembali);
    final kembali = _tanggalPengembalian ?? DateTime.now();

    totalDenda = 0;
    keterlambatanHari = 0;

    // Hitung denda keterlambatan
    if (rencana != null && kembali.isAfter(rencana)) {
      keterlambatanHari = kembali.difference(rencana).inDays;
      totalDenda += keterlambatanHari * dendaPerHari;
    }

    // Denda kerusakan akan dihitung di DendaPage
    setState(() {});
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _tanggalPengembalian = picked;
      });
      _hitungDenda();
    }
  }

  Future<void> _prosesPengembalian() async {
    if (_tanggalPengembalian == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Insert data pengembalian
      final pengembalianResult = await supabase
          .from('pengembalian')
          .insert({
            'id_peminjaman': widget.idPeminjaman,
            'tanggal_pengembalian': _tanggalPengembalian!.toIso8601String(),
            'kondisi_pengembalian': _kondisiAlat,
            'keterlambatan_hari': keterlambatanHari,
          })
          .select()
          .single();

      final idPengembalian = pengembalianResult['id_pengembalian'] as int;

      // Navigasi ke halaman denda jika ada potensi denda
      bool adaPotensiDenda = keterlambatanHari > 0 || _kondisiAlat != 'baik';
      
      if (adaPotensiDenda) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DendaPage(
              idPengembalian: idPengembalian,
              terlambat: keterlambatanHari > 0,
              rusak: _kondisiAlat != 'baik',
              hariTerlambat: keterlambatanHari,
              kondisiAlat: _kondisiAlat,
            ),
          ),
        );

        if (result == true) {
          // Update status peminjaman
          await _updateStatusPeminjaman();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Pengembalian berhasil dicatat'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          await _loadData();
        } else {
          // Jika user batal di halaman denda, hapus data pengembalian
          await supabase
              .from('pengembalian')
              .delete()
              .eq('id_pengembalian', idPengembalian);
          
          setState(() => _isSubmitting = false);
        }
      } else {
        // Update status peminjaman jika tidak ada denda
        await _updateStatusPeminjaman();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pengembalian berhasil dicatat'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        await _loadData();
      }
    } catch (e) {
      print('Error proses pengembalian: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _updateStatusPeminjaman() async {
    // Update status peminjaman
    await supabase
        .from('peminjaman')
        .update({'status_peminjaman': 'selesai'})
        .eq('id_peminjaman', widget.idPeminjaman);

    // Update status alat jika kondisi baik
    if (_kondisiAlat == 'baik' && alatDipinjam != null) {
      for (var alat in alatDipinjam!) {
        await supabase
            .from('alat_alat')
            .update({'status': 'tersedia'})
            .eq('id_alat', alat['id_alat']);
      }
    }
  }

  String _formatTanggal(String? value) {
    if (value == null) return '-';
    final d = DateTime.tryParse(value);
    if (d == null) return value;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _formatKondisi(String v) {
    switch (v) {
      case 'rusak_ringan':
        return 'Rusak Ringan';
      case 'rusak_berat':
        return 'Rusak Berat';
      default:
        return 'Baik';
    }
  }

  Color _kondisiColor(String v) {
    switch (v) {
      case 'rusak_ringan':
        return Colors.orange;
      case 'rusak_berat':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  String _formatStatusBayar(String status) {
    switch (status.toLowerCase()) {
      case 'lunas':
        return 'LUNAS';
      case 'belum':
        return 'BELUM LUNAS';
      case 'sebagian':
        return 'SEBAGIAN';
      default:
        return status;
    }
  }

  Color _statusBayarColor(String status) {
    switch (status.toLowerCase()) {
      case 'lunas':
        return Colors.green;
      case 'belum':
        return Colors.red;
      case 'sebagian':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPotensiDenda() {
    bool adaPotensiDenda = keterlambatanHari > 0 || _kondisiAlat != 'baik';
    
    if (!adaPotensiDenda) {
      return Card(
        elevation: 2,
        color: Colors.green[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tidak ada potensi denda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'POTENSI DENDA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (keterlambatanHari > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Keterlambatan:'),
                  Text(
                    '$keterlambatanHari hari',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            
            if (_kondisiAlat != 'baik') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kondisi Alat:'),
                  Text(
                    _formatKondisi(_kondisiAlat),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _kondisiColor(_kondisiAlat),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            
            const Divider(height: 20),
            
            Text(
              'Denda akan dihitung di halaman selanjutnya',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengembalian Alat'),
        backgroundColor: const Color(0xFFB8D8A0),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informasi Peminjaman
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📋 INFORMASI PEMINJAMAN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ID Peminjaman:'),
                              Text(
                                '#${widget.idPeminjaman}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Rencana Kembali:'),
                              Text(
                                _formatTanggal(widget.tanggalRencanaKembali),
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Form Pengembalian
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📝 FORM PENGEMBALIAN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Tanggal Pengembalian
                          InkWell(
                            onTap: _pilihTanggal,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '📅 Tanggal Pengembalian',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    _formatTanggal(_tanggalPengembalian?.toIso8601String()),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Kondisi Alat
                          Text(
                            '🎛️ Kondisi Alat Saat Dikembalikan',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _kondisiAlat,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            items: _kondisiOptions.map((kondisi) {
                              return DropdownMenuItem(
                                value: kondisi,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _kondisiColor(kondisi),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(_formatKondisi(kondisi)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _kondisiAlat = value;
                                });
                                _hitungDenda();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Potensi Denda
                  _buildPotensiDenda(),
                  
                  const SizedBox(height: 20),
                  
                  // Tombol Kembalikan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _prosesPengembalian,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'PROSES PENGEMBALIAN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  // Riwayat Denda
                  if (riwayatDenda.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      '💰 RIWAYAT DENDA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ...riwayatDenda.map((denda) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _statusBayarColor(denda['status_bayar']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.money,
                              color: _statusBayarColor(denda['status_bayar']),
                            ),
                          ),
                          title: Text(
                            'Denda ID: #${denda['id_denda']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Jenis: ${denda['jenis_denda'] ?? 'Tidak ada'}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Status: ${_formatStatusBayar(denda['status_bayar'] ?? 'belum')}',
                                style: TextStyle(
                                  color: _statusBayarColor(denda['status_bayar'] ?? 'belum'),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rp ${denda['total_denda'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTanggal(denda['created_at']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                  
                  const SizedBox(height: 30),
                  
                  // Riwayat Pengembalian
                  if (riwayatPengembalian.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      '📜 RIWAYAT PENGEMBALIAN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ...riwayatPengembalian.map((r) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 1,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _kondisiColor(r['kondisi_pengembalian']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.history,
                                color: _kondisiColor(r['kondisi_pengembalian']),
                              ),
                            ),
                            title: Text(
                              _formatTanggal(r['tanggal_pengembalian']),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Kondisi: ${_formatKondisi(r['kondisi_pengembalian'])}',
                              style: TextStyle(
                                color: _kondisiColor(r['kondisi_pengembalian']),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: (r['denda'] as int? ?? 0) > 0
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.red[100]!),
                                    ),
                                    child: Text(
                                      'Rp ${r['denda']}',
                                      style: TextStyle(
                                        color: Colors.red[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.green[100]!),
                                    ),
                                    child: const Text(
                                      'TANPA DENDA',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                          ),
                        )).toList(),
                  ] else ...[
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history_toggle_off,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada riwayat pengembalian',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

// ============== HALAMAN DENDA ==============
class DendaPage extends StatefulWidget {
  final int idPengembalian;
  final bool terlambat;
  final bool rusak;
  final int hariTerlambat;
  final String kondisiAlat;

  const DendaPage({
    super.key,
    required this.idPengembalian,
    required this.terlambat,
    required this.rusak,
    required this.hariTerlambat,
    required this.kondisiAlat,
  });

  @override
  State<DendaPage> createState() => _DendaPageState();
}

class _DendaPageState extends State<DendaPage> {
  final supabase = Supabase.instance.client;
  int totalDenda = 0;
  String jenisDenda = 'Tidak Ada Denda';
  
  // Harga denda
  final int dendaPerHari = 10000;
  final int dendaRusakRingan = 20000;
  final int dendaRusakBerat = 50000;

  @override
  void initState() {
    super.initState();
    _hitungDenda();
  }

  void _hitungDenda() {
    int denda = 0;
    List<String> jenis = [];

    // Hitung denda keterlambatan
    if (widget.terlambat && widget.hariTerlambat > 0) {
      int dendaTerlambat = widget.hariTerlambat * dendaPerHari;
      denda += dendaTerlambat;
      jenis.add('Terlambat ${widget.hariTerlambat} hari');
    }

    // Hitung denda kerusakan
    if (widget.rusak) {
      if (widget.kondisiAlat == 'rusak_ringan') {
        denda += dendaRusakRingan;
        jenis.add('Rusak Ringan');
      } else if (widget.kondisiAlat == 'rusak_berat') {
        denda += dendaRusakBerat;
        jenis.add('Rusak Berat');
      }
    }

    totalDenda = denda;
    jenisDenda = jenis.isEmpty ? 'Tidak Ada Denda' : jenis.join(' & ');
  }

  Future<void> _simpanDenda() async {
    try {
      // Update pengembalian dengan total denda
      await supabase
          .from('pengembalian')
          .update({
            'denda': totalDenda,
          })
          .eq('id_pengembalian', widget.idPengembalian);

      // Simpan data denda ke tabel denda
      if (totalDenda > 0) {
        await supabase.from('denda').insert({
          'id_pengembalian': widget.idPengembalian,
          'jenis_denda': jenisDenda,
          'total_denda': totalDenda,
          'status_bayar': 'belum',
        });
      }

      Navigator.pop(context, true); // Kembali dengan status sukses
    } catch (e) {
      print('Error simpan denda: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal menyimpan denda: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildItemDenda(String label, int? value, {String? subLabel, Color? color}) {
    if (value == null || value == 0) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                'Rp ${value.toString()}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color ?? Colors.red,
                ),
              ),
            ],
          ),
          if (subLabel != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                subLabel,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perhitungan Denda'),
        backgroundColor: const Color(0xFFB8D8A0),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              elevation: 2,
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.money,
                      color: Colors.blue[700],
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PERHITUNGAN DENDA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID Pengembalian: #${widget.idPengembalian}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Detail Perhitungan
            Text(
              '📊 DETAIL PERHITUNGAN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            
            if (widget.terlambat && widget.hariTerlambat > 0) 
              _buildItemDenda(
                'Denda Keterlambatan:',
                widget.hariTerlambat * dendaPerHari,
                subLabel: '${widget.hariTerlambat} hari × Rp $dendaPerHari/hari',
                color: Colors.orange[800],
              ),
            
            if (widget.kondisiAlat == 'rusak_ringan') 
              _buildItemDenda('Denda Rusak Ringan:', dendaRusakRingan),
            
            if (widget.kondisiAlat == 'rusak_berat') 
              _buildItemDenda('Denda Rusak Berat:', dendaRusakBerat),
            
            if (totalDenda == 0) ...[
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak ada denda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tidak ada keterlambatan dan alat dalam kondisi baik',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Total Denda
            if (totalDenda > 0) ...[
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL DENDA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rp ${totalDenda.toString()}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      jenisDenda,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 30),
            
            // Informasi Status
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ INFORMASI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Denda akan dicatat dan status pembayaran awal adalah "BELUM LUNAS"',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Admin dapat mengubah status pembayaran nanti',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'BATAL',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _simpanDenda,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'SIMPAN DENDA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}