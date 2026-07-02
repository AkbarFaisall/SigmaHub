// File: lib/admin/add_beasiswa_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../sigma_theme.dart';
import '../profile/profile_screen.dart'; 
import '../providers/scholarship_provider.dart';

class AddBeasiswaScreen extends StatefulWidget {
  final Map<String, dynamic>? beasiswaUntukEdit;
  const AddBeasiswaScreen({super.key, this.beasiswaUntukEdit});

  @override
  State<AddBeasiswaScreen> createState() => _AddBeasiswaScreenState();
}

class _AddBeasiswaScreenState extends State<AddBeasiswaScreen> {
  // Logika toggle untuk UI menggunakan variabel bahasa Indonesia
  String _kategoriTerpilih = 'Prestasi';
  List<String> _jenjangTerpilih = ['S1'];
  List<String> _wilayahTerpilih = ['Dalam Negeri']; 
  String _pembiayaanTerpilih = 'Penuh';

  // Pengendali Teks (TextEditingController) untuk Validasi Formulir
  late TextEditingController _namaController;
  late TextEditingController _tanggalBukaController;
  late TextEditingController _tanggalTutupController;
  late TextEditingController _linkController;
  
  // Data Gambar (Logo & Banner)
  Uint8List? _logoBytes;
  Uint8List? _fotoBannerBytes;
  String _logoUrl = '';
  String _fotoBannerUrl = '';
  
  // Status pengisian deskripsi dari halaman baru (Diubah menjadi Map agar menampung 3 data sekaligus)
  bool _deskripsiTerisi = false;
  Map<String, String> _deskripsiData = {
    'penyelenggara': '',
    'deskripsi': '',
    'persyaratan': '',
  };

