// File: lib/providers/scholarship_provider.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

class ScholarshipProvider with ChangeNotifier {
  List<Map<String, dynamic>> _scholarships = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get scholarships => _scholarships;
  bool get isLoading => _isLoading;

  static const String _spKey = 'sigma_scholarships_data';

  // Seed data awal jika database lokal kosong
  final List<Map<String, dynamic>> _seedData = [
    {
      'id': 1,
      'name': 'Beasiswa Unggulan',
      'host': 'Kementerian Pendidikan dan Kebudayaan',
      'country': 'Indonesia',
      'tags': ['S1, S2, S3', 'Dalam Negeri', 'Pembiayaan Penuh'],
      'startDate': '1 Ags 2024',
      'endDate': '31 Ags 2024',
      'daysLeft': '14 Hari',
      'type': 'Prestasi',
      'icon_name': 'school',
      'description': 'Beasiswa Unggulan adalah pemberian biaya pendidikan oleh pemerintah Indonesia kepada putra-putri terbaik bangsa Indonesia pada perguruan tinggi penerima sesuai dengan ketentuan yang berlaku.',
      'requirements': '1. Warga Negara Indonesia (WNI) berprestasi.\n2. Mendapatkan surat rekomendasi institusi.\n3. Tidak sedang menerima beasiswa lain.\n4. Diterima di Perguruan Tinggi terakreditasi.',
      'link': 'https://beasiswa.kemdikbud.go.id',
    },
    {
      'id': 2,
      'name': 'LPDP Reguler',
      'host': 'Kementerian Keuangan RI',
      'country': 'Indonesia',
      'tags': ['S2, S3', 'Dalam & Luar Negeri', 'Pembiayaan Penuh'],
      'startDate': '11 Jan 2024',
      'endDate': '15 Okt 2024',
      'daysLeft': '45 Hari',
      'type': 'Umum',
      'icon_name': 'account_balance',
      'description': 'Beasiswa LPDP bertujuan untuk mendukung ketersediaan sumber daya manusia Indonesia yang berpendidikan dan berkualitas tinggi serta memiliki jiwa kepemimpinan.',
      'requirements': '1. Warga Negara Indonesia.\n2. Lulusan S1/S2 Perguruan Tinggi terakreditasi.\n3. Memenuhi batas usia maksimal pendaftaran.\n4. Memiliki sertifikat kemampuan bahasa inggris resmi.',
      'link': 'https://lpdp.kemenkeu.go.id',
    },
    {
      'id': 3,
      'name': 'Djarum Beasiswa Plus',
      'host': 'Djarum Foundation',
      'country': 'Indonesia',
      'tags': ['S1 Semester 4', 'Dalam Negeri', 'Pembiayaan Parsial'],
      'startDate': '1 Sep 2024',
      'endDate': '30 Sep 2024',
      'daysLeft': 'Bulan Depan',
      'type': 'Prestasi',
      'icon_name': 'business',
      'description': 'Djarum Beasiswa Plus adalah beasiswa prestasi yang memberikan bantuan biaya hidup serta pembekalan soft skills bagi mahasiswa aktif semester 4.',
      'requirements': '1. Mahasiswa S1 semester 4.\n2. IPK minimum 3.00 pada semester 3.\n3. Aktif berorganisasi.\n4. Tidak sedang menerima beasiswa lain.',
      'link': 'https://djarumbeasiswaplus.org',
    },
    {
      'id': 4,
      'name': 'Beasiswa Bank Indonesia',
      'host': 'Bank Indonesia',
      'country': 'Indonesia',
      'tags': ['S1 Reguler', 'Dalam Negeri', 'Pembiayaan Parsial'],
      'startDate': '5 Ags 2024',
      'endDate': '25 Ags 2024',
      'daysLeft': '20 Hari',
      'type': 'Umum',
      'icon_name': 'account_balance',
      'description': 'Program beasiswa dari Bank Indonesia ditujukan bagi mahasiswa jenjang sarjana sebagai bentuk kepedulian BI terhadap pengembangan pendidikan nasional.',
      'requirements': '1. Mahasiswa aktif reguler S1.\n2. Sekurang-kurangnya telah menyelesaikan 40 SKS.\n3. IPK minimal 3.00.\n4. Berasal dari keluarga kurang mampu secara ekonomi.',
      'link': 'https://generasibaruindonesia.com',
    }
  ];

  ScholarshipProvider() {
    loadScholarships();
  }

