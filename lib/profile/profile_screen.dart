// File: lib/profile/profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sigma_theme.dart';
import '../home_screen.dart';
import '../bookmark_screen.dart';
import '../providers/profile_provider.dart';

// Variabel Global untuk mengontrol Mode Gelap di seluruh aplikasi
final ValueNotifier<bool> globalDarkModeNotifier = ValueNotifier(false);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool sedangProsesKeluar = false;

  // Fungsi untuk menangani proses logout secara aman dari Supabase
  Future<void> prosesKeluar() async {
    setState(() {
      sedangProsesKeluar = true;
    });

    try {
      // Putus sesi autentikasi Supabase secara resmi
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('Gagal keluar sesi: $e');
    } finally {
      if (mounted) {
        setState(() {
          sedangProsesKeluar = false;
        });
        // Arahkan kembali ke Halaman Login secara bersih
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
  Widget _buildAvatar(String avatarUrl, String name, double radius, double fontSize, Color primaryWarna, bool isDark) {
    if (avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('data:image')) {
        try {
          final String base64Content = avatarUrl.split(',').last;
          final bytes = base64Decode(base64Content);
          return CircleAvatar(
            radius: radius,
            backgroundImage: MemoryImage(bytes),
          );
        } catch (_) {}
      } else if (avatarUrl.startsWith('http')) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(avatarUrl),
        );
      }
    }
    
    final inisialNama = name.isNotEmpty ? name[0].toUpperCase() : 'M';
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.green,
      child: Text(
        inisialNama,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, isDark, child) {
        // WARNA UTAMA DINAMIS
        Color primaryWarna = isDark ? Colors.green.shade400 : WarnaSigma.utama;
        final profileProv = Provider.of<ProfileProvider>(context);

        // Bagian Atas (Kartu Informasi Pengguna)
        Widget kartuProfil = Card(
          elevation: 0,
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Sisi Kiri: Foto Profil
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
                      width: 2,
                    ),
                  ),
                  child: _buildAvatar(
                    profileProv.avatarUrl,
                    profileProv.name,
                    36,
                    32,
                    primaryWarna,
                    isDark,
                  ),
                ),
                const SizedBox(width: 16),
                // Sisi Kanan: Detail Informasi Pengguna
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileProv.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profileProv.university,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade300 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profileProv.major,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profileProv.email,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profileProv.phone,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : WarnaSigma.latar,
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              // Jarak atas untuk status bar jika tidak menggunakan AppBar
              const SizedBox(height: 30),
              
              // Bagian Atas: Kartu Informasi Pengguna
              kartuProfil,
              
              const SizedBox(height: 24),
              
              // Bagian Bawah: Daftar Menu Opsi
              _buildToggleMenu('Mode Gelap', Icons.dark_mode, isDark, (val) async {
                globalDarkModeNotifier.value = val;
                try {
                  final sp = await SharedPreferences.getInstance();
                  await sp.setBool('sigma_dark_mode', val);
                } catch (e) {
                  debugPrint('Gagal menyimpan tema lokal: $e');
                }
              }, isDark, primaryWarna),
              
              _buildMenu('Edit Profil', Icons.edit, '/edit_profile', isDark, primaryWarna),
              _buildMenu('Pengaturan Notifikasi', Icons.notifications, '/notifications', isDark, primaryWarna),
              _buildMenu('Keamanan Akun', Icons.lock, '/security', isDark, primaryWarna),
              _buildMenu('Pusat Bantuan', Icons.help, '/help', isDark, primaryWarna),
              _buildMenu('Tentang Sigma', Icons.info, '/about', isDark, primaryWarna),
              
              const SizedBox(height: 40), // Jarak agak jauh
              
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: WarnaSigma.peringatan,
                  side: const BorderSide(color: WarnaSigma.peringatan),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: sedangProsesKeluar ? null : prosesKeluar,
                icon: sedangProsesKeluar
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: WarnaSigma.peringatan,
                        ),
                      )
                    : const Icon(Icons.logout),
                label: Text(
                  sedangProsesKeluar ? 'Mengeluarkan...' : 'Keluar',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            unselectedItemColor: isDark ? Colors.white54 : Colors.grey,
            currentIndex: 2,
            selectedItemColor: primaryWarna,
            onTap: (indeks) {
              if (indeks == 0) {
                Navigator.pushReplacement(context, PageRouteBuilder(
                  pageBuilder: (context, a1, a2) => const HomeScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ));
              }
              if (indeks == 1) {
                Navigator.pushReplacement(context, PageRouteBuilder(
                  pageBuilder: (context, a1, a2) => const BookmarkScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ));
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
              BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Tersimpan'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        );
      }
    );
  }

  Widget _buildMenu(String title, IconData icon, String route, bool isDark, Color primaryWarna) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.transparent)
      ),
      child: ListTile(
        leading: Icon(icon, color: primaryWarna),
        title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        trailing: Icon(Icons.chevron_right, color: isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi),
        onTap: () {
          Navigator.pushNamed(context, route); 
        },
      ),
    );
  }

  Widget _buildToggleMenu(String title, IconData icon, bool value, Function(bool) onChanged, bool isDark, Color primaryWarna) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.transparent)
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: primaryWarna),
        title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        value: value,
        onChanged: onChanged,
        activeColor: primaryWarna,
      ),
    );
  }
}