import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DendaPage extends StatefulWidget {
  final int idPengembalian;

  const DendaPage({
    super.key,
    required this.idPengembalian,
  });

  @override
  State<DendaPage> createState() => _DendaPageState();
}

class _DendaPageState extends State<DendaPage> {
  final supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> _simpanDendaTanpaConstraint() async {
    setState(() => isLoading = true);
    
    try {
      // 1. Langsung coba SIMPLE INSERT tanpa status_bayar
      final result = await supabase.from('denda').insert({
        'id_pengembalian': widget.idPengembalian,
        'total_denda': 0,
        // JANGAN MASUKKAN status_bayar - biarkan NULL atau DEFAULT
      }).select();
      
      print('✅ Berhasil insert: $result');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Denda berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
      
    } catch (e) {
      print('Error: $e');
      
      // 2. Jika masih error, coba pakai FUNCTION
      try {
        await supabase.rpc('simpan_denda_aman', params: {
          'p_id': widget.idPengembalian,
        });
        
        print('✅ Berhasil via function');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Denda berhasil disimpan via function'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
        
      } catch (e2) {
        print('Error function: $e2');
        
        // 3. Coba SOLUSI EXTREME: Disable constraint sementara
        _solusiExtreme();
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _solusiExtreme() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Perbaiki Database'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Constraint error di tabel "denda".'),
            SizedBox(height: 10),
            Text('Jalankan query ini di SQL Editor:'),
            SizedBox(height: 5),
            SelectableText(
              "ALTER TABLE denda ALTER COLUMN status_bayar SET DEFAULT 'belum_bayar';",
              style: TextStyle(fontFamily: 'monospace'),
            ),
            SizedBox(height: 10),
            Text('Atau hapus constraint:'),
            SizedBox(height: 5),
            SelectableText(
              "ALTER TABLE denda DROP CONSTRAINT denda_status_bayar_check;",
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Denda'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Menyimpan denda...',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _simpanDendaTanpaConstraint,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('SIMPAN DENDA AMAN'),
              ),
              const SizedBox(height: 20),
              const Text(
                '⚠️ Setelah berhasil, cek constraint di database',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}