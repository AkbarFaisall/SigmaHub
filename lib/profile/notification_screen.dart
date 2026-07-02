// File: lib/profile/notification_screen.dart
import 'package:flutter/material.dart';
import '../sigma_theme.dart';
import 'profile_screen.dart'; // IMPORT PROFILE UNTUK AKSES VARIABEL DARK MODE

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _beasiswaBaru = true;
  bool _deadline = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, isDark, child) {
        Color primaryWarna = isDark ? Colors.green.shade400 : WarnaSigma.utama;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : WarnaSigma.latar,
          appBar: AppBar(
            title: Text('Pusat Notifikasi', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSwitchCard(
                'Beasiswa Baru', 
                'Info rilis setiap hari', 
                _beasiswaBaru, 
                (v) => setState(() => _beasiswaBaru = v), 
                isDark, 
                primaryWarna
              ),
              _buildSwitchCard(
                'Deadline Mendekat', 
                'Pengingat 1 hari sebelum penutupan', 
                _deadline, 
                (v) => setState(() => _deadline = v), 
                isDark, 
                primaryWarna
              ),
            ],
          ),
        );
      }
    );
  }

  // Widget Pembantu agar tampilan SwitchListTile rapi di dalam Card
  Widget _buildSwitchCard(String title, String subtitle, bool value, Function(bool) onChanged, bool isDark, Color primaryWarna) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: SwitchListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        subtitle: Text(subtitle, style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
        value: value,
        onChanged: onChanged,
        activeColor: primaryWarna,
      ),
    );
  }
}