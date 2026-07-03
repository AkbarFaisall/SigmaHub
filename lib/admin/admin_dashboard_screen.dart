// File: lib/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sigma_theme.dart';
import '../profile/profile_screen.dart'; 
import '../login/login_screen.dart'; 
import 'add_beasiswa_screen.dart'; 
import '../detail_screen.dart';
import '../providers/scholarship_provider.dart';
import '../providers/bookmark_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _kategoriAktif = 0; // 0: Semua, 1: Prestasi, 2: Umum
  bool sedangProsesKeluar = false;

  // Fungsi untuk memutus sesi admin dan kembali ke login
  Future<void> prosesKeluar() async {
    setState(() {
      sedangProsesKeluar = true;
    });

    try {
      // Putus sesi autentikasi Supabase secara resmi
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('Error saat keluar admin: $e');
    } finally {
      if (mounted) {
        setState(() {
          sedangProsesKeluar = false;
        });

        // Hapus seluruh tumpukan halaman dan arahkan kembali ke LoginScreen
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

  void _tampilkanKonfirmasiHapus(BuildContext context, dynamic id, String name, bool isDark, Color primaryWarna) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Hapus Beasiswa?', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus beasiswa "$name"? Tindakan ini tidak dapat dibatalkan.', style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<ScholarshipProvider>(context, listen: false).deleteScholarship(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Beasiswa "$name" berhasil dihapus!'),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scholarshipProv = Provider.of<ScholarshipProvider>(context);
    final listBeasiswa = scholarshipProv.scholarships;
    
    // Filter berdasarkan kategori tab admin
    final beasiswaTampil = listBeasiswa.where((item) {
      if (_kategoriAktif == 1) return item['type'] == 'Prestasi';
      if (_kategoriAktif == 2) return item['type'] == 'Umum';
      return true;
    }).toList();

    // Hitung total bookmarks dari bookmark provider
    final totalBookmarks = Provider.of<BookmarkProvider>(context).bookmarkedItems.length;

    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, isDark, child) {
        Color primaryWarna = isDark ? Colors.green.shade400 : const Color(0xFF004900); // Hijau gelap sesuai gambar
        Color bgWarna = isDark ? const Color(0xFF121212) : const Color(0xFFF9F9FF);
        Color surfaceWarna = isDark ? const Color(0xFF1E1E1E) : Colors.white;

        return Scaffold(
          backgroundColor: bgWarna,
          appBar: AppBar(
            backgroundColor: surfaceWarna,
            elevation: 0,
            iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: primaryWarna,
                  child: const Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Text('Admin Dashboard', style: TextStyle(color: primaryWarna, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          drawer: _buildDrawer(context, isDark, primaryWarna),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Search Bar
              TextField(
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Cari beasiswa...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey.shade500 : Colors.grey),
                  filled: true,
                  fillColor: surfaceWarna,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(99), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              
              // Kategori Beasiswa
              Text('KATEGORI BEASISWA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildKategoriChip('Semua', 0, isDark, primaryWarna),
                    const SizedBox(width: 8),
                    _buildKategoriChip('Prestasi', 1, isDark, primaryWarna),
                    const SizedBox(width: 8),
                    _buildKategoriChip('Umum', 2, isDark, primaryWarna),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Big Stat Card (Total Beasiswa)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryWarna,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: primaryWarna.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -10,
                      child: Icon(Icons.school, size: 100, color: Colors.white.withOpacity(0.1)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TOTAL BEASISWA', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        Container(margin: const EdgeInsets.only(top: 4, bottom: 16), width: 30, height: 2, color: WarnaSigma.emas),
                        Text('${listBeasiswa.length}', style: const TextStyle(color: WarnaSigma.emas, fontSize: 40, fontWeight: FontWeight.bold, height: 1)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Row Small Stats
              Row(
                children: [
                  Expanded(child: _buildSmallStatCard('8,492', 'TOTAL KUNJUNGAN', Icons.group, Colors.green.shade100, Colors.green.shade800, isDark, surfaceWarna)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSmallStatCard('$totalBookmarks', 'TOTAL BOOKMARKS', Icons.bookmark, Colors.orange.shade100, Colors.orange.shade800, isDark, surfaceWarna)),
                ],
              ),
              const SizedBox(height: 32),
              
              // Daftar Beasiswa List
              Text('Daftar Beasiswa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 16),
              
              ...beasiswaTampil.map((beasiswa) {
                return _buildBeasiswaCard(beasiswa, isDark, surfaceWarna, primaryWarna);
              }).toList(),
              
              const SizedBox(height: 80), // Ruang ekstra agar tidak tertutup FAB/Bottom Nav
            ],
          ),
          
          // Floating Action Button
          floatingActionButton: FloatingActionButton(
            backgroundColor: WarnaSigma.emas,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () {
              // --- TAMBAHAN: NAVIGASI KE HALAMAN BUAT BEASISWA BARU ---
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, a1, a2) => const AddBeasiswaScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.black87),
          ),
          
          // Bottom Navigation Bar
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: surfaceWarna,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: primaryWarna,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(color: isDark ? Colors.green.shade900 : Colors.green.shade200, borderRadius: BorderRadius.circular(20)),
                    child: Icon(Icons.home, color: isDark ? Colors.white : Colors.green.shade900),
                  ),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Icon(Icons.group_outlined)),
                  label: 'Pengguna',
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  // --- WIDGET PEMBANTU ---

  Widget _buildKategoriChip(String label, int index, bool isDark, Color primaryWarna) {
    bool isSelected = _kategoriAktif == index;
    return GestureDetector(
      onTap: () => setState(() => _kategoriAktif = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryWarna : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: isSelected ? primaryWarna : (isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallStatCard(String val, String title, IconData icon, Color iconBgColor, Color iconColor, bool isDark, Color surfaceWarna) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceWarna,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: isDark ? iconBgColor.withOpacity(0.1) : iconBgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: isDark ? iconBgColor : iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, height: 1.2)),
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  // Desain Kartu Beasiswa Baru
  Widget _buildBeasiswaCard(Map<String, dynamic> beasiswa, bool isDark, Color surfaceWarna, Color primaryWarna) {
    final String name = beasiswa['name'] ?? '';
    final String host = beasiswa['host'] ?? '';
    final String negara = beasiswa['country'] ?? '';
    final List<String> tags = List<String>.from(beasiswa['tags'] ?? []);
    final String mulai = beasiswa['startDate'] ?? '';
    final String tutup = '${beasiswa['endDate'] ?? ''} (${beasiswa['daysLeft'] ?? ''})';
    final dynamic id = beasiswa['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceWarna,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Atas: Ikon Topi, Judul, Penyelenggara & Negara, Tombol Edit/Delete
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                    const SizedBox(height: 4),
                    Text(host, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                    // Menampilkan Negara tepat di bawah Penyelenggara
                    Text(negara, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                  ],
                ),
              ),
              // Ikon Aksi Admin menggantikan posisi Bookmark
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.edit_outlined, size: 22, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, a1, a2) => AddBeasiswaScreen(beasiswaUntukEdit: beasiswa),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.delete_outline, size: 22, color: Colors.red),
                    onPressed: () => _tampilkanKonfirmasiHapus(context, id, name, isDark, primaryWarna),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Bagian Tengah: Chip / Tag
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? primaryWarna.withOpacity(0.15) : const Color(0xFFEAF0FA),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(tag, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryWarna)),
            )).toList(),
          ),
          const SizedBox(height: 16),
          
          // Garis Pembatas
          Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, height: 1),
          const SizedBox(height: 16),
          
          // Bagian Bawah: Tanggal Mulai/Tutup dan Tombol Detail
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.calendar_today_outlined, size: 18, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mulai: $mulai', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Text('Tutup: $tutup', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, a1, a2) => DetailScreen(beasiswa: beasiswa),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Text('Detail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryWarna)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DRAWER MENU UNTUK KELUAR/LOGOUT (TANPA GARIS HITAM) ---
  Widget _buildDrawer(BuildContext context, bool isDark, Color primaryWarna) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primaryWarna),
            accountName: const Text('Admin SIGMA', style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text('Administrator'),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Text('A', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
          ),
          // HIGHLIGHT UNTUK HALAMAN AKTIF (Kelola Beasiswa)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              selected: true,
              selectedTileColor: isDark ? primaryWarna.withOpacity(0.15) : primaryWarna.withOpacity(0.1),
              leading: Icon(Icons.school, color: primaryWarna),
              title: Text('Kelola Beasiswa', style: TextStyle(color: primaryWarna, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context); // Tutup drawer karena sudah di halaman ini
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              leading: Icon(Icons.group, color: isDark ? Colors.white70 : Colors.black87),
              title: Text('Pengguna', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () {},
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
              leading: sedangProsesKeluar
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2),
                    )
                  : const Icon(Icons.logout, color: Colors.red),
              title: Text(
                sedangProsesKeluar ? 'Mengeluarkan...' : 'Keluar / Logout',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: sedangProsesKeluar ? null : prosesKeluar,
            ),
          ),
        ],
      ),
    );
  }
}