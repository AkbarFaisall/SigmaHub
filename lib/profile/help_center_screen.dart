// File: lib/profile/help_center_screen.dart
import 'package:flutter/material.dart';
import '../sigma_theme.dart';
import 'profile_screen.dart'; // IMPORT PROFILE UNTUK AKSES VARIABEL DARK MODE

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, isDark, child) {
        Color primaryWarna = isDark ? Colors.green.shade400 : WarnaSigma.utama;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : WarnaSigma.latar,
          appBar: AppBar(
            title: Text('Pusat Bantuan', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Hero Icon
                Icon(Icons.support_agent, size: 80, color: isDark ? Colors.blue.shade300 : WarnaSigma.sekunder),
                const SizedBox(height: 16),
                Text('Halo, ada yang bisa kami bantu?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 8),
                Text('Temukan jawaban untuk pertanyaan Anda atau hubungi tim dukungan kami.', textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
                const SizedBox(height: 32),

                // Kontak Kami
                Align(alignment: Alignment.centerLeft, child: Text('Hubungi Kami', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryWarna))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildContactButton(Icons.chat, 'WhatsApp', Colors.green, isDark),
                    const SizedBox(width: 10),
                    _buildContactButton(Icons.mail, 'Email', WarnaSigma.emas, isDark),
                  ],
                ),
                const SizedBox(height: 32),

                // FAQ Section
                Align(alignment: Alignment.centerLeft, child: Text('Pertanyaan Umum (FAQ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryWarna))),
                const SizedBox(height: 16),
                _buildFaqItem('Bagaimana cara mendaftar beasiswa?', 'Anda dapat mendaftar melalui menu "Beasiswa" di halaman beranda, pilih kategori yang sesuai, dan klik tombol "Daftar Sekarang".', isDark, primaryWarna),
                _buildFaqItem('Kapan pengumuman hasil seleksi?', 'Hasil seleksi diumumkan 14 hari kerja setelah periode penutupan melalui notifikasi aplikasi.', isDark, primaryWarna),
                _buildFaqItem('Apa saja dokumen yang diperlukan?', 'Dokumen standar meliputi KTP, Transkrip Nilai, dan Sertifikat Prestasi.', isDark, primaryWarna),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildContactButton(IconData icon, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white, 
          borderRadius: BorderRadius.circular(12), 
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color), 
            const SizedBox(height: 8), 
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer, bool isDark, Color primaryWarna) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent), // Menghilangkan garis pembatas bawaan saat terbuka
        child: ExpansionTile(
          collapsedIconColor: isDark ? Colors.white70 : Colors.black54,
          iconColor: primaryWarna,
          title: Text(question, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), 
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(answer, style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi, height: 1.5)),
              ),
            )
          ],
        ),
      ),
    );
  }
}