# 🚀 Aplikasi SigmaHub

Repositori ini berisi *source code* untuk aplikasi SigmaHub. Ikuti panduan singkat di bawah ini untuk mengunduh dan menjalankan aplikasi ini di laptop/komputer masing-masing.

## 🛠️ 1. Prasyarat Sistem (Prerequisites)
Sebelum mulai, pastikan perangkatmu sudah terinstal:
* **Flutter SDK** (Versi 3.0.0 ke atas)
* **VS Code** (Sangat disarankan, lengkap dengan ekstensi Flutter & Dart) atau Android Studio.
* **Emulator Android** atau **HP Android Fisik** (pastikan *Developer Options* & *USB Debugging* sudah menyala).

## 📥 2. Langkah-Langkah Menjalankan Aplikasi

**Langkah A: Clone Repositori**
Buka terminal (Command Prompt / PowerShell), lalu ketik:
`git clone https://github.com/AkbarFaisall/SigmaHub`
*(Catatan: Sesuaikan URL di atas dengan link repository GitHub yang benar).*

**Langkah B: Masuk ke Folder Proyek**
Buka folder hasil *clone* tersebut di VS Code. Pastikan kamu membuka folder `sigma_gravity_app` sebagai folder utama (root).

**Langkah C: Unduh Dependensi**
Buka terminal di dalam VS Code, lalu jalankan perintah ini untuk mengunduh semua *package* pendukung:
`flutter pub get`

**Langkah D: Cek Kesehatan Sistem**
Untuk memastikan tidak ada sistem yang bermasalah, jalankan:
`flutter doctor`
*(Pastikan kategori Android Toolchain dan VS Code bercentang hijau).*

**Langkah E: Jalankan Aplikasi**
Hubungkan HP atau nyalakan Emulator. Pastikan perangkatmu terbaca di pojok kanan bawah VS Code. Lalu ketik perintah ini di terminal:
`flutter run`

## 🗄️ 3. Catatan Penting Database (Supabase)
Konfigurasi *database* Supabase saat ini sudah tertanam (*hardcoded*) di dalam file `lib/supabase_config.dart`. 
* **tidak perlu** *setup database* baru. Saat aplikasi dijalankan, kamu akan otomatis terhubung ke *database* utama proyek ini.
* *Warning:* Pastikan tidak mengubah nilai `url` dan `anonKey` pada file tersebut kecuali kamu ingin menyambungkannya ke *database* Supabase milikmu sendiri untuk keperluan *testing* terpisah.
