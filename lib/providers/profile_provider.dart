// File: lib/providers/profile_provider.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

class ProfileProvider with ChangeNotifier {
  String _email = 'scholar@sigma.edu';
  String _name = 'Muhammad Akbar Faisal';
  String _university = 'UIN Alauddin';
  String _major = 'Teknik Informatika';
  String _phone = '+62 812 3456 7890';
  String _avatarUrl = '';
  bool _isLoading = false;

  String get email => _email;
  String get name => _name;
  String get university => _university;
  String get major => _major;
  String get phone => _phone;
  String get avatarUrl => _avatarUrl;
  bool get isLoading => _isLoading;

  // Key untuk SharedPreferences
  String get _spKeyPrefix => 'profile_${_email}_';

  ProfileProvider() {
    _loadFromLocal();
  }

  /// Menyetel email pengguna saat login dan memuat data profil yang sesuai.
  Future<void> setProfileEmail(String userEmail) async {
    _email = userEmail.trim().toLowerCase();
    notifyListeners();
    await loadProfile();
  }

  /// Memuat profil dari SharedPreferences (lokal) dan Supabase (jika dikonfigurasi).
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    // 1. Muat dari SharedPreferences terlebih dahulu agar cepat
    await _loadFromLocal();

    // 2. Jika Supabase aktif, coba muat dari database online
    if (SupabaseConfig.isConfigured) {
      try {
        final client = Supabase.instance.client;
        final response = await client
            .from('profiles')
            .select()
            .eq('email', _email)
            .maybeSingle();

        if (response != null) {
          _name = response['name'] ?? _name;
          _university = response['university'] ?? _university;
          _major = response['major'] ?? _major;
          _phone = response['phone'] ?? _phone;
          _avatarUrl = response['avatar_url'] ?? '';
          
          // Sinkronkan kembali ke SharedPreferences lokal
          await _saveToLocal();
        } else {
          // Jika belum ada di Supabase, buat entri awal menggunakan data lokal saat ini
          await syncToSupabase();
        }
      } catch (e) {
        debugPrint('Gagal mengambil data profil dari Supabase: $e. Menggunakan data lokal.');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Memuat data dari penyimpanan lokal SharedPreferences.
  Future<void> _loadFromLocal() async {
    try {
      final sp = await SharedPreferences.getInstance();
      _name = sp.getString('${_spKeyPrefix}name') ?? 'Muhammad Akbar Faisal';
      _university = sp.getString('${_spKeyPrefix}university') ?? 'UIN Alauddin';
      _major = sp.getString('${_spKeyPrefix}major') ?? 'Teknik Informatika';
      _phone = sp.getString('${_spKeyPrefix}phone') ?? '+62 812 3456 7890';
      _avatarUrl = sp.getString('${_spKeyPrefix}avatar_url') ?? '';
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal membaca data profil lokal: $e');
    }
  }

  /// Menyimpan data ke penyimpanan lokal SharedPreferences.
  Future<void> _saveToLocal() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('${_spKeyPrefix}name', _name);
      await sp.setString('${_spKeyPrefix}university', _university);
      await sp.setString('${_spKeyPrefix}major', _major);
      await sp.setString('${_spKeyPrefix}phone', _phone);
      await sp.setString('${_spKeyPrefix}avatar_url', _avatarUrl);
    } catch (e) {
      debugPrint('Gagal menyimpan data profil lokal: $e');
    }
  }

  /// Memperbarui informasi profil.
  Future<void> updateProfile({
    required String name,
    required String university,
    required String major,
    required String phone,
    String? avatarUrl,
  }) async {
    _name = name;
    _university = university;
    _major = major;
    _phone = phone;
    if (avatarUrl != null) {
      _avatarUrl = avatarUrl;
    }
    notifyListeners();

    // Simpan ke lokal
    await _saveToLocal();

    // Sinkronkan ke Supabase
    await syncToSupabase();
  }

