import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widget/tambah_kategori.dart';
import '../widget/edit_kategori.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final supabase = Supabase.instance.client;
  String search = '';

  Future<List<Map<String, dynamic>>> fetchKategori() async {
    final data = search.isEmpty
        ? await supabase
            .from('kategori')
            .select()
            .order('id_kategori', ascending: false)
        : await supabase
            .from('kategori')
            .select()
            .ilike('nama_kategori', '%$search%')
            .order('id_kategori', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> hapusKategori(int id) async {
    await supabase
        .from('kategori')
        .delete()
        .eq('id_kategori', id);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8D8A0),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.more_vert),
                  SizedBox(width: 8),
                  Text(
                    'Kategori',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    /// SEARCH + PLUS
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (v) =>
                                  setState(() => search = v),
                              decoration: InputDecoration(
                                hintText: 'Cari...',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (_) =>
                                    const TambahKategoriDialog(),
                              );
                              if (result == true) setState(() {});
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6FAF6B),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),

                    /// LIST
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchKategori(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final data = snapshot.data!;
                          if (data.isEmpty) {
                            return const Center(
                                child: Text('Tidak ada kategori'));
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            itemCount: data.length,
                            itemBuilder: (context, i) {
                              final item = data[i];
                              return Container(
                                margin:
                                    const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                  border: Border.all(
                                      color: const Color(0xFFB8D8A0)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['nama_kategori'],
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold),
                                          ),
                                          if (item['keterangan'] !=
                                              null)
                                            Text(
                                              item['keterangan'],
                                              style: const TextStyle(
                                                  fontSize: 12),
                                            ),
                                        ],
                                      ),
                                    ),

                                    /// EDIT
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: Colors.black,
                                      ),
                                      onPressed: () async {
                                        final result =
                                            await showDialog(
                                          context: context,
                                          builder: (_) =>
                                              EditKategoriDialog(
                                            id: item['id_kategori'],
                                            nama:
                                                item['nama_kategori'],
                                            keterangan:
                                                item['keterangan'] ??
                                                    '',
                                          ),
                                        );
                                        if (result == true) {
                                          setState(() {});
                                        }
                                      },
                                    ),

                                    /// DELETE
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.black,
                                      ),
                                      onPressed: () =>
                                          hapusKategori(
                                              item['id_kategori']),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}