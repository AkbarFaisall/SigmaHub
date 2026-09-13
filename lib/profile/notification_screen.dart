// File: lib/profile/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
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
  int _hMinusHari = 1; // Default H-1

  @override
  void initState() {
    super.initState();
    _muatPengaturan();
  }

  Future<void> _muatPengaturan() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _beasiswaBaru = sp.getBool('notif_beasiswa_baru') ?? true;
      _deadline = sp.getBool('notif_deadline') ?? true;
      _hMinusHari = sp.getInt('notif_h_minus') ?? 1;
    });
  }

  Future<void> _simpanPengaturanBeasiswaBaru(bool val) async {
    setState(() => _beasiswaBaru = val);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('notif_beasiswa_baru', val);

    if (val) {
      OneSignal.User.addTagWithKey('new_scholarship', '1');
    } else {
      OneSignal.User.removeTag('new_scholarship');
    }
  }

  Future<void> _simpanPengaturanDeadline(bool val) async {
    setState(() => _deadline = val);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('notif_deadline', val);
    // Catatan: Jadwal ulang semua bookmark bisa ditaruh di sini jika perlu, 
    // namun demi performa, kita hanya mengubah preferensi masa depan.
  }

  Future<void> _simpanPengaturanHMinus(int val) async {
    setState(() => _hMinusHari = val);
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('notif_h_minus', val);
  }

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
                'Dapatkan notifikasi saat beasiswa baru ditambahkan', 
                _beasiswaBaru, 
                _simpanPengaturanBeasiswaBaru, 
                isDark, 
                primaryWarna
              ),
              _buildSwitchCard(
                'Deadline Mendekat', 
                'Pengingat sebelum beasiswa simpananmu ditutup', 
                _deadline, 
                _simpanPengaturanDeadline, 
                isDark, 
                primaryWarna,
                tambahanBawah: _deadline ? _buildDropdownHMinus(isDark) : null,
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildDropdownHMinus(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Ingatkan saya pada:', style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87)),
          DropdownButton<int>(
            value: _hMinusHari,
            dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
            underline: Container(height: 1, color: WarnaSigma.emas),
            items: const [
              DropdownMenuItem(value: 1, child: Text('H-1 Penutupan')),
              DropdownMenuItem(value: 3, child: Text('H-3 Penutupan')),
              DropdownMenuItem(value: 7, child: Text('H-7 Penutupan')),
            ],
            onChanged: (val) {
              if (val != null) _simpanPengaturanHMinus(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchCard(String title, String subtitle, bool value, Function(bool) onChanged, bool isDark, Color primaryWarna, {Widget? tambahanBawah}) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            subtitle: Text(subtitle, style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
            value: value,
            onChanged: onChanged,
            activeColor: primaryWarna,
          ),
          if (tambahanBawah != null) tambahanBawah,
        ],
      ),
    );
  }
}