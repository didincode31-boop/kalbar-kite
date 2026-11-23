# Mengaktifkan database Supabase Kalbar Kite

Aplikasi sudah memiliki koneksi REST untuk tabel `blood_posts`, antrean offline, dan tarik-untuk-refresh. APK hanya akan benar-benar tersambung setelah URL project dan anon/publishable key dimasukkan ke GitHub Actions.

## 1. Siapkan tabel dan izin database

1. Buka dashboard project Supabase.
2. Masuk ke **SQL Editor** lalu pilih **New query**.
3. Buka file `supabase/schema.sql` di repository Kalbar Kite, salin seluruh isinya, tempel ke SQL Editor, lalu tekan **Run**.
4. Pastikan query selesai tanpa error. Jangan gunakan service_role key di aplikasi.

## 2. Tambahkan dua GitHub Actions secrets

Di repository GitHub **DidinCode/Kalbar Kite**:

1. Buka **Settings**.
2. Pilih **Secrets and variables** → **Actions**.
3. Tekan **New repository secret**.
4. Tambahkan:
   - Name: `SUPABASE_URL` — Value: Project URL dari Supabase → Project Settings → API.
   - Name: `SUPABASE_ANON_KEY` — Value: anon / publishable key dari halaman API yang sama.
5. Simpan keduanya.

Gunakan hanya anon/publishable key. Jangan pernah memasukkan `service_role` key ke APK atau GitHub Actions build variable yang diteruskan ke aplikasi.

## 3. Buat APK baru

Buka tab **Actions** di GitHub, pilih workflow **Build Kalbar Kite APK**, lalu tekan **Run workflow**. Setelah status hijau, unduh artifact **Kalbar Kite-APK** dan ekstrak file APK.

## Cara kerja data donor

- Saat online, formulir dikirim ke Supabase.
- Saat offline atau koneksi gagal, formulir tetap disimpan di perangkat dan masuk antrean sinkronisasi.
- Buka halaman Donor darah lalu tarik ke bawah untuk mencoba sinkronisasi ulang dan memuat daftar.
- Pendonor yang mencentang persetujuan tampil di daftar akan dipublikasikan. Permintaan darah tetap berstatus pending agar ditinjau terlebih dahulu.
- Data yang disimpan lokal di perangkat lama tidak otomatis masuk ke database sampai aplikasi melakukan sinkronisasi ulang saat koneksi tersedia.

## Privasi

Nomor telepon pendonor hanya boleh dipublikasikan jika pendonor mencentang persetujuan tampil di daftar. Jangan mengunggah data orang lain tanpa izin.
