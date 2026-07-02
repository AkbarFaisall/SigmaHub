// File: lib/sigma_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WarnaSigma {
  static const Color utama = Color(0xFF004900);
  static const Color teksUtama = Color(0xFFFFFFFF);
  static const Color wadahUtama = Color(0xFF006400);
  
  static const Color sekunder = Color(0xFF016E21);
  static const Color latar = Color(0xFFF9F9FF);
  static const Color teksLatar = Color(0xFF151C27);
  
  static const Color permukaan = Color(0xFFFFFFFF);
  static const Color teksPermukaan = Color(0xFF151C27);
  static const Color garisTepi = Color(0xFF707A6A);
  static const Color peringatan = Color(0xFFBA1A1A);
  
  // Warna aksen kuning/emas untuk badge
  static const Color emas = Color(0xFFFFE16D);
}

ThemeData buatTemaSigma() {
  final temaDasar = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: WarnaSigma.utama,
      onPrimary: WarnaSigma.teksUtama,
      secondary: WarnaSigma.sekunder,
      background: WarnaSigma.latar,
      surface: WarnaSigma.permukaan,
      error: WarnaSigma.peringatan,
    ),
    scaffoldBackgroundColor: WarnaSigma.latar,
  );

  return temaDasar.copyWith(
    textTheme: GoogleFonts.interTextTheme(temaDasar.textTheme).copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: WarnaSigma.utama),
      headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: WarnaSigma.teksPermukaan),
      titleMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: WarnaSigma.teksPermukaan),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: WarnaSigma.teksPermukaan),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: WarnaSigma.teksPermukaan),
    ),
  );
}