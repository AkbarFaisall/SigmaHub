// File: lib/profile/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sigma_theme.dart';
import 'profile_screen.dart'; // IMPORT PROFILE UNTUK AKSES VARIABEL DARK MODE

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;

  Future<void> _gantiKataSandi() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user?.email != null) {
        // 1. Verifikasi kata sandi lama dengan mencoba login ulang
        await Supabase.instance.client.auth.signInWithPassword(
          email: user!.email!,
          password: _oldPasswordController.text,
        );
        
        // 2. Jika berhasil (tidak error), perbarui ke kata sandi baru
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: _newPasswordController.text),
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kata sandi berhasil diubah!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Kembali ke halaman keamanan
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal: Kata sandi lama salah atau terjadi kesalahan.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
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
          appBar: AppBar(
            title: Text('Ganti Kata Sandi', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_reset, size: 80, color: primaryWarna),
                  const SizedBox(height: 24),
                  Text(
                    'Perbarui Keamanan Anda',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masukkan kata sandi lama Anda untuk memverifikasi, lalu tentukan kata sandi yang baru.',
                    style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Kata Sandi Lama
                  TextFormField(
                    controller: _oldPasswordController,
                    obscureText: _obscureOld,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Lama',
                      labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.grey.shade500 : Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.grey.shade500 : Colors.grey),
                        onPressed: () => setState(() => _obscureOld = !_obscureOld),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Kata sandi lama wajib diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Kata Sandi Baru
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Baru',
                      labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      prefixIcon: Icon(Icons.lock, color: primaryWarna),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.grey.shade500 : Colors.grey),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Kata sandi baru wajib diisi';
                      if (val.length < 6) return 'Kata sandi minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Tombol Simpan
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryWarna,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    onPressed: _isLoading ? null : _gantiKataSandi,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Simpan Kata Sandi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
