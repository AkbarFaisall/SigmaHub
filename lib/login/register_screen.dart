// File: lib/register_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sigma_theme.dart';
import '../profile/profile_screen.dart'; // IMPORT PROFILE UNTUK AKSES VARIABEL DARK MODE
import 'login_screen.dart'; // IMPORT LOGIN SCREEN

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _kunciForm = GlobalKey<FormState>();
  final _kontrolerNama = TextEditingController();
  final _kontrolerEmail = TextEditingController();
  final _kontrolerTelepon = TextEditingController();
  final _kontrolerSandi = TextEditingController();
  final _kontrolerKonfirmasi = TextEditingController();
  
  bool _sembunyikanSandi = true;
  bool _sembunyikanKonfirmasi = true;
  bool _sedangMemuat = false;

  // Melakukan pendaftaran menggunakan Supabase Auth dan menyimpan data profil ke database
  void _prosesDaftar(bool isDark, Color primaryWarna) async {
    if (!_kunciForm.currentState!.validate()) return;

    setState(() {
      _sedangMemuat = true;
    });

    String namaLengkap = _kontrolerNama.text.trim();
    String email = _kontrolerEmail.text.trim().toLowerCase();
    String nomorTelepon = _kontrolerTelepon.text.trim();
    String kataSandi = _kontrolerSandi.text;

    try {
      // 1. Mendaftarkan kredensial pengguna baru di Supabase Auth
      final respon = await Supabase.instance.client.auth.signUp(
        email: email,
        password: kataSandi,
      );

      if (respon.user != null) {
        // 2. Secara otomatis memasukkan data profil ke tabel profiles
        await Supabase.instance.client.from('profiles').insert({
          'email': email,
          'name': namaLengkap,
          'university': 'UIN Alauddin',
          'major': 'Teknik Informatika',
          'phone': nomorTelepon,
          'avatar_url': '',
          'updated_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Pendaftaran Berhasil! Silakan masuk dengan akun baru Anda.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: primaryWarna,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, a1, a2) => const LoginScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          });
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message,
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
              'Pendaftaran gagal: $e',
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
    _kontrolerNama.dispose();
    _kontrolerEmail.dispose();
    _kontrolerTelepon.dispose();
    _kontrolerSandi.dispose();
    _kontrolerKonfirmasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, isDark, child) {
        Color primaryWarna = isDark ? Colors.green.shade400 : WarnaSigma.utama;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Form(
                key: _kunciForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tombol Kembali Custom
                    GestureDetector(
                      onTap: () => Navigator.pushAndRemoveUntil(
                        context, 
                        PageRouteBuilder(
                          pageBuilder: (context, a1, a2) => const LoginScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                        (route) => false,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, size: 20, color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi),
                          const SizedBox(width: 8),
                          Text('KEMBALI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Judul
                    Text('SIGMA', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: primaryWarna, letterSpacing: -0.5)),
                    const SizedBox(height: 8),
                    Text(
                      'Buat akun untuk memulai perjalanan Anda menuju dukungan finansial dan kesuksesan akademik.',
                      style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    
                    // Input Nama Lengkap
                    _buatInputTeks('NAMA LENGKAP', 'Jane Doe', Icons.person_outline, _kontrolerNama, false, isDark, primaryWarna),
                    const SizedBox(height: 20),
                    
                    // Input Email
                    _buatInputTeks('ALAMAT EMAIL', 'jane.doe@university.edu', Icons.mail_outline, _kontrolerEmail, false, isDark, primaryWarna, isEmail: true),
                    const SizedBox(height: 20),
                    
                    // Input Nomor Telepon
                    _buatInputTeks('NOMOR TELEPON', '+62 812...', Icons.phone_outlined, _kontrolerTelepon, false, isDark, primaryWarna, isPhone: true),
                    const SizedBox(height: 20),
                    
                    // Input Kata Sandi
                    _buatInputSandi('KATA SANDI', _kontrolerSandi, _sembunyikanSandi, (val) => setState(() => _sembunyikanSandi = val), isDark, primaryWarna),
                    const SizedBox(height: 20),
                    
                    // Input Konfirmasi Kata Sandi
                    _buatInputSandi('KONFIRMASI KATA SANDI', _kontrolerKonfirmasi, _sembunyikanKonfirmasi, (val) => setState(() => _sembunyikanKonfirmasi = val), isDark, primaryWarna, isKonfirmasi: true),
                    const SizedBox(height: 32),
                    
                    // Tombol Daftar
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryWarna,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          shadowColor: primaryWarna.withOpacity(0.4),
                        ),
                        onPressed: _sedangMemuat ? null : () => _prosesDaftar(isDark, primaryWarna),
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
                                  Text('Daftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Link Masuk
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sudah memiliki akun? ', style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
                        GestureDetector(
                          onTap: () => Navigator.pushAndRemoveUntil(
                            context, 
                            PageRouteBuilder(
                              pageBuilder: (context, a1, a2) => const LoginScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                            (route) => false,
                          ),
                          child: Text(
                            'Masuk',
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
        );
      }
    );
  }

  Widget _buatInputTeks(String label, String hint, IconData icon, TextEditingController controller, bool isPassword, bool isDark, Color primaryWarna, {bool isEmail = false, bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: isDark ? Colors.white70 : WarnaSigma.garisTepi)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isEmail 
              ? TextInputType.emailAddress 
              : (isPhone ? TextInputType.phone : TextInputType.text),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            prefixIcon: Icon(icon, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : WarnaSigma.latar,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryWarna, width: 2)),
          ),
          validator: (nilai) {
            if (nilai == null || nilai.isEmpty) {
              return 'Bagian ini wajib diisi';
            }
            if (isEmail && !nilai.contains('@')) {
              return 'Email wajib mengandung simbol @';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buatInputSandi(String label, TextEditingController controller, bool isHidden, Function(bool) onToggle, bool isDark, Color primaryWarna, {bool isKonfirmasi = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: isDark ? Colors.white70 : WarnaSigma.garisTepi)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isHidden,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
            suffixIcon: IconButton(
              icon: Icon(isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
              onPressed: () => onToggle(!isHidden),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : WarnaSigma.latar,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryWarna, width: 2)),
          ),
          validator: (nilai) {
            if (nilai == null || nilai.isEmpty) {
              return 'Kata sandi wajib diisi';
            }
            if (isKonfirmasi && nilai != _kontrolerSandi.text) {
              return 'Kata sandi tidak cocok';
            }
            return null;
          },
        ),
      ],
    );
  }
}