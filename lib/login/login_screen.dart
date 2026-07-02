// File: lib/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sigma_theme.dart';
import '../profile/profile_screen.dart'; 
import '../home_screen.dart'; 
import 'register_screen.dart'; 
import '../admin/admin_dashboard_screen.dart';
import '../providers/profile_provider.dart';
import '../providers/bookmark_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _kunciForm = GlobalKey<FormState>();
  final _kontrolerEmail = TextEditingController();
  final _kontrolerSandi = TextEditingController();
  bool _sembunyikanSandi = true;
  bool _sedangMemuat = false;

  // Melakukan login menggunakan Supabase Auth
  void _prosesLogin(bool isDark, Color primaryWarna) async {
    if (!_kunciForm.currentState!.validate()) return;

    setState(() {
      _sedangMemuat = true;
    });

    String email = _kontrolerEmail.text.trim().toLowerCase();
    String kataSandi = _kontrolerSandi.text;

    try {
      // 1. Verifikasi kecocokan email dan kata sandi menggunakan Supabase Auth
      final respon = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: kataSandi,
      );

      if (respon.user != null) {
        // Set email pengguna di Provider untuk memuat data profil & bookmark yang sesuai
        if (mounted) {
          Provider.of<ProfileProvider>(context, listen: false).setProfileEmail(email);
          Provider.of<BookmarkProvider>(context, listen: false).setUserEmail(email);
        }

        // Tentukan halaman tujuan berdasarkan level akses (admin vs user biasa)
        Widget targetHalaman = (email == "admin@sigma.edu")
            ? const AdminDashboardScreen()
            : const HomeScreen();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Login berhasil sebagai ${email == "admin@sigma.edu" ? "Admin" : "User"}!',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              backgroundColor: primaryWarna,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
              behavior: SnackBarBehavior.floating,
            ),
          );

          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, a1, a2) => targetHalaman,
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          });
        }
      }
    } on AuthException catch (e) {
      String pesanError = 'Kredensial salah';
      // Menyesuaikan pesan error agar lebih ramah bagi pengguna Indonesia
      if (e.message.contains('Invalid login credentials') || e.statusCode == '400') {
        pesanError = 'Kredensial salah atau email tidak ditemukan';
      } else {
        pesanError = e.message;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              pesanError,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan: $e',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sedangMemuat = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _kontrolerEmail.dispose();
    _kontrolerSandi.dispose();
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
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDark 
                        ? [] 
                        : const [BoxShadow(color: Color(0x14006400), blurRadius: 20, offset: Offset(0, 4))],
                  ),
                  child: Form(
                    key: _kunciForm,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo dengan Aksen Emas
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF121212) : WarnaSigma.latar,
                            shape: BoxShape.circle,
                            border: Border.all(color: WarnaSigma.emas, width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.school, size: 32, color: WarnaSigma.emas),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Judul & Subjudul
                        Text(
                          'SIGMA',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: primaryWarna,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selamat datang kembali. Akses dasbor beasiswa Anda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi, fontSize: 14),
                        ),
                        const SizedBox(height: 32),
                        
                        // Input Email
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alamat Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : WarnaSigma.teksPermukaan)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _kontrolerEmail,
                              keyboardType: TextInputType.emailAddress,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                hintText: 'mahasiswa@universitas.ac.id',
                                hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                                prefixIcon: Icon(Icons.mail_outline, color: isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF121212) : Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryWarna, width: 2),
                                ),
                              ),
                              validator: (nilai) {
                                if (nilai == null || nilai.isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                if (!nilai.contains('@')) {
                                  return 'Email wajib mengandung simbol @';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Input Kata Sandi
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kata Sandi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : WarnaSigma.teksPermukaan)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _kontrolerSandi,
                              obscureText: _sembunyikanSandi,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                                prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _sembunyikanSandi ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _sembunyikanSandi = !_sembunyikanSandi;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF121212) : Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryWarna, width: 2),
                                ),
                              ),
                              validator: (nilai) {
                                if (nilai == null || nilai.isEmpty) {
                                  return 'Kata sandi tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Tombol Masuk
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryWarna,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            onPressed: _sedangMemuat ? null : () => _prosesLogin(isDark, primaryWarna),
                            child: _sedangMemuat
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 20),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Link Register
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Belum punya akun? ', style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
                            GestureDetector(
                              // MENGHILANGKAN GLITCH PUTIH SAAT PINDAH KE REGISTER
                              onTap: () => Navigator.push(
                                context, 
                                PageRouteBuilder(
                                  pageBuilder: (context, a1, a2) => const RegisterScreen(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                )
                              ),
                              child: Text(
                                'Daftar Sekarang',
                                style: TextStyle(color: primaryWarna, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}