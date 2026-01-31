import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  // Ganti ini dengan URL & ANON KEY Supabase kamu
  static const String supabaseUrl = 'https://vefbzsnlhbbwcwomvkbb.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZlZmJ6c25saGJid2N3b212a2JiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgzMjc4NjIsImV4cCI6MjA4MzkwMzg2Mn0.QC1nP0NxbwTXLqf-YOBCjWCpDf-VJGQeX01uJ6QLTwQ';

  static final SupabaseClient supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);

  // Inisialisasi Supabase
  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    print('Supabase berhasil dihubungkan!');
  }
}