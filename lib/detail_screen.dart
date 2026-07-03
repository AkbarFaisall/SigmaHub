// File: lib/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'sigma_theme.dart';
import 'profile/profile_screen.dart'; // IMPORT PROFILE UNTUK AKSES VARIABEL DARK MODE

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> beasiswa;

  const DetailScreen({super.key, required this.beasiswa});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, isDark, child) {
        // WARNA UTAMA DINAMIS
        Color primaryWarna = isDark ? Colors.green.shade400 : WarnaSigma.utama;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          body: Stack(
            children: [
              // KONTEN SCROLL
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Gambar Header dengan tombol back
                    Stack(
                      children: [
                        beasiswa['fotoUtama'] != null && (beasiswa['fotoUtama'] as String).isNotEmpty
                            ? Image.network(
                                beasiswa['fotoUtama'],
                                height: 300,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, _, __) => _buatHeaderFallback(),
                              )
                            : _buatHeaderFallback(),
                        Positioned(
                          top: 50,
                          left: 20,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.8) : Colors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. Judul Beasiswa
                          Text(
                            beasiswa['name'] ?? 'Nama Beasiswa Tidak Tersedia',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryWarna,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 3. Bento Box Metadata (Waktu & Penyelenggara + Negara)
                          _buildMetadataCard(
                            icon: Icons.calendar_today,
                            label: 'PERIODE PENDAFTARAN',
                            value: '${beasiswa['startDate'] ?? 'TBA'} - ${beasiswa['endDate'] ?? 'TBA'} (${beasiswa['daysLeft'] ?? '-'})', 
                            bgColor: isDark ? const Color(0xFF2A2612) : const Color(0xFFFFF9E6), // Kuning gelap untuk dark mode
                            iconColor: WarnaSigma.emas,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildMetadataCard(
                            icon: Icons.account_balance,
                            label: 'PENYELENGGARA',
                            // PERUBAHAN: Menghapus titik dan menggunakan \n agar negara pindah ke baris bawah
                            value: '${beasiswa['host'] ?? 'TBA'}\n${beasiswa['country'] ?? 'Indonesia'}',
                            bgColor: isDark ? const Color(0xFF1A222C) : const Color(0xFFF5F9FF), // Biru gelap untuk dark mode
                            iconColor: Colors.blue,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 20),

                          // 4. Tag / Pills Beasiswa
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ((beasiswa['tags'] as List?) ?? []).map((tag) => 
                              _buildTag(tag.toString(), isDark)
                            ).toList(),
                          ),
                          const SizedBox(height: 24),

                          // 5. Deskripsi
                          Text(
                            'Deskripsi Beasiswa',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            (beasiswa['description'] != null && beasiswa['description'].toString().trim().isNotEmpty)
                                ? beasiswa['description']
                                : 'Beasiswa Unggulan adalah pemberian biaya pendidikan oleh pemerintah Indonesia kepada putra-putri terbaik bangsa Indonesia pada perguruan tinggi penerima sesuai dengan ketentuan yang berlaku.',
                            style: TextStyle(fontSize: 15, color: isDark ? Colors.grey.shade300 : Colors.black87, height: 1.5),
                          ),
                          const SizedBox(height: 24),

                          // 6. Persyaratan
                          Text(
                            'Persyaratan Umum',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                          ),
                          const SizedBox(height: 12),
                          ..._buildRequirementsList(beasiswa['requirements'], isDark, primaryWarna),

                          const SizedBox(height: 100), // Space agar tidak tertutup tombol bottom
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 7. Tombol Daftar Sekarang (Fixed Bottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    boxShadow: [
                      BoxShadow(color: isDark ? Colors.black87 : Colors.black12, blurRadius: 10, offset: const Offset(0, -2))
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WarnaSigma.emas,
                      foregroundColor: WarnaSigma.utama, // Teks tetap hijau gelap agar kontras di atas tombol emas
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () => _tampilkanKonfirmasi(context, isDark),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Daftar Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  // Widget Pembantu untuk Kartu Bento Metadata
  Widget _buildMetadataCard({required IconData icon, required String label, required String value, required Color bgColor, required Color iconColor, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: isDark ? const Color(0xFF121212) : Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.bold)),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tag disesuaikan dengan warna tema Global
  Widget _buildTag(String text, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE7EEFE), 
        borderRadius: BorderRadius.circular(20)
      ),
      child: Text(
        text, 
        style: TextStyle(
          color: isDark ? Colors.green.shade300 : const Color(0xFF0F7427), 
          fontSize: 12, 
          fontWeight: FontWeight.w600
        )
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isDark, Color primaryWarna) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: primaryWarna, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.black87))),
        ],
      ),
    );
  }

  List<Widget> _buildRequirementsList(dynamic reqData, bool isDark, Color primaryWarna) {
    if (reqData == null || reqData.toString().trim().isEmpty) {
      return [
        _buildRequirementItem('Warga Negara Indonesia (WNI) berprestasi.', isDark, primaryWarna),
        _buildRequirementItem('Mendapatkan surat rekomendasi institusi.', isDark, primaryWarna),
        _buildRequirementItem('Tidak sedang menerima beasiswa lain.', isDark, primaryWarna),
        _buildRequirementItem('Diterima di Perguruan Tinggi terakreditasi.', isDark, primaryWarna),
      ];
    }

    final String reqStr = reqData.toString();
    final List<String> lines = reqStr.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    return lines.map((line) => _buildRequirementItem(line.trim(), isDark, primaryWarna)).toList();
  }

  void _tampilkanKonfirmasi(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Konfirmasi', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text('Lanjutkan pendaftaran ke situs eksternal?', style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Batal', style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: WarnaSigma.emas),
            onPressed: () {
              Navigator.pop(context); 
              bukaTautan(beasiswa['link'], context);
            }, 
            child: const Text('Lanjutkan', style: TextStyle(color: WarnaSigma.utama))
          ),
        ],
      ),
    );
  }

  // Fungsi asinkronus untuk membuka link eksternal beasiswa menggunakan url_launcher
  Future<void> bukaTautan(String? urlMentah, BuildContext konteks) async {
    final penyajiPesan = ScaffoldMessenger.of(konteks);
    if (urlMentah == null || urlMentah.trim().isEmpty) {
      penyajiPesan.showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka tautan karena link pendaftaran kosong.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final Uri tautanValid = Uri.parse(urlMentah.trim());
    try {
      final bool apakahBisaBuka = await canLaunchUrl(tautanValid);
      if (apakahBisaBuka) {
        await launchUrl(tautanValid, mode: LaunchMode.externalApplication);
      } else {
        penyajiPesan.showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka tautan.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      penyajiPesan.showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka tautan.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buatHeaderFallback() {
    return Image.asset(
      'assets/images/default_banner.jpeg',
      height: 300,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}