// File: lib/main.dart
import 'package:flutter/material.dart';
import 'sigma_theme.dart';
import 'login/splash_screen.dart';
import 'login/login_screen.dart';
import 'login/register_screen.dart';
import 'home_screen.dart';
import 'bookmark_screen.dart';
import 'profile/profile_screen.dart';
import 'profile/about_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'profile/help_center_screen.dart';
import 'profile/notification_screen.dart';
import 'profile/security_screen.dart';
import 'admin/admin_dashboard_screen.dart'; // IMPORT DASHBOARD ADMIN

import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_config.dart';
import 'providers/profile_provider.dart';
import 'providers/scholarship_provider.dart';
import 'providers/bookmark_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Supabase jika kredensial sudah dikonfigurasi
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      debugPrint('Koneksi Supabase berhasil diinisialisasi.');
    } catch (e) {
      debugPrint('Inisialisasi Supabase gagal: $e');
    }
  } else {
    debugPrint('Supabase belum terkonfigurasi. Berjalan dalam mode database lokal.');
  }

  // 2. Muat status Dark Mode dari penyimpanan lokal
  try {
    final sp = await SharedPreferences.getInstance();
    final bool isDark = sp.getBool('sigma_dark_mode') ?? false;
    globalDarkModeNotifier.value = isDark;
  } catch (e) {
    debugPrint('Gagal membaca status tema lokal: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ScholarshipProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
      ],
      child: const AplikasiSigma(),
    ),
  );
}

class AplikasiSigma extends StatelessWidget {
  const AplikasiSigma({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIGMA',
      debugShowCheckedModeBanner: false,
      theme: buatTemaSigma(),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/bookmarks': (context) => const BookmarkScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/security': (context) => const SecurityScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/about': (context) => const AboutScreen(),
        '/help': (context) => const HelpCenterScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
      },
    );
  }
}

// Logika dummy untuk menyimpan beasiswa agar terbaca di semua halaman
class BookmarkGlobal {
  static final List<Map<String, dynamic>> daftarSimpanan = [];

  static bool cekTersimpan(String namaBeasiswa) {
    return daftarSimpanan.any((data) => data['name'] == namaBeasiswa);
  }

  static void tekanBookmark(Map<String, dynamic> item) {
    if (cekTersimpan(item['name'])) {
      daftarSimpanan.removeWhere((data) => data['name'] == item['name']);
    } else {
      daftarSimpanan.add(item);
    }
  }
}