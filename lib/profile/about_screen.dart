// File: lib/profile/about_screen.dart
import 'package:flutter/material.dart';
import '../sigma_theme.dart';
import 'profile_screen.dart'; // IMPORT PROFILE UNTUK AKSES VARIABEL DARK MODE

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, isDark, child) {
        Color primaryWarna = isDark ? Colors.green.shade400 : WarnaSigma.utama;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          appBar: AppBar(
            title: Text('Tentang SIGMA', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.school, size: 80, color: primaryWarna),
                Text('SIGMA', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                Chip(
                  label: const Text('v1.0.4'),
                  backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200,
                  labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
                  side: BorderSide.none,
                ),
                const SizedBox(height: 20),
                Text(
                  'SIGMA adalah platform informasi beasiswa untuk menjembatani aspirasi akademik dengan aksesibilitas modern.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: isDark ? Colors.grey.shade400 : Colors.black87),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}