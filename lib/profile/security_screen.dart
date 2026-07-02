// File: lib/profile/security_screen.dart
import 'package:flutter/material.dart';
import '../sigma_theme.dart';
import 'profile_screen.dart'; // IMPORT PROFILE UNTUK AKSES VARIABEL DARK MODE

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, isDark, child) {
        Color primaryWarna = isDark ? Colors.green.shade400 : WarnaSigma.utama;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : WarnaSigma.latar,
          appBar: AppBar(
            title: Text('Keamanan Akun', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                elevation: 0,
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: Icon(Icons.lock_reset, color: primaryWarna),
                  title: Text('Ganti Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  subtitle: Text('Terakhir diupdate 3 bulan lalu', style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
                  trailing: Icon(Icons.chevron_right, color: isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi),
                  onTap: () {
                    // Fungsi tap bisa diisi nanti
                  },
                ),
              )
            ],
          ),
        );
      }
    );
  }
}