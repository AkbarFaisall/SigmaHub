// File: lib/profile/crop_image_screen.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../sigma_theme.dart';

class CropImageScreen extends StatefulWidget {
  final Uint8List imageBytes;
  const CropImageScreen({super.key, required this.imageBytes});

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  final TransformationController _transformationController = TransformationController();
  bool _isLoading = false;

  Future<void> _prosesPotongGambar() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tunggu hingga frame render stabil
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Temukan render object dari RepaintBoundary
      final RenderRepaintBoundary boundary = 
          _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // Tangkap gambar dengan pixel ratio tinggi untuk kualitas maksimal
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final Uint8List croppedBytes = byteData.buffer.asUint8List();
        if (mounted) {
          Navigator.pop(context, croppedBytes);
        }
      } else {
        throw Exception('Gagal membaca data byte gambar');
      }
    } catch (e) {
      debugPrint('Terjadi kesalahan saat memotong gambar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memotong gambar. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Atur Area Foto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Area Pemotongan Foto
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Latar Belakang Kotak Panduan
                  Container(
                    width: 304,
                    height: 304,
                    decoration: const BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Area Tangkapan Gambar (100% Terang & Jelas)
                  RepaintBoundary(
                    key: _repaintKey,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          boundaryMargin: const EdgeInsets.all(150),
                          minScale: 0.5,
                          maxScale: 5.0,
                          child: Image.memory(
                            widget.imageBytes,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Overlay Lingkaran Panduan Putih Bersih (Tanpa Redup/Bayangan)
                  IgnorePointer(
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Teks bantuan panduan gestur (diletakkan di luar area crop, menggunakan bahasa formal)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Rentangkan dua jari untuk memperbesar • Geser untuk mengatur posisi',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),

          // Tombol Kontrol Bawah
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WarnaSigma.emas,
                      foregroundColor: WarnaSigma.utama,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _prosesPotongGambar,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: WarnaSigma.utama,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Potong & Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
