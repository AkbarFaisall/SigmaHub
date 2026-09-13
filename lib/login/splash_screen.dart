// File: lib/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../sigma_theme.dart';
import '../profile/profile_screen.dart';
import 'login_screen.dart';
import '../home_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _kontrolerMuncul;
  late Animation<double> _animasiPudar;
  late Animation<Offset> _animasiNaik;
  
  bool _terkunci = false;
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();

    // Mengatur animasi transisi (Fade In & Slide Up) mirip class "fade-in-up"
    _kontrolerMuncul = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animasiPudar = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _kontrolerMuncul, curve: Curves.easeOut),
    );

    _animasiNaik = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _kontrolerMuncul, curve: Curves.easeOutQuart),
    );

    _kontrolerMuncul.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _prosesRouting();
      }
    });
  }

  Future<void> _prosesRouting() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _pindahHalaman(const LoginScreen());
      return;
    }

    // Memperbarui rekam jejak aktif pengguna saat membuka aplikasi
    try {
      await Supabase.instance.client.from('profiles').update({
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('email', user.email!);
    } catch (e) {
      debugPrint('Gagal memperbarui status aktif: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final kunciAktif = prefs.getBool('kunciAktif') ?? false;

    Widget targetHalaman = const HomeScreen();
    if (user.email == 'admin@sigma.edu') {
      targetHalaman = const AdminDashboardScreen();
    }

    if (!kunciAktif) {
      _pindahHalaman(targetHalaman);
      return;
    }

    _verifikasiBiometrik(targetHalaman);
  }

  Future<void> _verifikasiBiometrik(Widget targetHalaman) async {
    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Gunakan biometrik untuk membuka kunci aplikasi',
        biometricOnly: false, 
        persistAcrossBackgrounding: true,
      );

      if (didAuthenticate) {
        _pindahHalaman(targetHalaman);
      } else {
        setState(() {
          _terkunci = true;
        });
      }
    } catch (e) {
      setState(() {
        _terkunci = true;
      });
    }
  }

  void _pindahHalaman(Widget halaman) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context, 
      PageRouteBuilder(
        pageBuilder: (context, a1, a2) => halaman,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void dispose() {
    _kontrolerMuncul.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, isDark, child) {
        Color primaryWarna = isDark ? Colors.green.shade400 : WarnaSigma.utama;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : WarnaSigma.latar,
          body: _terkunci 
            ? _buatLayarTerkunci(primaryWarna, isDark)
            : Center(
                child: FadeTransition(
                  opacity: _animasiPudar,
              child: SlideTransition(
                position: _animasiNaik,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Wadah Logo dengan efek Shadow/Glow
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Efek Glow di belakang
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryWarna.withOpacity(0.1),
                            boxShadow: [
                              BoxShadow(
                                color: primaryWarna.withOpacity(isDark ? 0.4 : 0.2),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        // Lingkaran Logo Utama
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.transparent : const Color(0x14006400),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.school,
                              size: 64,
                              color: primaryWarna,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Teks Nama Aplikasi
                    Text(
                      'ScholarHub',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: primaryWarna,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Teks Tagline
                    Text(
                      'Temukan Peluangmu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.yellow.shade600 : const Color(0xFFC8A900), // Warna emas/tertiary container
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Indikator Loading (3 Titik Melompat)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TitikLoading(jedaWaktu: 0),
                        SizedBox(width: 8),
                        _TitikLoading(jedaWaktu: 150),
                        SizedBox(width: 8),
                        _TitikLoading(jedaWaktu: 300),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buatLayarTerkunci(Color primaryWarna, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 80, color: primaryWarna),
          const SizedBox(height: 16),
          Text(
            'Aplikasi Terkunci',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan verifikasi identitas Anda',
            style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryWarna,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final user = Supabase.instance.client.auth.currentUser;
              Widget target = const HomeScreen();
              if (user?.email == 'admin@sigma.edu') target = const AdminDashboardScreen();
              _verifikasiBiometrik(target);
            },
            icon: const Icon(Icons.fingerprint),
            label: const Text('Coba Lagi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Supabase.instance.client.auth.signOut();
              _pindahHalaman(const LoginScreen());
            },
            child: Text('Keluar Akun', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET KHUSUS UNTUK TITIK LOADING MELOMPAT ---
class _TitikLoading extends StatefulWidget {
  final int jedaWaktu;
  const _TitikLoading({required this.jedaWaktu});

  @override
  State<_TitikLoading> createState() => _TitikLoadingState();
}

class _TitikLoadingState extends State<_TitikLoading> with SingleTickerProviderStateMixin {
  late AnimationController _kontrolerLompat;
  late Animation<double> _animasiLompat;

  @override
  void initState() {
    super.initState();
    _kontrolerLompat = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animasiLompat = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _kontrolerLompat, curve: Curves.easeInOut),
    );

    // Memulai lompatan sesuai jeda waktu masing-masing titik
    Future.delayed(Duration(milliseconds: widget.jedaWaktu), () {
      if (mounted) {
        _kontrolerLompat.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _kontrolerLompat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, isDark, child) {
        return AnimatedBuilder(
          animation: _animasiLompat,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animasiLompat.value),
              child: child,
            );
          },
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isDark ? Colors.green.shade300 : const Color(0xFF7EDB7F), // Warna hijau muda disesuaikan dgn mode gelap
              shape: BoxShape.circle,
            ),
          ),
        );
      }
    );
  }
}