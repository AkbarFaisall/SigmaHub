import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../profile/profile_screen.dart'; // for globalDarkModeNotifier
import '../providers/profile_provider.dart';
import '../sigma_theme.dart';
import '../login/login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';

class AdminDrawer extends StatefulWidget {
  final String activeRoute; // 'beasiswa' or 'pengguna'
  const AdminDrawer({super.key, required this.activeRoute});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  bool _sedangProsesKeluar = false;

  Future<void> _prosesKeluar() async {
    setState(() {
      _sedangProsesKeluar = true;
    });

    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('Error saat keluar admin: $e');
    } finally {
      if (mounted) {
        setState(() {
          _sedangProsesKeluar = false;
        });

        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, a1, a2) => const LoginScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
          (route) => false,
        );
      }
    }
  }

  void _tampilkanKonfirmasiKeluar(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Keluar Akun?', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin keluar dari sesi Admin?', style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _prosesKeluar();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, a1, a2) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, isDark, child) {
        Color primaryWarna = isDark ? Colors.green.shade400 : WarnaSigma.utama;
        final profile = Provider.of<ProfileProvider>(context);
        
        return Drawer(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: primaryWarna),
                accountName: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                accountEmail: const Text('Administrator'),
                currentAccountPicture: _buatAvatar(
                  '',
                  'Admin Dashboard',
                  30,
                  30,
                  primaryWarna,
                  isDark,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  selected: widget.activeRoute == 'beasiswa',
                  selectedTileColor: isDark ? primaryWarna.withValues(alpha: 0.15) : primaryWarna.withValues(alpha: 0.1),
                  leading: Icon(
                    Icons.school, 
                    color: widget.activeRoute == 'beasiswa' ? primaryWarna : (isDark ? Colors.white70 : Colors.black87)
                  ),
                  title: Text(
                    'Kelola Beasiswa', 
                    style: TextStyle(
                      color: widget.activeRoute == 'beasiswa' ? primaryWarna : (isDark ? Colors.white : Colors.black), 
                      fontWeight: widget.activeRoute == 'beasiswa' ? FontWeight.bold : FontWeight.normal
                    )
                  ),
                  onTap: () {
                    if (widget.activeRoute != 'beasiswa') {
                      _navigateTo(const AdminDashboardScreen());
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  selected: widget.activeRoute == 'pengguna',
                  selectedTileColor: isDark ? primaryWarna.withValues(alpha: 0.15) : primaryWarna.withValues(alpha: 0.1),
                  leading: Icon(
                    Icons.group, 
                    color: widget.activeRoute == 'pengguna' ? primaryWarna : (isDark ? Colors.white70 : Colors.black87)
                  ),
                  title: Text(
                    'Pengguna', 
                    style: TextStyle(
                      color: widget.activeRoute == 'pengguna' ? primaryWarna : (isDark ? Colors.white : Colors.black),
                      fontWeight: widget.activeRoute == 'pengguna' ? FontWeight.bold : FontWeight.normal
                    )
                  ),
                  onTap: () {
                    if (widget.activeRoute != 'pengguna') {
                      _navigateTo(const AdminUsersScreen());
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: SwitchListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  secondary: Icon(Icons.dark_mode, color: isDark ? Colors.white70 : Colors.black87),
                  title: Text('Mode Gelap', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  value: globalDarkModeNotifier.value,
                  onChanged: (v) => globalDarkModeNotifier.value = v,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  leading: _sedangProsesKeluar
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2),
                        )
                      : const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    _sedangProsesKeluar ? 'Mengeluarkan...' : 'Keluar / Logout',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onTap: _sedangProsesKeluar ? null : () => _tampilkanKonfirmasiKeluar(isDark),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buatAvatar(String avatarUrl, String name, double radius, double fontSize, Color primaryWarna, bool isDark) {
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
    
    final inisialNama = name.isNotEmpty ? name[0].toUpperCase() : 'A';
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
}
