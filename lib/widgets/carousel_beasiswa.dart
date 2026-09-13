import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sigma_theme.dart';
import '../detail_screen.dart';
import '../login/login_screen.dart';
import '../providers/bookmark_provider.dart';

class CarouselBeasiswa extends StatefulWidget {
  final List<dynamic> allBeasiswa;
  final bool isDark;

  const CarouselBeasiswa({
    super.key,
    required this.allBeasiswa,
    required this.isDark,
  });

  @override
  State<CarouselBeasiswa> createState() => _CarouselBeasiswaState();
}

class _CarouselBeasiswaState extends State<CarouselBeasiswa> {
  List<dynamic> _randomBeasiswa = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _acakBeasiswa();
  }

  @override
  void didUpdateWidget(covariant CarouselBeasiswa oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allBeasiswa.length != oldWidget.allBeasiswa.length || 
        (widget.allBeasiswa.isNotEmpty && oldWidget.allBeasiswa.isEmpty)) {
      _acakBeasiswa();
    }
  }

  void _acakBeasiswa() {
    if (widget.allBeasiswa.isEmpty) {
      if (mounted) {
        setState(() {
          _randomBeasiswa = [];
        });
      }
      return;
    }
    
    // Copy list untuk di-shuffle agar tidak mengubah list aslinya
    List<dynamic> listCopy = List.from(widget.allBeasiswa);
    listCopy.shuffle();
    
    // Ambil maksimal 5
    if (mounted) {
      setState(() {
        _randomBeasiswa = listCopy.take(5).toList();
        _currentIndex = 0;
      });
    }
  }

  void _cekAksesTamu(VoidCallback aksiLanjutan) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Akses Dibatasi'),
          content: const Text('Silakan masuk atau daftar terlebih dahulu untuk mengakses fitur ini.'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: WarnaSigma.utama,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, a1, a2) => const LoginScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: const Text('Masuk'),
            ),
          ],
        ),
      );
    } else {
      aksiLanjutan();
    }
  } 

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
    if (_randomBeasiswa.isEmpty) {
      return const SizedBox.shrink(); 
    }
    
    Color primaryWarna = widget.isDark ? Colors.green.shade400 : const Color(0xFF004900);

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 255,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: _randomBeasiswa.map((beasiswa) {
            return Builder(
              builder: (BuildContext context) {
                bool apakahTersimpan = Provider.of<BookmarkProvider>(context).isBookmarked(beasiswa['name']);
                
                return GestureDetector(
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
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      boxShadow: widget.isDark ? [] : const [BoxShadow(color: Color(0x0F006400), blurRadius: 12, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bagian Atas: Judul, Penyelenggara, Negara
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    beasiswa['name'], 
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black), 
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    beasiswa['host'], 
                                    style: TextStyle(fontSize: 14, color: widget.isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi), 
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  Text(
                                    beasiswa['country'], 
                                    style: TextStyle(fontSize: 14, color: widget.isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi), 
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                apakahTersimpan ? Icons.bookmark : Icons.bookmark_border,
                                color: apakahTersimpan ? primaryWarna : (widget.isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi),
                              ),
                              onPressed: () {
                                _cekAksesTamu(() {
                                  Provider.of<BookmarkProvider>(context, listen: false).toggleBookmark(beasiswa);
                                  _tampilkanNotifTersimpan(!apakahTersimpan, widget.isDark);
                                });
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Bagian Tengah: Tags
                        Wrap(
                          runSpacing: 8,
                          children: (beasiswa['tags'] as List).map((tag) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE7EEFE),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDark ? Colors.green.shade300 : const Color(0xFF0F7427),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        
                        const SizedBox(height: 16),
                        Divider(height: 1, color: widget.isDark ? Colors.grey.shade800 : const Color(0xFFDCE2F3)),
                        const SizedBox(height: 12),
                        
                        // Bagian Bawah: Tanggal & Tombol Detail
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: widget.isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Mulai: ${beasiswa['startDate']}', style: TextStyle(fontSize: 12, color: widget.isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
                                        const SizedBox(height: 2),
                                        Text('Tutup: ${beasiswa['endDate']} (${beasiswa['daysLeft']})', style: TextStyle(fontSize: 12, color: widget.isDark ? Colors.red.shade400 : Colors.red.shade700, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                              child: Text('Detail', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryWarna)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _randomBeasiswa.asMap().entries.map((entry) {
            return Container(
              width: _currentIndex == entry.key ? 24.0 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: _currentIndex == entry.key
                    ? (widget.isDark ? WarnaSigma.emas : WarnaSigma.utama)
                    : (widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