  /// Sinkronisasi paksa ke Supabase.
  Future<void> syncToSupabase() async {
    if (!SupabaseConfig.isConfigured) return;

    try {
      final client = Supabase.instance.client;
      await client.from('profiles').upsert({
        'email': _email,
        'name': _name,
        'university': _university,
        'major': _major,
        'phone': _phone,
        'avatar_url': _avatarUrl.isEmpty ? null : _avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint('Profil berhasil disinkronkan ke Supabase.');
    } catch (e) {
      debugPrint('Gagal menyinkronkan profil ke Supabase: $e');
    }
  }

  /// Menghapus foto profil dari Supabase Storage dan men-null-kan kolom avatar_url di database.
  Future<void> hapusFotoProfil() async {
    try {
      // Jika Supabase aktif, hapus dari storage online
      if (SupabaseConfig.isConfigured && _avatarUrl.isNotEmpty && _avatarUrl.startsWith('http')) {
        try {
          final client = Supabase.instance.client;
          // Ambil path berkas relatif dari URL publik
          final uri = Uri.parse(_avatarUrl);
          final pathSegments = uri.pathSegments;
          if (pathSegments.length >= 2) {
            final emailSegment = pathSegments[pathSegments.length - 2];
            final filenameSegment = pathSegments[pathSegments.length - 1];
            final pathFile = '$emailSegment/$filenameSegment';
            
            // Hapus berkas gambar secara fisik di storage
            await client.storage.from('avatars').remove([pathFile]);
          }
        } catch (e) {
          debugPrint('Gagal menghapus file gambar di storage: $e');
        }
      }
      
      // Setel URL kosong, simpan lokal, dan update database Supabase
      _avatarUrl = '';
      notifyListeners();
      
      await _saveToLocal();
      await syncToSupabase();
    } catch (e) {
      debugPrint('Gagal menghapus foto profil: $e');
      rethrow;
    }
  }

  /// Mengunggah foto profil ke Supabase Storage bucket 'avatars'
  Future<String?> unggahFotoProfil(File fileGambar) async {
    if (!SupabaseConfig.isConfigured) return null;

    try {
      final client = Supabase.instance.client;
      
      // Ambil ekstensi asli berkas
      final ekstensi = fileGambar.path.split('.').last;
      // Buat nama berkas unik menggunakan timestamp
      final namaFile = '${DateTime.now().millisecondsSinceEpoch}.$ekstensi';
      
      // Tentukan path tujuan unggahan di dalam bucket avatars
      final pathTujuan = '$_email/$namaFile';

      // Unggah berkas gambar ke bucket 'avatars'
      await client.storage.from('avatars').upload(pathTujuan, fileGambar);

      // Dapatkan URL publik gambar
      final urlPublik = client.storage.from('avatars').getPublicUrl(pathTujuan);
      
      // Perbarui tautan foto profil di state lokal, SharedPreferences, dan Supabase
      _avatarUrl = urlPublik;
      notifyListeners();
      
      await _saveToLocal();
      await syncToSupabase();
      
      return urlPublik;
    } catch (e) {
      debugPrint('Terjadi kesalahan saat mengunggah foto profil: $e');
      rethrow;
    }
  }

  /// Mengunggah bytes foto profil langsung (lebih fleksibel untuk Web, Windows, Android)
  /// Mendukung penyimpanan Base64 lokal jika Supabase tidak aktif atau gagal.
  Future<String?> unggahFotoProfilBytes(Uint8List bytes, String ekstensi) async {
    if (!SupabaseConfig.isConfigured) {
      final base64String = base64Encode(bytes);
      _avatarUrl = 'data:image/png;base64,$base64String';
      notifyListeners();
      await _saveToLocal();
      return _avatarUrl;
    }

    try {
      final client = Supabase.instance.client;
      final namaFile = '${DateTime.now().millisecondsSinceEpoch}.$ekstensi';
      final pathTujuan = '$_email/$namaFile';

      // Unggah menggunakan binary
      await client.storage.from('avatars').uploadBinary(pathTujuan, bytes);

      final urlPublik = client.storage.from('avatars').getPublicUrl(pathTujuan);
      
      _avatarUrl = urlPublik;
      notifyListeners();
      
      await _saveToLocal();
      await syncToSupabase();
      
      return urlPublik;
    } catch (e) {
      debugPrint('Gagal mengunggah foto ke Supabase: $e. Menyimpan offline base64.');
      final base64String = base64Encode(bytes);
      _avatarUrl = 'data:image/png;base64,$base64String';
      notifyListeners();
      await _saveToLocal();
      return _avatarUrl;
    }
  }
}
