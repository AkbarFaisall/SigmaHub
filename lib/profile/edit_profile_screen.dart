import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../sigma_theme.dart';
import 'profile_screen.dart'; 
import '../providers/profile_provider.dart';
import 'crop_image_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nama;
  late TextEditingController _univ;
  late TextEditingController _jurusan;
  late TextEditingController _hp;
  
  late String _namaAwal;
  late String _univAwal;
  late String _jurusanAwal;
  late String _hpAwal;

  bool _apakahFormBerubah = false;
  bool _sedangUnggah = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    _namaAwal = profile.name;
    _univAwal = profile.university;
    _jurusanAwal = profile.major;
    _hpAwal = profile.phone;

    _nama = TextEditingController(text: _namaAwal);
    _univ = TextEditingController(text: _univAwal);
    _jurusan = TextEditingController(text: _jurusanAwal);
    _hp = TextEditingController(text: _hpAwal);

    _nama.addListener(_cekPerubahanData);
    _univ.addListener(_cekPerubahanData);
    _jurusan.addListener(_cekPerubahanData);
    _hp.addListener(_cekPerubahanData);
  }

  @override
  void dispose() {
    _nama.removeListener(_cekPerubahanData);
    _univ.removeListener(_cekPerubahanData);
    _jurusan.removeListener(_cekPerubahanData);
    _hp.removeListener(_cekPerubahanData);
    _nama.dispose();
    _univ.dispose();
    _jurusan.dispose();
    _hp.dispose();
    super.dispose();
  }

  void _cekPerubahanData() {
    final apakahBerubah = _nama.text != _namaAwal ||
        _univ.text != _univAwal ||
        _jurusan.text != _jurusanAwal ||
        _hp.text != _hpAwal;
    if (apakahBerubah != _apakahFormBerubah) {
      setState(() {
        _apakahFormBerubah = apakahBerubah;
      });
    }
  }

  // Fungsi konfirmasi sebelum menyimpan data teks
  void _tampilkanKonfirmasi(bool isDark, Color primaryWarna) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Simpan Perubahan?', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text('Apakah Anda yakin ingin menyimpan data profil yang baru?', style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Batal
            child: Text('Batal', style: TextStyle(color: isDark ? Colors.grey.shade400 : WarnaSigma.garisTepi)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryWarna),
            onPressed: () async {
              final profileProv = Provider.of<ProfileProvider>(context, listen: false);
              final penyajiPesan = ScaffoldMessenger.of(context);
              Navigator.pop(context); // Menutup dialog
              
              await profileProv.updateProfile(
                name: _nama.text,
                university: _univ.text,
                major: _jurusan.text,
                phone: _hp.text,
              );
              
              setState(() {
                _namaAwal = _nama.text;
                _univAwal = _univ.text;
                _jurusanAwal = _jurusan.text;
                _hpAwal = _hp.text;
                _apakahFormBerubah = false;
              });

              penyajiPesan.showSnackBar(
                SnackBar(
                  content: const Text('Profil berhasil diperbarui! Silakan kembali.'),
                  backgroundColor: primaryWarna,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Ya, Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Menampilkan BottomSheet untuk memilih sumber foto (Kamera atau Galeri)
  void _pilihSumberFoto(bool isDark, Color primaryWarna) {
    final profilProv = Provider.of<ProfileProvider>(context, listen: false);
    final apakahAdaFoto = profilProv.avatarUrl.isNotEmpty;

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
                  _ambilDanCropFoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: primaryWarna),
                title: Text('Pilih dari Galeri', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _ambilDanCropFoto(ImageSource.gallery);
                },
              ),
              if (apakahAdaFoto)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text('Hapus Foto', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  onTap: () {
                    Navigator.pop(context);
                    _hapusFotoProfil();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Menghapus foto profil dari Supabase Storage dan profiles database
  Future<void> _hapusFotoProfil() async {
    setState(() {
      _sedangUnggah = true;
    });

    try {
      final profilProv = Provider.of<ProfileProvider>(context, listen: false);
      await profilProv.hapusFotoProfil();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil dihapus!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Gagal menghapus foto profil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus foto profil.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sedangUnggah = false;
        });
      }
    }
  }

  // Mengambil foto dari sumber yang dipilih dan mengarahkannya ke halaman potong (crop) gambar
  Future<void> _ambilDanCropFoto(ImageSource sumber) async {
    try {
      final ImagePicker pemilih = ImagePicker();
      final profileProv = Provider.of<ProfileProvider>(context, listen: false);
      final penyajiPesan = ScaffoldMessenger.of(context);
      
      final XFile? berkasFoto = await pemilih.pickImage(
        source: sumber,
        imageQuality: 90,
      );
      
      if (berkasFoto != null) {
        final Uint8List dataByte = await berkasFoto.readAsBytes();
        
        if (!mounted) return;
        final Uint8List? hasilPotong = await Navigator.push<Uint8List>(
          context,
          MaterialPageRoute(
            builder: (context) => CropImageScreen(imageBytes: dataByte),
          ),
        );
        
        if (hasilPotong != null) {
          setState(() {
            _sedangUnggah = true;
          });
          
          try {
            final urlBaru = await profileProv.unggahFotoProfilBytes(hasilPotong, 'png');
            
            if (urlBaru != null) {
              penyajiPesan.showSnackBar(
                const SnackBar(
                  content: Text('Foto profil berhasil diperbarui!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            debugPrint('Gagal mengunggah foto profil: $e');
            penyajiPesan.showSnackBar(
              const SnackBar(
                content: Text('Gagal memperbarui foto profil.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } finally {
            if (mounted) {
              setState(() {
                _sedangUnggah = false;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Terjadi kesalahan saat memilih/memotong foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil atau memotong foto.')),
        );
      }
    }
  }

  Widget _buildAvatarPreview(Color primaryWarna) {
    if (_sedangUnggah) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.black54,
        child: const CircularProgressIndicator(color: Colors.white),
      );
    }
    
    final profile = Provider.of<ProfileProvider>(context);
    final String avatarUrl = profile.avatarUrl;
    
    if (avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('data:image')) {
        try {
          final String base64Content = avatarUrl.split(',').last;
          final bytes = base64Decode(base64Content);
          return CircleAvatar(
            radius: 50,
            backgroundImage: MemoryImage(bytes),
          );
        } catch (_) {}
      } else if (avatarUrl.startsWith('http')) {
        return CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(avatarUrl),
        );
      }
    }
    
    final inisialNama = _nama.text.isNotEmpty ? _nama.text[0].toUpperCase() : 'M';
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.green,
      child: Text(
        inisialNama,
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
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
            title: Text('Edit Profil', style: TextStyle(color: isDark ? Colors.white : Colors.black)), 
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Stack(
                  children: [
                    _buildAvatarPreview(primaryWarna),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _pilihSumberFoto(isDark, primaryWarna),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: WarnaSigma.emas,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? const Color(0xFF121212) : Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: WarnaSigma.utama,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Email (Read-Only)
              _fieldDisabled('Alamat Email', Provider.of<ProfileProvider>(context).email, Icons.mail_outline, isDark),
              
              // Field Input dengan Hint Text sebagai panduan
              _field('Nama Lengkap', 'Masukkan nama lengkap Anda', _nama, Icons.person_outline, isDark, primaryWarna),
              _field('Universitas', 'Contoh: UIN Alauddin', _univ, Icons.school_outlined, isDark, primaryWarna),
              _field('Jurusan', 'Contoh: Teknik Informatika', _jurusan, Icons.menu_book, isDark, primaryWarna),
              _field('Nomor Telepon', 'Contoh: +62 812...', _hp, Icons.call_outlined, isDark, primaryWarna),
              
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _apakahFormBerubah ? WarnaSigma.emas : Colors.grey.shade400, 
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: _apakahFormBerubah ? 2 : 0,
                ),
                onPressed: _apakahFormBerubah ? () => _tampilkanKonfirmasi(isDark, primaryWarna) : null,
                child: Text(
                  'SIMPAN PERUBAHAN', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: _apakahFormBerubah ? WarnaSigma.utama : Colors.grey.shade600,
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _field(String label, String hint, TextEditingController ctrl, IconData icon, bool isDark, Color primaryWarna) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : WarnaSigma.garisTepi)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl, 
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: hint, 
          hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
          prefixIcon: Icon(icon, color: isDark ? Colors.grey.shade500 : WarnaSigma.garisTepi), 
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryWarna, width: 2)),
        )
      ),
      const SizedBox(height: 15),
    ],
  );

  Widget _fieldDisabled(String label, String value, IconData icon, bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : WarnaSigma.garisTepi)),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: value,
        enabled: false,
        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E1E).withOpacity(0.5) : WarnaSigma.latar,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200)),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200)),
        ),
      ),
      const SizedBox(height: 15),
    ],
  );
}