  /// Memetakan nama ikon ke objek IconData.
  static IconData parseIcon(String? iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school;
      case 'business':
        return Icons.business;
      case 'account_balance':
        return Icons.account_balance;
      default:
        return Icons.school;
    }
  }

  /// Memuat daftar beasiswa dari database.
  Future<void> loadScholarships() async {
    _isLoading = true;
    notifyListeners();

    // Muat dari SharedPreferences terlebih dahulu
    await _loadFromLocal();

    // Jika Supabase aktif, coba sinkronkan data online
    if (SupabaseConfig.isConfigured) {
      try {
        final client = Supabase.instance.client;
        final List<dynamic> response = await client
            .from('beasiswa')
            .select()
            .order('created_at', ascending: false);

        if (response.isNotEmpty) {
          _scholarships = response.map((item) {
            // Mapping dari Supabase snake_case ke camelCase aplikasi
            return {
              'id': item['id'],
              'name': item['name'],
              'host': item['host'],
              'country': item['country'],
              'tags': List<String>.from(item['tags'] ?? []),
              'startDate': item['start_date'],
              'endDate': item['end_date'],
              'daysLeft': item['days_left'],
              'type': item['type'],
              'icon_name': item['icon_name'] ?? 'school',
              'icon': parseIcon(item['icon_name']),
              'description': item['description'] ?? '',
              'requirements': item['requirements'] ?? '',
              'link': item['link'] ?? '',
              'logoPenyelenggara': item['logo_penyelenggara'] ?? '',
              'fotoUtama': item['foto_utama'] ?? '',
            };
          }).toList();

          await _saveToLocal();
        }
      } catch (e) {
        debugPrint('Gagal memuat beasiswa dari Supabase: $e. Menggunakan data lokal.');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFromLocal() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final String? jsonStr = sp.getString(_spKey);

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        _scholarships = decoded.map((item) {
          final map = Map<String, dynamic>.from(item);
          // Tambahkan instance IconData untuk UI
          map['icon'] = parseIcon(map['icon_name']);
          return map;
        }).toList();
      } else {
        // Jika kosong, pakai seedData awal
        _scholarships = List<Map<String, dynamic>>.from(_seedData);
        for (var item in _scholarships) {
          item['icon'] = parseIcon(item['icon_name']);
        }
        await _saveToLocal();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal membaca beasiswa lokal: $e');
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final sp = await SharedPreferences.getInstance();
      // Bersihkan instance IconData sebelum diconvert ke JSON (karena IconData tidak serializeable)
      final serializableList = _scholarships.map((item) {
        final copy = Map<String, dynamic>.from(item);
        copy.remove('icon'); // Hapus objek IconData sebelum JSON Encode
        return copy;
      }).toList();

      await sp.setString(_spKey, jsonEncode(serializableList));
    } catch (e) {
      debugPrint('Gagal menyimpan beasiswa lokal: $e');
    }
  }

  /// Menambah beasiswa baru.
  Future<void> addScholarship(Map<String, dynamic> data) async {
    final int tempId = DateTime.now().millisecondsSinceEpoch;
    final Map<String, dynamic> newItem = {
      'id': tempId,
      'name': data['name'],
      'host': data['host'] ?? 'Penyelenggara',
      'country': data['country'] ?? 'Indonesia',
      'tags': List<String>.from(data['tags'] ?? []),
      'startDate': data['startDate'],
      'endDate': data['endDate'],
      'daysLeft': data['daysLeft'] ?? 'Aktif',
      'type': data['type'],
      'icon_name': data['icon_name'] ?? 'school',
      'icon': parseIcon(data['icon_name']),
      'description': data['description'] ?? '',
      'requirements': data['requirements'] ?? '',
      'link': data['link'] ?? '',
      'logoPenyelenggara': data['logoPenyelenggara'] ?? '',
      'fotoUtama': data['fotoUtama'] ?? '',
    };

    // Tambahkan secara lokal terlebih dahulu
    _scholarships.insert(0, newItem);
    notifyListeners();
    await _saveToLocal();

    // Sinkronkan ke Supabase jika aktif
    if (SupabaseConfig.isConfigured) {
      try {
        final client = Supabase.instance.client;
        final response = await client.from('beasiswa').insert({
          'name': newItem['name'],
          'host': newItem['host'],
          'country': newItem['country'],
          'tags': newItem['tags'],
          'start_date': newItem['startDate'],
          'end_date': newItem['endDate'],
          'days_left': newItem['daysLeft'],
          'type': newItem['type'],
          'icon_name': newItem['icon_name'],
          'description': newItem['description'],
          'requirements': newItem['requirements'],
          'link': newItem['link'],
          'logo_penyelenggara': newItem['logoPenyelenggara'],
          'foto_utama': newItem['fotoUtama'],
        }).select();

        if (response.isNotEmpty) {
          // Perbarui ID lokal dengan ID asli dari Supabase database
          newItem['id'] = response.first['id'];
          await _saveToLocal();
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Gagal menyimpan beasiswa baru ke Supabase: $e');
      }
    }
  }

  /// Memperbarui beasiswa yang ada.
  Future<void> updateScholarship(dynamic id, Map<String, dynamic> data) async {
    final index = _scholarships.indexWhere((item) => item['id'] == id);
    if (index == -1) return;

    final updatedItem = {
      'id': id,
      'name': data['name'],
      'host': data['host'] ?? _scholarships[index]['host'],
      'country': data['country'] ?? _scholarships[index]['country'],
      'tags': List<String>.from(data['tags'] ?? _scholarships[index]['tags']),
      'startDate': data['startDate'],
      'endDate': data['endDate'],
      'daysLeft': data['daysLeft'] ?? _scholarships[index]['daysLeft'],
      'type': data['type'],
      'icon_name': data['icon_name'] ?? _scholarships[index]['icon_name'] ?? 'school',
      'icon': parseIcon(data['icon_name'] ?? _scholarships[index]['icon_name']),
      'description': data['description'] ?? _scholarships[index]['description'],
      'requirements': data['requirements'] ?? _scholarships[index]['requirements'],
      'link': data['link'] ?? _scholarships[index]['link'],
      'logoPenyelenggara': data['logoPenyelenggara'] ?? _scholarships[index]['logoPenyelenggara'] ?? '',
      'fotoUtama': data['fotoUtama'] ?? _scholarships[index]['fotoUtama'] ?? '',
    };

    _scholarships[index] = updatedItem;
    notifyListeners();
    await _saveToLocal();

    // Sinkronkan ke Supabase jika aktif
    if (SupabaseConfig.isConfigured) {
      try {
        final client = Supabase.instance.client;
        await client.from('beasiswa').update({
          'name': updatedItem['name'],
          'host': updatedItem['host'],
          'country': updatedItem['country'],
          'tags': updatedItem['tags'],
          'start_date': updatedItem['startDate'],
          'end_date': updatedItem['endDate'],
          'days_left': updatedItem['daysLeft'],
          'type': updatedItem['type'],
          'icon_name': updatedItem['icon_name'],
          'description': updatedItem['description'],
          'requirements': updatedItem['requirements'],
          'link': updatedItem['link'],
          'logo_penyelenggara': updatedItem['logoPenyelenggara'],
          'foto_utama': updatedItem['fotoUtama'],
        }).eq('id', id);
        debugPrint('Beasiswa berhasil diperbarui di Supabase.');
      } catch (e) {
        debugPrint('Gagal memperbarui beasiswa di Supabase: $e');
      }
    }
  }

  /// Menghapus beasiswa.
  Future<void> deleteScholarship(dynamic id) async {
    _scholarships.removeWhere((item) => item['id'] == id);
    notifyListeners();
    await _saveToLocal();

    // Hapus di Supabase jika aktif
    if (SupabaseConfig.isConfigured) {
      try {
        final client = Supabase.instance.client;
        await client.from('beasiswa').delete().eq('id', id);
        debugPrint('Beasiswa berhasil dihapus dari Supabase.');
      } catch (e) {
        debugPrint('Gagal menghapus beasiswa dari Supabase: $e');
      }
    }
  }

  /// Mengunggah gambar beasiswa (logo/banner) langsung ke Supabase Storage bucket gambar_beasiswa
  Future<String?> unggahGambarBeasiswa(Uint8List dataByte, String tipe, String ekstensi) async {
    if (!SupabaseConfig.isConfigured) return '';
    try {
      final client = Supabase.instance.client;
      final namaFile = '${tipe}_${DateTime.now().millisecondsSinceEpoch}.$ekstensi';
      final pathTujuan = 'beasiswa/$namaFile';

      await client.storage.from('gambar_beasiswa').uploadBinary(pathTujuan, dataByte);
      final urlPublik = client.storage.from('gambar_beasiswa').getPublicUrl(pathTujuan);
      return urlPublik;
    } catch (e) {
      debugPrint('Gagal mengunggah gambar beasiswa ke Supabase: $e');
      return null;
    }
  }

  /// Menghapus gambar beasiswa (logo/banner) dari Supabase Storage, database, dan state lokal.
  Future<void> hapusGambarBeasiswa(dynamic id, String tipeGambar, String urlGambar) async {
    // 1. Hapus dari Supabase Storage jika ada URL online
    if (SupabaseConfig.isConfigured && urlGambar.isNotEmpty && urlGambar.startsWith('http')) {
      try {
        final client = Supabase.instance.client;
        final uri = Uri.parse(urlGambar);
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 2) {
          final tipeSegment = pathSegments[pathSegments.length - 2];
          final fileSegment = pathSegments[pathSegments.length - 1];
          final pathFile = '$tipeSegment/$fileSegment';
          
          await client.storage.from('gambar_beasiswa').remove([pathFile]);
        }
      } catch (e) {
        debugPrint('Gagal menghapus file gambar beasiswa dari storage: $e');
      }
    }

    // 2. Perbarui kolom database menjadi null di Supabase
    if (SupabaseConfig.isConfigured) {
      try {
        final client = Supabase.instance.client;
        final namaKolom = tipeGambar == 'logo' ? 'logo_penyelenggara' : 'foto_utama';
        await client.from('beasiswa').update({
          namaKolom: null,
        }).eq('id', id);
        debugPrint('Gambar beasiswa di database berhasil dinullkan.');
      } catch (e) {
        debugPrint('Gagal men-null-kan gambar beasiswa di database: $e');
      }
    }

    // 3. Perbarui state lokal
    final index = _scholarships.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      if (tipeGambar == 'logo') {
        _scholarships[index]['logoPenyelenggara'] = '';
      } else {
        _scholarships[index]['fotoUtama'] = '';
      }
      notifyListeners();
      await _saveToLocal();
    }
  }
}
