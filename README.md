# Kalbar Kite

Aplikasi Flutter Android untuk budaya, informasi, aktivitas warga, dan koordinasi donor darah di Kalimantan Barat.

## Build APK

GitHub Actions workflow **Build Kalbar Kite APK** membangun APK Android. Buka tab **Actions**, pilih workflow tersebut, jalankan **Run workflow**, lalu unduh artifact **Kalbar-Kite-APK** setelah proses berhasil.

## Firebase setup

Project menggunakan Firebase Authentication (Email/Password) dan Cloud Firestore.

1. Buka Firebase Console project `kalbarku`.
2. Di **Authentication → Sign-in method**, aktifkan **Email/Password** dan **Google**.
3. Di pengaturan aplikasi Android Firebase, pastikan package name `com.example.kalbarku` cocok dengan aplikasi yang dibangun.
4. Tambahkan SHA-1 dari signing certificate APK. Workflow menampilkan hasil `signingReport` di log Actions.
5. Setelah Google aktif dan SHA-1 ditambahkan, unduh ulang `google-services.json` dari Project settings → Your apps, lalu ganti file `google-services.json` di repository. File baru harus memuat OAuth client, bukan `oauth_client: []`.
6. Di **Firestore Database → Rules**, salin isi file `firestore.rules` dari repository dan tekan **Publish**.
7. Collection `follows` dibuat otomatis oleh Firestore saat pengguna pertama kali menekan Ikuti. Jangan membuat collection atau dokumen Follow manual.
8. Balasan/reaksi story menggunakan satu dokumen per UID per story agar satu akun hanya dapat mengirim satu balasan atau reaksi pada story yang sama.
9. Profil publik disimpan di `public_profiles`; data privat akun disimpan di `profiles`.

### Follow

Dokumen Follow memakai ID deterministik `followerUid_followingUid` dan field `followerUid`, `followingUid`, serta `createdAt`. Kode aplikasi dan Firestore Rules harus memakai nama field dan format ID yang sama.

### Foto profil, banner, dan thumbnail

Aplikasi saat ini mengunggah gambar melalui Cloudinary, bukan Firebase Storage. Konfigurasi cloud name dan unsigned upload preset berada di bagian konfigurasi Cloudinary pada `lib/main.dart`. Jangan memasukkan API secret Cloudinary ke aplikasi. Firebase Storage Rules di `storage.rules` hanya diperlukan jika aplikasi kelak dipindahkan untuk mengunggah file ke Firebase Storage.

## Profil

Profil mendukung nama, username, bio, foto profil, dan banner. Bio serta URL gambar disimpan pada dokumen `profiles/{uid}` dan disinkronkan ke `public_profiles/{uid}` agar dapat dibaca pengguna lain yang sudah login.

## Keamanan

- Jangan gunakan aturan Firestore terbuka seperti `allow read, write: if true`.
- Jangan commit service-role key, private key, password, atau keystore.
- Nomor telepon dan email tetap berada di dokumen privat `profiles`, bukan profil publik.
