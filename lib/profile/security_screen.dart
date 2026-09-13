// File: lib/profile/security_screen.dart
import 'package:flutter/material.dart';
import '../sigma_theme.dart';
import 'profile_screen.dart'; // IMPORT PROFILE UNTUK AKSES VARIABEL DARK MODE
import 'change_password_screen.dart'; // IMPORT HALAMAN GANTI KATA SANDI

import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _kunciAktif = false;
  bool _dukungBiometrik = false;

  @override
  void initState() {
    super.initState();
    _cekDukunganBiometrik();
    _muatStatusKunci();
  }

  Future<void> _cekDukunganBiometrik() async {
    final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    setState(() {
      _dukungBiometrik = canAuthenticate;
    });
  }

  Future<void> _muatStatusKunci() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _kunciAktif = prefs.getBool('kunciAktif') ?? false;
    });
  }

  Future<void> _toggleKunci(bool nilaiBaru) async {
    if (!_dukungBiometrik) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Perangkat tidak mendukung biometrik atau biometrik belum diatur.')),
      );
      return;
    }

    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: nilaiBaru ? 'Autentikasi untuk mengaktifkan kunci aplikasi' : 'Autentikasi untuk menonaktifkan kunci aplikasi',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('kunciAktif', nilaiBaru);
        setState(() {
          _kunciAktif = nilaiBaru;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(nilaiBaru ? 'Kunci aplikasi diaktifkan' : 'Kunci aplikasi dinonaktifkan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan autentikasi: $e')),
      );
    }
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
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.lock_reset, color: primaryWarna),
                      title: Text('Ganti Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      subtitle: Text('Perbarui kata sandi secara berkala', style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
                      trailing: Icon(Icons.chevron_right, color: isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                        );
                      },
                    ),
                    Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                    ListTile(
                      leading: Icon(Icons.fingerprint, color: primaryWarna),
                      title: Text('Kunci Aplikasi (Biometrik)', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      subtitle: Text('Perlu autentikasi saat aplikasi dibuka', style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
                      trailing: Switch(
                        value: _kunciAktif,
                        onChanged: _toggleKunci,
                        activeColor: primaryWarna,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }
}