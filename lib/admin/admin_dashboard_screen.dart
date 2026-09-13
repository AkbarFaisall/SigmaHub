// File: lib/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../sigma_theme.dart';
import '../profile/profile_screen.dart'; 
import 'add_beasiswa_screen.dart'; 
import 'admin_drawer.dart';
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
  String _searchQuery = '';

  void _tampilkanKonfirmasiHapus(BuildContext context, dynamic id, String name, bool isDark, Color primaryWarna) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Hapus Beasiswa?', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus beasiswa "$name"? Tindakan ini tidak dapat dibatalkan.', style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final provider = Provider.of<ScholarshipProvider>(context, listen: false);
              Navigator.pop(dialogContext); // Tutup dialog konfirmasi
              
              // Tampilkan dialog loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(color: WarnaSigma.emas),
                ),
              );

              try {
                await provider.deleteScholarship(id);
                if (context.mounted) {
                  Navigator.pop(context); // Tutup loading
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Beasiswa "$name" berhasil dihapus!'),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Tutup loading
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus beasiswa: $e'),
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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
    
    // Filter berdasarkan kategori tab admin & pencarian
    final beasiswaTampil = listBeasiswa.where((item) {
      bool cocokKategori = true;
      if (_kategoriAktif == 1) cocokKategori = item['type'] == 'Prestasi';
      if (_kategoriAktif == 2) cocokKategori = item['type'] == 'Umum';
      
      bool cocokPencarian = true;
      if (_searchQuery.isNotEmpty) {
        String query = _searchQuery.toLowerCase();
        String nama = (item['name'] ?? '').toString().toLowerCase();
        String host = (item['host'] ?? '').toString().toLowerCase();
        cocokPencarian = nama.contains(query) || host.contains(query);
      }
      return cocokKategori && cocokPencarian;
    }).toList();

    // Hitung total bookmarks dari bookmark provider
    final totalBookmarks = Provider.of<BookmarkProvider>(context).bookmarkedItems.length;

    // Hitung total views
    int totalViews = 0;
    for (var b in listBeasiswa) {
      totalViews += (b['views'] as int?) ?? 0;
    }

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
            title: Text('Admin Dashboard', style: TextStyle(color: primaryWarna, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          drawer: const AdminDrawer(activeRoute: 'beasiswa'),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
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
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => Provider.of<ScholarshipProvider>(context, listen: false).loadScholarships(),
                  color: primaryWarna,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    children: [
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
                  Expanded(child: _buildSmallStatCard('$totalViews', 'TOTAL KUNJUNGAN', Icons.remove_red_eye, Colors.green.shade100, Colors.green.shade800, isDark, surfaceWarna)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSmallStatCard('$totalBookmarks', 'TOTAL BOOKMARKS', Icons.bookmark, Colors.orange.shade100, Colors.orange.shade800, isDark, surfaceWarna)),
                ],
              ),
              const SizedBox(height: 16),
              
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
              const SizedBox(height: 32),
              
              // Daftar Beasiswa List
              Text('Daftar Beasiswa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 16),
              
              if (beasiswaTampil.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 80, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada beasiswa yang sesuai pencarianmu :(',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cek kembali nanti ya!',
                        style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              else
                ...beasiswaTampil.map((beasiswa) {
                  return _buildBeasiswaCard(beasiswa, isDark, surfaceWarna, primaryWarna);
                }).toList(),
              
                    ],
                  ),
                ),
              ),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.remove_red_eye, size: 14, color: WarnaSigma.emas),
                        const SizedBox(width: 4),
                        Text('${beasiswa['views'] ?? 0} Kali Dilihat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WarnaSigma.emas)),
                      ],
                    ),
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
                    Text('Tutup: $tutup', style: TextStyle(fontSize: 13, color: isDark ? Colors.red.shade400 : Colors.red.shade700, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, a1, a2) => DetailScreen(beasiswa: beasiswa, isAdmin: true),
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

}