  @override
  void initState() {
    super.initState();
    if (widget.beasiswaUntukEdit != null) {
      final b = widget.beasiswaUntukEdit!;
      _kategoriTerpilih = b['type'] ?? 'Prestasi';
      
      // Parse tags
      final List<String> tags = List<String>.from(b['tags'] ?? []);
      _pembiayaanTerpilih = tags.any((t) => t.contains('Parsial')) ? 'Parsial' : 'Penuh';
      
      _wilayahTerpilih = [];
      if (tags.any((t) => t.contains('Dalam Negeri'))) _wilayahTerpilih.add('Dalam Negeri');
      if (tags.any((t) => t.contains('Luar Negeri'))) _wilayahTerpilih.add('Luar Negeri');
      
      _jenjangTerpilih = [];
      if (tags.isNotEmpty) {
        final firstTag = tags.first;
        if (firstTag.contains('S1')) _jenjangTerpilih.add('S1');
        if (firstTag.contains('S2')) _jenjangTerpilih.add('S2');
        if (firstTag.contains('S3')) _jenjangTerpilih.add('S3');
      }
      if (_jenjangTerpilih.isEmpty) _jenjangTerpilih.add('S1');

      _namaController = TextEditingController(text: b['name']);
      _tanggalBukaController = TextEditingController(text: b['startDate']);
      _tanggalTutupController = TextEditingController(text: b['endDate']);
      _linkController = TextEditingController(text: b['link']);
      
      _logoUrl = b['logoPenyelenggara'] ?? '';
      _fotoBannerUrl = b['fotoUtama'] ?? '';
      
      _deskripsiData = {
        'penyelenggara': b['host'] ?? '',
        'deskripsi': b['description'] ?? '',
        'persyaratan': b['requirements'] ?? '',
      };
      _deskripsiTerisi = _deskripsiData['penyelenggara']!.isNotEmpty && 
                         _deskripsiData['deskripsi']!.isNotEmpty && 
                         _deskripsiData['persyaratan']!.isNotEmpty;
    } else {
      _namaController = TextEditingController();
      _tanggalBukaController = TextEditingController();
      _tanggalTutupController = TextEditingController();
      _linkController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalBukaController.dispose();
    _tanggalTutupController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // Fungsi pembantu format nama bulan Indonesia
  String _getNamaBulan(int month) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return bulan[month - 1];
  }

  // Fungsi memvalidasi form sebelum memunculkan dialog konfirmasi akhir
  void _prosesValidasiForm(BuildContext context, bool modeGelap) {
    if (_namaController.text.trim().isEmpty ||
        _tanggalBukaController.text.trim().isEmpty ||
        _tanggalTutupController.text.trim().isEmpty ||
        _linkController.text.trim().isEmpty ||
        !_deskripsiTerisi) {
      
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Semua kolom wajib (Nama, Link, Tanggal Buka/Tutup, dan Detail Deskripsi) harus terisi!', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Jika lolos validasi, tampilkan dialog konfirmasi
    _tampilkanKonfirmasiBuat(context, modeGelap);
  }

  // --- FUNGSI DIALOG SUKSES (DENGAN ANIMASI MANTUL / ELASTIC) ---
  void _tampilkanDialogSukses(BuildContext context, bool modeGelap) {
    final bool isEdit = widget.beasiswaUntukEdit != null;
    showDialog(
      context: context,
      barrierDismissible: false, // User tidak bisa tutup popup dengan klik di luar layar
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Transparan agar animasi scale container terlihat mulus
          elevation: 0,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.4, end: 1.0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut, // Kurva animasi memantul
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: scale.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: modeGelap ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ikon Centang (Sesuai gambar referensi)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(color: Colors.green.shade200, shape: BoxShape.circle),
                          child: Center(
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(color: Colors.green.shade800, shape: BoxShape.circle),
                              child: const Icon(Icons.check, color: Colors.white, size: 36),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Teks Judul
                        Text(
                          isEdit ? 'Beasiswa Berhasil\nDiperbarui' : 'Beasiswa Berhasil\nDitambahkan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: modeGelap ? Colors.white : const Color(0xFF151C27),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Teks Subjudul
                        Text(
                          isEdit 
                              ? 'Program beasiswa Anda telah berhasil\ndiperbarui dan dapat dilihat oleh\npara pelajar.'
                              : 'Program beasiswa Anda telah berhasil\ndipublikasikan dan dapat dilihat oleh\npara pelajar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: modeGelap ? Colors.grey.shade400 : Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Tombol Kembali ke Dashboard
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WarnaSigma.emas,
                              foregroundColor: const Color(0xFF004900), // Teks hijau gelap
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.pop(context); // Tutup Dialog Sukses
                              Navigator.pop(context); // Kembali ke Dashboard Admin
                            },
                            child: const Text('Kembali ke Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _tampilkanKonfirmasiBuat(BuildContext context, bool modeGelap) {
    final bool isEdit = widget.beasiswaUntukEdit != null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: modeGelap ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(isEdit ? 'Konfirmasi Edit' : 'Konfirmasi', style: TextStyle(color: modeGelap ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text(
          isEdit 
              ? 'Apakah Anda yakin ingin memperbarui beasiswa ini?' 
              : 'Apakah Anda yakin ingin membuat dan menerbitkan beasiswa baru ini?',
          style: TextStyle(color: modeGelap ? Colors.grey.shade300 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: modeGelap ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: WarnaSigma.emas),
            onPressed: () async {
              final provider = Provider.of<ScholarshipProvider>(context, listen: false);
              final penyajiPesan = ScaffoldMessenger.of(context);
              Navigator.pop(context); // Tutup dialog konfirmasi
              
              // Tampilkan dialog proses
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: WarnaSigma.emas),
                ),
              );

              try {
                String logoUrlBaru = _logoUrl;
                String fotoBannerUrlBaru = _fotoBannerUrl;

                if (_logoBytes != null) {
                  final url = await provider.unggahGambarBeasiswa(_logoBytes!, 'logo', 'png');
                  if (url != null) logoUrlBaru = url;
                }

                if (_fotoBannerBytes != null) {
                  final url = await provider.unggahGambarBeasiswa(_fotoBannerBytes!, 'banner', 'png');
                  if (url != null) fotoBannerUrlBaru = url;
                }

                // Susun data beasiswa baru
                final List<String> tags = [
                  _jenjangTerpilih.join(', '),
                  _wilayahTerpilih.join(' & '),
                  'Pembiayaan $_pembiayaanTerpilih'
                ];

                // Coba hitung sisa hari dari tanggal tutup
                String daysLeftStr = 'Aktif';
                try {
                  final parts = _tanggalTutupController.text.split(' ');
                  if (parts.length >= 3) {
                    final int day = int.parse(parts[0]);
                    final int year = int.parse(parts[2]);
                    final bulanMap = {'Jan':1, 'Feb':2, 'Mar':3, 'Apr':4, 'Mei':5, 'Jun':6, 'Jul':7, 'Ags':8, 'Sep':9, 'Okt':10, 'Nov':11, 'Des':12};
                    final int? month = bulanMap[parts[1]];
                    if (month != null) {
                      final closingDate = DateTime(year, month, day);
                      final diff = closingDate.difference(DateTime.now()).inDays;
                      daysLeftStr = diff > 0 ? '$diff Hari' : 'Tutup';
                    }
                  }
                } catch (_) {}

                final data = {
                  'name': _namaController.text.trim(),
                  'host': _deskripsiData['penyelenggara'],
                  'country': _wilayahTerpilih.isEmpty ? 'Indonesia' : _wilayahTerpilih.first,
                  'tags': tags,
                  'startDate': _tanggalBukaController.text.trim(),
                  'endDate': _tanggalTutupController.text.trim(),
                  'daysLeft': daysLeftStr,
                  'type': _kategoriTerpilih,
                  'icon_name': 'school',
                  'description': _deskripsiData['deskripsi'],
                  'requirements': _deskripsiData['persyaratan'],
                  'link': _linkController.text.trim(),
                  'logoPenyelenggara': logoUrlBaru,
                  'fotoUtama': fotoBannerUrlBaru,
                };

                if (isEdit) {
                  await provider.updateScholarship(widget.beasiswaUntukEdit!['id'], data);
                } else {
                  await provider.addScholarship(data);
                }

                if (context.mounted) {
                  Navigator.pop(context); // Tutup dialog loading
                  _tampilkanDialogSukses(context, modeGelap);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Tutup dialog loading
                  penyajiPesan.showSnackBar(
                    SnackBar(
                      content: Text('Gagal menyimpan beasiswa: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEdit ? 'Ya, Simpan' : 'Ya, Buat', style: const TextStyle(color: WarnaSigma.utama, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Helper fungsi untuk theme DatePicker agar jelas di Dark Mode
  ThemeData _getThemeDatePicker(BuildContext context, bool modeGelap, Color warnaUtama, Color warnaPermukaan) {
    return Theme.of(context).copyWith(
      colorScheme: modeGelap
          ? ColorScheme.dark(
              primary: warnaUtama,
              onPrimary: Colors.white,
              surface: warnaPermukaan,
              onSurface: Colors.white, // Memastikan tanggal di kalender terlihat
            )
          : ColorScheme.light(
              primary: warnaUtama,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
      dialogBackgroundColor: warnaPermukaan,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, modeGelap, child) {
        Color warnaUtama = modeGelap ? Colors.green.shade400 : const Color(0xFF004900);
        Color warnaLatar = modeGelap ? const Color(0xFF121212) : const Color(0xFFF9F9FF);
        Color warnaPermukaan = modeGelap ? const Color(0xFF1E1E1E) : Colors.white;

        return Scaffold(
          backgroundColor: warnaLatar,
          appBar: AppBar(
            backgroundColor: warnaPermukaan,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: modeGelap ? Colors.white : Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(widget.beasiswaUntukEdit != null ? 'Edit Beasiswa' : 'Buat Beasiswa Baru', style: TextStyle(color: warnaUtama, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Detail Informasi Dasar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: modeGelap ? Colors.white : Colors.black)),
              const SizedBox(height: 8),
              Text('Isi detail dasar beasiswa Anda untuk mulai menarik pelamar terbaik.', style: TextStyle(color: modeGelap ? Colors.grey.shade400 : Colors.grey.shade600)),
              const SizedBox(height: 24),

              // Nama Beasiswa
              _buatLabel('Nama Beasiswa', modeGelap),
              TextField(
                controller: _namaController,
                style: TextStyle(color: modeGelap ? Colors.white : Colors.black),
                decoration: _dekorasiInput('Contoh: Beasiswa Unggulan Prestasi 2024', modeGelap, warnaPermukaan),
              ),
              const SizedBox(height: 20),

              // Link Beasiswa
              _buatLabel('Link Resmi Beasiswa', modeGelap),
              TextField(
                controller: _linkController,
                style: TextStyle(color: modeGelap ? Colors.white : Colors.black),
                decoration: _dekorasiInput('Contoh: https://beasiswa.kemdikbud.go.id', modeGelap, warnaPermukaan).copyWith(
                  prefixIcon: Icon(Icons.link, color: modeGelap ? Colors.grey.shade500 : Colors.grey),
                ),
              ),
              const SizedBox(height: 20),

              // Kategori
              _buatLabel('Kategori Beasiswa', modeGelap),
              Row(
                children: [
                  _buatChip('Prestasi', _kategoriTerpilih == 'Prestasi', () => setState(() => _kategoriTerpilih = 'Prestasi'), modeGelap, warnaUtama),
                  const SizedBox(width: 8),
                  _buatChip('Umum', _kategoriTerpilih == 'Umum', () => setState(() => _kategoriTerpilih = 'Umum'), modeGelap, warnaUtama),
                ],
              ),
              const SizedBox(height: 20),

              // Jenjang
              _buatLabel('Jenjang Pendidikan', modeGelap),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['S1', 'S2', 'S3'].map((jenjang) => _buatChip(jenjang, _jenjangTerpilih.contains(jenjang), () {
                  setState(() => _jenjangTerpilih.contains(jenjang) ? _jenjangTerpilih.remove(jenjang) : _jenjangTerpilih.add(jenjang));
                }, modeGelap, warnaUtama)).toList(),
              ),
              const SizedBox(height: 20),

              // Cakupan Wilayah (Format Mendatar & Multi-select)
              _buatLabel('Cakupan Wilayah', modeGelap),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Dalam Negeri', 'Luar Negeri'].map((wilayah) => _buatChip(wilayah, _wilayahTerpilih.contains(wilayah), () {
                  setState(() => _wilayahTerpilih.contains(wilayah) ? _wilayahTerpilih.remove(wilayah) : _wilayahTerpilih.add(wilayah));
                }, modeGelap, warnaUtama)).toList(),
              ),
              const SizedBox(height: 20),

              // Tipe Pembiayaan (Format Mendatar)
              _buatLabel('Tipe Pembiayaan', modeGelap),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buatChip('Penuh', _pembiayaanTerpilih == 'Penuh', () => setState(() => _pembiayaanTerpilih = 'Penuh'), modeGelap, warnaUtama),
                  _buatChip('Parsial', _pembiayaanTerpilih == 'Parsial', () => setState(() => _pembiayaanTerpilih = 'Parsial'), modeGelap, warnaUtama),
                ],
              ),
              const SizedBox(height: 20),

              // DUA KOLOM TANGGAL (BUKA & TUTUP)
              Row(
                children: [
                  // Kolom Tanggal Buka
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buatLabel('Tanggal Buka', modeGelap),
                        TextField(
                          controller: _tanggalBukaController,
                          style: TextStyle(color: modeGelap ? Colors.white : Colors.black, fontSize: 13),
                          decoration: _dekorasiInput('Pilih Buka', modeGelap, warnaPermukaan).copyWith(
                            suffixIcon: Icon(Icons.calendar_month, size: 20, color: modeGelap ? Colors.grey.shade400 : Colors.grey.shade600),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                              builder: (context, child) {
                                return Theme(
                                  data: _getThemeDatePicker(context, modeGelap, warnaUtama, warnaPermukaan),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _tanggalBukaController.text = "${pickedDate.day} ${_getNamaBulan(pickedDate.month)} ${pickedDate.year}";
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Kolom Tanggal Tutup
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buatLabel('Tanggal Tutup', modeGelap),
                        TextField(
                          controller: _tanggalTutupController,
                          style: TextStyle(color: modeGelap ? Colors.white : Colors.black, fontSize: 13),
                          decoration: _dekorasiInput('Pilih Tutup', modeGelap, warnaPermukaan).copyWith(
                            suffixIcon: Icon(Icons.calendar_month, size: 20, color: modeGelap ? Colors.grey.shade400 : Colors.grey.shade600),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(), 
                              lastDate: DateTime(2101),
                              builder: (context, child) {
                                return Theme(
                                  data: _getThemeDatePicker(context, modeGelap, warnaUtama, warnaPermukaan),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _tanggalTutupController.text = "${pickedDate.day} ${_getNamaBulan(pickedDate.month)} ${pickedDate.year}";
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Deskripsi & Persyaratan (Navigasi ke Halaman Baru)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _deskripsiTerisi ? Colors.green : warnaUtama, style: BorderStyle.solid),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(20),
                  backgroundColor: _deskripsiTerisi ? (_deskripsiTerisi ? Colors.green.withOpacity(0.05) : Colors.transparent) : Colors.transparent,
                ),
                onPressed: () async {
                  // Pindah ke halaman pengisian deskripsi, membawa data jika sudah ada isinya
                  final hasil = await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, a1, a2) => AddDescriptionScreen(dataAwal: _deskripsiData),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );

                  // Jika user kembali membawa hasil map, simpan statusnya
                  if (hasil != null && hasil is Map<String, String>) {
                    setState(() {
                      _deskripsiData = hasil;
                      // Akan dianggap terisi jika Penyelenggara, Deskripsi, dan Persyaratan diisi
                      _deskripsiTerisi = _deskripsiData['penyelenggara']!.isNotEmpty && 
                                         _deskripsiData['deskripsi']!.isNotEmpty && 
                                         _deskripsiData['persyaratan']!.isNotEmpty;
                    });
                  }
                },
                child: Row(
                  children: [
                    Icon(_deskripsiTerisi ? Icons.check_circle : Icons.description, color: _deskripsiTerisi ? Colors.green : warnaUtama),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _deskripsiTerisi ? 'Detail & Persyaratan Telah Diisi' : 'Tambahkan Deskripsi & Persyaratan', 
                        style: TextStyle(color: _deskripsiTerisi ? Colors.green : warnaUtama, fontWeight: FontWeight.bold)
                      )
                    ),
                    Icon(Icons.chevron_right, color: _deskripsiTerisi ? Colors.green : warnaUtama),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // Area unggah Logo Penyelenggara & Banner Utama beasiswa
              _buatLabel('Logo Penyelenggara', modeGelap),
              _buildAreaLogo(modeGelap, warnaUtama, warnaPermukaan),
              const SizedBox(height: 25),
              _buatLabel('Foto Banner Utama / Detail', modeGelap),
              _buildAreaBanner(modeGelap, warnaUtama, warnaPermukaan),
              const SizedBox(height: 100),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(20),
            color: warnaPermukaan,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: WarnaSigma.emas,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
              ),
              onPressed: () => _prosesValidasiForm(context, modeGelap),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.beasiswaUntukEdit != null ? 'Simpan Perubahan' : 'Buat Beasiswa', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 8),
                  const Icon(Icons.send, color: Colors.black),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET PEMBANTU ---

  Widget _buatLabel(String teks, bool modeGelap) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(teks, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: modeGelap ? Colors.white : Colors.black)),
  );

  InputDecoration _dekorasiInput(String petunjuk, bool modeGelap, Color permukaan) => InputDecoration(
    hintText: petunjuk,
    hintStyle: TextStyle(color: modeGelap ? Colors.grey.shade600 : Colors.grey.shade400),
    filled: true,
    fillColor: permukaan,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade400, width: 2)),
  );

  Widget _buatChip(String label, bool aktif, VoidCallback saatDitekan, bool modeGelap, Color warnaUtama) => GestureDetector(
    onTap: saatDitekan,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: aktif ? warnaUtama : (modeGelap ? const Color(0xFF2C2C2C) : Colors.white),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: aktif ? warnaUtama : Colors.grey.shade400),
      ),
      child: Text(label, style: TextStyle(color: aktif ? Colors.white : (modeGelap ? Colors.grey.shade300 : Colors.black))),
    ),
  );

  Widget _buildAreaLogo(bool modeGelap, Color warnaUtama, Color warnaPermukaan) {
    Widget child;
    bool apakahAdaLogo = _logoBytes != null || _logoUrl.isNotEmpty;

    if (_logoBytes != null) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(_logoBytes!, fit: BoxFit.cover),
      );
    } else if (_logoUrl.isNotEmpty) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _logoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, _, __) => Image.asset(
            'assets/images/default_logo.jpeg',
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // Fallback ke aset lokal default jika logo kosong/null
      child = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/default_logo.jpeg',
          fit: BoxFit.cover,
        ),
      );
    }

    final tumpukanGambar = Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          bottom: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _pilihSumberGambarBeasiswa(modeGelap, warnaUtama, true),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: warnaPermukaan,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: modeGelap ? Colors.grey.shade800 : Colors.grey.shade300),
            ),
            child: tumpukanGambar,
          ),
        ),
        if (apakahAdaLogo) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _hapusGambarBeasiswaDialog(true, modeGelap, warnaUtama),
            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
            label: const Text('Hapus Logo', style: TextStyle(color: Colors.red, fontSize: 13)),
          ),
        ]
      ],
    );
  }

  Widget _buildAreaBanner(bool modeGelap, Color warnaUtama, Color warnaPermukaan) {
    Widget child;
    bool apakahAdaBanner = _fotoBannerBytes != null || _fotoBannerUrl.isNotEmpty;

    if (_fotoBannerBytes != null) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(_fotoBannerBytes!, fit: BoxFit.cover, width: double.infinity, height: 160),
      );
    } else if (_fotoBannerUrl.isNotEmpty) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _fotoBannerUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 160,
          errorBuilder: (context, _, __) => Image.asset(
            'assets/images/default_banner.jpeg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 160,
          ),
        ),
      );
    } else {
      // Fallback ke aset lokal default jika banner kosong/null
      child = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/default_banner.jpeg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: 160,
        ),
      );
    }

    final tumpukanGambar = Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _pilihSumberGambarBeasiswa(modeGelap, warnaUtama, false),
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: warnaPermukaan,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: modeGelap ? Colors.grey.shade800 : Colors.grey.shade300),
            ),
            child: tumpukanGambar,
          ),
        ),
        if (apakahAdaBanner) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _hapusGambarBeasiswaDialog(false, modeGelap, warnaUtama),
            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
            label: const Text('Hapus Foto Banner', style: TextStyle(color: Colors.red, fontSize: 13)),
          ),
        ]
      ],
    );
  }

  void _hapusGambarBeasiswaDialog(bool isLogo, bool modeGelap, Color warnaUtama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: modeGelap ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(isLogo ? 'Hapus Logo?' : 'Hapus Banner?', style: TextStyle(color: modeGelap ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text(
          isLogo 
              ? 'Apakah Anda yakin ingin menghapus logo penyelenggara beasiswa ini?' 
              : 'Apakah Anda yakin ingin menghapus foto banner beasiswa ini?',
          style: TextStyle(color: modeGelap ? Colors.grey.shade300 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: modeGelap ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final provider = Provider.of<ScholarshipProvider>(context, listen: false);
              final penyajiPesan = ScaffoldMessenger.of(context);
              Navigator.pop(context); // Tutup dialog konfirmasi
              
              // Jika ini mode Edit (beasiswa terdaftar di database), panggil provider untuk menghapus di storage & online database
              if (widget.beasiswaUntukEdit != null) {
                final dynamic beasiswaId = widget.beasiswaUntukEdit!['id'];
                
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: WarnaSigma.emas),
                  ),
                );

                try {
                  final String urlHapus = isLogo ? _logoUrl : _fotoBannerUrl;
                  final String tipeGambar = isLogo ? 'logo' : 'banner';
                  
                  await provider.hapusGambarBeasiswa(beasiswaId, tipeGambar, urlHapus);
                } catch (e) {
                  debugPrint('Gagal menghapus gambar secara online: $e');
                } finally {
                  if (context.mounted) {
                    Navigator.pop(context); // Tutup dialog loading
                  }
                }
              }

              // Perbarui status lokal di state page
              setState(() {
                if (isLogo) {
                  _logoBytes = null;
                  _logoUrl = '';
                } else {
                  _fotoBannerBytes = null;
                  _fotoBannerUrl = '';
                }
              });

              penyajiPesan.showSnackBar(
                SnackBar(
                  content: Text('${isLogo ? 'Logo' : 'Banner'} berhasil dihapus!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _pilihSumberGambarBeasiswa(bool isDark, Color primaryWarna, bool isLogo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: primaryWarna),
                title: Text('Ambil dari Kamera', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _ambilGambarBeasiswa(ImageSource.camera, isLogo);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: primaryWarna),
                title: Text('Pilih dari Galeri', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _ambilGambarBeasiswa(ImageSource.gallery, isLogo);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _ambilGambarBeasiswa(ImageSource sumber, bool isLogo) async {
    try {
      final ImagePicker pemilih = ImagePicker();
      final XFile? berkasFoto = await pemilih.pickImage(
        source: sumber,
        imageQuality: 85,
        maxWidth: 800,
      );
      
      if (berkasFoto != null) {
        final Uint8List dataByte = await berkasFoto.readAsBytes();
        setState(() {
          if (isLogo) {
            _logoBytes = dataByte;
          } else {
            _fotoBannerBytes = dataByte;
          }
        });
      }
    } catch (e) {
      debugPrint('Gagal mengambil gambar: $e');
    }
  }
}


// ============================================================================
// HALAMAN BARU: ADD DESCRIPTION SCREEN
// (Ini dipanggil saat admin menekan tombol "Tambahkan Deskripsi & Persyaratan")
// ============================================================================
class AddDescriptionScreen extends StatefulWidget {
  final Map<String, String> dataAwal;
  const AddDescriptionScreen({super.key, required this.dataAwal});

  @override
  State<AddDescriptionScreen> createState() => _AddDescriptionScreenState();
}

class _AddDescriptionScreenState extends State<AddDescriptionScreen> {
  late TextEditingController _penyelenggaraController;
  late TextEditingController _deskripsiController;
  late TextEditingController _persyaratanController;

  @override
  void initState() {
    super.initState();
    _penyelenggaraController = TextEditingController(text: widget.dataAwal['penyelenggara']);
    _deskripsiController = TextEditingController(text: widget.dataAwal['deskripsi']);
    _persyaratanController = TextEditingController(text: widget.dataAwal['persyaratan']);
  }

  @override
  void dispose() {
    _penyelenggaraController.dispose();
    _deskripsiController.dispose();
    _persyaratanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, modeGelap, child) {
        Color warnaUtama = modeGelap ? Colors.green.shade400 : const Color(0xFF004900);
        Color warnaLatar = modeGelap ? const Color(0xFF121212) : const Color(0xFFF9F9FF);
        Color warnaPermukaan = modeGelap ? const Color(0xFF1E1E1E) : Colors.white;
        Color warnaGaris = modeGelap ? Colors.grey.shade800 : Colors.grey.shade300;

        return Scaffold(
          backgroundColor: warnaLatar,
          appBar: AppBar(
            backgroundColor: warnaPermukaan,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: modeGelap ? Colors.white : Colors.black),
              onPressed: () {
                Navigator.pop(context, {
                  'penyelenggara': _penyelenggaraController.text,
                  'deskripsi': _deskripsiController.text,
                  'persyaratan': _persyaratanController.text,
                });
              },
            ),
            title: Text('Deskripsi & Persyaratan', style: TextStyle(color: warnaUtama, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Informasi Beasiswa
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24), 
                  decoration: BoxDecoration(
                    color: modeGelap ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: modeGelap ? Colors.green.shade400 : const Color(0xFF016E21)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Informasi Beasiswa', style: TextStyle(fontWeight: FontWeight.bold, color: modeGelap ? Colors.white : Colors.black)),
                            const SizedBox(height: 4),
                            Text(
                              'Lengkapi detail deskripsi dan persyaratan agar calon pendaftar memahami kriteria yang dibutuhkan.',
                              style: TextStyle(fontSize: 13, color: modeGelap ? Colors.grey.shade300 : Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Kartu 1: Penyelenggara Beasiswa
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: warnaPermukaan,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: warnaGaris),
                    boxShadow: modeGelap ? [] : [const BoxShadow(color: Color(0x0F006400), blurRadius: 12, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Penyelenggara Beasiswa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: modeGelap ? Colors.white : Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _penyelenggaraController,
                        style: TextStyle(color: modeGelap ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.corporate_fare, color: modeGelap ? Colors.grey.shade500 : Colors.grey),
                          hintText: 'Contoh: Yayasan Pendidikan Global',
                          hintStyle: TextStyle(color: modeGelap ? Colors.grey.shade600 : Colors.grey.shade400),
                          filled: true,
                          fillColor: warnaPermukaan,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: warnaGaris)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: warnaUtama, width: 2)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Kartu 2: Deskripsi Beasiswa (Polos tanpa Fake Toolbar)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: warnaPermukaan,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: warnaGaris),
                    boxShadow: modeGelap ? [] : [const BoxShadow(color: Color(0x0F006400), blurRadius: 12, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Deskripsi Beasiswa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: modeGelap ? Colors.white : Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _deskripsiController,
                        maxLines: 6,
                        style: TextStyle(color: modeGelap ? Colors.white : Colors.black, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Jelaskan mengenai tujuan, cakupan, dan manfaat beasiswa ini secara detail...',
                          hintStyle: TextStyle(color: modeGelap ? Colors.grey.shade600 : Colors.grey.shade400),
                          filled: true,
                          fillColor: warnaPermukaan,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: warnaGaris)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: warnaUtama, width: 2)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Kartu 3: Persyaratan Umum
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: warnaPermukaan,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: warnaGaris),
                    boxShadow: modeGelap ? [] : [const BoxShadow(color: Color(0x0F006400), blurRadius: 12, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Persyaratan Umum', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: modeGelap ? Colors.white : Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _persyaratanController,
                        maxLines: 5,
                        style: TextStyle(color: modeGelap ? Colors.white : Colors.black, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '1. Mahasiswa aktif semester 3-7\n2. IPK Minimal 3.50\n3. Memiliki sertifikat TOEFL/IELTS...',
                          hintStyle: TextStyle(color: modeGelap ? Colors.grey.shade600 : Colors.grey.shade400),
                          filled: true,
                          fillColor: warnaPermukaan,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: warnaGaris)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: warnaUtama, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tip Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: modeGelap ? const Color(0xFF2A2612) : const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: modeGelap ? const Color(0xFF544600) : const Color(0xFFE9C400).withOpacity(0.5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.tips_and_updates, color: modeGelap ? const Color(0xFFE9C400) : const Color(0xFF705D00), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tips: Tuliskan poin-poin persyaratan secara jelas untuk meminimalisir pertanyaan berulang dari pendaftar.',
                                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: modeGelap ? Colors.grey.shade300 : const Color(0xFF4B3E00)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 80), // Ruang ekstra bawah
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(20),
            color: warnaPermukaan,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WarnaSigma.emas,
                      foregroundColor: const Color(0xFF004900), // Warna teks hijau gelap
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // Mengembalikan data Map ke halaman sebelumnya
                      Navigator.pop(context, {
                        'penyelenggara': _penyelenggaraController.text,
                        'deskripsi': _deskripsiController.text,
                        'persyaratan': _persyaratanController.text,
                      });
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save),
                        SizedBox(width: 8),
                        Text('Simpan Detail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Perubahan akan disimpan sebagai draft', style: TextStyle(fontSize: 11, color: modeGelap ? Colors.grey.shade500 : Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }
}