// File: lib/providers/bookmark_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; 
import '../supabase_config.dart';

class BookmarkProvider with ChangeNotifier {
  List<Map<String, dynamic>> _bookmarkedItems = [];
  String _userEmail = 'scholar@sigma.edu';
  bool _isLoading = false;

  List<Map<String, dynamic>> get bookmarkedItems => _bookmarkedItems;
  bool get isLoading => _isLoading;

  String get _spKey => 'sigma_bookmarks_v2_$_userEmail';

  BookmarkProvider() {
    _loadFromLocal();
  }

  /// Menyetel email pengguna aktif saat login dan memuat bookmarknya.
  Future<void> setUserEmail(String email) async {
    _userEmail = email.trim().toLowerCase();
    notifyListeners();
    await loadBookmarks();
  }

  /// Memeriksa apakah beasiswa ditandai sebagai bookmark.
  bool isBookmarked(String name) {
    return _bookmarkedItems.any((item) => item['name'] == name);
  }

  /// Memuat bookmark dari penyimpanan.
  Future<void> loadBookmarks() async {
    _isLoading = true;
    notifyListeners();

    // 1. Muat dari SharedPreferences terlebih dahulu
    await _loadFromLocal();

    // 2. Sinkronkan dengan Supabase jika aktif
    if (SupabaseConfig.isConfigured) {
      try {
        final client = Supabase.instance.client;
        final response = await client
            .from('bookmarks')
            .select('beasiswa_id, beasiswa(*)')
            .eq('user_email', _userEmail);

        if (response.isNotEmpty) {
          final List<Map<String, dynamic>> items = [];
          for (var row in response) {
            final beasiswa = row['beasiswa'];
            if (beasiswa != null) {
              items.add({
                'id': beasiswa['id'],
                'name': beasiswa['name'],
                'host': beasiswa['host'],
                'country': beasiswa['country'],
                'tags': List<String>.from(beasiswa['tags'] ?? []),
                'startDate': beasiswa['start_date'],
                'endDate': beasiswa['end_date'],
                'daysLeft': beasiswa['days_left'],
                'type': beasiswa['type'],
                'icon_name': beasiswa['icon_name'] ?? 'school',
                'description': beasiswa['description'] ?? '',
                'requirements': beasiswa['requirements'] ?? '',
                'link': beasiswa['link'] ?? '',
              });
            }
          }

          if (items.isNotEmpty) {
            _bookmarkedItems = items;
            _syncToLegacyGlobal();
            await _saveToLocal();
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint('Gagal memuat bookmark dari Supabase: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFromLocal() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final List<String>? ids = sp.getStringList(_spKey);

      // Sinkronkan ke daftar lokal sementara menggunakan data global jika ada
      if (ids == null) {
        // Fallback mengambil dari legacy BookmarkGlobal jika ada isinya
        if (BookmarkGlobal.daftarSimpanan.isNotEmpty) {
          _bookmarkedItems = List<Map<String, dynamic>>.from(BookmarkGlobal.daftarSimpanan);
          await _saveToLocal();
        }
      } else {
        // Kita simpan bookmark sebagai data json string atau mencocokkan dengan daftar beasiswa
        final List<String> jsonItems = sp.getStringList('${_spKey}_items') ?? [];
        _bookmarkedItems = jsonItems.map((itemStr) {
          final decoded = Map<String, dynamic>.from(jsonDecode(itemStr));
          return decoded;
        }).toList();
      }

      _syncToLegacyGlobal();
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal membaca bookmark lokal: $e');
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final List<String> ids = _bookmarkedItems.map((e) => e['id'].toString()).toList();
      final List<String> jsonItems = _bookmarkedItems.map((e) {
        final copy = Map<String, dynamic>.from(e);
        copy.remove('icon'); // Pastikan tidak meng-encode IconData
        return jsonEncode(copy);
      }).toList();

      await sp.setStringList(_spKey, ids);
      await sp.setStringList('${_spKey}_items', jsonItems);
    } catch (e) {
      debugPrint('Gagal menyimpan bookmark lokal: $e');
    }
  }

  /// Menyelaraskan bookmark lokal dengan kelas legacy BookmarkGlobal agar kompatibel.
  void _syncToLegacyGlobal() {
    BookmarkGlobal.daftarSimpanan.clear();
    BookmarkGlobal.daftarSimpanan.addAll(_bookmarkedItems);
  }

  /// Menambah atau menghapus beasiswa dari bookmark.
  Future<void> toggleBookmark(Map<String, dynamic> item) async {
    final name = item['name'];
    final bool exist = isBookmarked(name);

    if (exist) {
      _bookmarkedItems.removeWhere((e) => e['name'] == name);
    } else {
      // Pastikan membersihkan instansi IconData sebelum disimpan
      final cleanItem = Map<String, dynamic>.from(item);
      cleanItem.remove('icon');
      _bookmarkedItems.add(cleanItem);
    }

    _syncToLegacyGlobal();
    notifyListeners();
    await _saveToLocal();

    // Sinkronisasi ke Supabase jika aktif
    if (SupabaseConfig.isConfigured) {
      try {
        final client = Supabase.instance.client;
        final int beasiswaId = item['id'];

        if (exist) {
          // Hapus dari Supabase
          await client
              .from('bookmarks')
              .delete()
              .eq('user_email', _userEmail)
              .eq('beasiswa_id', beasiswaId);
          debugPrint('Bookmark dihapus dari Supabase.');
        } else {
          // Masukkan ke Supabase
          await client.from('bookmarks').insert({
            'user_email': _userEmail,
            'beasiswa_id': beasiswaId,
          });
          debugPrint('Bookmark ditambahkan ke Supabase.');
        }
      } catch (e) {
        debugPrint('Gagal sinkronisasi bookmark ke Supabase: $e');
      }
    }
  }
}
