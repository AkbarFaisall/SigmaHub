// File: lib/supabase_config.dart

class SupabaseConfig {
  /// URL Proyek Supabase Anda.
  /// Isi dengan URL dari dasbor Supabase Anda (Settings -> API -> Project URL).
  /// Contoh: 'https://yourprojectid.supabase.co'
  static const String url = 'https://siajumqcylygycplutdk.supabase.co';

  /// Anon Key Proyek Supabase Anda.
  /// Isi dengan Anon Key dari dasbor Supabase Anda (Settings -> API -> Project API keys -> anon public).
  static const String anonKey = 'sb_publishable_1Evq--pW0sC1pWajagmC-w_vUL-UvKj';

  /// Memeriksa apakah konfigurasi Supabase sudah terisi dan valid.
  static bool get isConfigured {
    return url.isNotEmpty && anonKey.isNotEmpty && url.startsWith('http');
  }
}