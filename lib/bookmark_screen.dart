// File: lib/bookmark_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sigma_theme.dart';
import 'detail_screen.dart'; 
import 'profile/profile_screen.dart'; 
import 'home_screen.dart'; 
import 'providers/profile_provider.dart';
import 'providers/bookmark_provider.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final int _indeksMenuBawah = 1; // Indeks 1 untuk tab Tersimpan
  String _kategoriTerpilih = 'Semua';
  String _kataKunciPencarian = '';

  @override
  Widget build(BuildContext context) {
    final daftarTersimpan = Provider.of<BookmarkProvider>(context).bookmarkedItems;

    final beasiswaTampil = daftarTersimpan.where((item) {
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
        // WARNA UTAMA DINAMIS
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
              children: [
                if (daftarTersimpan.isEmpty) 
                   _buatLayarKosong(isDark, primaryWarna)
                else 
                   _buatDaftarTersimpan(beasiswaTampil, isDark, primaryWarna),
              ],
            ),
          ),

          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            unselectedItemColor: isDark ? Colors.white54 : Colors.grey,
            currentIndex: _indeksMenuBawah,
            selectedItemColor: primaryWarna,
            onTap: (indeks) {
              if (indeks == 0) {
                Navigator.pushReplacement(context, PageRouteBuilder(
                  pageBuilder: (context, a1, a2) => const HomeScreen(),
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

  Widget _buatLayarKosong(bool isDark, Color primaryWarna) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE7EEFE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.bookmark_border, size: 48, color: isDark ? Colors.blue.shade200 : WarnaSigma.garisTepi),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada beasiswa yang disimpan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : WarnaSigma.teksPermukaan),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Jelajahi berbagai beasiswa dan simpan yang menarik untuk Anda lamar nanti.',
            style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryWarna,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
              elevation: 4,
            ),
            onPressed: () {
              Navigator.pushReplacement(context, PageRouteBuilder(
                pageBuilder: (context, a1, a2) => const HomeScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ));
            },
            child: const Text('Jelajahi Beasiswa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buatDaftarTersimpan(List<Map<String, dynamic>> daftar, bool isDark, Color primaryWarna) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bookmark', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : WarnaSigma.teksPermukaan)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(99)),
                child: Text('${daftar.length} Disimpan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.blue.shade200 : WarnaSigma.garisTepi)),
              ),
            ],
          ),
        ),
        
        // Tombol Filter
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
                    child: Text(kategori, style: TextStyle(fontSize: 14, fontWeight: aktif ? FontWeight.bold : FontWeight.w500, color: aktif ? Colors.white : (isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi))),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: (nilai) => setState(() => _kataKunciPencarian = nilai),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Cari beasiswa tersimpan...',
              hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryWarna)),
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(height: 32, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: daftar.length,
          itemBuilder: (context, indeks) {
            final beasiswa = daftar[indeks];
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
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
                            Text(beasiswa['name'] ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('${beasiswa['host'] ?? ''} • ${beasiswa['country'] ?? 'Indonesia'}', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark, color: WarnaSigma.utama),
                        onPressed: () {
                          Provider.of<BookmarkProvider>(context, listen: false).toggleBookmark(beasiswa);
                          
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Text(
                                    'Beasiswa dihapus dari simpanan',
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
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    runSpacing: 8,
                    children: ((beasiswa['tags'] as List?) ?? []).map((tag) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(4)),
                        child: Text(tag.toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.green.shade300 : const Color(0xFF0F7427))),
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
                                  Text('Mulai: ${beasiswa['startDate'] ?? 'TBA'}', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tutup: ${beasiswa['endDate'] ?? beasiswa['closingDate'] ?? 'TBA'} (${beasiswa['daysLeft'] ?? '-'})', 
                                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        // --- PERBAIKAN GLITCH PUTIH SAAT KLIK DETAIL ---
                        onTap: () {
                          Navigator.push(context, PageRouteBuilder(
                            pageBuilder: (context, a1, a2) => DetailScreen(beasiswa: beasiswa),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ));
                        },
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
      ],
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