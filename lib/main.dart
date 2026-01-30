import 'package:flutter/material.dart';
import 'package:krpl/widget/alat_page.dart';
import 'package:krpl/widget/tambah_pengguna.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screen/splash_screen.dart';
import 'screen/login_screen.dart';
import 'screen/user_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vefbzsnlhbbwcwomvkbb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZlZmJ6c25saGJid2N3b212a2JiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgzMjc4NjIsImV4cCI6MjA4MzkwMzg2Mn0.QC1nP0NxbwTXLqf-YOBCjWCpDf-VJGQeX01uJ6QLTwQ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/users': (context) => const UserScreen(),
        '/pengguna': (context) => const TambahPenggunaDialog(),
        '/alat' : (context) => const AlatScreen(),
      },
    );
  }
}