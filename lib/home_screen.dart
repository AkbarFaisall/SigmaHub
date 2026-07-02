// File: lib/home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sigma_theme.dart';
import 'detail_screen.dart'; 
import 'profile/profile_screen.dart'; 
import 'bookmark_screen.dart'; 
import 'providers/profile_provider.dart';
import 'providers/scholarship_provider.dart';
import 'providers/bookmark_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _indeksMenuBawah = 0; // Beranda selalu 0
  String _kategoriTerpilih = 'Semua';
  String _kataKunciPencarian = ''; 

  void _tampilkanNotifTersimpan(bool statusSimpan, bool isDark) {
    Color warnaAksen = isDark ? Colors.green.shade400 : WarnaSigma.utama;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (statusSimpan) 
              Icon(Icons.check_circle, color: warnaAksen),
            if (statusSimpan) 
              const SizedBox(width: 12),
            Text(
              statusSimpan ? 'Beasiswa berhasil tersimpan!' : 'Beasiswa dihapus dari simpanan',
              style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : WarnaSigma.teksPermukaan),
            ),
          ],
        ),
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),
          side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        margin: const EdgeInsets.only(bottom: 90, left: 20, right: 20),
        elevation: 4,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daftarBeasiswa = Provider.of<ScholarshipProvider>(context).scholarships;

    final beasiswaTampil = daftarBeasiswa.where((item) {
      bool cocokKategori = _kategoriTerpilih == 'Semua' || item['type'] == _kategoriTerpilih;
      bool cocokPencarian = true;
      if (_kataKunciPencarian.isNotEmpty) {
        String query = _kataKunciPencarian.toLowerCase();
        String nama = (item['name'] ?? '').toString().toLowerCase();
        String host = (item['host'] ?? '').toString().toLowerCase();
        String negara = (item['country'] ?? '').toString().toLowerCase();
        List tags = item['tags'] ?? [];
        bool cocokTag = tags.any((tag) => tag.toString().toLowerCase().contains(query));
        cocokPencarian = nama.contains(query) || host.contains(query) || negara.contains(query) || cocokTag;
      }
      return cocokKategori && cocokPencarian;
    }).toList();

    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, isDark, child) {
        // WARNA UTAMA DINAMIS: Hijau terang untuk Dark Mode, Hijau gelap untuk Light Mode
        Color primaryWarna = isDark ? Colors.green.shade400 : WarnaSigma.utama;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : WarnaSigma.latar,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Row(
              children: [
                _buatAvatar(
                  Provider.of<ProfileProvider>(context).avatarUrl,
                  Provider.of<ProfileProvider>(context).name,
                  20,
                  14,
                  primaryWarna,
                  isDark,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    Provider.of<ProfileProvider>(context).name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryWarna, letterSpacing: -0.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: _buatBannerDinamis(isDark),
                ),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: ['Semua', 'Prestasi', 'Umum'].map((kategori) {
                      bool aktif = _kategoriTerpilih == kategori;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _kategoriTerpilih = kategori),
                          borderRadius: BorderRadius.circular(99),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: aktif ? primaryWarna : Colors.transparent,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: aktif ? primaryWarna : (isDark ? Colors.grey.shade700 : Colors.grey.shade400)),
                            ),
                            child: Text(
                              kategori,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: aktif ? FontWeight.bold : FontWeight.w500,
                                color: aktif ? Colors.white : (isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (nilai) => setState(() => _kataKunciPencarian = nilai),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Cari beasiswa, penyelenggara, S1...',
                      hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                        borderSide: BorderSide(color: primaryWarna),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 32, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _kategoriTerpilih == 'Semua' ? 'Pilihan Terbaik Untuk Anda' : 'Rekomendasi $_kategoriTerpilih',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                      ),
                      Text('${beasiswaTampil.length} Hasil', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
                    ],
                  ),
                ),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: beasiswaTampil.length,
                  itemBuilder: (context, indeks) {
                    final beasiswa = beasiswaTampil[indeks];
                    bool apakahTersimpan = Provider.of<BookmarkProvider>(context).isBookmarked(beasiswa['name']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                        boxShadow: isDark ? [] : const [BoxShadow(color: Color(0x0F006400), blurRadius: 12, offset: Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: beasiswa['logoPenyelenggara'] != null && (beasiswa['logoPenyelenggara'] as String).isNotEmpty
                                      ? Image.network(
                                          beasiswa['logoPenyelenggara'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, _, __) => Image.asset(
                                            'assets/images/default_logo.jpeg',
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/default_logo.jpeg',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(beasiswa['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    // PERUBAHAN: Menampilkan Negara di bawah Penyelenggara (Tanpa titik)
                                    Text(beasiswa['host'], style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text(beasiswa['country'], style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  apakahTersimpan ? Icons.bookmark : Icons.bookmark_border,
                                  color: apakahTersimpan ? primaryWarna : (isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi),
                                ),
                                onPressed: () {
                                  Provider.of<BookmarkProvider>(context, listen: false).toggleBookmark(beasiswa);
                                  _tampilkanNotifTersimpan(!apakahTersimpan, isDark);
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          Wrap(
                            runSpacing: 8,
                            children: (beasiswa['tags'] as List).map((tag) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE7EEFE),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.green.shade300 : const Color(0xFF0F7427),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Divider(height: 1, color: isDark ? Colors.grey.shade800 : const Color(0xFFDCE2F3)),
                          const SizedBox(height: 12),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Mulai: ${beasiswa['startDate']}', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
                                          const SizedBox(height: 2),
                                          Text('Tutup: ${beasiswa['endDate']} (${beasiswa['daysLeft']})', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                // --- PERBAIKAN GLITCH PUTIH SAAT KLIK DETAIL ---
                                onTap: () => Navigator.push(
                                  context, 
                                  PageRouteBuilder(
                                    pageBuilder: (context, a1, a2) => DetailScreen(beasiswa: beasiswa),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                                  child: Text('Detail', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryWarna)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            unselectedItemColor: isDark ? Colors.white54 : Colors.grey,
            currentIndex: _indeksMenuBawah,
            selectedItemColor: primaryWarna,
            onTap: (indeks) {
              if (indeks == 1) {
                Navigator.pushReplacement(context, PageRouteBuilder(
                  pageBuilder: (context, a1, a2) => const BookmarkScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ));
              }
              if (indeks == 2) {
                Navigator.pushReplacement(context, PageRouteBuilder(
                  pageBuilder: (context, a1, a2) => const ProfileScreen(),
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

  Widget _buatBannerDinamis(bool isDark) {
    String judul = 'Buka Masa Depan Global Anda';
    String subjudul = 'Jelajahi pilihan beasiswa unggulan kami untuk semua jenjang.';
    String labelKecil = '';

    if (_kategoriTerpilih == 'Prestasi') {
      judul = 'Merayakan Keunggulan';
      subjudul = 'Beasiswa untuk pelajar berprestasi dan pemimpin mahasiswa.';
      labelKecil = 'Unggulan Prestasi';
    } else if (_kategoriTerpilih == 'Umum') {
      judul = 'Peluang Untuk Semua';
      subjudul = 'Temukan berbagai pilihan beasiswa umum untuk mendukung perjalanan pendidikan Anda.';
      labelKecil = 'Unggulan Umum';
    }

    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D47A1) : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1565C0) : Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (labelKecil.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: WarnaSigma.emas, borderRadius: BorderRadius.circular(6)),
              child: Text(labelKecil, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: WarnaSigma.utama)),
            ),
          Text(judul, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : WarnaSigma.teksPermukaan)),
          const SizedBox(height: 4),
          Text(subjudul, style: TextStyle(fontSize: 14, color: isDark ? Colors.blue.shade100 : WarnaSigma.garisTepi)),
        ],
      ),
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
}