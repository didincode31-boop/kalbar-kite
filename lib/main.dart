import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:video_player/video_player.dart';
import 'package:video_compress/video_compress.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

part 'messaging.dart';

const forest = Color(0xFF171717);
const pale = Color(0xFFF0F0F0);
const paper = Color(0xFFFFFFFF);
const ink = Color(0xFF1C1C1E);
const harvestGold = Color(0xFFFFCC00);

// Isi setelah membuat unsigned upload preset di Cloudinary.
const String cloudinaryCloudName = 'nviwtrl2';
const String cloudinaryUploadPreset = 'kalbarku_unsigned';
const int maxImageBytes = 7 * 1024 * 1024;

const List<String> kalbarDistricts = [
  'Kabupaten Sambas','Kabupaten Bengkayang','Kabupaten Landak',
  'Kabupaten Mempawah','Kabupaten Sanggau','Kabupaten Ketapang',
  'Kabupaten Sintang','Kabupaten Kapuas Hulu','Kabupaten Sekadau',
  'Kabupaten Melawi','Kabupaten Kayong Utara','Kabupaten Kubu Raya',
  'Kota Pontianak','Kota Singkawang',
];
const List<String> kalbarHospitals = [
  'RS Umum Bethesda Serukam',
  'RS Umum Daerah Bengkayang',
  'RS Bergerak Badau Kapuas Hulu',
  'RS Umum Daerah dr. A. Diponegoro Putussibau',
  'RS Umum Daerah Semitau',
  'RS Umum Daerah Sultan Muhammad Jamaludin I',
  'RS Bersalin Permata Bunda Ketapang',
  'RS Fatima Ketapang',
  'RS Umum Daerah Dr. Agoesdjam Ketapang',
  'RS Angkatan Udara dr. Mohammad Sutomo',
  'RS Ibu dan Anak Anugrah',
  'RS Tk.II Kartika Husada Kes.Dam XII Tanjungpura',
  'RS Umum Daerah Kubu Raya',
  'RS Umum Daerah Kabupaten Landak',
  'Rumah Sakit Pratama Kabupaten Landak',
  'RS Pratama Batu Buil',
  'RS Umum Citra Husada Nanga Pinoh',
  'RS Umum Daerah Kabupaten Melawi',
  'RS Umum Kasih Bunda Jaya Nanga Pinoh',
  'RS Umum Daerah Dr. Rubini Mempawah',
  'RS Pratama Teluk Keramat',
  'RS Santa Elizabeth',
  'RS Umum Daerah Pemangkat',
  'RS Umum Daerah Sambas',
  'RS Parindu',
  'RS Umum Daerah M. Th. Djaman Sanggau',
  'RS Umum Daerah Temenggung Gergaji',
  'RS Umum Sentra Medika Sanggau',
  'RS Pratama Tamongokng Naga Lantai',
  'RS Umum Daerah Kabupaten Sekadau',
  'RS Ibu dan Anak Bujang Dara Sintang',
  'RS Pratama Serawai',
  'RS Tk. IV 12.07.02 Sintang',
  'RS Umum Anugerah Bunda Jaya',
  'RS Umum Daerah Ade Muhammad Djoen Sintang',
  'RS Umum Sayang Ibu Sintang',
  'RSJ Sudiyanto',
  'RS Anugerah Bunda Khatulistiwa',
  'RS Bersalin Jeumpa Pontianak',
  'RS Bersalin Nabasa Pontianak',
  'RS Bhayangkara Anton Sudjarwo Pontianak',
  'RS Islam Yarsi Pontianak',
  'RS Medika Djaya',
  'RS Mitra Medika Pontianak',
  'RS Pro Medika Pontianak',
  'RS Umum Daerah Dr. Soedarso Pontianak',
  'RS Umum Daerah Pontianak Utara',
  'RS Umum Daerah Sultan Syarif Mohammad Alkadri',
  'RS Umum Kharitas Bhakti',
  'RS Umum St. Antonius Pontianak',
  'RS Universitas Tanjungpura',
  'RSM Pontianak Eye Center',
  'RUMKITAL Rahadi Osman',
  'RS Ibu dan Anak Wempe Singkawang',
  'RS Jiwa Provinsi Kalimantan Barat',
  'RS Kusta Alverno Singkawang',
  'RS Tk. IV Singkawang',
  'RS Umum Daerah Dr. Abdul Aziz Singkawang',
  'RS Umum Harapan Bersama Singkawang',
  'RS Umum Santo Vincentius Singkawang',
  'Rumah Sakit Umum Saadah',
];
const List<Map<String, String>> kalbarDonorLocations = [
  {'name': 'UTD RSUD Pemangkat', 'district': 'Kabupaten Sambas', 'area': 'pemangkat', 'hospital': 'RSUD Pemangkat'},
  {'name': 'UTD RSUD Sambas', 'district': 'Kabupaten Sambas', 'area': 'sambas', 'hospital': 'RSUD Sambas'},
  {'name': 'UTD RSUD Teluk Keramat', 'district': 'Kabupaten Sambas', 'area': 'teluk keramat', 'hospital': 'RSUD Teluk Keramat'},
  {'name': 'UTDRS Dr. Soedarso', 'district': 'Kota Pontianak', 'area': 'pontianak', 'hospital': 'RSUD Dr. Soedarso'},
  {'name': 'UDD PMI Kota Pontianak', 'district': 'Kota Pontianak', 'area': 'pontianak', 'hospital': 'PMI Kota Pontianak'},
  {'name': 'UTD RSUD dr. Abdul Aziz', 'district': 'Kota Singkawang', 'hospital': 'RSUD Dr. Abdul Aziz'},
  {'name': 'UDD PMI Kota Singkawang', 'district': 'Kota Singkawang', 'hospital': 'PMI Kota Singkawang'},
  {'name': 'UDD PMI Kabupaten Mempawah', 'district': 'Kabupaten Mempawah'},
  {'name': 'UTD RSUD Bumi Sebalo', 'district': 'Kabupaten Bengkayang', 'hospital': 'RSUD Bengkayang'},
  {'name': 'UTD PMI Kabupaten Sanggau', 'district': 'Kabupaten Sanggau', 'hospital': 'PMI Kabupaten Sanggau'},
  {'name': 'Unit Pengelola Darah RSUD Sultan Muhammad Jamaludin I', 'district': 'Kabupaten Kayong Utara', 'hospital': 'RSUD Sultan Muhammad Jamaludin I'},
  {'name': 'UTD RSUD dr. Agoesdjam', 'district': 'Kabupaten Ketapang', 'hospital': 'RSUD dr. Agoesdjam'},
  {'name': 'UTDRS RSUD Tuan Besar Syarif Idrus', 'district': 'Kabupaten Kubu Raya', 'hospital': 'RSUD Tuan Besar Syarif Idrus'},
  {'name': 'UPDRS Sekadau', 'district': 'Kabupaten Sekadau', 'hospital': 'RSUD Sekadau'},
  {'name': 'Unit Pengelola Darah Sintang', 'district': 'Kabupaten Sintang'},
];
const List<String> kalbarTribes = ['Melayu', 'Dayak', 'Tionghoa'];

bool _donorLocationMatchesHospital(String unitName, String district, String hospital) {
  final selected = district.trim().toLowerCase();
  final entry = kalbarDonorLocations.cast<Map<String, String>?>().firstWhere(
    (item) => item?['name'] == unitName,
    orElse: () => null,
  );
  if (entry == null || (entry['district'] ?? '').trim().toLowerCase() != selected) return false;
  if (selected == 'kota pontianak') return true;
  String key(String value) => value.toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .replaceFirst(RegExp(r'^(rsud|rs umum daerah|rs|rumah sakit)\s+'), '');
  if (selected == 'kabupaten sambas') {
    final name = key(hospital);
    final area = name.contains('pemangkat')
        ? 'pemangkat'
        : name.contains('teluk keramat')
            ? 'teluk keramat'
            : 'sambas';
    return (entry['area'] ?? '').trim().toLowerCase() == area;
  }
  final linked = key(entry['hospital'] ?? '');
  final selectedHospital = key(hospital);
  return linked.isNotEmpty && (linked == selectedHospital ||
      linked.contains(selectedHospital) || selectedHospital.contains(linked));
}

bool _hospitalBelongsToDistrict(String hospitalName, String districtName) {
  final name = hospitalName.trim().toLowerCase();
  final district = districtName.trim().toLowerCase();
  if (name.isEmpty || district.isEmpty) return false;
  final configuredDistrict = Store.hospitalDistricts[name];
  if (configuredDistrict != null) return configuredDistrict.trim().toLowerCase() == district;
  final keywords = switch (district) {
    'kabupaten sambas' => const ['sambas', 'pemangkat', 'teluk keramat'],
    'kabupaten bengkayang' => const ['bengkayang', 'serukam'],
    'kabupaten landak' => const ['landak', 'ngabang'],
    'kabupaten mempawah' => const ['mempawah', 'rubini'],
    'kabupaten sanggau' => const ['sanggau', 'parindu', 'temenggung gergaji', 'naga lantai'],
    'kabupaten ketapang' => const ['ketapang', 'agoesdjam'],
    'kabupaten sintang' => const ['sintang', 'serawai', 'bujang dara'],
    'kabupaten kapuas hulu' => const ['kapuas hulu', 'badau', 'putussibau', 'semitau'],
    'kabupaten sekadau' => const ['sekadau'],
    'kabupaten melawi' => const ['melawi', 'nanga pinoh', 'batu buil'],
    'kabupaten kayong utara' => const ['kayong utara', 'jamaludin', 'sukadana'],
    'kabupaten kubu raya' => const ['kubu raya', 'rasau jaya'],
    'kota pontianak' => const ['pontianak', 'kartika husada', 'rahadi osman', 'mohammad sutomo'],
    'kota singkawang' => const ['singkawang', 'alverno'],
    _ => const <String>[],
  };
  return keywords.any(name.contains);
}

String _normalizeImageUrl(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return '';
  final uri = Uri.tryParse(value);
  if (uri == null || uri.host.isEmpty) return '';
  if (uri.scheme == 'https') return uri.toString();
  if (uri.scheme == 'http') return uri.replace(scheme: 'https').toString();
  return '';
}

String _firstImageUrl(Map<String, dynamic> data, [List<String> keys = const [
  'imageUrl', 'imagePath', 'photoUrl', 'photoURL', 'image', 'url',
]]) {
  for (final key in keys) {
    final value = data[key];
    if (value is String) {
      final url = _normalizeImageUrl(value);
      if (url.isNotEmpty) return url;
    }
  }
  return '';
}

Future<String> _loadAvatarFromPublicContent(String uid) async {
  if (uid.trim().isEmpty) return '';
  // Older versions kept avatar snapshots on public posts/stories only.
  for (final collection in ['activity_posts', 'stories']) {
    try {
      final snapshot = await _db.collection(collection)
          .where('ownerUid', isEqualTo: uid)
          .limit(30)
          .get().timeout(const Duration(seconds: 7));
      if (snapshot.docs.isEmpty) continue;
      final docs = snapshot.docs.toList()
        ..sort((a, b) {
          final aDate = a.data()['createdAt'];
          final bDate = b.data()['createdAt'];
          final aMillis = aDate is Timestamp ? aDate.millisecondsSinceEpoch : 0;
          final bMillis = bDate is Timestamp ? bDate.millisecondsSinceEpoch : 0;
          return bMillis.compareTo(aMillis);
        });
      for (final doc in docs) {
        final avatar = _firstImageUrl(doc.data(),
            const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl']);
        if (avatar.isNotEmpty) return avatar;
      }
    } catch (_) {}
  }
  return '';
}

Future<Map<String, String>> _loadAvatarsForUsers(Iterable<String> userIds) async {
  final ids = userIds.where((uid) => uid.trim().isNotEmpty).toSet().take(40);
  final result = <String, String>{};
  await Future.wait(ids.map((uid) async {
    try {
      final snapshot = await _db.collection('public_profiles').doc(uid)
          .get().timeout(const Duration(seconds: 7));
      final profile = snapshot.data() ?? <String, dynamic>{};
      var avatar = _firstImageUrl(profile,
          const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl']);
      if (avatar.isEmpty) avatar = await _loadAvatarFromPublicContent(uid);
      if (avatar.isNotEmpty) result[uid] = avatar;
    } catch (_) {}
  }));
  return result;
}

// Satu pemutar global agar audio Al-Qur'an tetap berjalan saat halaman surah ditutup.
final AudioPlayer quranAudioPlayer = AudioPlayer();
// Pemutar terpisah untuk audio intro pada splash setelah login.
final AudioPlayer splashAudioPlayer = AudioPlayer();

String? currentQuranAudioUrl;

// Firebase configuration for the registered Kalbar Kite Android app.
const FirebaseOptions _firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyCTPL-TwkbCj2sHDT-6qPz3_2xa6aj7DQw',
  appId: '1:288065846932:android:6abbce640edc9b3b95be81',
  messagingSenderId: '288065846932',
  projectId: 'kalbarku',
  storageBucket: 'kalbarku.firebasestorage.app',
);

late final FirebaseAuth _auth = FirebaseAuth.instance;
late final FirebaseFirestore _db = FirebaseFirestore.instance;
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
bool _notificationServiceReady = false;
bool _notificationTokenRefreshListenerReady = false;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: _firebaseOptions);
  // Notification payloads are normally displayed by the OS in background.
  // Data-only payloads need a local notification because they have no OS alert.
  if (message.notification == null) {
    final data = message.data;
    final title = (data['title'] ?? data['senderName'] ?? 'Kalbar Kite').toString();
    final body = (data['body'] ?? 'Ada aktivitas baru untukmu.').toString();
    final eventAt = DateTime.tryParse((data['eventAt'] ?? '').toString()) ?? DateTime.now();
    final notificationId = (data['notificationId'] ?? message.messageId ?? '').toString();
    await localNotifications.show(
      notificationId.isNotEmpty ? notificationId.hashCode : DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'kalbar_kite_social', 'Aktivitas sosial',
          channelDescription: 'Chat, pengikut, suka, komentar, dan story',
          importance: Importance.high, priority: Priority.high, playSound: true,
          showWhen: true, when: eventAt.millisecondsSinceEpoch,
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
      payload: jsonEncode(data),
    );
  }
}

Future<void> _initializeNotifications(User user) async {
  try {
    // Pasang handler UI hanya sekali, tetapi sinkronkan token pada setiap login.
    if (!_notificationServiceReady) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      await localNotifications.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
        onDidReceiveNotificationResponse: (response) => _openNotificationData(response.payload),
      );
      const channel = AndroidNotificationChannel(
        'kalbar_kite_updates', 'Notifikasi Kalbar Kite',
        description: 'Pengumuman, berita, dan informasi Kalbar Kite',
        importance: Importance.high,
        playSound: true,
      );
      final androidPlugin = localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(channel);
      const socialChannel = AndroidNotificationChannel(
        'kalbar_kite_social', 'Aktivitas sosial',
        description: 'Chat, pengikut, suka, komentar, dan story',
        importance: Importance.high, playSound: true,
      );
      await androidPlugin?.createNotificationChannel(socialChannel);
      FirebaseMessaging.onMessage.listen(_showForegroundNotification);
      FirebaseMessaging.onMessageOpenedApp.listen((message) => _handleNotificationData(message.data));
      _notificationServiceReady = true;
    }

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true, badge: true, sound: true,
    );
    debugPrint('FCM permission: ${settings.authorizationStatus} untuk UID ${user.uid}');
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      debugPrint('Token FCM tidak disinkronkan karena izin notifikasi belum diberikan.');
      return;
    }

    // Ambil token terbaru setiap login, bukan hanya saat listener pertama dibuat.
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('FCM getToken menghasilkan token kosong.');
    } else {
      await _saveNotificationToken(user.uid, token);
    }

    // Listener global mengambil UID yang sedang login saat token berubah,
    // bukan UID akun pertama yang kebetulan membuka aplikasi.
    if (!_notificationTokenRefreshListenerReady) {
      FirebaseMessaging.instance.onTokenRefresh.listen((value) {
        final currentUid = _auth.currentUser?.uid;
        if (currentUid != null && value.isNotEmpty) {
          unawaited(_saveNotificationToken(currentUid, value));
        }
      }, onError: (Object error) {
        debugPrint('FCM token refresh listener error: $error');
      });
      _notificationTokenRefreshListenerReady = true;
    }

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _handleNotificationData(initial.data);
  } catch (error, stackTrace) {
    debugPrint('Inisialisasi/sinkronisasi FCM gagal: $error');
    debugPrintStack(stackTrace: stackTrace);
    _notificationServiceReady = false;
  }
}

Future<void> _saveNotificationToken(String uid, String token) async {
  try {
    final tokenId = base64Url.encode(utf8.encode(token)).replaceAll('=', '');
    await _db.collection('notification_tokens').doc(tokenId).set({
      'uid': uid,
      'token': token,
      'platform': Platform.isIOS ? 'ios' : 'android',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    debugPrint('FCM token berhasil disimpan untuk UID $uid (doc: $tokenId).');
  } catch (error, stackTrace) {
    debugPrint('Gagal menyimpan token FCM ke Firestore: $error');
    debugPrintStack(stackTrace: stackTrace);
    rethrow;
  }
}

Future<void> _showForegroundNotification(RemoteMessage message) async {
  // Render text immediately. Downloading optional avatars/images first can
  // hold a foreground notification for many seconds on a slow connection.
  final data = message.data;
  final title = message.notification?.title ?? (data['title'] ?? 'Kalbar Kite').toString();
  final body = message.notification?.body ?? (data['body'] ?? 'Ada informasi baru untukmu.').toString();
  final eventAt = DateTime.tryParse((data['eventAt'] ?? '').toString()) ?? DateTime.now();
  final notificationId = (data['notificationId'] ?? message.messageId ?? '').toString();
  final isChatNotification = const {'chat', 'story_reply', 'story_reaction'}.contains(data['type']);

  await localNotifications.show(
    notificationId.isNotEmpty ? notificationId.hashCode : message.hashCode,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        isChatNotification ? 'kalbar_kite_social' : 'kalbar_kite_updates',
        isChatNotification ? 'Pesan chat' : 'Notifikasi Kalbar Kite',
        channelDescription: isChatNotification ? 'Pesan baru di Kalbar Kite' : 'Pengumuman, berita, dan informasi Kalbar Kite',
        importance: Importance.high, priority: Priority.high, playSound: true,
        showWhen: true, when: eventAt.millisecondsSinceEpoch,
      ),
      iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    ),
    payload: jsonEncode(data),
  );
}

void _openNotificationData(String? payload) {
  if (payload == null || payload.isEmpty) return;
  try { _handleNotificationData(Map<String, dynamic>.from(jsonDecode(payload) as Map)); } catch (_) {}
}

void _handleNotificationData(Map<String, dynamic> data) {
  final routeType = (data['routeType'] ?? 'none').toString();
  final routeValue = (data['routeValue'] ?? '').toString();
  if (routeType == 'url' && routeValue.startsWith('https://')) {
    launchUrl(Uri.parse(routeValue), mode: LaunchMode.externalApplication);
  } else if (routeType == 'info') {
    final page = routeValue == 'dashboard'
        ? const HomePage()
        : const InfoPage();
    appNavigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => page));
  } else if (routeType == 'dashboard_info') {
    appNavigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const HomePage()));
  } else if (routeType == 'chat') {
    final peerUid = (data['peerUid'] ?? routeValue).toString();
    if (peerUid.isNotEmpty && peerUid != _auth.currentUser?.uid) {
      appNavigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => ChatThreadPage(peerUid: peerUid)));
    }
  } else if (routeType == 'dashboard') {
    appNavigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const HomePage()));
  }
}


Future<void> _submitBloodPostRemote(Map<String, String> form) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('Silakan masuk untuk mengirim formulir.');
  final isDonor = form['type'] == 'Calon pendonor';
  final donorAvatar = await Store.resolveCurrentAvatar();
  final ref = await _db.collection('blood_posts').add({
    'ownerUid': user.uid, 'ownerEmail': user.email ?? '',
    'post_type': isDonor ? 'donor' : 'request',
    'name': form['name'] ?? '', 'phone': form['phone'] ?? '',
    'blood_type': (form['blood'] ?? '').replaceAll('−', '-'),
    'location': [form['district'], form['hospital']].where((v) => (v ?? '').isNotEmpty).join(' • '),
    'district': form['district'] ?? '', 'hospital': form['hospital'] ?? '',
    'donor_location': form['donorLocation'] ?? '',
    'show_in_list': form['showInDonorList'] == 'true',
    'notes': form['note'] ?? '',
    // Donor yang memilih tampil langsung dipublikasikan.
    // Permintaan darah dan donor privat tetap menunggu admin.
    'status': form['showInDonorList'] == 'true' ? 'approved' : 'pending',
    // Simpan snapshot avatar di posting donor agar kartu tetap punya foto
    // meskipun profil publik lama belum tersinkron.
    'avatarUrl': donorAvatar,
    'createdAt': FieldValue.serverTimestamp(),
  });
  form['cloudId'] = ref.id; form['syncStatus'] = 'synced';
}

Future<List<Map<String, String>>> _loadRemoteBloodPosts() async {
  if (_auth.currentUser == null) return [];

  // Firestore rules allow signed-in users to read approved blood posts.
  // Do not scan the private profiles collection here: members may only read
  // their own profile, and that denied query previously blocked the whole list.
  final snapshot = await _db.collection('blood_posts')
      .where('status', isEqualTo: 'approved')
      .where('show_in_list', isEqualTo: true)
      .get()
      .timeout(const Duration(seconds: 15));

  final owners = snapshot.docs.map((doc) => (doc.data()['ownerUid'] ?? '').toString().trim())
      .where((uid) => uid.isNotEmpty).toSet();
  final publicProfiles = <String, Map<String,dynamic>>{};
  await Future.wait(owners.map((uid) async {
    try {
      final profile = await _db.collection('public_profiles').doc(uid).get().timeout(const Duration(seconds: 7));
      if (profile.exists) publicProfiles[uid] = profile.data() ?? <String,dynamic>{};
    } catch (_) {}
  }));

  final fallbackAvatars = <String, String>{};
  await Future.wait(owners.map((uid) async {
    final profile = publicProfiles[uid] ?? <String, dynamic>{};
    if (_firstImageUrl(profile, const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl']).isNotEmpty) return;
    final avatar = await _loadAvatarFromPublicContent(uid);
    if (avatar.isNotEmpty) fallbackAvatars[uid] = avatar;
  }));

  return snapshot.docs.map((doc) {
    final item = doc.data();
    final donor = item['post_type'] == 'donor';
    final ownerUid = (item['ownerUid'] ?? '').toString().trim();
    final publicProfile = publicProfiles[ownerUid] ?? <String,dynamic>{};
    final postAvatar = _firstImageUrl(item, const ['avatarUrl', 'photoURL', 'photoUrl', 'photo']);
    final publicAvatar = _firstImageUrl(publicProfile, const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl']);
    return <String, String>{
      'id': doc.id,
      'uid': ownerUid,
      'ownerUid': ownerUid,
      'ownerEmail': (item['ownerEmail'] ?? '').toString(),
      'type': donor ? 'Calon pendonor' : 'Permintaan darah',
      'name': (item['name'] ?? publicProfile['name'] ?? 'Pengguna Kalbar Kite').toString(),
      'avatarUrl': postAvatar.isNotEmpty ? postAvatar
          : (publicAvatar.isNotEmpty ? publicAvatar : (fallbackAvatars[ownerUid] ?? '')),
      'phone': (item['phone'] ?? '').toString(),
      'blood': (item['blood_type'] ?? '-').toString(),
      'district': (item['district'] ?? item['location'] ?? '').toString(),
      'hospital': (item['hospital'] ?? '').toString(),
      'donorLocation': (item['donor_location'] ?? '').toString(),
      'note': (item['notes'] ?? '').toString(),
      'showInDonorList': 'true',
    };
  }).toList();
}

String _authMessage(String code) {
  switch (code) {
    case 'email-already-in-use': return 'Email sudah terdaftar. Silakan masuk.';
    case 'invalid-email': return 'Format email tidak valid.';
    case 'weak-password': return 'Kata sandi terlalu lemah.';
    case 'user-not-found': case 'wrong-password': case 'invalid-credential': return 'Email atau kata sandi tidak cocok.';
    case 'network-request-failed': return 'Koneksi internet bermasalah.';
    case 'too-many-requests': return 'Terlalu banyak percobaan. Coba lagi nanti.';
    case 'operation-not-allowed': return 'Aktifkan login Email/Password di Firebase Console.';
    default: return 'Autentikasi gagal ($code).';
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Use TextureView on Android to prevent black SurfaceView composition glitches.
  MapLibreMap.useHybridComposition = true;
  await Firebase.initializeApp(options: _firebaseOptions);
  await Store.initialize();
  runApp(const App());
  // Muat identitas publik sekali saat aplikasi dibuka, termasuk sebelum login.
  // Future yang sama dipakai splash pasca-login agar tidak mengunduh konfigurasi dua kali.
  unawaited(Store.loadVisualConfigWithRetry());
  _auth.authStateChanges().listen((user) { if (user != null) unawaited(_initializeNotifications(user)); });
  // Sinkronisasi berjalan setelah UI tampil agar splash screen tidak tertahan jaringan.
  if (_auth.currentUser != null) {
    Store.currentEmail = _auth.currentUser!.email ?? '';
    Store.currentUid = _auth.currentUser!.uid;
  }
}

class Store {
  static String appName = 'Kalbar Kite', tagline = 'Kenali Kalbar, temukan cerita daerah, dan tumbuhkan kepedulian bersama.', logo = '◈';
  static String contactEmail = '', contactWhatsapp = '', contactWebsite = '';
  static String donorGroupWhatsapp = '';
  static String helpCenterContent = '';
  static String privacyPolicyContent = '';
  // Kamus sepenuhnya berasal dari Firestore dan dikelola melalui website admin.
  static final words = <Map<String,String>>[];
  static final forms = <Map<String,String>>[];
  static final accounts = <String,String>{};
  static final memberNames = <String,String>{};
  static final phones = <String,String>{};
  static final infoPosts = <Map<String,String>>[];
  static final eventPosts = <Map<String,String>>[];
  static final historyPosts = <Map<String,String>>[];
  static final pantunPosts = <Map<String,String>>[];
  static final hospitalOptions = <String>[];
  static final districtOptions = <String>[];
  static final hospitalDistricts = <String,String>{};
  static final activityPosts = <Map<String,String>>[];
  static final avatarPaths = <String,String>{};
  static final avatarUrls = <String,String>{};
  static final bannerUrls = <String,String>{};
  static final bios = <String,String>{};
  static final usernames = <String,String>{};
  static final stories = <Map<String,String>>[];
  static String currentEmail = '';
  static String currentUid = '';
  static bool adminRole = false;
  static bool isDarkMode = false;
  static final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);
  static final ValueNotifier<int> appConfigRevision = ValueNotifier<int>(0);
  static Map<String,dynamic> visualConfig = <String,dynamic>{};
  static final welcomeSlides = <Map<String,String>>[];

  // Satu request bersama untuk login dan splash, bukan request berurutan dua kali.
  static Future<void>? _visualConfigFuture;

  static Future<void> loadVisualConfigFromWorker() async {
    final pending = _visualConfigFuture;
    if (pending != null) return pending;
    final request = _fetchVisualConfigFromWorker();
    _visualConfigFuture = request;
    try {
      await request;
    } catch (_) {
      if (identical(_visualConfigFuture, request)) _visualConfigFuture = null;
      rethrow;
    }
  }

  static Future<void> loadVisualConfigWithRetry() async {
    for (var attempt = 0; attempt < 4; attempt++) {
      try {
        await loadVisualConfigFromWorker();
        return;
      } catch (_) {
        if (attempt == 3) return;
        await Future.delayed(Duration(seconds: (attempt + 1) * 2));
      }
    }
  }

  static Future<void> _fetchVisualConfigFromWorker() async {
    final response = await http.get(
      Uri.parse('https://kalbarkite.dcxcomunity.my.id/api/public-config'),
      headers: const {'Accept': 'application/json', 'Cache-Control': 'no-cache'},
    ).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('Worker public-config HTTP ${response.statusCode}');
    }
    final payload = jsonDecode(response.body);
    if (payload is! Map) throw const FormatException('Format konfigurasi Worker tidak valid.');
    final settings = payload['settings'];
    if (settings is! Map) throw const FormatException('Pengaturan Worker tidak ditemukan.');
    contactEmail = (settings['contactEmail'] ?? contactEmail).toString().trim();
    contactWhatsapp = (settings['contactWhatsapp'] ?? contactWhatsapp).toString().trim();
    contactWebsite = (settings['contactWebsite'] ?? contactWebsite).toString().trim();
    donorGroupWhatsapp = (settings['donorGroupWhatsapp'] ?? donorGroupWhatsapp).toString().trim();
    helpCenterContent = (settings['helpCenterContent'] ?? helpCenterContent).toString();
    await prefs?.setString('contactEmail', contactEmail);
    await prefs?.setString('contactWhatsapp', contactWhatsapp);
    await prefs?.setString('contactWebsite', contactWebsite);
    await prefs?.setString('donorGroupWhatsapp', donorGroupWhatsapp);
    final rawVisual = settings['visualConfig'];
    if (rawVisual is Map) {
      visualConfig = Map<String,dynamic>.from(rawVisual);
      await prefs?.setString('visualConfig', jsonEncode(visualConfig));
    }
    final remoteName = (settings['appName'] ?? '').toString().trim();
    final remoteTagline = (settings['tagline'] ?? '').toString().trim();
    if (remoteName.isNotEmpty) appName = remoteName;
    if (remoteTagline.isNotEmpty) tagline = remoteTagline;
    appConfigRevision.value++;
  }
  static final randomCards = <Map<String,String>>[];
  static final exploreCards = <Map<String,String>>[];
  static String eventFallbackImageUrl = '';
  static SharedPreferences? prefs;
  static Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    // Tidak ada kosakata lokal atau data bawaan di perangkat.
    words.clear();
    appName = prefs?.getString('appName') ?? appName;
    tagline = prefs?.getString('tagline') ?? tagline;
    final savedLogo = prefs?.getString('logo') ?? logo;
    logo = ['🌿', '🌳', '🌾', '🛶', '⭐'].contains(savedLogo) ? '◈' : savedLogo;
    contactEmail = prefs?.getString('contactEmail') ?? contactEmail;
    contactWhatsapp = prefs?.getString('contactWhatsapp') ?? contactWhatsapp;
    contactWebsite = prefs?.getString('contactWebsite') ?? contactWebsite;
    donorGroupWhatsapp = prefs?.getString('donorGroupWhatsapp') ?? donorGroupWhatsapp;
    currentEmail = _auth.currentUser?.email ?? '';
    currentUid = _auth.currentUser?.uid ?? '';
    final cachedVisualJson = prefs?.getString('visualConfig');
    if (cachedVisualJson != null && cachedVisualJson.isNotEmpty) {
      try {
        final cachedVisual = jsonDecode(cachedVisualJson);
        if (cachedVisual is Map) {
          visualConfig = Map<String, dynamic>.from(cachedVisual);
        }
      } catch (_) {}
    }
    if (_auth.currentUser != null) {
      try { final token = await _auth.currentUser!.getIdTokenResult().timeout(const Duration(seconds: 6)); adminRole = token.claims?['admin'] == true; } catch (_) { adminRole = false; }
    }
    isDarkMode = prefs?.getBool('isDarkMode') ?? false;
    darkMode.value = isDarkMode;
  }
  static Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    darkMode.value = value;
    await prefs?.setBool('isDarkMode', value);
  }
  static Future<void> save() async {
    // Shared records are persisted in Firestore, not device preferences.
    // Application content and public settings are managed in Firestore.
  }
  static Future<void> saveSession() async {}
  static Future<void> saveAppSettings() async {
    await _db.collection('app_config').doc('public').set({
      'appName': appName, 'tagline': tagline, 'logo': logo,
      'contactEmail': contactEmail, 'contactWhatsapp': contactWhatsapp,
      'contactWebsite': contactWebsite,
      'donorGroupWhatsapp': donorGroupWhatsapp,
      'helpCenterContent': helpCenterContent,
      'privacyPolicyContent': privacyPolicyContent,
      'welcomeSlides': welcomeSlides,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    appConfigRevision.value++;
  }
  static bool get isAdmin => adminRole;

  static DateTime? _legacyEventDate(KalbarEvent event) {
    const months = {'Januari':1,'Februari':2,'Maret':3,'April':4,'Mei':5,'Juni':6,'Juli':7,'Agustus':8,'September':9,'Oktober':10,'November':11,'Desember':12};
    final match = RegExp(r'^(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})$').firstMatch(event.date.trim());
    if (match == null) return null;
    final month = months[match.group(2)];
    if (month == null) return null;
    final clock = RegExp(r'(\d{1,2})[.:](\d{2})').firstMatch(event.time);
    return DateTime(int.parse(match.group(3)!), month, int.parse(match.group(1)!),
      clock == null ? 8 : int.parse(clock.group(1)!),
      clock == null ? 0 : int.parse(clock.group(2)!));
  }

  static Future<void> loadCloudData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    currentUid = user.uid;
    currentEmail = user.email ?? '';
    try {
      final token = await user.getIdTokenResult().timeout(const Duration(seconds: 5));
      adminRole = token.claims?['admin'] == true;
    } catch (_) { adminRole = false; }

    try {
      final snap = await _db.collection('app_config').doc('public').get().timeout(const Duration(seconds: 8));
      final d = snap.data();
      if (d != null) {
        final configuredName = (d['appName'] ?? appName).toString();
        appName = configuredName.toLowerCase() == 'kalbarku' ? 'Kalbar Kite' : configuredName.replaceAll('KalbarKu', 'Kalbar Kite');
        tagline = (d['tagline'] ?? tagline).toString().replaceAll('KalbarKu', 'Kalbar Kite');
        final configuredLogo = (d['logo'] ?? logo).toString();
        logo = ['🌿', '🌳', '🌾', '🛶', '⭐'].contains(configuredLogo) ? '◈' : configuredLogo;
        contactEmail = (d['contactEmail'] ?? contactEmail).toString();
        contactWhatsapp = (d['contactWhatsapp'] ?? contactWhatsapp).toString();
        contactWebsite = (d['contactWebsite'] ?? '').toString();
        donorGroupWhatsapp = (d['donorGroupWhatsapp'] ?? '').toString().trim();
        helpCenterContent = (d['helpCenterContent'] ?? helpCenterContent).toString();
        privacyPolicyContent = (d['privacyPolicyContent'] ?? privacyPolicyContent).toString();
        final rawVisualConfig = d['visualConfig'];
        if (rawVisualConfig is Map) {
          visualConfig = Map<String,dynamic>.from(rawVisualConfig);
          await prefs?.setString('visualConfig', jsonEncode(visualConfig));
        }
        final rawSlides = d['welcomeSlides'];
        if (rawSlides is List) {
          final configuredSlides = rawSlides.whereType<Map>().map((slide) => <String,String>{
            'title': (slide['title'] ?? '').toString(),
            'imageUrl': _normalizeImageUrl((slide['imageUrl'] ?? '').toString()),
          }).where((slide) => slide['title']!.isNotEmpty || slide['imageUrl']!.isNotEmpty).take(3).toList();
          welcomeSlides
            ..clear()
            ..addAll(configuredSlides);
        }
        eventFallbackImageUrl = (d['eventFallbackImageUrl'] ?? '').toString().trim();
        final rawExploreCards = d['exploreCards'];
        if (rawExploreCards is List) {
          exploreCards
            ..clear()
            ..addAll(rawExploreCards.whereType<Map>().map((card) => <String,String>{
              'id': (card['id'] ?? '').toString(),
              'title': (card['title'] ?? '').toString(),
              'subtitle': (card['subtitle'] ?? '').toString(),
              'imageUrl': _normalizeImageUrl((card['imageUrl'] ?? '').toString()),
              'icon': (card['icon'] ?? 'compass').toString(),
            }).take(12));
        }
        final rawRandomCards = d['randomCards'];
        if (rawRandomCards is List) {
          randomCards
            ..clear()
            ..addAll(rawRandomCards.whereType<Map>().map((card) => <String,String>{
              'title': (card['title'] ?? '').toString(),
              'subtitle': (card['subtitle'] ?? '').toString(),
              'imageUrl': _normalizeImageUrl((card['imageUrl'] ?? '').toString()),
              'action': (card['action'] ?? '').toString(),
              'target': (card['target'] ?? '').toString(),
              'id': (card['id'] ?? '').toString(),
            }).take(8));
        }
        appConfigRevision.value++;
      }
    } catch (_) {}

    // Ambil role profil lebih awal agar migrasi konten lokal hanya dijalankan admin.
    try {
      final roleDoc = await _db.collection('profiles').doc(user.uid).get().timeout(const Duration(seconds: 8));
      adminRole = adminRole || roleDoc.data()?['role'] == 'admin';
    } catch (_) {}

    try {
      final snap = await _db.collection('dictionary').get().timeout(const Duration(seconds: 8));
      words
        ..clear()
        ..addAll(snap.docs.map((doc) => <String,String>{
          'id':doc.id,
          'word':(doc.data()['word']??'').toString(),
          'language':(doc.data()['language']??'').toString(),
          'meaning':(doc.data()['meaning']??'').toString(),
          'district':(doc.data()['district']??'').toString(),
        }));
    } catch (_) {
      words.clear();
    }

    DocumentSnapshot<Map<String,dynamic>>? profile;
    try {
      profile = await _db.collection('profiles').doc(user.uid).get().timeout(const Duration(seconds: 8));
      final d = profile.data();
      if (d != null) {
        adminRole = adminRole || d['role'] == 'admin';
        memberNames[currentEmail] = (d['name'] ?? '').toString();
        phones[currentEmail] = (d['phone'] ?? '').toString();
        usernames[currentEmail] = (d['username'] ?? currentEmail.split('@').first).toString();
        // Jangan menimpa foto publik dengan string kosong saat dokumen profil
        // privat berasal dari akun lama yang belum punya field avatar/banner.
        Map<String, dynamic> existingPublic = <String, dynamic>{};
        try {
          final publicSnapshot = await _db.collection('public_profiles').doc(user.uid)
              .get().timeout(const Duration(seconds: 8));
          existingPublic = publicSnapshot.data() ?? <String, dynamic>{};
        } catch (_) {}
        final privateAvatar = _firstImageUrl(d, const ['avatarUrl', 'photoURL', 'photoUrl', 'photo']);
        final publicAvatar = _firstImageUrl(existingPublic, const ['avatarUrl', 'photoURL', 'photoUrl', 'photo']);
        final postAvatar = privateAvatar.isEmpty && publicAvatar.isEmpty
            ? await _loadAvatarFromPublicContent(user.uid) : '';
        final avatar = privateAvatar.isNotEmpty ? privateAvatar
            : (publicAvatar.isNotEmpty ? publicAvatar
                : (postAvatar.isNotEmpty ? postAvatar : _normalizeImageUrl(user.photoURL ?? '')));
        final privateBanner = _firstImageUrl(d, const ['bannerUrl', 'coverUrl', 'headerImageUrl']);
        final banner = privateBanner.isNotEmpty ? privateBanner
            : _firstImageUrl(existingPublic, const ['bannerUrl', 'coverUrl', 'headerImageUrl']);
        final bio = (d['bio'] ?? existingPublic['bio'] ?? '').toString();
        if (avatar.isNotEmpty) {
          avatarUrls[currentEmail] = avatar;
        } else {
          avatarUrls.remove(currentEmail);
        }
        if (banner.isNotEmpty) bannerUrls[currentEmail] = banner;
        bios[currentEmail] = bio;
        try {
          await _db.collection('public_profiles').doc(user.uid).set({
            'uid': user.uid,
            'name': d['name'] ?? 'Warga Kalbar',
            'username': d['username'] ?? currentEmail.split('@').first,
            'bio': bio,
            if (avatar.isNotEmpty) 'avatarUrl': avatar,
            if (banner.isNotEmpty) 'bannerUrl': banner,
            'lastSeenAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)).timeout(const Duration(seconds: 8));
        } catch (error) {
          debugPrint('Sinkronisasi profil publik dilewati: $error');
        }
        try { await _db.collection('profiles').doc(user.uid).set({'lastSeenAt':FieldValue.serverTimestamp()}, SetOptions(merge:true)).timeout(const Duration(seconds:8)); } catch (_) {}
      }
    } catch (_) {}

    // Akun lama bisa hanya mempunyai public_profiles. Tetap pulihkan nama,
    // username, bio, avatar, dan banner tanpa mengharuskan dokumen privat ada.
    if (profile?.exists != true) {
      try {
        final publicSnapshot = await _db.collection('public_profiles').doc(user.uid)
            .get().timeout(const Duration(seconds: 8));
        final publicData = publicSnapshot.data() ?? <String, dynamic>{};
        if (publicData.isNotEmpty) {
          final publicName = (publicData['name'] ?? '').toString();
          final publicUsername = (publicData['username'] ?? currentEmail.split('@').first).toString();
          if (publicName.isNotEmpty) memberNames[currentEmail] = publicName;
          usernames[currentEmail] = publicUsername;
          bios[currentEmail] = (publicData['bio'] ?? '').toString();
          final publicAvatar = _firstImageUrl(publicData,
              const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl']);
          final fallbackAvatar = publicAvatar.isNotEmpty
              ? publicAvatar : await _loadAvatarFromPublicContent(user.uid);
          final avatar = fallbackAvatar.isNotEmpty
              ? fallbackAvatar : _normalizeImageUrl(user.photoURL ?? '');
          if (avatar.isNotEmpty) avatarUrls[currentEmail] = avatar;
          final banner = _firstImageUrl(publicData,
              const ['bannerUrl', 'coverUrl', 'headerImageUrl']);
          if (banner.isNotEmpty) bannerUrls[currentEmail] = banner;
        } else {
          final fallbackAvatar = await _loadAvatarFromPublicContent(user.uid);
          if (fallbackAvatar.isNotEmpty) avatarUrls[currentEmail] = fallbackAvatar;
        }
      } catch (_) {}
    }

    if (profile?.exists == true && !adminRole) {
      final d = profile!.data()!;
      accounts[currentEmail] = '';
      memberNames[currentEmail] = (d['name'] ?? '').toString();
      phones[currentEmail] = (d['phone'] ?? '').toString();
      usernames[currentEmail] = (d['username'] ?? currentEmail.split('@').first).toString();
    }
    if (adminRole) {
      try {
        final all = await _db.collection('profiles').get().timeout(const Duration(seconds: 8));
        accounts.clear(); memberNames.clear(); phones.clear();
        final uidByEmail = <String, String>{};
        for (final doc in all.docs) {
          final d = doc.data(); final email = (d['email'] ?? '').toString().trim().toLowerCase();
          if (email.isNotEmpty) {
            uidByEmail[email] = doc.id;
            accounts[email] = ''; memberNames[email] = (d['name'] ?? '').toString();
            phones[email] = (d['phone'] ?? '').toString(); usernames[email] = (d['username'] ?? '').toString();
            final avatar = _normalizeImageUrl((d['avatarUrl'] ?? '').toString());
            if (avatar.isNotEmpty) avatarUrls[email] = avatar;
          }
        }
        // Repair older public donor posts that were saved before ownerUid was included.
        try {
          final posts = await _db.collection('blood_posts').get().timeout(const Duration(seconds: 12));
          WriteBatch batch = _db.batch();
          var pending = 0;
          for (final post in posts.docs) {
            final data = post.data();
            if ((data['ownerUid'] ?? '').toString().trim().isNotEmpty) continue;
            final email = (data['ownerEmail'] ?? '').toString().trim().toLowerCase();
            final ownerUid = uidByEmail[email] ?? '';
            if (ownerUid.isEmpty) continue;
            batch.update(post.reference, {'ownerUid': ownerUid});
            pending++;
            if (pending == 400) {
              await batch.commit();
              batch = _db.batch();
              pending = 0;
            }
          }
          if (pending > 0) await batch.commit();
        } catch (_) {}
      } catch (_) {}
    }

    try {
      final snap = await _db.collection('stories').where('expiresAt', isGreaterThan: Timestamp.now()).orderBy('expiresAt').get().timeout(const Duration(seconds: 10));
      stories..clear()..addAll(snap.docs.map((doc) {
        final d = doc.data();
        return <String,String>{
          'id':doc.id,
          'uid':(d['ownerUid']??'').toString(),
          'username':(d['username']??'warga').toString(),
          'name':(d['name']??'Warga Kalbar').toString(),
          'text':(d['text']??'').toString(),
          'imageUrl':_normalizeImageUrl((d['imageUrl']??'').toString()),
          'videoUrl':(d['videoUrl']??'').toString(),
          'avatarUrl':_normalizeImageUrl((d['avatarUrl']??'').toString()),
          'createdAt':d['createdAt'] is Timestamp ? (d['createdAt'] as Timestamp).toDate().toIso8601String() : '',
          'expiresAt':d['expiresAt'] is Timestamp ? (d['expiresAt'] as Timestamp).toDate().toIso8601String() : '',
        };
      }));
    } catch (_) {}

    try {
      final snap = await _db.collection('info_posts').orderBy('createdAt', descending:true).get().timeout(const Duration(seconds: 10));
      infoPosts..clear()..addAll(snap.docs.map((doc) {
        final d=doc.data();
        return <String,String>{'id':doc.id,'title':(d['title']??'').toString(),'body':(d['body']??'').toString(),'date':(d['date']??'').toString(),'category':(d['category']??'Informasi umum').toString(),'displaySection':(d['displaySection']??'both').toString(),'imagePath':_firstImageUrl(d)};
      }));
    } catch (_) {}

    try {
      final snap = await _db.collection('admin_events').get().timeout(const Duration(seconds: 10));
      eventPosts..clear()..addAll(snap.docs.map((doc) {
        final d=doc.data();
        return <String,String>{'id':doc.id,'title':(d['title']??'').toString(),'description':(d['description']??'').toString(),'date':(d['date']??'').toString(),'time':(d['time']??'').toString(),'scheduledAt':(d['scheduledAt'] is Timestamp ? (d['scheduledAt'] as Timestamp).toDate().toIso8601String() : (d['scheduledAt']??'').toString()),'location':(d['location']??'').toString(),'sourceName':(d['sourceName']??'').toString(),'sourceUrl':(d['sourceUrl']??'').toString(),'imageUrl':_normalizeImageUrl((d['imageUrl']??'').toString()),'status':(d['status']??'published').toString()};
      }));
    } catch (_) {}

    try {
      final snap = await _db.collection('history_posts').get().timeout(const Duration(seconds: 10));
      historyPosts..clear()..addAll(snap.docs.map((doc) {
        final d=doc.data();
        return <String,String>{'id':doc.id,'title':(d['title']??'').toString(),'pageTitle':(d['pageTitle']??d['title']??'').toString(),'kind':(d['kind']??'Kabupaten').toString(),'body':(d['body']??d['extract']??'').toString(),'imageUrl':_normalizeImageUrl((d['imageUrl']??'').toString()),'sourceName':(d['sourceName']??'').toString(),'sourceUrl':(d['sourceUrl']??'').toString(),'status':(d['status']??'published').toString()};
      }));
      districtOptions
        ..clear()
        ..addAll(kalbarDistricts);
    } catch (_) {
      historyPosts.clear();
      districtOptions
        ..clear()
        ..addAll(kalbarDistricts);
    }

    try {
      final snap = await _db.collection('pantun_posts').get().timeout(const Duration(seconds: 10));
      pantunPosts..clear()..addAll(snap.docs.map((doc) {
        final d=doc.data();
        return <String,String>{'id':doc.id,'title':(d['title']??'').toString(),'culture':(d['culture']??'Melayu').toString(),'theme':(d['theme']??'Budaya').toString(),'first':(d['first']??'').toString(),'second':(d['second']??'').toString(),'third':(d['third']??'').toString(),'fourth':(d['fourth']??'').toString(),'status':(d['status']??'published').toString()};
      }));
    } catch (_) {}

    try {
      final snap = await _db.collection('activity_posts').orderBy('createdAt', descending:true).get().timeout(const Duration(seconds: 12));
      activityPosts..clear()..addAll(snap.docs.map((doc) {
        final d=doc.data();
        return <String,String>{'id':doc.id,'uid':(d['ownerUid']??'').toString(),'email':(d['email']??'').toString(),'author':(d['author']??'Warga Kalbar').toString(),'username':(d['username']??'warga').toString(),'body':(d['body']??'').toString(),'imagePath':_firstImageUrl(d),'avatarUrl':_normalizeImageUrl((d['avatarUrl']??'').toString()),'linkUrl':(d['linkUrl']??'').toString(),'date':(d['date']??'').toString(),'comments':jsonEncode(d['comments']??[])};
      }));
    } catch (_) {}

    try {
      Query<Map<String,dynamic>> query = _db.collection('blood_posts');
      if (!adminRole) query = query.where('ownerUid', isEqualTo:user.uid);
      final snap = await query.get().timeout(const Duration(seconds: 10));
      forms..clear()..addAll(snap.docs.map((doc) {
        final d=doc.data();
        return <String,String>{'cloudId':doc.id,'type':d['post_type']=='donor'?'Calon pendonor':'Permintaan darah','name':(d['name']??'').toString(),'phone':(d['phone']??'').toString(),'blood':(d['blood_type']??'').toString(),'district':(d['district']??'').toString(),'hospital':(d['hospital']??'').toString(),'donorLocation':(d['donorLocation']??d['donor_location']??'').toString(),'place':(d['hospital']??d['district']??'').toString(),'note':(d['notes']??'').toString(),'showInDonorList':(d['show_in_list']??false).toString(),'status':(d['status']??'pending').toString(),'syncStatus':'synced'};
      }));
    } catch (_) {}

    try {
      final options = await _db.collection('blood_posts').where('status', isEqualTo: 'approved').get().timeout(const Duration(seconds: 10));
      hospitalDistricts.clear();
      for (final doc in options.docs) {
        final data = doc.data();
        final hospitalName = (data['hospital'] ?? '').toString().trim();
        final districtName = (data['district'] ?? '').toString().trim();
        if (hospitalName.isNotEmpty && districtName.isNotEmpty) {
          hospitalDistricts[hospitalName.toLowerCase()] = districtName;
        }
      }
      hospitalOptions
        ..clear()
        ..addAll({
          ...kalbarHospitals,
          ...options.docs.map((doc) => (doc.data()['hospital'] ?? '').toString().trim()).where((x) => x.isNotEmpty),
        }.toList()..sort());
    } catch (_) {
      hospitalDistricts.clear();
      hospitalOptions
        ..clear()
        ..addAll(kalbarHospitals);
    }
    appConfigRevision.value++;
  }

  static Future<void> _savePrivateProfileFields(Map<String, dynamic> fields) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Sesi login berakhir.');
    final ref = _db.collection('profiles').doc(user.uid);
    final snapshot = await ref.get().timeout(const Duration(seconds: 10));
    final existing = snapshot.data() ?? <String, dynamic>{};
    final role = (existing['role'] ?? 'member').toString();
    // Keep required identity fields present even on legacy profile documents.
    // Firestore rules compare the role before/after an update, so preserve it.
    await ref.set({
      'uid': user.uid,
      'email': user.email ?? '',
      'role': role,
      ...fields,
    }, SetOptions(merge: true));
  }

  static Future<void> _savePublicProfileFields(Map<String, dynamic> fields) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Sesi login berakhir.');
    final publicRef = _db.collection('public_profiles').doc(user.uid);
    // Merge only member-editable fields. Verification fields remain admin-owned.
    await publicRef.set({
      'uid': user.uid,
      ...fields,
    }, SetOptions(merge: true));
  }

  static Future<void> saveProfile(String name, String phone, String username, String bio) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Sesi login berakhir.');
    final cleanUsername = username.trim().replaceAll('@','').toLowerCase();
    if (cleanUsername.length < 3 || !RegExp(r'^[a-z0-9_]+$').hasMatch(cleanUsername)) throw Exception('Username minimal 3 karakter, gunakan huruf, angka, atau garis bawah.');
    final cleanBio = bio.trim();
    Map<String, dynamic> existingPrivate = <String, dynamic>{};
    Map<String, dynamic> existingPublic = <String, dynamic>{};
    try {
      final snapshot = await _db.collection('profiles').doc(user.uid).get();
      existingPrivate = snapshot.data() ?? <String, dynamic>{};
    } catch (_) {}
    try {
      final snapshot = await _db.collection('public_profiles').doc(user.uid).get();
      existingPublic = snapshot.data() ?? <String, dynamic>{};
    } catch (_) {}
    final currentAvatar = _normalizeImageUrl(avatarUrls[currentEmail] ?? '');
    final avatar = currentAvatar.isNotEmpty ? currentAvatar
        : (_firstImageUrl(existingPrivate, const ['avatarUrl', 'photoURL', 'photoUrl', 'photo']).isNotEmpty
            ? _firstImageUrl(existingPrivate, const ['avatarUrl', 'photoURL', 'photoUrl', 'photo'])
            : (_firstImageUrl(existingPublic, const ['avatarUrl', 'photoURL', 'photoUrl', 'photo']).isNotEmpty
                ? _firstImageUrl(existingPublic, const ['avatarUrl', 'photoURL', 'photoUrl', 'photo'])
                : _normalizeImageUrl(user.photoURL ?? '')));
    final currentBanner = _normalizeImageUrl(bannerUrls[currentEmail] ?? '');
    final banner = currentBanner.isNotEmpty ? currentBanner
        : (_firstImageUrl(existingPrivate, const ['bannerUrl', 'coverUrl', 'headerImageUrl']).isNotEmpty
            ? _firstImageUrl(existingPrivate, const ['bannerUrl', 'coverUrl', 'headerImageUrl'])
            : _firstImageUrl(existingPublic, const ['bannerUrl', 'coverUrl', 'headerImageUrl']));
    final profileData = <String, dynamic>{
      'uid': user.uid, 'email': user.email ?? '', 'name': name, 'phone': phone,
      'username': cleanUsername, 'bio': cleanBio, 'updatedAt': FieldValue.serverTimestamp(),
      if (avatar.isNotEmpty) 'avatarUrl': avatar,
      if (banner.isNotEmpty) 'bannerUrl': banner,
    };
    await _savePrivateProfileFields(profileData);
    await _savePublicProfileFields({
      'name': name, 'username': cleanUsername, 'bio': cleanBio,
      'updatedAt': FieldValue.serverTimestamp(),
      if (avatar.isNotEmpty) 'avatarUrl': avatar,
      if (banner.isNotEmpty) 'bannerUrl': banner,
    });
    memberNames[currentEmail]=name; phones[currentEmail]=phone; usernames[currentEmail]=cleanUsername; bios[currentEmail]=cleanBio; await save();
  }

  static Future<String> uploadImage(String localPath, String folder) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Silakan masuk kembali.');
    if (cloudinaryCloudName == 'ISI_CLOUD_NAME' || cloudinaryUploadPreset == 'ISI_UNSIGNED_UPLOAD_PRESET') {
      throw Exception('Cloudinary belum dikonfigurasi. Isi cloud name dan upload preset terlebih dahulu.');
    }
    final file = File(localPath);
    if (!await file.exists()) throw Exception('File foto tidak ditemukan.');
    final bytes = await file.length();
    if (bytes > maxImageBytes) throw Exception('Ukuran foto maksimal 7 MB. Pilih foto yang lebih kecil.');
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = cloudinaryUploadPreset
      ..fields['public_id'] = 'kalbarku/$folder/${user.uid}/${DateTime.now().microsecondsSinceEpoch}'
      ..files.add(await http.MultipartFile.fromPath('file', localPath));
    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed).timeout(const Duration(seconds: 20));
    final data = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorData = data is Map ? data['error'] : null;
      final errorMessage = errorData is Map ? errorData['message']?.toString() : null;
      throw Exception(errorMessage ?? 'Cloudinary gagal mengunggah foto.');
    }
    final url = (data['secure_url'] ?? '').toString();
    if (url.isEmpty) throw Exception('Cloudinary tidak mengembalikan URL foto.');
    return url;
  }
  static Future<void> saveAvatar(String localPath) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Silakan masuk kembali.');
    final url = _normalizeImageUrl(await uploadImage(localPath, 'avatars'));
    if (url.isEmpty) throw Exception('Cloudinary tidak memberikan URL HTTPS untuk foto profil.');
    // Update local UI immediately after Cloudinary confirms the upload.
    avatarUrls[currentEmail] = url;
    try { await user.updatePhotoURL(url); } catch (_) {}
    await _savePrivateProfileFields({'avatarUrl':url, 'updatedAt':FieldValue.serverTimestamp()});
    await _savePublicProfileFields({'avatarUrl':url,'updatedAt':FieldValue.serverTimestamp()});
  }
  static Future<void> saveBanner(String localPath) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Silakan masuk kembali.');
    final url = _normalizeImageUrl(await uploadImage(localPath, 'banners'));
    if (url.isEmpty) throw Exception('Cloudinary tidak memberikan URL HTTPS untuk banner.');
    bannerUrls[currentEmail] = url;
    await _savePrivateProfileFields({'bannerUrl':url, 'updatedAt':FieldValue.serverTimestamp()});
    await _savePublicProfileFields({'bannerUrl':url,'updatedAt':FieldValue.serverTimestamp()});
  }

  static Future<String> resolveCurrentAvatar() async {
    final user = _auth.currentUser;
    if (user == null) return '';
    var avatar = _normalizeImageUrl(avatarUrls[currentEmail] ?? user.photoURL ?? '');
    if (avatar.isEmpty) {
      for (final collection in ['public_profiles', 'profiles']) {
        try {
          final snapshot = await _db.collection(collection).doc(user.uid)
              .get().timeout(const Duration(seconds: 7));
          avatar = _firstImageUrl(snapshot.data() ?? <String, dynamic>{},
              const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl']);
          if (avatar.isNotEmpty) break;
        } catch (_) {}
      }
    }
    if (avatar.isEmpty) avatar = await _loadAvatarFromPublicContent(user.uid);
    if (avatar.isNotEmpty) avatarUrls[currentEmail] = avatar;
    return avatar;
  }
  static Future<void> loadActivityFeed() async {
    if (_auth.currentUser == null) throw Exception('Silakan masuk kembali.');
    final storySnap = await _db.collection('stories')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt').get().timeout(const Duration(seconds: 15));
    final postSnap = await _db.collection('activity_posts')
        .orderBy('createdAt', descending: true)
        .get().timeout(const Duration(seconds: 20));
    final owners = <String>{
      ...storySnap.docs.map((doc) => (doc.data()['ownerUid'] ?? '').toString()),
      ...postSnap.docs.map((doc) => (doc.data()['ownerUid'] ?? '').toString()),
    };
    final fallbackAvatars = await _loadAvatarsForUsers(owners);

    stories
      ..clear()
      ..addAll(storySnap.docs.map((doc) {
        final d = doc.data();
        final uid = (d['ownerUid'] ?? '').toString();
        final storedAvatar = _firstImageUrl(d,
            const ['avatarUrl', 'photoURL', 'photoUrl', 'photo']);
        return <String, String>{
          'id': doc.id, 'uid': uid,
          'username': (d['username'] ?? 'warga').toString(),
          'name': (d['name'] ?? 'Warga Kalbar').toString(),
          'text': (d['text'] ?? '').toString(),
          'imageUrl': _firstImageUrl(d, const ['imageUrl', 'imagePath']),
          'videoUrl': (d['videoUrl'] ?? '').toString(),
          'mediaType': (d['mediaType'] ?? 'image').toString(),
          'avatarUrl': storedAvatar.isNotEmpty ? storedAvatar : (fallbackAvatars[uid] ?? ''),
          'createdAt': d['createdAt'] is Timestamp
              ? (d['createdAt'] as Timestamp).toDate().toIso8601String() : '',
          'expiresAt': d['expiresAt'] is Timestamp
              ? (d['expiresAt'] as Timestamp).toDate().toIso8601String() : '',
        };
      }));

    activityPosts
      ..clear()
      ..addAll(postSnap.docs.map((doc) {
        final d = doc.data();
        final uid = (d['ownerUid'] ?? '').toString();
        final storedAvatar = _firstImageUrl(d,
            const ['avatarUrl', 'photoURL', 'photoUrl', 'photo']);
        return <String, String>{
          'id': doc.id, 'uid': uid,
          'email': (d['email'] ?? '').toString(),
          'author': (d['author'] ?? 'Warga Kalbar').toString(),
          'username': (d['username'] ?? 'warga').toString(),
          'body': (d['body'] ?? '').toString(),
          'imagePath': _firstImageUrl(d, const ['imageUrl', 'imagePath']),
          'videoUrl': (d['videoUrl'] ?? '').toString(),
          'avatarUrl': storedAvatar.isNotEmpty ? storedAvatar : (fallbackAvatars[uid] ?? ''),
          'linkUrl': (d['linkUrl'] ?? '').toString(),
          'date': (d['date'] ?? '').toString(),
          'comments': jsonEncode(d['comments'] ?? []),
        };
      }));
  }

  static Future<String> compressVideo(String localPath) async {
    final source = File(localPath);
    if (!await source.exists()) throw Exception('File video tidak ditemukan.');
    final info = await VideoCompress.getMediaInfo(localPath);
    final durationMs = (info.duration ?? 0).toDouble();
    if (durationMs <= 0) throw Exception('Durasi video tidak dapat dibaca.');
    if (durationMs > 30000) throw Exception('Durasi video maksimal 30 detik.');
    if (await source.length() <= 10 * 1024 * 1024) return localPath;
    final compressed = await VideoCompress.compressVideo(
      localPath,
      quality: VideoQuality.LowQuality,
      includeAudio: true,
      deleteOrigin: false,
    );
    final compressedPath = compressed?.path;
    if (compressedPath == null || compressedPath.isEmpty) {
      throw Exception('Video gagal dikompres. Coba pilih video lain.');
    }
    final compressedFile = File(compressedPath);
    if (!await compressedFile.exists()) throw Exception('Hasil kompresi video tidak ditemukan.');
    final bytes = await compressedFile.length();
    if (bytes > 10 * 1024 * 1024) {
      throw Exception('Setelah dikompres, video masih lebih dari 10 MB. Pilih video dengan resolusi atau durasi lebih rendah.');
    }
    return compressedPath;
  }

  static Future<String> uploadVideo(String localPath, String folder) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Silakan masuk kembali.');
    final compressedPath = await compressVideo(localPath);
    final file = File(compressedPath);
    if (!await file.exists()) throw Exception('File video tidak ditemukan.');
    if (await file.length() > 10 * 1024 * 1024) {
      throw Exception('Ukuran video maksimal 10 MB setelah kompresi.');
    }
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudinaryCloudName/video/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = cloudinaryUploadPreset
      ..fields['public_id'] = 'kalbarku/$folder/${user.uid}/${DateTime.now().microsecondsSinceEpoch}'
      ..files.add(await http.MultipartFile.fromPath('file', compressedPath));
    final streamed = await request.send().timeout(const Duration(seconds: 120));
    final response = await http.Response.fromStream(streamed).timeout(const Duration(seconds: 30));
    final data = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorData = data is Map ? data['error'] : null;
      final message = errorData is Map ? errorData['message']?.toString() : null;
      throw Exception(message ?? 'Cloudinary gagal mengunggah video.');
    }
    final url = (data['secure_url'] ?? '').toString();
    if (url.isEmpty) throw Exception('Cloudinary tidak mengembalikan URL video.');
    return url;
  }

  static Future<void> deleteStory(String id) async {
    if (id.isEmpty) throw Exception('ID story tidak ditemukan.');
    final ref = _db.collection('stories').doc(id);
    final snap = await ref.get();
    if (!snap.exists || snap.data()?['ownerUid'] != _auth.currentUser?.uid) {
      throw Exception('Kamu hanya bisa menghapus story milikmu sendiri.');
    }
    for (final sub in ['likes', 'replies', 'reactions']) {
      final docs = await ref.collection(sub).get();
      for (var start = 0; start < docs.docs.length; start += 400) {
        final batch = _db.batch();
        for (final doc in docs.docs.skip(start).take(400)) { batch.delete(doc.reference); }
        await batch.commit();
      }
    }
    await ref.delete();
    stories.removeWhere((item) => item['id'] == id);
  }

  static Future<void> deleteActivityPost(String id) async {
    if (id.isEmpty) throw Exception('ID postingan tidak ditemukan.');
    final ref = _db.collection('activity_posts').doc(id);
    final snap = await ref.get();
    if (!snap.exists || snap.data()?['ownerUid'] != _auth.currentUser?.uid) {
      throw Exception('Kamu hanya bisa menghapus postingan milikmu sendiri.');
    }
    final likes = await ref.collection('likes').get();
    for (var start = 0; start < likes.docs.length; start += 400) {
      final batch = _db.batch();
      for (final doc in likes.docs.skip(start).take(400)) { batch.delete(doc.reference); }
      await batch.commit();
    }
    await ref.delete();
    activityPosts.removeWhere((item) => item['id'] == id);
  }

  static Future<void> publishStory(String text, {String imagePath = '', String videoPath = ''}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Silakan masuk kembali.');

    // Refresh profil publik agar nama, username, dan foto terbaru ikut tersimpan pada Story.
    Map<String,dynamic> profileData = {};
    try {
      final profileSnap = await _db.collection('public_profiles').doc(user.uid).get();
      profileData = profileSnap.data() ?? {};
    } catch (_) {}
    if (profileData.isEmpty) {
      try {
        final profileSnap = await _db.collection('profiles').doc(user.uid).get();
        profileData = profileSnap.data() ?? {};
      } catch (_) {}
    }

    final username = (profileData['username'] ?? usernames[currentEmail] ?? currentEmail.split('@').first).toString();
    final displayName = (profileData['name'] ?? memberNames[currentEmail] ?? user.displayName ?? username).toString();
    final avatar = _firstImageUrl(profileData,
        const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl']).isNotEmpty
        ? _firstImageUrl(profileData,
            const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl'])
        : await resolveCurrentAvatar();
    if (displayName.trim().isNotEmpty) memberNames[currentEmail] = displayName;
    if (username.trim().isNotEmpty) usernames[currentEmail] = username;
    if (avatar.trim().isNotEmpty) avatarUrls[currentEmail] = avatar;

    final isVideo = videoPath.isNotEmpty;
    final mediaUrl = isVideo ? await uploadVideo(videoPath, 'stories') :
        (imagePath.isEmpty ? '' : await uploadImage(imagePath, 'stories'));
    final createdAt = DateTime.now();
    final expiresAt = createdAt.add(const Duration(hours:24));
    final data = {
      'ownerUid':user.uid,
      'name':displayName,
      'username':username,
      'avatarUrl':avatar,
      'text':text,
      'imageUrl':isVideo ? '' : mediaUrl,
      'videoUrl':isVideo ? mediaUrl : '',
      'mediaType':isVideo ? 'video' : 'image',
      'createdAt':FieldValue.serverTimestamp(),
      'expiresAt':Timestamp.fromDate(expiresAt),
    };
    final ref = await _db.collection('stories').add(data);
    stories.insert(0, {
      'id':ref.id,'uid':user.uid,'name':displayName,
      'username':username,'avatarUrl':avatar,'text':text,
      'imageUrl':isVideo ? '' : mediaUrl,'videoUrl':isVideo ? mediaUrl : '',
      'mediaType':isVideo ? 'video' : 'image',
      'createdAt':createdAt.toIso8601String(),
      'expiresAt':expiresAt.toIso8601String(),
    });
  }

  static Future<void> publishActivity(Map<String,String> post) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Silakan masuk kembali.');
    final localImage = post['imagePath'] ?? '';
    if ((post['videoPath'] ?? '').isNotEmpty) throw Exception('Video hanya bisa diunggah ke Story. Postingan hanya menerima foto.');
    final imageUrl = localImage.isEmpty ? '' : await uploadImage(localImage, 'activity');
    final avatar = await resolveCurrentAvatar();
    final ref = await _db.collection('activity_posts').add({
      'ownerUid': user.uid, 'email': user.email ?? '',
      'author': post['author'] ?? '',
      'username': usernames[currentEmail] ?? currentEmail.split('@').first,
      'avatarUrl': avatar, 'body': post['body'] ?? '',
      'imageUrl': imageUrl, 'linkUrl': post['linkUrl'] ?? '',
      'date': post['date'] ?? '', 'comments': <Map<String, dynamic>>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
    post['id']=ref.id; post['uid']=user.uid; post['imagePath']=imageUrl; post.remove('videoPath'); activityPosts.insert(0, post); await save();
  }

  static Future<void> updateActivityPost(Map<String,String> post) async {
    final id=post['id']??''; if(id.isEmpty) return;
    await _db.collection('activity_posts').doc(id).update({'comments':jsonDecode(post['comments']??'[]')});
    await save();
  }

  static Future<void> publishInfo(Map<String,String> post) async {
    final localImage = post['imagePath'] ?? '';
    final imageUrl = localImage.isEmpty ? '' : await uploadImage(localImage, 'information');
    final ref = await _db.collection('info_posts').add({
      'title': post['title'] ?? '',
      'body': post['body'] ?? '',
      'date': post['date'] ?? '',
      'category': post['category'] ?? 'Informasi umum',
      'displaySection': post['displaySection'] ?? 'both',
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    post['id'] = ref.id;
    post['imagePath'] = imageUrl;
    infoPosts.insert(0, post);
    await save();
  }

  static Future<void> deleteInfo(String id) async {
    if(id.isNotEmpty) await _db.collection('info_posts').doc(id).delete();
    infoPosts.removeWhere((p)=>p['id']==id); await save();
  }

  static Future<void> updateBloodStatus(Map<String,String> form,String status) async {
    final id=form['cloudId']??''; if(id.isEmpty) throw Exception('ID database tidak ditemukan.');
    await _db.collection('blood_posts').doc(id).update({'status':status});
    form['status']=status; await save();
  }
}

class LocalMedia {
  static Future<String> save(String sourcePath, String folder, String extension) async {
    final dir = await getApplicationDocumentsDirectory();
    final targetDir = Directory('${dir.path}/$folder');
    if (!await targetDir.exists()) await targetDir.create(recursive: true);
    final target = '${targetDir.path}/${DateTime.now().microsecondsSinceEpoch}.$extension';
    await File(sourcePath).copy(target);
    return target;
  }
}

class App extends StatelessWidget {
  final bool admin;
  const App({super.key, this.admin = false});
  ThemeData _buildTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final surface = dark ? const Color(0xFF111114) : Colors.white;
    final foreground = dark ? const Color(0xFFF5F5F7) : const Color(0xFF1C1C1E);
    final card = dark ? const Color(0xFF1C1C1E) : Colors.white;
    final border = dark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);
    final accent = dark ? const Color(0xFFE5E5E5) : const Color(0xFF171717);
    // Inter is a clean, highly legible sans-serif with strong bold weights.
    // Rounded Fredoka display paired with Manrope's clean, iOS-like text rhythm.
    final textFont = GoogleFonts.manrope().fontFamily!;
    final displayFont = GoogleFonts.fredoka().fontFamily!;
    final roundedFont = GoogleFonts.manrope().fontFamily!;
    final navigationFont = GoogleFonts.fredoka().fontFamily!;
    final baseTextTheme = ThemeData(brightness: brightness).textTheme.apply(
      bodyColor: foreground, displayColor: foreground, fontFamily: textFont,
      fontSizeFactor: 1.08);
    final boldTextTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(fontFamily: displayFont, fontWeight: FontWeight.w800),
      displayMedium: baseTextTheme.displayMedium?.copyWith(fontFamily: displayFont, fontWeight: FontWeight.w800),
      displaySmall: baseTextTheme.displaySmall?.copyWith(fontFamily: displayFont, fontWeight: FontWeight.w800),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontFamily: displayFont, fontWeight: FontWeight.w800),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontFamily: displayFont, fontWeight: FontWeight.w800),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontFamily: displayFont, fontWeight: FontWeight.w800),
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontFamily: displayFont, fontWeight: FontWeight.w800),
      titleMedium: baseTextTheme.titleMedium?.copyWith(fontFamily: roundedFont, fontWeight: FontWeight.w800),
      titleSmall: baseTextTheme.titleSmall?.copyWith(fontFamily: roundedFont, fontWeight: FontWeight.w800),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
      bodySmall: baseTextTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
      labelLarge: baseTextTheme.labelLarge?.copyWith(fontFamily: roundedFont, fontWeight: FontWeight.w600),
      labelMedium: baseTextTheme.labelMedium?.copyWith(fontFamily: roundedFont, fontWeight: FontWeight.w500),
      labelSmall: baseTextTheme.labelSmall?.copyWith(fontFamily: roundedFont, fontWeight: FontWeight.w500),
    );
    final scheme = ColorScheme.fromSeed(seedColor: accent, brightness: brightness,
      primary: accent, secondary: const Color(0xFF5AC8FA), surface: surface, onSurface: foreground);
    return ThemeData(
      useMaterial3: true, platform: TargetPlatform.android, brightness: brightness,
      scaffoldBackgroundColor: surface, visualDensity: VisualDensity.standard,
      colorScheme: scheme, primaryColor: accent, cardColor: card, dividerColor: border,
      iconTheme: IconThemeData(color: foreground, size: 21),
      textTheme: boldTextTheme,
      dialogTheme: DialogThemeData(backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: BorderSide(color: border, width: .8))),
      cardTheme: CardThemeData(color: card, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: border, width: .8)),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 1)),
      appBarTheme: AppBarTheme(backgroundColor: surface, foregroundColor: foreground,
        elevation: 0, scrolledUnderElevation: 0, surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(color: foreground, fontSize: 21, fontWeight: FontWeight.w900, fontFamily: displayFont),
        iconTheme: IconThemeData(color: accent, size: 23), actionsIconTheme: IconThemeData(color: accent, size: 23)),
      navigationBarTheme: NavigationBarThemeData(height: 62, backgroundColor: surface,
        elevation: 0, indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          color: states.contains(WidgetState.selected) ? accent : const Color(0xFF8E8E93),
          fontSize: 13.5, fontFamily: navigationFont, fontWeight: FontWeight.w800)),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? accent : const Color(0xFF8E8E93), size: 23))),
      inputDecorationTheme: InputDecorationTheme(filled: true,
        fillColor: dark ? const Color(0xFF22262D) : const Color(0xFFF7F8FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border, width: .8)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border, width: .8)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accent, width: 1.2))),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: accent, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        foregroundColor: accent, side: BorderSide(color: border, width: .9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10))),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: accent, textStyle: TextStyle(fontFamily: roundedFont, fontWeight: FontWeight.w800))),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      listTileTheme: ListTileThemeData(iconColor: accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2)),
    );
  }
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: Store.darkMode,
    builder: (context, isDark, _) => MaterialApp(
      navigatorKey: appNavigatorKey,
      title: Store.appName,
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const AuthGate(),
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: isDark ? const Color(0xFF111114) : Colors.white,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: isDark ? const Color(0xFF111114) : Colors.white,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarDividerColor: isDark ? const Color(0xFF111114) : Colors.white,
          systemNavigationBarContrastEnforced: false,
        ), child: child ?? const SizedBox.shrink()),
    ),
  );
}
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) return const Login();
    return const _PostLoginSplash();
  }
}

class _PostLoginSplash extends StatefulWidget {
  const _PostLoginSplash();

  @override
  State<_PostLoginSplash> createState() => _PostLoginSplashState();
}

class _PostLoginSplashState extends State<_PostLoginSplash> {
  @override
  void initState() {
    super.initState();
    unawaited(_prepareApp());
  }

  Future<void> _prepareApp() async {
    final stopwatch = Stopwatch()..start();

    // Data komunitas boleh dimuat di latar belakang, tetapi splash visual dan
    // audio sepenuhnya berasal dari aset lokal. Tidak ada request Worker/URL.
    final cloudFuture = Store.loadCloudData()
        .timeout(const Duration(seconds: 12))
        .catchError((_) {});

    var audioStarted = false;
    StreamSubscription<void>? completionSubscription;
    Future<void>? audioFinished;
    try {
      await splashAudioPlayer.stop();
      await splashAudioPlayer.setReleaseMode(ReleaseMode.stop);
      final completion = Completer<void>();
      completionSubscription = splashAudioPlayer.onPlayerComplete.listen((_) {
        if (!completion.isCompleted) completion.complete();
      });
      await splashAudioPlayer.play(
        AssetSource('audio/Generated Audio November 20, 2026 - 11_04PM.wav'),
      );
      audioStarted = true;
      audioFinished = completion.future
          .timeout(const Duration(seconds: 15))
          .catchError((_) {});
    } catch (_) {
      // Jika audio gagal, splash tetap lanjut tanpa menghentikan aplikasi.
    }

    await cloudFuture;
    if (audioFinished != null) await audioFinished;
    await completionSubscription?.cancel();

    const splashDuration = Duration(milliseconds: 3200);
    final remaining = splashDuration - stopwatch.elapsed;
    if (remaining > Duration.zero) await Future.delayed(remaining);
    if (!mounted) {
      if (audioStarted) {
        try { await splashAudioPlayer.stop(); } catch (_) {}
      }
      return;
    }
    if (audioStarted) {
      try { await splashAudioPlayer.stop(); } catch (_) {}
    }
    if (_auth.currentUser == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Login()));
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => Store.isAdmin ? const AdminHome() : const Home(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final visual = Store.visualConfig;
    Color visualColor(dynamic value, Color fallback) {
      final hex = (value ?? '').toString().replaceFirst('#', '');
      if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) return fallback;
      return Color(0xFF000000 | int.parse(hex, radix: 16));
    }
    final primaryColor = visualColor(visual['primaryColor'], const Color(0xFF0878F9));
    final secondaryColor = visualColor(visual['secondaryColor'], const Color(0xFF55B8F4));
    final deepColor = Color.lerp(primaryColor, Colors.black, .42)!;
    final year = DateTime.now().year;
    final logoUrl = (visual['loginLogoUrl'] ?? '').toString().trim();
    final title = (visual['brandTitle'] ?? Store.appName).toString();
    final subtitle = (visual['brandSubtitle'] ?? Store.tagline).toString();
    final loadingTitle = (visual['loadingTitle'] ?? 'Menyiapkan ruang ceritamu...').toString();
    final loadingSubtitle = (visual['loadingSubtitle'] ?? '').toString();
    final copyright = (visual['copyrightText'] ?? '© $year Kalbar Kite • Hak cipta dilindungi').toString();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [deepColor, primaryColor, secondaryColor],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/Festival Budaya Katulistiwa di Pontianak.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [deepColor, primaryColor, secondaryColor],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.transparent,
                    ],
                    stops: const [0, .48, 1],
                  ),
                ),
              ),
            ),
            // Gambar yang diunggah dashboard tampil apa adanya, tanpa ditimpa gradien biru.
            Positioned(
              top: -90, right: -65,
              child: Container(
                width: 250, height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .07),
                ),
              ),
            ),
            Positioned(
              bottom: -110, left: -70,
              child: Container(
                width: 290, height: 290,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .06),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 94, height: 94,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [BoxShadow(
                            color: Color(0x33051B4A), blurRadius: 28, offset: Offset(0, 12),
                          )],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: logoUrl.startsWith('https://')
                            ? Image.network(
                                logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(CupertinoIcons.paperplane_fill, size: 48, color: Color(0xFF0878F9)),
                              )
                            : const Icon(CupertinoIcons.paperplane_fill, size: 48, color: Color(0xFF0878F9)),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: .2)),
                      const SizedBox(height: 7),
                      Text(subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: Colors.white.withValues(alpha: .92), fontWeight: FontWeight.w500)),
                      const SizedBox(height: 42),
                      const SizedBox(
                        width: 150,
                        child: LinearProgressIndicator(
                          minHeight: 4,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          backgroundColor: Color(0x55FFFFFF),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        loadingTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          shadows: const [
                            Shadow(color: Color(0xDD000000), blurRadius: 9, offset: Offset(0, 2)),
                            Shadow(color: Color(0x99000000), blurRadius: 3, offset: Offset(0, 1)),
                          ],
                        ),
                      ),
                      if (loadingSubtitle.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          loadingSubtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            height: 1.4,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            shadows: const [
                              Shadow(color: Color(0xDD000000), blurRadius: 9, offset: Offset(0, 2)),
                              Shadow(color: Color(0x99000000), blurRadius: 3, offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20, right: 20, bottom: 18,
              child: SafeArea(
                top: false,
                child: Text(copyright,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: .82), fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 34, height: 34, decoration: BoxDecoration(color: pale, borderRadius: BorderRadius.circular(11)), child: const Icon(CupertinoIcons.paperplane_fill, color: Color(0xFF007AFF), size: 20)),
    const SizedBox(width: 8),
    Text(Store.appName, style: GoogleFonts.fredoka(fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -.3, color: Theme.of(context).colorScheme.onSurface)),
    const SizedBox(width: 5),
    Transform.translate(
      offset: const Offset(0, -8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(color: const Color(0xFFE32636), borderRadius: BorderRadius.circular(5)),
        child: Text('BARU', style: GoogleFonts.fredoka(
          color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: .2)),
      ),
    ),
  ]);
}

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}
class _LoginState extends State<Login> {
  final username = TextEditingController(), password = TextEditingController(), fullName = TextEditingController();
  final phone = TextEditingController(), confirmPassword = TextEditingController();
  bool registering = false, hidePassword = true, hideConfirmPassword = true;
  bool rememberMe = true, acceptedTerms = false;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }
  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('kalbar_saved_email');
    if (saved != null && mounted) username.text = saved;
  }
  Future<void> _saveRememberedEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('kalbar_saved_email', email);
    } else {
      await prefs.remove('kalbar_saved_email');
    }
  }
  @override
  void dispose() {
    username.dispose(); password.dispose(); fullName.dispose();
    phone.dispose(); confirmPassword.dispose();
    super.dispose();
  }
  Future<void> login() async {
    if (submitting) return;
    final email = username.text.trim().toLowerCase();
    if (email.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan email dan kata sandi.')));
      return;
    }
    setState(() => submitting = true);
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password.text).timeout(const Duration(seconds: 20));
      Store.currentEmail = credential.user?.email ?? email;
      Store.currentUid = credential.user?.uid ?? '';
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const _PostLoginSplash()), (route) => false);
    } on FirebaseAuthException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_authMessage(error.code))));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal masuk: $error')));
    } finally { if (mounted) setState(() => submitting = false); }
  }
  Future<void> signInWithGoogle() async {
    if (submitting) return;
    setState(() => submitting = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential).timeout(const Duration(seconds: 25));
      final user = result.user!;
      Store.currentEmail = user.email ?? '';
      Store.currentUid = user.uid;
      final profileRef = _db.collection('profiles').doc(user.uid);
      final profile = await profileRef.get();
      if (!profile.exists) {
        final usernameValue = (user.email ?? 'warga').split('@').first.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
        await profileRef.set({'uid':user.uid,'email':user.email??'','name':user.displayName??'Pengguna Kalbar','username':usernameValue,'phone':'','bio':'','avatarUrl':user.photoURL??'','bannerUrl':'','role':'member','createdAt':FieldValue.serverTimestamp()});
        await _db.collection('public_profiles').doc(user.uid).set({'uid':user.uid,'name':user.displayName??'Pengguna Kalbar','username':usernameValue,'bio':'','avatarUrl':user.photoURL??'','bannerUrl':''});
      }
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const _PostLoginSplash()), (route) => false);
    } on FirebaseAuthException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_authMessage(error.code))));
    } catch (error) {
      final detail = error.toString();
      final message = detail.contains('sign_in_failed') || detail.contains('ApiException: 10') || detail.contains('j5: 10')
          ? 'Konfigurasi Google belum cocok. Periksa SHA-1/SHA-256, package name, dan google-services.json terbaru di Firebase.'
          : 'Login Google gagal. Periksa koneksi dan konfigurasi OAuth Firebase.';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }
  Future<void> register() async {
    if (submitting) return;
    final email = username.text.trim().toLowerCase();
    if (fullName.text.trim().isEmpty || !email.contains('@') || password.text.length < 8 || confirmPassword.text != password.text || !acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi nama, email valid, kata sandi minimal 8 karakter, konfirmasi kata sandi, dan persetujuan ketentuan.')));
      return;
    }
    setState(() => submitting = true);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password.text).timeout(const Duration(seconds: 20));
      final user = credential.user!;
      await user.updateDisplayName(fullName.text.trim());
      final defaultUsername = email.split('@').first.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
      Store.currentEmail=email; Store.currentUid=user.uid;
      var profileSaved = true;
      try {
        await _db.collection('profiles').doc(user.uid).set({'uid':user.uid,'email':email,'name':fullName.text.trim(),'username':defaultUsername,'phone':phone.text.trim(),'bio':'','avatarUrl':'','bannerUrl':'','role':'member','createdAt':FieldValue.serverTimestamp()}).timeout(const Duration(seconds: 12));
        await _db.collection('public_profiles').doc(user.uid).set({'uid':user.uid,'name':fullName.text.trim(),'username':defaultUsername,'phone':phone.text.trim(),'bio':'','avatarUrl':'','bannerUrl':'','createdAt':FieldValue.serverTimestamp()}).timeout(const Duration(seconds: 12));
        Store.memberNames[email] = fullName.text.trim(); Store.usernames[email] = defaultUsername;
      } catch (_) { profileSaved = false; }
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const _PostLoginSplash()), (route) => false);
      if (!profileSaved) {
        // Akun Firebase Auth sudah berhasil dibuat; profil dapat disinkronkan dari halaman profil.
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_authMessage(error.code))));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat akun: $error')));
    } finally { if (mounted) setState(() => submitting = false); }
  }
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
    child: Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _KalbarAuthHeader(),
                const SizedBox(height: 12),
                Text(
                  registering ? 'Buat Akun' : 'Masuk ke Akun',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(fontSize: 34, fontWeight: FontWeight.w600, color: const Color(0xFF111B3A), height: 1.12),
                ),
                const SizedBox(height: 9),
                Text(
                  registering
                    ? 'Gabung dengan komunitas Kalimantan Barat.'
                    : 'Masuk untuk berbagi, membaca, dan terhubung dengan komunitas Kalimantan Barat.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: const Color(0xFF667085), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 27),
                if (registering) ...[
                  _AuthLabel(text: 'Nama Lengkap', icon: CupertinoIcons.person),
                  const SizedBox(height: 7),
                  _AuthInput(controller: fullName, hint: 'Masukkan nama lengkap', capitalization: TextCapitalization.words),
                  const SizedBox(height: 16),
                  _AuthLabel(text: 'Nomor WhatsApp (opsional)', icon: CupertinoIcons.phone),
                  const SizedBox(height: 7),
                  _AuthInput(controller: phone, hint: '08xxxxxxxxxx', keyboard: TextInputType.phone),
                  const SizedBox(height: 16),
                ],
                _AuthLabel(text: 'Email', icon: CupertinoIcons.mail),
                const SizedBox(height: 7),
                _AuthInput(controller: username, hint: 'Masukkan email kamu', keyboard: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _AuthLabel(text: 'Kata Sandi', icon: CupertinoIcons.lock),
                const SizedBox(height: 7),
                _AuthInput(
                  controller: password,
                  hint: registering ? 'Minimal 8 karakter' : 'Masukkan kata sandi',
                  obscure: hidePassword,
                  suffix: IconButton(
                    onPressed: () => setState(() => hidePassword = !hidePassword),
                    icon: Icon(hidePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash, color: const Color(0xFF667085)),
                  ),
                  onSubmitted: (_) => registering ? register() : login(),
                ),
                if (registering) ...[
                  const SizedBox(height: 16),
                  _AuthLabel(text: 'Konfirmasi Kata Sandi', icon: CupertinoIcons.lock_rotation),
                  const SizedBox(height: 7),
                  _AuthInput(
                    controller: confirmPassword,
                    hint: 'Ulangi kata sandi',
                    obscure: hideConfirmPassword,
                    suffix: IconButton(
                      onPressed: () => setState(() => hideConfirmPassword = !hideConfirmPassword),
                      icon: Icon(hideConfirmPassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash, color: const Color(0xFF667085)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    value: acceptedTerms,
                    onChanged: (value) => setState(() => acceptedTerms = value ?? false),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    activeColor: const Color(0xFF0878F9),
                    title: Text('Saya setuju dengan ketentuan penggunaan dan kebijakan privasi Kalbar Kite.', style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF596273), height: 1.35)),
                  ),
                ],
                if (!registering) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        height: 28,
                        child: Checkbox(
                          value: rememberMe,
                          onChanged: (value) => setState(() => rememberMe = value ?? false),
                          activeColor: const Color(0xFF0878F9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                      Text('Ingat saya', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF596273), fontWeight: FontWeight.w600)),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final email = username.text.trim();
                          if (!email.contains('@')) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan email untuk reset password.')));
                            return;
                          }
                          try {
                            _auth.setLanguageCode('id');
                            await _auth.sendPasswordResetEmail(email: email);
                            if (mounted) await showDialog<void>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: Text('Periksa email kamu', style: GoogleFonts.fredoka(fontSize: 22)),
                                content: Text('Jika $email terdaftar, Firebase sudah mengirim tautan untuk mengatur kata sandi baru.', style: GoogleFonts.inter()),
                                actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Mengerti'))],
                              ),
                            );
                          } catch (error) {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengirim reset password: $error')));
                          }
                        },
                        child: Text('Lupa password?', style: GoogleFonts.fredoka(fontSize: 15, color: const Color(0xFF0878F9), fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 17),
                SizedBox(
                  height: 58,
                  child: FilledButton(
                    onPressed: submitting ? null : (registering ? register : () async {
                      await _saveRememberedEmail(username.text.trim().toLowerCase());
                      await login();
                    }),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0878F9),
                      disabledBackgroundColor: const Color(0xFF83B9F5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: submitting
                      ? const SizedBox(width: 21, height: 21, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(registering ? 'Daftar Sekarang' : 'Masuk Sekarang', style: GoogleFonts.fredoka(fontSize: 21, fontWeight: FontWeight.w600)),
                  ),
                ),
                if (!registering) ...[
                  const SizedBox(height: 23),
                  Row(children: [
                    const Expanded(child: Divider(color: Color(0xFFD9DEE8), thickness: 1)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Text('atau', style: GoogleFonts.fredoka(fontSize: 16, color: const Color(0xFF687083)))),
                    const Expanded(child: Divider(color: Color(0xFFD9DEE8), thickness: 1)),
                  ]),
                  const SizedBox(height: 17),
                  SizedBox(
                    height: 58,
                    child: OutlinedButton(
                      onPressed: submitting ? null : signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF111B3A),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFD8DEEA), width: 1.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const _GoogleFourColorMark(size: 26),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'Lanjutkan dengan Google',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
                const SizedBox(height: 27),
                if (!registering) const _AuthFeatureStrip(),
                const SizedBox(height: 25),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      registering = !registering;
                      acceptedTerms = false;
                    }),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.fredoka(fontSize: 16, color: const Color(0xFF687083)),
                        children: [
                          TextSpan(text: registering ? 'Sudah punya akun? ' : 'Belum punya akun? '),
                          TextSpan(text: registering ? 'Masuk' : 'Daftar', style: const TextStyle(color: Color(0xFF0878F9), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 17),
              ],
            ),
          ),
        ),
      ),
    ),
  ));
}

class _KalbarAuthHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: Store.appConfigRevision,
    builder: (context, revision, _) {
      final visual = Store.visualConfig;
      final logoUrl = (visual['loginLogoUrl'] ?? '').toString().trim();
      final title = (visual['brandTitle'] ?? Store.appName).toString();
      final subtitle = (visual['brandSubtitle'] ?? Store.tagline).toString();
      final screenWidth = MediaQuery.sizeOf(context).width;
      return SizedBox(
        height: 300,
        child: OverflowBox(
          alignment: Alignment.center,
        minWidth: screenWidth,
        maxWidth: screenWidth,
        minHeight: 300,
        maxHeight: 300,
        child: SizedBox(
          width: screenWidth,
          height: 300,
          child: ClipRect(
            child: Stack(
              alignment: Alignment.topCenter,
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/kalbar_kite_login.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
                // Soft white mist at the straight lower edge of the hero image.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: .22),
                          Colors.white.withValues(alpha: .78),
                        ],
                        stops: const [0, .58, 1],
                      ),
                    ),
                  ),
                ),

            ],
          ),
          ),
        ),
      ),
    );
    },
  );
}

class _AuthLabel extends StatelessWidget {
  final String text; final IconData icon;
  const _AuthLabel({required this.text, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: const Color(0xFF111B3A), size: 22),
    const SizedBox(width: 12),
    Text(text, style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF111B3A))),
  ]);
}
class _AuthInput extends StatelessWidget {
  final TextEditingController controller; final String hint;
  final TextInputType keyboard; final TextCapitalization capitalization;
  final bool obscure; final Widget? suffix; final ValueChanged<String>? onSubmitted;
  const _AuthInput({required this.controller, required this.hint, this.keyboard = TextInputType.text, this.capitalization = TextCapitalization.none, this.obscure = false, this.suffix, this.onSubmitted});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, keyboardType: keyboard, textCapitalization: capitalization,
    obscureText: obscure, onSubmitted: onSubmitted,
    style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF111B3A)),
    decoration: InputDecoration(
      hintText: hint, hintStyle: GoogleFonts.fredoka(fontSize: 15, color: const Color(0xFF8791A3), fontWeight: FontWeight.w400),
      prefixIcon: keyboard == TextInputType.emailAddress ? null : null,
      suffixIcon: suffix, filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 19, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFD8DEEA), width: 1.3)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFD8DEEA), width: 1.3)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF0878F9), width: 1.6)),
    ),
  );
}
class _GoogleFourColorMark extends StatelessWidget {
  final double size;
  const _GoogleFourColorMark({this.size = 24});
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: CustomPaint(painter: _GoogleFourColorPainter()));
}
class _GoogleFourColorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = size.width * .18..strokeCap = StrokeCap.butt;
    final rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width * .34);
    p.color = const Color(0xFF4285F4); canvas.drawArc(rect, -.55, 1.45, false, p);
    p.color = const Color(0xFF34A853); canvas.drawArc(rect, .85, 1.0, false, p);
    p.color = const Color(0xFFFBBC05); canvas.drawArc(rect, 1.85, 1.0, false, p);
    p.color = const Color(0xFFEA4335); canvas.drawArc(rect, 2.85, 1.25, false, p);
    p.color = const Color(0xFF4285F4); canvas.drawLine(Offset(size.width*.5,size.height*.5), Offset(size.width*.87,size.height*.5), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class _AuthFeatureStrip extends StatelessWidget {
  const _AuthFeatureStrip();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 9),
    decoration: BoxDecoration(color: const Color(0xFFF0F6FF), borderRadius: BorderRadius.circular(23)),
    child: Row(children: const [
      Expanded(child: _AuthFeature(icon: CupertinoIcons.person_3, title: 'Komunitas', subtitle: 'Lokal', color: Color(0xFF0878F9))),
      _AuthFeatureDivider(),
      Expanded(child: _AuthFeature(icon: CupertinoIcons.book, title: 'Cerita &', subtitle: 'Wawasan', color: Color(0xFF0878F9))),
      _AuthFeatureDivider(),
      Expanded(child: _AuthFeature(icon: Icons.eco_outlined, title: 'Jaga Warisan', subtitle: 'Kalbar', color: Color(0xFF25A65A))),
    ]),
  );
}
class _AuthFeatureDivider extends StatelessWidget {
  const _AuthFeatureDivider();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 57, color: const Color(0xFFD7E1F0));
}
class _AuthFeature extends StatelessWidget {
  final IconData icon; final String title, subtitle; final Color color;
  const _AuthFeature({required this.icon, required this.title, required this.subtitle, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: color, size: 27),
    const SizedBox(height: 6),
    Text(title, textAlign: TextAlign.center, style: GoogleFonts.fredoka(fontSize: 12.5, color: const Color(0xFF111B3A), fontWeight: FontWeight.w500)),
    Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.fredoka(fontSize: 12.5, color: const Color(0xFF111B3A), fontWeight: FontWeight.w500)),
  ]);
}
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> with WidgetsBindingObserver {
  int tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateLastSeen();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _updateLastSeen();
  }

  Future<void> _updateLastSeen() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _db.collection('public_profiles').doc(user.uid).set({
        'uid': user.uid,
        'lastSeenAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      final profile = await _db.collection('profiles').doc(user.uid).get();
      if (profile.exists) {
        await profile.reference.set({'lastSeenAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Brand(), actions: [
      IconButton(
        tooltip: 'Notifikasi dari admin',
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BroadcastNotificationsPage())),
        icon: const Icon(CupertinoIcons.bell),
        color: Theme.of(context).colorScheme.onSurface,
      ),
      IconButton(
        tooltip: Theme.of(context).brightness == Brightness.dark ? 'Aktifkan mode terang' : 'Aktifkan mode malam',
        onPressed: () => Store.setDarkMode(Theme.of(context).brightness != Brightness.dark),
        icon: Icon(Theme.of(context).brightness == Brightness.dark ? CupertinoIcons.sun_max : CupertinoIcons.moon),
        color: Theme.of(context).colorScheme.onSurface,
      ),
      const SizedBox(width: 6),
    ]),
    body: IndexedStack(index: tab, children: const [HomePage(), InfoPage(), ActivityPage(), ChatListPage(embedded: true), ProfilePage()]),
    bottomNavigationBar: _iosBottomBar(context, NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (v) => setState(() => tab = v),
      destinations: const [
        NavigationDestination(icon: Icon(CupertinoIcons.house), selectedIcon: Icon(CupertinoIcons.house_fill), label: 'Home'),
        NavigationDestination(icon: Icon(CupertinoIcons.info), selectedIcon: Icon(CupertinoIcons.info_circle_fill), label: 'Info'),
        NavigationDestination(icon: Icon(CupertinoIcons.square_grid_2x2), selectedIcon: Icon(CupertinoIcons.square_grid_2x2_fill), label: 'Posting'),
        NavigationDestination(icon: Icon(CupertinoIcons.chat_bubble_2), selectedIcon: Icon(CupertinoIcons.chat_bubble_2_fill), label: 'Chat'),
        NavigationDestination(icon: Icon(CupertinoIcons.person), selectedIcon: Icon(CupertinoIcons.person_fill), label: 'Profile'),
      ],
    )),
  );
}

Widget _iosBottomBar(BuildContext context, NavigationBar navigationBar) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return SafeArea(top: false, child: Container(
    decoration: BoxDecoration(color: dark ? const Color(0xFF1C1C1E) : Colors.white,
      border: Border(top: BorderSide(color: dark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA), width: .6))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      navigationBar,
    ]),
  ));
}

class ContributePage extends StatelessWidget {
  const ContributePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 26), children: [
    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: pale, borderRadius: BorderRadius.circular(11), border: Border.all(color: Theme.of(context).dividerColor)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.volunteer_activism_outlined, color: forest, size: 32),
        SizedBox(height: 9),
        Text('Kontribusi untuk Kalbar', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: ink)),
        SizedBox(height: 5),
        Text('Ambil bagian dalam membantu sesama melalui layanan donor darah Kalbar Kite.', style: TextStyle(color: ink, height: 1.4)),
      ]),
    ),
    const SizedBox(height: 18),
    FeatureTile(icon: Icons.bloodtype_outlined, title: 'Daftar sebagai pendonor', subtitle: 'Bagikan informasi golongan darah dan kontak', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonorForm(request: false)))),
    FeatureTile(icon: Icons.emergency_outlined, title: 'Ajukan kebutuhan darah', subtitle: 'Buat permintaan bantuan donor darah', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonorForm(request: true)))),
    const SizedBox(height: 8),
    Text('Terima kasih sudah ikut membangun kepedulian di Kalimantan Barat.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
  ]);
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  void _openCategory(BuildContext context, String title, String description) {
    if (title == 'Wilayah') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
    } else {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ExploreCategoryPage(title: title, description: description)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultCards = [
      _ExploreCardData('Wilayah', 'Jelajahi kabupaten dan kota di Kalbar',
        'https://commons.wikimedia.org/wiki/Special:FilePath/Keraton_kesultanan_sambas_kalimantan_barat.jpg?width=900', CupertinoIcons.location_solid,
        const Color(0xFFEAF4FF), const Color(0xFF1478E8)),
      _ExploreCardData('Wisata', 'Destinasi alam dan budaya Kalbar',
        'https://www.pesonaindo.com/wp-content/uploads/2016/04/P9203020.jpg', CupertinoIcons.camera_fill,
        const Color(0xFFFFF3E3), const Color(0xFFF28A16)),
      _ExploreCardData('Kuliner', 'Makanan khas dari berbagai daerah',
        'https://image.popmama.com/post/20260512/upload_4a7fe54d554ab970173472ff8fa3aa73_2392ba97-ccfb-4c7e-b185-07b1eff66bbc.jpg', Icons.restaurant_menu,
        const Color(0xFFFFEAF0), const Color(0xFFE94B68)),
      _ExploreCardData('Usaha', 'Produk dan usaha lokal masyarakat',
        'https://jadesta.kemenpar.go.id/imgpost/2022/08/02/tenun-sambas.jpg', Icons.storefront,
        const Color(0xFFEAF9EF), const Color(0xFF20A35A)),
      _ExploreCardData('Acara', 'Festival dan kegiatan budaya',
        'https://awsimages.detik.net.id/community/media/visual/2024/11/07/seni-tato-suku-dayak-iban-2.jpeg?q=90&w=650', CupertinoIcons.calendar,
        const Color(0xFFF1ECFF), const Color(0xFF7545E8)),
      _ExploreCardData('Permainan', 'Permainan tradisional Kalbar',
        'https://beritanasional.com/storage/2024/10/festival-melayu-ajang-menumbuhkan-cinta-kepada-warisan-budaya-20102024-194024.jpg', CupertinoIcons.gamecontroller_fill,
        const Color(0xFFF0ECFF), const Color(0xFF6538D6)),
      _ExploreCardData('Ensiklopedia', 'Kenali sejarah dan budaya Kalbar',
        'https://commons.wikimedia.org/wiki/Special:FilePath/Dayak_book.jpg?width=900', CupertinoIcons.book_fill,
        const Color(0xFFEAF4FF), const Color(0xFF1478E8)),
      _ExploreCardData('Layanan Publik', 'Informasi layanan masyarakat',
        'https://beritanasional.com/storage/2024/10/festival-melayu-ajang-menumbuhkan-cinta-kepada-warisan-budaya-20102024-194024.jpg', CupertinoIcons.person_2_fill,
        const Color(0xFFFFF0E8), const Color(0xFFEA851B)),
    ];

    final iconMap = <String,IconData>{
      'compass': CupertinoIcons.compass_fill, 'location': CupertinoIcons.location_solid,
      'camera': CupertinoIcons.camera_fill, 'restaurant': Icons.restaurant_menu,
      'store': Icons.storefront, 'calendar': CupertinoIcons.calendar,
      'game': CupertinoIcons.gamecontroller_fill, 'book': CupertinoIcons.book_fill,
      'people': CupertinoIcons.person_2_fill, 'leaf': Icons.eco,
      'museum': Icons.museum_outlined, 'map': CupertinoIcons.map_fill,
    };
    final palette = <(Color,Color)>[
      (const Color(0xFFEAF4FF), const Color(0xFF1478E8)),
      (const Color(0xFFFFF3E3), const Color(0xFFF28A16)),
      (const Color(0xFFFFEAF0), const Color(0xFFE94B68)),
      (const Color(0xFFEAF9EF), const Color(0xFF20A35A)),
      (const Color(0xFFF1ECFF), const Color(0xFF7545E8)),
      (const Color(0xFFF0ECFF), const Color(0xFF6538D6)),
    ];
    final cards = Store.exploreCards.isEmpty ? defaultCards : Store.exploreCards.asMap().entries.map((entry) {
      final item = entry.value;
      final colors = palette[entry.key % palette.length];
      return _ExploreCardData(
        item['title'] ?? 'Jelajahi',
        item['subtitle'] ?? '',
        item['imageUrl'] ?? '',
        iconMap[item['icon']] ?? CupertinoIcons.compass_fill,
        colors.$1,
        colors.$2,
      );
    }).toList();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      children: [
        const KalbarLiveMap(height: 270),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: GridView.builder(
            itemCount: cards.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
              mainAxisExtent: 108,
            ),
            itemBuilder: (context, index) {
              final card = cards[index];
              final dark = Theme.of(context).brightness == Brightness.dark;
              final cardBackground = dark
                  ? Color.lerp(card.background, const Color(0xFF171B24), .88)!
                  : card.background;
              final titleColor = Theme.of(context).colorScheme.onSurface;
              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => _openCategory(context, card.title, card.description),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: dark ? Colors.white.withValues(alpha: .07) : Colors.transparent,
                      ),
                      gradient: LinearGradient(
                        colors: [cardBackground, cardBackground.withValues(alpha: dark ? .94 : .82)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Semua kategori mendapat bidang foto yang sama lebar,
                        // bukan hanya kartu Wilayah.
                        final imageWidth = constraints.maxWidth * .46;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              width: imageWidth,
                              child: ClipPath(
                                clipper: _ExploreImageClipper(),
                                child: CachedNetworkImage(
                                  imageUrl: card.image,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 720,
                                  maxWidthDiskCache: 900,
                                  filterQuality: FilterQuality.high,
                                  fadeInDuration: const Duration(milliseconds: 180),
                                  placeholder: (_, __) => Container(
                                    color: card.accent.withValues(alpha: dark ? .20 : .12)),
                                  errorWidget: (_, __, ___) => Container(
                                    color: card.accent.withValues(alpha: dark ? .20 : .12),
                                    child: Icon(card.icon, color: card.accent, size: 26)),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 10,
                              right: imageWidth + 7,
                              top: 0,
                              bottom: 0,
                              child: Row(
                                children: [
                                  Icon(card.icon, color: card.accent, size: 24),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        card.title,
                                        maxLines: 1,
                                        softWrap: false,
                                        style: GoogleFonts.fredoka(
                                          fontSize: 16,
                                          height: 1,
                                          fontWeight: FontWeight.w700,
                                          color: titleColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ));
  }
}

class _ExploreImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * .36, 0)
      ..quadraticBezierTo(size.width * .12, size.height * .48, 0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class KalbarLiveMap extends StatelessWidget {
  final double height;
  const KalbarLiveMap({super.key, this.height = 205});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.zero,
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ExploreMapPage())),
          child: SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  child: MapLibreMap(
                    styleString: dark
                      ? 'https://tiles.openfreemap.org/styles/dark'
                      : 'https://tiles.openfreemap.org/styles/liberty',
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(0.25, 109.55),
                      zoom: 7.1,
                    ),
                    compassEnabled: false,
                    rotateGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    myLocationEnabled: false,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        (dark ? Colors.black : Colors.white).withValues(alpha: .92),
                        (dark ? Colors.black : Colors.white).withValues(alpha: .40),
                        Colors.transparent,
                      ],
                      stops: const [0, .48, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 18,
                  bottom: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Jelajahi Kalbar',
                        style: GoogleFonts.fredoka(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: dark ? Colors.white : const Color(0xFF101B39),
                        )),
                      const SizedBox(height: 3),
                      Text('Peta hidup Kalimantan Barat • ketuk untuk membuka.',
                        maxLines: 2,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: dark ? Colors.white70 : const Color(0xFF555B6C),
                        )),
                    ],
                  ),
                ),
                Positioned(
                  right: 13,
                  bottom: 12,
                  child: Icon(Icons.open_in_full_rounded,
                    size: 17, color: dark ? Colors.white70 : Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExploreMapPage extends StatefulWidget {
  const ExploreMapPage({super.key});

  @override
  State<ExploreMapPage> createState() => _ExploreMapPageState();
}

class _ExploreMapPageState extends State<ExploreMapPage> {
  MapLibreMapController? _controller;
  Position? _position;
  bool _styleReady = false;
  bool _dark = false;
  bool _locating = false;
  String _message = 'Menampilkan Tugu Khatulistiwa, Pontianak';

  static const LatLng _kalbarCenter = LatLng(0.000919, 109.322389);
  String get _style => _dark
      ? 'https://tiles.openfreemap.org/styles/dark'
      : 'https://tiles.openfreemap.org/styles/liberty';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
  }

  Future<void> _onStyleLoaded() async {
    _styleReady = true;
    await _updateMarker();
    if (_position == null) _locateDevice();
  }

  Future<void> _updateMarker() async {
    final c = _controller;
    if (!_styleReady || c == null || _position == null) return;
    try {
      await c.clearCircles();
      await c.addCircle(CircleOptions(
        geometry: LatLng(_position!.latitude, _position!.longitude),
        circleRadius: 10,
        circleColor: '#087CF0',
        circleStrokeColor: '#FFFFFF',
        circleStrokeWidth: 3,
        circleOpacity: 1,
      ));
    } catch (_) {}
  }

  Future<void> _locateDevice() async {
    if (_locating) return;
    setState(() {
      _locating = true;
      _message = 'Mendeteksi lokasi perangkat…';
    });
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (mounted) setState(() {
          _locating = false;
          _message = 'GPS belum aktif • menampilkan peta Kalimantan Barat';
        });
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() {
          _locating = false;
          _message = 'Izin lokasi tidak tersedia • jelajahi peta secara manual';
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return;
      setState(() {
        _position = position;
        _locating = false;
        _message = 'Lokasi perangkat saat ini';
      });
      await _updateMarker();
      await _controller?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
        )),
        duration: const Duration(milliseconds: 700),
      );
    } catch (_) {
      if (mounted) setState(() {
        _locating = false;
        _message = 'Lokasi tidak ditemukan • peta Kalbar tetap tersedia';
      });
    }
  }

  Widget _control(IconData icon, VoidCallback action, {String? tooltip}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).cardColor.withValues(alpha: .96),
        elevation: 3,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: action,
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 22,
              color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: MapLibreMap(
              key: ValueKey(_dark),
              styleString: _style,
              initialCameraPosition: const CameraPosition(
                target: _kalbarCenter,
                zoom: 14.2,
              ),
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoaded,
              compassEnabled: true,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: false,
              zoomGesturesEnabled: true,
              myLocationEnabled: false,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: Column(
              children: [
                _control(CupertinoIcons.arrow_left,
                  () => Navigator.pop(context), tooltip: 'Kembali'),
                _control(_dark ? CupertinoIcons.sun_max : CupertinoIcons.moon,
                  () => setState(() => _dark = !_dark), tooltip: 'Tema peta'),
                _control(_locating ? CupertinoIcons.hourglass : CupertinoIcons.location,
                  _locateDevice, tooltip: 'Lokasi saya'),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: (dark ? const Color(0xFF17191E) : Colors.white)
                    .withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (dark ? Colors.white : Colors.black).withValues(alpha: .08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Jelajahi Kalbar',
                      style: GoogleFonts.fredoka(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: dark ? Colors.white : const Color(0xFF101B39))),
                    Text(_message,
                      style: GoogleFonts.inter(
                        fontSize: 11, color: dark ? Colors.white70 : Colors.black54)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreCardData {
  final String title, description, image;
  final IconData icon;
  final Color background, accent;
  const _ExploreCardData(
    this.title, this.description, this.image, this.icon, this.background, this.accent,
  );
}
class ExploreCategoryPage extends StatelessWidget {
  final String title, description;
  const ExploreCategoryPage({super.key, required this.title, required this.description});
  @override
  Widget build(BuildContext context) => BackPage(
    title: title,
    child: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(CupertinoIcons.compass, color: forest, size: 48),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
      const SizedBox(height: 7),
      Text(description, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const SizedBox(height: 12),
      const Text('Konten kategori ini sedang disiapkan untuk Kalbar Kite.', textAlign: TextAlign.center),
    ]))),
  );
}

class WelcomeBanner extends StatefulWidget {
  const WelcomeBanner({super.key});
  @override
  State<WelcomeBanner> createState() => _WelcomeBannerState();
}

class _WelcomeBannerState extends State<WelcomeBanner> {
  final PageController _pageController = PageController();
  Timer? _carouselTimer;
  int _currentSlide = 0;
  int _precacheRevision = -1;

  static const List<Map<String,String>> _defaultSlides = [
    {'title': 'Jelajahi keindahan Kalimantan Barat', 'imageUrl': ''},
    {'title': 'Budaya, cerita, dan alam Kalbar', 'imageUrl': ''},
    {'title': 'Semua layanan Kalbar dalam satu aplikasi', 'imageUrl': ''},
  ];

  List<Map<String,String>> get _slides =>
      Store.welcomeSlides.isNotEmpty ? Store.welcomeSlides : _defaultSlides;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String get dateLabel {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  IconData get _greetingIcon {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 18) return CupertinoIcons.sun_max_fill;
    return CupertinoIcons.moon_stars_fill;
  }

  @override
  void initState() {
    super.initState();
    _carouselTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final count = _slides.length;
      final next = (_currentSlide + 1) % count;
      _pageController.animateToPage(next, duration: const Duration(milliseconds: 650), curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: Store.appConfigRevision,
    builder: (context, revision, _) => _buildBanner(context, revision),
  );

  Widget _buildBanner(BuildContext context, int revision) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final slides = _slides;
    if (_precacheRevision != revision) {
      _precacheRevision = revision;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final imageUrls = <String>{
          ...slides.map((item) => (item['imageUrl'] ?? '').trim()),
          ...Store.eventPosts.take(12).map((item) => (item['imageUrl'] ?? '').trim()),
          ...Store.infoPosts.take(8).map((item) => (item['imagePath'] ?? '').trim()),
          ...Store.historyPosts.take(14).map((item) => (item['imageUrl'] ?? '').trim()),
          ...Store.randomCards.take(4).map((item) => (item['imageUrl'] ?? '').trim()),
          ...Store.activityPosts.take(10).map((item) => (item['imagePath'] ?? '').trim()),
          ...Store.stories.take(10).map((item) => (item['imageUrl'] ?? '').trim()),
          ...Store.avatarUrls.values.take(16),
          ...Store.bannerUrls.values.take(8),
        }.where((url) => url.startsWith('https://'));
        for (final url in imageUrls) {
          precacheImage(CachedNetworkImageProvider(url), context).catchError((_) {});
        }
      });
    }
    final activeIndex = _currentSlide % slides.length;
    return Container(
      height: 238,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: dark ? const Color(0xFF17191D) : const Color(0xFF30343B),
        // Flat banner without colored shadow.
      ),
      child: Stack(fit: StackFit.expand, children: [
        PageView.builder(
          controller: _pageController,
          itemCount: slides.length,
          onPageChanged: (index) => setState(() => _currentSlide = index),
          itemBuilder: (context, index) {
            final imageUrl = slides[index]['imageUrl'] ?? '';
            if (imageUrl.startsWith('https://')) {
              return CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const _WelcomeBannerFallback(),
                errorWidget: (_, __, ___) => const _WelcomeBannerFallback(),
              );
            }
            return const _WelcomeBannerFallback();
          },
        ),
        const DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0x99101F3C), Color(0x22101F3C), Color(0xCC071C38)],
            stops: [0, .48, 1]),
        )),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 17, 18, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(_greetingIcon, color: Colors.white, size: 27),
              const SizedBox(width: 9),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(greeting, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, fontFamily: GoogleFonts.fredoka().fontFamily))),
                  const SizedBox(width: 6),
                  const Text('👋', style: TextStyle(fontSize: 18)),
                ]),
                Text('Senang melihatmu di Kalbar Kite', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: GoogleFonts.nunitoSans().fontFamily)),
              ])),
              Text(dateLabel, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
            ]),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: Text(slides[activeIndex]['title']?.isNotEmpty == true
                ? slides[activeIndex]['title']!
                : 'Jelajahi Kalimantan Barat',
                key: ValueKey(activeIndex),
                maxLines: 2,
                style: TextStyle(color: Colors.white, fontSize: 23, height: 1.12,
                  fontWeight: FontWeight.w700, fontFamily: GoogleFonts.fredoka().fontFamily,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 9)])),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Row(children: List.generate(slides.length, (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 5),
                width: activeIndex == index ? 18 : 7, height: 7,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha:activeIndex == index ? 1 : .48), borderRadius: BorderRadius.circular(10)),
              ))),
              const Spacer(),
              _bannerArrow(Icons.chevron_left_rounded, () {
                final next = (activeIndex - 1 + slides.length) % slides.length;
                _pageController.animateToPage(next, duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
              }),
              const SizedBox(width: 8),
              _bannerArrow(Icons.chevron_right_rounded, () {
                final next = (activeIndex + 1) % slides.length;
                _pageController.animateToPage(next, duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
              }),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _bannerArrow(IconData icon, VoidCallback onTap) => Material(
    color: Colors.white.withValues(alpha:.20),
    shape: const CircleBorder(),
    child: InkWell(onTap: onTap, customBorder: const CircleBorder(),
      child: SizedBox(width: 34, height: 34, child: Icon(icon, color: Colors.white, size: 23))),
  );
}

class _WelcomeBannerFallback extends StatelessWidget {
  const _WelcomeBannerFallback();
  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF3B91D9), Color(0xFF123C70)]),
    ),
  );
}

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});
  @override
  State<ActivityPage> createState() => _ActivityPageState();
}
class _ActivityPageState extends State<ActivityPage> {
  bool _loadingFeed = true;
  String _feedError = '';
  @override
  void initState() {
    super.initState();
    _loadFeed();
  }
  Future<void> _loadFeed() async {
    try {
      await Store.loadActivityFeed();
      if (mounted) setState(() { _loadingFeed = false; _feedError = ''; });
    } catch (error) {
      if (mounted) setState(() { _loadingFeed = false; _feedError = error.toString(); });
    }
  }
  Future<void> _compose() async {
    final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const ActivityComposePage()));
    if (result == true && mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final posts = Store.activityPosts.toList();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadFeed,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 90), children: [
          Row(children: [
            Expanded(child: Text('Aktivitas',
              style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.w700,
                letterSpacing: -.3, color: Theme.of(context).colorScheme.onSurface))),
            PopupMenuButton<String>(
              tooltip: 'Menu aktivitas',
              icon: Icon(Icons.more_horiz_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant, size: 27),
              onSelected: (value) {
                if (value == 'post') _compose();
                if (value == 'story') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryComposePage()))
                    .then((text) { if (text != null && mounted) setState(() {}); });
                }
                if (value == 'chat') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListPage()));
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'post', child: ListTile(
                  dense: true, leading: Icon(CupertinoIcons.pencil), title: Text('Buat postingan'))),
                PopupMenuItem(value: 'story', child: ListTile(
                  dense: true, leading: Icon(Icons.add_circle_outline), title: Text('Bagikan cerita'))),
                PopupMenuItem(value: 'chat', child: ListTile(
                  dense: true, leading: Icon(CupertinoIcons.chat_bubble), title: Text('Pesan teman'))),
              ],
            ),
          ]),
          const SizedBox(height: 14),
          _StoriesStrip(onAdd: () async {
            final text = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const StoryComposePage()));
            if (text != null && text.trim().isNotEmpty && mounted) setState(() {});
          }, onOpen: (story) {
            final owner = story['uid'] ?? '';
            final items = Store.stories.where((item) => (item['uid'] ?? '') == owner).toList();
            Navigator.push(context, MaterialPageRoute(builder: (_) => StoryViewerPage(stories: items)));
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha:.65)),
            ),
            child: Row(children: [
              _accountAvatar(Store.currentEmail, radius: 21),
              const SizedBox(width: 11),
              Expanded(
                child: InkWell(
                  onTap: _compose,
                  borderRadius: BorderRadius.circular(13),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF242424) : const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text('Apa yang ingin kamu ceritakan?',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                tooltip: 'Buat postingan',
                onPressed: _compose,
                icon: Icon(CupertinoIcons.plus_circle_fill, color: Theme.of(context).colorScheme.onSurface, size: 25),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          if (_loadingFeed) const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator())),
          if (!_loadingFeed && _feedError.isNotEmpty) Padding(padding: const EdgeInsets.all(16), child: Text('Gagal memuat aktivitas: $_feedError', style: const TextStyle(color: Colors.red))),
          if (!_loadingFeed && posts.isEmpty)
            Container(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor)),
              child: Column(children: [
                Icon(Icons.dynamic_feed_outlined, size: 42, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 10),
                Text('Belum ada aktivitas', style: GoogleFonts.fredoka(fontSize: 19, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 5),
                Text('Jadilah yang pertama membagikan cerita atau kabar dari daerahmu.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 13),
                FilledButton.icon(onPressed: _compose, icon: const Icon(CupertinoIcons.pencil), label: const Text('Buat postingan')),
              ]),
            ),
          for (final post in posts) _ActivityPostCard(
            post: post,
            onDeleted: () { if (mounted) setState(() {}); },
            onComments: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityCommentsPage(postId: post['id'] ?? '')));
              if (mounted) setState(() {});
            },
          ),
        ]),
      ),
    );
  }
}

class StoryViewerPage extends StatefulWidget {
  final List<Map<String,String>> stories;
  const StoryViewerPage({super.key, required this.stories});
  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}
class _StoryViewerPageState extends State<StoryViewerPage> {
  int index = 0;
  double progress = 0;
  Timer? timer;
  VideoPlayerController? video;
  bool paused = false;
  bool sendingReply = false;
  bool hasReacted = false;
  bool _videoAutoClosed = false;
  final TextEditingController replyController = TextEditingController();
  Map<String,String> get story => widget.stories[index];
  String get storyId => story['id'] ?? '';
  String get myUid => _auth.currentUser?.uid ?? '';

  String _storyAgeLabel(String rawDate) {
    final created = DateTime.tryParse(rawDate)?.toLocal();
    if (created == null) return 'Baru saja';
    final now = DateTime.now();
    final difference = now.difference(created);
    final clock = '${created.hour.toString().padLeft(2, '0')}.${created.minute.toString().padLeft(2, '0')}';
    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inHours < 1) return '${difference.inMinutes} menit yang lalu';
    if (difference.inHours < 24 && created.day == now.day && created.month == now.month && created.year == now.year) {
      return 'Hari ini • ${difference.inHours} jam yang lalu';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (created.day == yesterday.day && created.month == yesterday.month && created.year == yesterday.year) {
      return 'Kemarin • ${clock}';
    }
    return '${created.day.toString().padLeft(2, '0')}/${created.month.toString().padLeft(2, '0')}/${created.year} • ${clock}';
  }

  @override
  void initState() {
    super.initState();
    _startStory();
  }

  void _startStory() {
    replyController.clear();
    hasReacted = false;
    _videoAutoClosed = false;
    final storyIndex = index;
    if (myUid.isNotEmpty && storyId.isNotEmpty) {
      _db.collection('stories').doc(storyId).collection('reactions').doc(myUid).get().then((doc) {
        if (mounted && index == storyIndex) setState(() => hasReacted = doc.exists);
      }).catchError((_) {});
    }
    if (myUid.isNotEmpty && storyId.isNotEmpty && (story['uid'] ?? '') != myUid) {
      _recordStoryView(storyId, myUid);
    }
    timer?.cancel();
    video?.dispose();
    video = null;
    progress = 0;
    paused = false;
    final url = story['videoUrl'] ?? '';
    if (url.startsWith('https://')) {
      final c = VideoPlayerController.networkUrl(Uri.parse(url));
      video = c;
      c.initialize().then((_) {
        if (mounted && video == c) {
          setState(() {});
          c.setLooping(false);
          c.play();
        }
      }).catchError((_) {});
    }
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || paused) return;
      var shouldAdvance = false;
      setState(() {
        if (url.startsWith('https://')) {
          final activeVideo = video;
          if (activeVideo?.value.isInitialized == true && activeVideo!.value.duration.inMilliseconds > 0) {
            progress = (activeVideo.value.position.inMilliseconds / activeVideo.value.duration.inMilliseconds).clamp(0.0, 1.0);
            shouldAdvance = activeVideo.value.isCompleted;
          }
        } else {
          progress = (progress + 0.1 / 60).clamp(0.0, 1.0);
          shouldAdvance = progress >= 1;
        }
      });
      if (shouldAdvance && mounted) {
        if (url.startsWith('https://')) {
          if (!_videoAutoClosed) { _videoAutoClosed = true; timer?.cancel(); Navigator.of(context).maybePop(); }
        } else {
          _next();
        }
      }
    });
  }

  Future<void> _recordStoryView(String targetStoryId, String viewerUid) async {
    final viewRef = _db.collection('stories').doc(targetStoryId).collection('views').doc(viewerUid);
    try {
      // Do not read this document first: non-owners are intentionally denied read access.
      // A direct idempotent write avoids a permission-denied error on the preliminary get().
      await viewRef.set({
        'uid': viewerUid,
        'viewedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      debugPrint('Kalbar Kite story view write failed: ${error.code} ${error.message}');
      if (mounted && index < widget.stories.length && storyId == targetStoryId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencatat view (${error.code}). Periksa Firestore Rules yang sudah dipublikasikan.')),
        );
      }
    } catch (error) {
      debugPrint('Kalbar Kite story view error: $error');
    }
  }
  Future<void> _showStoryViewers() async {
    if ((story['uid'] ?? '') != myUid || storyId.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * .62,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(children: [
                const Expanded(child: Text('Dilihat oleh', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
                StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
                  stream: _db.collection('stories').doc(storyId).collection('views').snapshots(),
                  builder: (context, snapshot) => Text('${snapshot.data?.docs.length ?? 0}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
            Divider(height: 1, color: Theme.of(sheetContext).dividerColor),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
                stream: _db.collection('stories').doc(storyId).collection('views').orderBy('viewedAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text('Daftar penonton belum dapat dimuat.'));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final viewers = snapshot.data!.docs;
                  if (viewers.isEmpty) return const Center(child: Text('Belum ada yang melihat story ini.'));
                  return ListView.separated(
                    itemCount: viewers.length,
                    separatorBuilder: (_, __) => Divider(height: 1, indent: 76, color: Theme.of(sheetContext).dividerColor),
                    itemBuilder: (context, i) {
                      final uid = (viewers[i].data()['uid'] ?? viewers[i].id).toString();
                      return FutureBuilder<DocumentSnapshot<Map<String,dynamic>>>(
                        future: _db.collection('public_profiles').doc(uid).get(),
                        builder: (context, profileSnapshot) {
                          final profile = profileSnapshot.data?.data() ?? <String,dynamic>{};
                          final name = (profile['name'] ?? 'Warga Kalbar').toString();
                          final username = (profile['username'] ?? 'warga').toString();
                          final avatar = (profile['avatarUrl'] ?? '').toString();
                          return ListTile(
                            leading: _remoteAvatar(avatar, radius: 25),
                            title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                            subtitle: Text('@$username'),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _writeStoryInboxMessage({
    required String type,
    required String value,
    required String ownerUid,
    String replyId = '',
  }) async {
    if (ownerUid.isEmpty || ownerUid == myUid) return;
    final chatId = _chatIdFor(myUid, ownerUid);
    final chatRef = _db.collection('chats').doc(chatId);
    final existing = await chatRef.get();
    final friends = await _areMutualFriends(myUid, ownerUid);
    await chatRef.set({
      'participants': _chatParticipantsFor(myUid, ownerUid),
      if (!existing.exists) 'initiatedByUid': myUid,
      if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
      'requestType': friends ? 'friend' : 'story_reaction',
      'storyId': storyId,
      if (replyId.isNotEmpty) 'latestReplyId': replyId,
      'lastMessage': type == 'story_reaction' ? 'Reaksi story: $value' : value,
      'lastSenderUid': myUid,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    final messageRef = chatRef.collection('messages').doc();
    await messageRef.set({
      'senderUid': myUid,
      'receiverUid': ownerUid,
      'type': type,
      'text': value,
      'storyId': storyId,
      if (replyId.isNotEmpty) 'replyId': replyId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Text replies are unlimited. Each reply gets its own document.
  Future<void> _sendReply({String text = ''}) async {
    final value = text.trim();
    if (value.isEmpty || storyId.isEmpty || myUid.isEmpty || sendingReply) return;
    setState(() => sendingReply = true);
    try {
      final replyRef = _db.collection('stories').doc(storyId).collection('replies').doc();
      await replyRef.set({
        'uid': myUid,
        'username': Store.usernames[Store.currentEmail] ?? Store.currentEmail.split('@').first,
        'text': value,
        'emoji': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      final ownerUid = story['uid'] ?? '';
      try {
        await _writeStoryInboxMessage(
          type: 'story_reply', value: value, ownerUid: ownerUid, replyId: replyRef.id,
        );
      } catch (inboxError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Balasan tersimpan, tetapi notifikasi Pesan gagal diperbarui: $inboxError')),
          );
        }
      }
      if (mounted) {
        replyController.clear();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Balasan story terkirim. Kamu bisa membalas lagi kapan saja.')),
        );
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Balasan gagal dikirim: $error')),
      );
    } finally {
      if (mounted) setState(() => sendingReply = false);
    }
  }

  // A viewer may send exactly one quick reaction per story.
  Future<void> _sendStoryReaction(String emoji) async {
    if (emoji.isEmpty || storyId.isEmpty || myUid.isEmpty || sendingReply || hasReacted) return;
    setState(() => sendingReply = true);
    try {
      final reactionRef = _db.collection('stories').doc(storyId).collection('reactions').doc(myUid);
      await reactionRef.set({
        'uid': myUid,
        'emoji': emoji,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) setState(() => hasReacted = true);
      final ownerUid = story['uid'] ?? '';
      try {
        await _writeStoryInboxMessage(type: 'story_reaction', value: emoji, ownerUid: ownerUid);
      } catch (inboxError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reaksi tersimpan, tetapi notifikasi Pesan gagal diperbarui: $inboxError')),
          );
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reaksi story terkirim. Kamu hanya bisa mengirim satu reaksi untuk story ini.')),
        );
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reaksi gagal dikirim: $error')),
      );
    } finally {
      if (mounted) setState(() => sendingReply = false);
    }
  }

  void _next() {
    if (index < widget.stories.length - 1) {
      setState(() => index++);
      _startStory();
    } else {
      Navigator.pop(context);
    }
  }

  void _previous() {
    if (index > 0) {
      setState(() => index--);
      _startStory();
    }
  }

  Future<void> _deleteCurrentStory() async {
    if ((story['uid'] ?? '') != myUid) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus story?'),
        content: const Text('Story ini akan dihapus dan tidak bisa dipulihkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      timer?.cancel();
      await Store.deleteStory(storyId);
      if (!mounted) return;
      if (widget.stories.length > 1) {
        widget.stories.removeAt(index);
        if (index >= widget.stories.length) index = widget.stories.length - 1;
        setState(() {});
        _startStory();
      } else {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Story berhasil dihapus.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Story gagal dihapus: $error')));
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    video?.dispose();
    replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = story;
    final image = item['imageUrl'] ?? '';
    final videoUrl = item['videoUrl'] ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFF171C18),
      body: SafeArea(
        child: GestureDetector(
          onTapUp: (details) {
            final screenHeight = MediaQuery.of(context).size.height;
            if (details.localPosition.dy > screenHeight - 250 || details.localPosition.dy < 72) return;
            if (details.localPosition.dx < MediaQuery.of(context).size.width * .35) {
              _previous();
            } else {
              _next();
            }
          },
          onLongPressStart: (_) {
            setState(() => paused = true);
            video?.pause();
          },
          onLongPressEnd: (_) {
            setState(() => paused = false);
            if (video?.value.isInitialized == true) video?.play();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (videoUrl.startsWith('https://'))
                if (video?.value.isInitialized == true)
                  Center(child: AspectRatio(aspectRatio: video!.value.aspectRatio, child: VideoPlayer(video!)))
                else const Center(child: CircularProgressIndicator(color: Colors.white))
              else if (image.startsWith('https://'))
                Center(child: Image.network(image, fit: BoxFit.contain, width: double.infinity,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white)))
              else
                Center(child: Padding(padding: const EdgeInsets.all(28), child: Text(item['text'] ?? '',
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800)))),
              Positioned(top: 10, left: 12, right: 12, child: Column(children: [
                LinearProgressIndicator(value: progress, minHeight: 2, backgroundColor: Colors.white38, color: Colors.white),
                const SizedBox(height: 12),
                Row(children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF34443A),
                    child: _remoteAvatar(item['avatarUrl'] ?? '', radius: 25,
                      backgroundColor: const Color(0xFF34443A), iconColor: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(children: [
                        Flexible(child: _VerifiedDisplayName(uid: item['uid'] ?? '', name: item['name']?.trim().isNotEmpty == true ? item['name']! : 'Warga Kalbar', maxLines: 1, iconSize: 16, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800))),
                      ]),
                      const SizedBox(height: 2),
                      Text(_storyAgeLabel(item['createdAt'] ?? ''),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  )),
                  if ((item['uid'] ?? '') == myUid)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: const Color(0xFF26332B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0x66007AFF), width: 1.1),
                      ),
                      elevation: 8,
                      onSelected: (value) { if (value == 'delete') _deleteCurrentStory(); },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'delete',
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34443A),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0x66007AFF), width: .8),
                            ),
                            child: const Row(children: [
                              Icon(CupertinoIcons.trash, color: Colors.redAccent),
                              SizedBox(width: 10),
                              Text('Hapus story', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                            ]),
                          ),
                        ),
                      ],
                    )
                  else
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(CupertinoIcons.xmark, color: Colors.white)),
                ]),
              ])),
        
              Positioned(left: 12, right: 12, bottom: 8, child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    if ((item['text'] ?? '').trim().isNotEmpty && (image.startsWith('https://') || videoUrl.startsWith('https://'))) ...[
                      GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: item['text']!));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Caption disalin')));
                        },
                        child: Center(child: Text(item['text']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, shadows: [Shadow(color: Colors.black87, blurRadius: 5)]))),
                      ),
                      const SizedBox(height: 6),
                      Divider(height: 1, thickness: 1, color: Colors.white.withValues(alpha: .55)),
                      const SizedBox(height: 5),
                    ],
                    const SizedBox(height: 5),
                    if ((item['uid'] ?? '') == myUid)
                      Center(
                        child: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
                          stream: _db.collection('stories').doc(storyId).collection('views').snapshots(),
                          builder: (context, snapshot) {
                            final count = snapshot.data?.docs.length ?? 0;
                            return InkWell(
                              onTap: _showStoryViewers,
                              borderRadius: BorderRadius.circular(24),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  const Icon(CupertinoIcons.eye, color: Colors.white, size: 27),
                                  const SizedBox(width: 10),
                                  Text('$count', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                                ]),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 54,
                              padding: const EdgeInsets.symmetric(horizontal: 13),
                              decoration: BoxDecoration(
                                color: const Color(0xE91D2425),
                                border: Border.all(color: Colors.white.withValues(alpha: .82), width: 1.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(children: [
                                Expanded(
                                  child: TextField(
                                    controller: replyController,
                                    enabled: !sendingReply,
                                    minLines: 1,
                                    maxLines: 1,
                                    maxLength: 300,
                                    textInputAction: TextInputAction.send,
                                    textCapitalization: TextCapitalization.sentences,
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                    decoration: const InputDecoration(
                                      hintText: 'Balas Story...',
                                      hintStyle: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                                      filled: false,
                                      counterText: '',
                                      isCollapsed: true,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (_) { if (mounted) setState(() {}); },
                                    onSubmitted: (_) => _sendReply(text: replyController.text),
                                  ),
                                ),
                                for (final emoji in ['😂', '🧐', '🙏'])
                                  InkWell(
                                    onTap: sendingReply || hasReacted ? null : () => _sendStoryReaction(emoji),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                      child: Opacity(
                                        opacity: hasReacted ? .38 : 1,
                                        child: Text(emoji, style: const TextStyle(fontSize: 21)),
                                      ),
                                    ),
                                  ),
                              ]),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: const Color(0xE91D2425),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: sendingReply || replyController.text.trim().isEmpty
                                ? null : () => _sendReply(text: replyController.text),
                              child: SizedBox(
                                width: 52,
                                height: 52,
                                child: Center(
                                  child: Icon(
                                    CupertinoIcons.paperplane_fill,
                                    color: replyController.text.trim().isEmpty ? Colors.white54 : Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ]),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoriesStrip extends StatelessWidget {
  final VoidCallback onAdd;
  final void Function(Map<String,String>) onOpen;
  const _StoriesStrip({required this.onAdd, required this.onOpen});
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 92, child: ListView(scrollDirection: Axis.horizontal, children: [
      GestureDetector(onTap: onAdd, child: SizedBox(width: 68, child: Column(children: [
        Stack(children: [_accountAvatar(Store.currentEmail, radius: 34), Positioned(right: 0, bottom: 0, child: Container(width: 19, height: 19, decoration: const BoxDecoration(color: forest, shape: BoxShape.circle), child: const Icon(CupertinoIcons.plus, size: 15, color: Colors.white)))]),
        const SizedBox(height: 5), const Text('Cerita kamu', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      ]))),
      for (final story in Store.stories) GestureDetector(onTap: () => onOpen(story), child: SizedBox(width: 68, child: Column(children: [
        Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2587D8), width: 2)), child: _remoteAvatar(story['avatarUrl'] ?? '', radius: 25,
              backgroundColor: Colors.white, iconColor: forest)),
        const SizedBox(height: 5), Text('@${story['username'] ?? 'warga'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      ]))),
    ]));
  }
}
class _StoryVideoPlayer extends StatefulWidget {
  final String url;
  const _StoryVideoPlayer({required this.url});
  @override
  State<_StoryVideoPlayer> createState() => _StoryVideoPlayerState();
}
class _StoryVideoPlayerState extends State<_StoryVideoPlayer> {
  late final VideoPlayerController controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
  @override
  void initState() {
    super.initState();
    controller.initialize().then((_) { if (mounted) setState(() {}); controller.setLooping(true); controller.play(); });
  }
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) return const SizedBox(height: 190, child: Center(child: CircularProgressIndicator()));
    return AspectRatio(aspectRatio: controller.value.aspectRatio, child: Stack(alignment: Alignment.center, children: [
      VideoPlayer(controller),
      IconButton(onPressed: () { setState(() { controller.value.isPlaying ? controller.pause() : controller.play(); }); },
        icon: Icon(controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle, size: 48, color: Colors.white)),
    ]));
  }
}

class StoryComposePage extends StatefulWidget {
  const StoryComposePage({super.key});
  @override
  State<StoryComposePage> createState() => _StoryComposePageState();
}
class _StoryComposePageState extends State<StoryComposePage> {
  final controller = TextEditingController();
  String imagePath = '';
  String videoPath = '';
  bool saving = false;
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 55, maxWidth: 1024, maxHeight: 1024);
      if (file != null && mounted) setState(() => imagePath = file.path);
    } catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto tidak dapat dipilih: $error'))); }
  }
  Future<void> _pickVideo() async {
    try {
      final file = await ImagePicker().pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 30));
      if (file != null && mounted) setState(() { videoPath = file.path; imagePath = ''; });
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Video tidak dapat dipilih: $error')));
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userName = Store.memberNames[Store.currentEmail] ?? Store.currentEmail.split('@').first;
    final avatarUrl = Store.avatarUrls[Store.currentEmail] ?? '';
    final hasMedia = imagePath.isNotEmpty || videoPath.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat cerita', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: saving ? null : () async {
                if (controller.text.trim().isEmpty && !hasMedia) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tambahkan teks, foto, atau video terlebih dahulu.')),
                  );
                  return;
                }
                setState(() => saving = true);
                try {
                  await Store.publishStory(
                    controller.text.trim(), imagePath: imagePath, videoPath: videoPath,
                  ).timeout(const Duration(seconds: 150));
                  if (mounted) Navigator.pop(context, controller.text.trim().isEmpty ? 'Cerita baru' : controller.text.trim());
                } catch (error) {
                  if (mounted) {
                    setState(() => saving = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cerita gagal dikirim: $error')),
                    );
                  }
                }
              },
              child: Text(saving ? 'Mengirim…' : 'Bagikan',
                style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(children: [
                    avatarUrl.trim().isNotEmpty
                        ? _remoteAvatar(avatarUrl, radius: 23, backgroundColor: pale, iconColor: forest)
                        : _accountAvatar(Store.currentEmail, radius: 23),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(userName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      const SizedBox(height: 3),
                      Text('Cerita akan tampil selama 24 jam',
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                    ])),
                    const Icon(Icons.auto_awesome_rounded, color: forest),
                  ]),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    maxLength: 240,
                    minLines: 5,
                    maxLines: 8,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    decoration: const InputDecoration(
                      hintText: 'Tulis sesuatu untuk ceritamu…',
                      border: InputBorder.none,
                      counterStyle: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (imagePath.isNotEmpty && File(imagePath).existsSync()) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(children: [
                      Image.file(File(imagePath), width: double.infinity, height: 330, fit: BoxFit.cover),
                      Positioned(top: 10, right: 10,
                        child: IconButton.filledTonal(
                          onPressed: () => setState(() => imagePath = ''),
                          icon: const Icon(CupertinoIcons.xmark),
                        )),
                    ]),
                  ),
                  const SizedBox(height: 12),
                ],
                if (videoPath.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(children: [
                      Container(width: 44, height: 44,
                        decoration: BoxDecoration(color: forest, borderRadius: BorderRadius.circular(14)),
                        child: const Icon(CupertinoIcons.play_arrow_solid, color: Colors.white, size: 32)),
                      const SizedBox(width: 12),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Video siap diunggah', style: TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(height: 3),
                        Text('Video story maksimal 30 detik', style: TextStyle(fontSize: 12)),
                      ])),
                      IconButton(onPressed: () => setState(() => videoPath = ''),
                        icon: const Icon(CupertinoIcons.trash)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                ],
                Text('Tambahkan ke cerita', style: TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 14, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: saving ? null : _pickImage,
                    icon: const Icon(CupertinoIcons.photo),
                    label: const Text('Foto'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton.icon(
                    onPressed: saving ? null : _pickVideo,
                    icon: const Icon(CupertinoIcons.video_camera),
                    label: const Text('Video'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  )),
                ]),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: saving ? null : () async {
                  if (controller.text.trim().isEmpty && !hasMedia) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tambahkan teks, foto, atau video terlebih dahulu.')),
                    );
                    return;
                  }
                  setState(() => saving = true);
                  try {
                    await Store.publishStory(
                      controller.text.trim(), imagePath: imagePath, videoPath: videoPath,
                    ).timeout(const Duration(seconds: 150));
                    if (mounted) Navigator.pop(context, controller.text.trim().isEmpty ? 'Cerita baru' : controller.text.trim());
                  } catch (error) {
                    if (mounted) {
                      setState(() => saving = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cerita gagal dikirim: $error')),
                      );
                    }
                  }
                },
                icon: saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(CupertinoIcons.paperplane_fill),
                label: Text(saving ? 'Sedang mengunggah…' : 'Bagikan cerita'),
                style: FilledButton.styleFrom(
                  backgroundColor: forest,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class PublicProfilePage extends StatefulWidget {
  final String uid;
  const PublicProfilePage({super.key, required this.uid});
  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}
class _PublicProfilePageState extends State<PublicProfilePage> {
  bool working = false;
  bool _fallbackAvatarRequested = false;
  String _fallbackAvatar = '';
  String get myUid => _auth.currentUser?.uid ?? '';
  String get followId => '${myUid}_${widget.uid}';
  Future<void> toggleFollow(bool following) async {
    if (myUid.isEmpty || myUid == widget.uid || working) return;
    setState(() => working = true);
    try {
      final ref = _db.collection('follows').doc(followId);
      if (following) {
        await ref.delete();
      } else {
        await ref.set({'followerUid':myUid,'followingUid':widget.uid,'createdAt':FieldValue.serverTimestamp()});
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Follow gagal: $e')));
    } finally {
      if (mounted) setState(() => working = false);
    }
  }
  @override
  Widget build(BuildContext context) => StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
    stream: _db.collection('public_profiles').doc(widget.uid).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) return Scaffold(appBar: AppBar(title: const Text('Profil')), body: Center(child: Text('Profil tidak dapat dimuat.\\n${snapshot.error}')));
      if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      final data = snapshot.data?.data() ?? <String,dynamic>{};
      final username = (data['username'] ?? 'warga').toString();
      final name = (data['name'] ?? 'Warga Kalbar').toString();
      final storedAvatar = _firstImageUrl(data,
          const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl']);
      if (storedAvatar.isEmpty && !_fallbackAvatarRequested) {
        _fallbackAvatarRequested = true;
        _loadAvatarFromPublicContent(widget.uid).then((value) {
          if (mounted && value.isNotEmpty) setState(() => _fallbackAvatar = value);
        });
      }
      final avatar = storedAvatar.isNotEmpty ? storedAvatar : _fallbackAvatar;
      final banner = _firstImageUrl(data, const ['bannerUrl', 'coverUrl', 'headerImageUrl']);
      final bio = (data['bio'] ?? '').toString();
      final isMe = myUid == widget.uid;
      final theme = Theme.of(context);
      return Scaffold(appBar: AppBar(title: Text('@$username')),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 28), children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(height: 178, width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                gradient: const LinearGradient(colors: [Color(0xFFEAEAEA), Color(0xFFF8E6E7)]),
              ),
              child: banner.startsWith('https://')
                  ? CachedNetworkImage(
                      imageUrl: _normalizeImageUrl(banner), fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const SizedBox.expand())
                  : const SizedBox.expand(),
            ),
            Positioned(left: 18, bottom: -38, child: Container(padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, shape: BoxShape.circle),
              child: _remoteAvatar(avatar, radius: 43,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                iconColor: theme.colorScheme.onSurfaceVariant))),
          ]),
          const SizedBox(height: 49),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(stream: _db.collection('public_profiles').doc(widget.uid).snapshots(), builder: (context, live) { final verified = live.data?.data()?['ownerVerified'] == true; return Row(mainAxisSize: MainAxisSize.min, children: [Flexible(child: Text(name, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis)), if (verified) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.verified_rounded, color: Color(0xFF2196F3), size: 22))]); }),
              const SizedBox(height: 2),
              Text('@$username', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ])),
            if (!isMe) StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
              stream: _db.collection('follows').doc(followId).snapshots(),
              builder: (context, follow) {
                final following = follow.data?.exists == true;
                return FilledButton.tonalIcon(
                  onPressed: working || follow.connectionState == ConnectionState.waiting ? null : () => toggleFollow(following),
                  icon: Icon(following ? Icons.person_remove_alt_1 : Icons.person_add_alt_1),
                  label: Text(following ? 'Mengikuti' : 'Ikuti'));
              }),
          ]),
          if (bio.isNotEmpty) ...[const SizedBox(height: 10), Text(bio, style: TextStyle(fontSize: 14, height: 1.45, color: theme.colorScheme.onSurface))],
          const SizedBox(height: 17),
          Container(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(13), border: Border.all(color: theme.dividerColor)),
            child: Row(children: [
              Expanded(child: _FollowCount(uid:widget.uid, followers:true)),
              Container(width: 1, height: 30, color: theme.dividerColor),
              Expanded(child: _FollowCount(uid:widget.uid, followers:false)),
            ])),
          const SizedBox(height: 24),
          Text('Postingan', style: GoogleFonts.fredoka(fontSize: 21, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
            stream: _db.collection('activity_posts').where('ownerUid', isEqualTo: widget.uid).snapshots(),
            builder: (context, posts) {
              if (posts.hasError) return Padding(padding: const EdgeInsets.all(16), child: Text('Postingan tidak dapat dimuat: ${posts.error}'));
              if (posts.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
              final docs = posts.data!.docs.toList()..sort((a,b) {
                final at=a.data()['createdAt'], bt=b.data()['createdAt'];
                final av=at is Timestamp ? at.millisecondsSinceEpoch : 0;
                final bv=bt is Timestamp ? bt.millisecondsSinceEpoch : 0;
                return bv.compareTo(av);
              });
              if (docs.isEmpty) return const Padding(padding: EdgeInsets.all(18), child: Text('Belum ada postingan.', textAlign: TextAlign.center));
              return Column(children: docs.map((doc) {
                final d=doc.data(); final image=(d['imageUrl']??'').toString();
                return Container(margin: const EdgeInsets.only(bottom: 13), padding: const EdgeInsets.fromLTRB(0, 13, 0, 13),
                   decoration: const BoxDecoration(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      _remoteAvatar(
                        _firstImageUrl(d, const ['avatarUrl', 'photoURL', 'photoUrl', 'photo']).isNotEmpty
                            ? _firstImageUrl(d, const ['avatarUrl', 'photoURL', 'photoUrl', 'photo'])
                            : avatar,
                        radius: 21, backgroundColor: pale, iconColor: forest),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _VerifiedDisplayName(uid: (d['ownerUid'] ?? widget.uid).toString(), name: (d['author'] ?? name).toString(), maxLines: 1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                        Text('@${(d['username'] ?? username).toString()}',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                      ])),
                      Text((d['date'] ?? '').toString(), style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                    ]),
                    const SizedBox(height: 13),
                    if ((d['body']??'').toString().isNotEmpty) ...[ Text((d['body']??'').toString(), style: const TextStyle(fontSize: 14, height: 1.4))],
                    if (image.startsWith('https://')) ...[const SizedBox(height: 9), ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(image, width: double.infinity, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox(height: 120, child: Center(child: Icon(Icons.broken_image_outlined)))))],
                    const SizedBox(height: 8),
                    Row(children: [
                      _PostLikeButton(postId: doc.id),
                      TextButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityCommentsPage(postId: doc.id))),
                        icon: const Icon(CupertinoIcons.chat_bubble, size: 17),
                        label: Text('Komentar ${(d['comments'] as List?)?.length ?? 0}'),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Bagikan',
                        onPressed: () => Share.share('${(d['author'] ?? 'Warga Kalbar')} di Kalbar Kite\\n${(d['body'] ?? '').toString()}\\n$image'),
                        icon: const Icon(CupertinoIcons.square_arrow_up),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: theme.dividerColor),
                  ]));
              }).toList());
            }),
        ]));
    });
}
class _FollowCount extends StatelessWidget {
  final String uid; final bool followers;
  const _FollowCount({required this.uid, required this.followers});
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: () => Navigator.push(context, MaterialPageRoute(
      builder: (_) => FollowListPage(uid: uid, followers: followers))),
    child: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
      stream: _db.collection('follows').where(followers ? 'followingUid' : 'followerUid', isEqualTo: uid).snapshots(),
      builder: (context, snap) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(followers ? Icons.people_alt_outlined : Icons.person_add_alt_1_outlined,
            size: 19, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 7),
          Text('${snap.data?.docs.length ?? 0}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(width: 5),
          Flexible(child: Text(followers ? 'Pengikut' : 'Mengikuti',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface))),
        ],
      ),
    ),
  );
}

class FollowListPage extends StatelessWidget {
  final String uid;
  final bool followers;
  const FollowListPage({super.key, required this.uid, required this.followers});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(followers ? 'Pengikut' : 'Mengikuti')),
    body: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
      stream: _db.collection('follows')
        .where(followers ? 'followingUid' : 'followerUid', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Daftar belum dapat dimuat: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return Center(child: Text(followers ? 'Belum ada pengikut.' : 'Belum mengikuti siapa pun.'));
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final peerUid = (followers ? data['followerUid'] : data['followingUid']).toString();
            return _FollowUserTile(uid: peerUid);
          },
        );
      },
    ),
  );
}

class _FollowUserTile extends StatelessWidget {
  final String uid;
  const _FollowUserTile({required this.uid});
  @override
  Widget build(BuildContext context) => StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
    stream: _db.collection('public_profiles').doc(uid).snapshots(),
    builder: (context, snap) {
      final data = snap.data?.data() ?? <String,dynamic>{};
      final name = (data['name'] ?? 'Pengguna Kalbar Kite').toString();
      final username = (data['username'] ?? 'warga').toString();
      final avatar = (data['avatarUrl'] ?? '').toString();
      return ListTile(
        leading: _remoteAvatar(avatar, radius: 20),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('@$username'),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfilePage(uid: uid))),
      );
    },
  );
}

class _PostLikeButton extends StatelessWidget {
  final String postId;
  const _PostLikeButton({required this.postId});
  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty || postId.isEmpty) return const SizedBox.shrink();
    final likes = _db.collection('activity_posts').doc(postId).collection('likes');
    final mine = likes.doc(uid);
    return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
      stream: mine.snapshots(),
      builder: (context, own) {
        final liked = own.data?.exists == true;
        return StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
          stream: likes.snapshots(),
          builder: (context, all) => TextButton.icon(
            onPressed: () async {
              try {
                if (liked) {
                  await mine.delete();
                } else {
                  await mine.set({'uid':uid,'createdAt':FieldValue.serverTimestamp()});
                }
              } catch (error) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menyukai postingan: $error')),
                );
              }
            },
            icon: Icon(liked ? Icons.favorite : Icons.favorite_border, size: 18,
              color: liked ? Colors.redAccent : Theme.of(context).colorScheme.onSurfaceVariant),
            label: Text('Suka ${all.data?.docs.length ?? 0}',
              style: TextStyle(fontSize: 12, color: liked ? Colors.redAccent : Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        );
      },
    );
  }
}

class _ActivityPostCard extends StatelessWidget {
  final Map<String,String> post;
  final VoidCallback onComments;
  final VoidCallback? onDeleted;
  const _ActivityPostCard({required this.post, required this.onComments, this.onDeleted});

  Future<void> _deletePost(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus postingan?'),
        content: const Text('Postingan ini akan dihapus dan tidak bisa dipulihkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await Store.deleteActivityPost(post['id'] ?? '');
      onDeleted?.call();
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Postingan berhasil dihapus.')));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Postingan gagal dihapus: $error')));
    }
  }
  @override
  Widget build(BuildContext context) {
    final photo = post['imagePath'] ?? '';
    final hasPhoto = photo.startsWith('https://');
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 0), padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      decoration: const BoxDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          InkWell(onTap: (post['uid'] ?? '').isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfilePage(uid:post['uid']!))),
            child: (post['avatarUrl'] ?? '').toString().trim().isNotEmpty
                ? _remoteAvatar(post['avatarUrl'] ?? '', radius: 21,
                    backgroundColor: pale, iconColor: forest)
                : _accountAvatar(post['email'] ?? '', radius: 21)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InkWell(onTap: (post['uid'] ?? '').isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfilePage(uid:post['uid']!))),
              child: _VerifiedDisplayName(uid: post['uid'] ?? '', name: post['author'] ?? 'Warga Kalbar', maxLines: 1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900))),
            Text('@${post['username'] ?? 'warga'}', style: TextStyle(fontSize: 10, color: muted)),
          ])),
          _FeedFollowButton(uid: post['uid'] ?? ''),
          Text(post['date'] ?? '', style: TextStyle(fontSize: 10, color: muted)),
          if ((post['uid'] ?? '') == (_auth.currentUser?.uid ?? ''))
            PopupMenuButton<String>(
              tooltip: 'Opsi postingan',
              onSelected: (value) { if (value == 'delete') _deletePost(context); },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'delete', child: Row(children: [
                  Icon(CupertinoIcons.trash, color: Colors.redAccent),
                  SizedBox(width: 9),
                  Text('Hapus postingan'),
                ])),
              ],
            ),
        ]),
        const SizedBox(height: 12),
        if ((post['body'] ?? '').trim().isNotEmpty) ...[
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: post['body'] ?? ''));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Postingan disalin')));
            },
            child: _LinkifiedText(post['body'] ?? '', style: TextStyle(fontSize: 14, height: 1.45, color: theme.colorScheme.onSurface)),
          ),
        ],
        if (hasPhoto) ...[const SizedBox(height: 9), ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(
          photo, width: double.infinity, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(height: 150, color: theme.colorScheme.surfaceContainerHighest, alignment: Alignment.center, child: const Icon(Icons.broken_image_outlined, size: 34))))],
        const SizedBox(height: 8),
        Row(children: [
          _PostLikeButton(postId: post['id'] ?? ''),
          const SizedBox(width: 4),
          TextButton.icon(onPressed: onComments, icon: Icon(CupertinoIcons.chat_bubble, size: 17, color: muted), label: Text('Komentar ${_commentCount(post)}', style: TextStyle(fontSize: 12, color: muted))),
          const Spacer(),
          TextButton.icon(onPressed: () => Share.share('${post['author'] ?? 'Warga Kalbar'} di Kalbar Kite\n${post['body'] ?? ''}\n${post['imagePath'] ?? ''}'), icon: Icon(CupertinoIcons.square_arrow_up, size: 17, color: muted), label: Text('Bagikan', style: TextStyle(fontSize: 12, color: muted))),
        ]),
        const SizedBox(height: 10),
        Divider(height: 1, thickness: 0.7, color: theme.dividerColor),
      ]),
    );
  }
}


class _ActivityVideoPreview extends StatefulWidget {
  final String url;
  const _ActivityVideoPreview({required this.url});
  @override
  State<_ActivityVideoPreview> createState() => _ActivityVideoPreviewState();
}
class _ActivityVideoPreviewState extends State<_ActivityVideoPreview> {
  VideoPlayerController? controller;
  bool failed = false;
  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) { if (mounted) setState(() {}); })
        .catchError((_) { if (mounted) setState(() => failed = true); });
  }
  @override
  void dispose() { controller?.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final c = controller;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: c?.value.isInitialized == true ? c!.value.aspectRatio : 16 / 9,
        child: Stack(fit: StackFit.expand, children: [
          Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
          if (failed) const Center(child: Icon(Icons.error_outline, size: 34))
          else if (c?.value.isInitialized == true) VideoPlayer(c!)
          else const Center(child: CircularProgressIndicator()),
          if (c?.value.isInitialized == true)
            Center(child: IconButton.filledTonal(
              onPressed: () { setState(() { c.value.isPlaying ? c.pause() : c.play(); }); },
              icon: Icon(c!.value.isPlaying ? Icons.pause : CupertinoIcons.play_arrow_solid),
            )),
        ]),
      ),
    );
  }
}

class _FeedFollowButton extends StatelessWidget {
  final String uid;
  const _FeedFollowButton({required this.uid});
  @override
  Widget build(BuildContext context) {
    final me = _auth.currentUser?.uid ?? '';
    if (me.isEmpty || uid.isEmpty || me == uid) return const SizedBox.shrink();
    final ref = _db.collection('follows').doc('${me}_${uid}');
    return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
      stream: ref.snapshots(),
      builder: (context, snap) {
        final following = snap.data?.exists == true;
        return TextButton(
          onPressed: snap.connectionState == ConnectionState.waiting ? null : () async {
            try {
              if (following) {
                await ref.delete();
              } else {
                await ref.set({'followerUid':me,'followingUid':uid,'createdAt':FieldValue.serverTimestamp()});
              }
            } catch (error) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Follow gagal. Periksa koneksi dan Firestore Rules: $error')),
              );
            }
          },
          child: Text(following ? 'Mengikuti' : 'Ikuti', style: const TextStyle(color: forest, fontWeight: FontWeight.w800)),
        );
      },
    );
  }
}

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  const _MarqueeText({required this.text, required this.style});
  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}
class _MarqueeTextState extends State<_MarqueeText> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  double distance = 0;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  }
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final painter = TextPainter(text: TextSpan(text: widget.text, style: widget.style), textDirection: Directionality.of(context), maxLines: 1)..layout();
    distance = painter.width + 44;
    final durationMs = (distance * 55).round().clamp(7000, 24000);
    if (controller.duration?.inMilliseconds != durationMs) {
      controller.duration = Duration(milliseconds: durationMs);
      controller.repeat();
    }
    return ClipRect(child: AnimatedBuilder(animation: controller, builder: (context, _) {
      final offset = -distance * controller.value;
      return Transform.translate(offset: Offset(offset, 0), child: SizedBox(
        width: distance + constraints.maxWidth,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
          const SizedBox(width: 44),
          Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
        ]),
      ));
    }));
  });
}

int _commentCount(Map<String,String> post) {
  try { return (jsonDecode(post['comments'] ?? '[]') as List).length; } catch (_) { return 0; }
}

class _VerifiedDisplayName extends StatelessWidget {
  final String uid;
  final String name;
  final TextStyle? style;
  final int maxLines;
  final double iconSize;
  const _VerifiedDisplayName({
    required this.uid,
    required this.name,
    this.style,
    this.maxLines = 1,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final nameText = Text(name, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: style);
    if (uid.trim().isEmpty) return nameText;
    return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
      stream: FirebaseFirestore.instance.collection('public_profiles').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final verified = snapshot.data?.data()?['ownerVerified'] == true;
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Flexible(child: nameText),
          if (verified) ...[
            const SizedBox(width: 5),
            Icon(Icons.verified_rounded, color: const Color(0xFF2196F3), size: iconSize),
          ],
        ]);
      },
    );
  }
}

class _LinkifiedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  const _LinkifiedText(this.text, {this.style});
  @override
  State<_LinkifiedText> createState() => _LinkifiedTextState();
}
class _LinkifiedTextState extends State<_LinkifiedText> {
  final List<TapGestureRecognizer> _recognizers = [];
  static final RegExp _urlPattern = RegExp(r'((https?:\/\/|www\.)[^\s]+|(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(?:\/[^\s]*)?)', caseSensitive: false);
  @override
  void dispose() { for (final item in _recognizers) { item.dispose(); } super.dispose(); }
  Future<void> _open(String value) async {
    var url = value.replaceAll(RegExp(r'[),.!?;:]+$'), '');
    if (!url.startsWith('http://') && !url.startsWith('https://')) url = 'https://$url';
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tautan tidak dapat dibuka.')));
  }
  @override
  Widget build(BuildContext context) {
    for (final item in _recognizers) { item.dispose(); }
    _recognizers.clear();
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in _urlPattern.allMatches(widget.text)) {
      if (match.start > cursor) spans.add(TextSpan(text: widget.text.substring(cursor, match.start)));
      final value = match.group(0)!;
      final recognizer = TapGestureRecognizer()..onTap = () => _open(value);
      _recognizers.add(recognizer);
      spans.add(TextSpan(text: value, style: const TextStyle(color: Color(0xFF2876C7), decoration: TextDecoration.underline, fontWeight: FontWeight.w700), recognizer: recognizer));
      cursor = match.end;
    }
    if (cursor < widget.text.length) spans.add(TextSpan(text: widget.text.substring(cursor)));
    return Text.rich(TextSpan(children: spans, style: widget.style));
  }
}

class ActivityCommentsPage extends StatefulWidget {
  final String postId;
  const ActivityCommentsPage({super.key, required this.postId});
  @override
  State<ActivityCommentsPage> createState() => _ActivityCommentsPageState();
}
class _ActivityCommentsPageState extends State<ActivityCommentsPage> {
  final controller = TextEditingController();
  Map<String,String>? get post {
    for (final item in Store.activityPosts) {
      if (item['id'] == widget.postId) return item;
    }
    return null;
  }
  List<Map<String,dynamic>> get comments {
    try {
      final raw = jsonDecode(post?['comments'] ?? '[]') as List;
      return raw.map((e) => Map<String,dynamic>.from(e as Map)).toList();
    } catch (_) { return []; }
  }
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  Future<void> _send() async {
    final value = controller.text.trim();
    if (value.isEmpty || post == null) return;
    final email = Store.currentEmail;
    final name = Store.memberNames[email] ?? email.split('@').first;
    final updated = comments..add({
      'author': name,
      'email': email,
      'uid': Store.currentUid,
      'body': value,
      'date': DateTime.now().toUtc().toIso8601String(),
    });
    post!['comments'] = jsonEncode(updated);
    await Store.updateActivityPost(post!);
    controller.clear();
    if (mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final data = comments;
    return Scaffold(
      appBar: AppBar(title: const Text('Komentar')),
      body: Column(children: [
        Expanded(child: data.isEmpty
          ? const Center(child: Text('Belum ada komentar. Mulai percakapan dengan sopan.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              separatorBuilder: (_, __) => const Divider(height: 18),
              itemBuilder: (context, index) {
                final item = data[index];
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _accountAvatar((item['email'] ?? '').toString(), radius: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _VerifiedDisplayName(uid: (item['uid'] ?? '').toString(), name: (item['author'] ?? 'Warga Kalbar').toString(), style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    _LinkifiedText((item['body'] ?? '').toString(), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, height: 1.4)),
                  ])),
                ]);
              },
            )),
        SafeArea(top: false, child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(children: [
            Expanded(child: TextField(controller: controller, minLines: 1, maxLines: 4, decoration: const InputDecoration(hintText: 'Tulis komentar...', isDense: true))),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: _send, icon: const Icon(CupertinoIcons.paperplane_fill)),
          ]),
        )),
      ]),
    );
  }
}

class ActivityComposePage extends StatefulWidget {
  const ActivityComposePage({super.key});
  @override
  State<ActivityComposePage> createState() => _ActivityComposePageState();
}
class _ActivityComposePageState extends State<ActivityComposePage> {
  final controller = TextEditingController();
  final linkController = TextEditingController();
  final picker = ImagePicker();
  String imagePath = '';
  bool saving = false;
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  Future<void> _pickPhoto() async {
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 55, maxWidth: 1024, maxHeight: 1024);
    if (image == null) return;
    imagePath = image.path;
    if (mounted) setState(() {});
  }
  Future<void> _publish() async {
    if (controller.text.trim().isEmpty && imagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tulis cerita atau pilih foto terlebih dahulu.')));
      return;
    }
    setState(() => saving = true);
    final email = Store.currentEmail;
    final author = Store.memberNames[email] ?? email.split('@').first;
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final post = <String,String>{
      'id': now.microsecondsSinceEpoch.toString(),
      'email': email,
      'author': author,
      'body': controller.text.trim(),
      'imagePath': imagePath,
      'date': '${now.day} ${months[now.month - 1]} ${now.year} • ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    };
    try { await Store.publishActivity(post); } catch (error, stack) { debugPrint('Kalbar Kite publishActivity failed: $error'); debugPrintStack(stackTrace: stack); if (mounted) { setState(() => saving = false); final detail = error.toString().replaceFirst('Exception: ', ''); ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: const Duration(seconds: 8), content: Text('Postingan gagal: $detail'))); } return; }
    if (!mounted) return;
    Navigator.pop(context, true);
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postTheme = theme.copyWith(textTheme: theme.textTheme.apply(fontFamily: GoogleFonts.inter().fontFamily));
    final userName = Store.memberNames[Store.currentEmail] ?? Store.currentEmail.split('@').first;
    final avatarUrl = Store.avatarUrls[Store.currentEmail] ?? '';
    return Theme(data: postTheme, child: Scaffold(
      appBar: AppBar(
        title: Text('Buat Postingan', style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(onPressed: saving ? null : _publish,
            child: Text(saving ? 'Mengirim…' : 'Posting', style: GoogleFonts.fredoka(fontWeight: FontWeight.w700))),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: Column(children: [
        Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 24), children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.dividerColor)),
            child: Row(children: [
              avatarUrl.trim().isNotEmpty
                  ? _remoteAvatar(avatarUrl, radius: 24, backgroundColor: pale, iconColor: forest)
                  : _accountAvatar(Store.currentEmail, radius: 24),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(userName, style: GoogleFonts.fredoka(fontWeight: FontWeight.w700, fontSize: 17)),
                const SizedBox(height: 3),
                Text('Membagikan ke Aktivitas', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              ])),
              Icon(Icons.public_rounded, color: theme.colorScheme.onSurfaceVariant),
            ]),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.dividerColor)),
            child: TextField(controller: controller, minLines: 6, maxLines: 12, maxLength: 1000,
              style: const TextStyle(fontSize: 16, height: 1.5),
              decoration: InputDecoration(hintText: 'Apa yang ingin kamu ceritakan hari ini?',
                hintStyle: GoogleFonts.inter(fontSize: 15, color: theme.colorScheme.onSurfaceVariant), border: InputBorder.none,
                counterStyle: TextStyle(fontSize: 11))),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor)),
            child: ListTile(leading: const Icon(CupertinoIcons.photo, color: forest),
              title: Text('Foto dari galeri', style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 16)),
              subtitle: const Text('Tambahkan foto ke postingan'),
              trailing: const Icon(CupertinoIcons.photo), onTap: saving ? null : _pickPhoto),
          ),
          if (imagePath.isNotEmpty && File(imagePath).existsSync()) ...[
            const SizedBox(height: 14),
            ClipRRect(borderRadius: BorderRadius.circular(16), child: Stack(children: [
              Image.file(File(imagePath), height: 260, width: double.infinity, fit: BoxFit.cover),
              Positioned(top: 10, right: 10, child: IconButton.filledTonal(
                onPressed: () => setState(() => imagePath = ''), icon: const Icon(CupertinoIcons.xmark))),
            ])),
          ],
        ])),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
          decoration: BoxDecoration(color: theme.cardColor,
            border: Border(top: BorderSide(color: theme.dividerColor))),
          child: SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: saving ? null : _publish,
            icon: saving ? const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(CupertinoIcons.paperplane_fill),
            label: Text(saving ? 'Sedang menerbitkan…' : 'Terbitkan Postingan', style: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(backgroundColor: forest, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )),
        ),
      ])),
    ));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openInfo(BuildContext context, Map<String, String> post) {
    final imageUrl = _normalizeImageUrl(post['imagePath'] ?? '');
    Navigator.push(context, MaterialPageRoute(builder: (_) => BackPage(
      title: 'Informasi',
      child: ListView(padding: const EdgeInsets.all(16), children: [
        if (imageUrl.startsWith('https://')) ...[
          ClipRRect(borderRadius: BorderRadius.circular(10), child: CachedNetworkImage(
            imageUrl: imageUrl, width: double.infinity, height: 210, fit: BoxFit.cover,
          )),
          const SizedBox(height: 14),
        ],
        Text(post['date'] ?? '', style: const TextStyle(fontSize: 12, color: forest, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(post['title'] ?? '', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Text(post['body'] ?? '', style: const TextStyle(fontSize: 14, height: 1.55)),
      ]),
    )));
  }

  Widget _sectionTitle(BuildContext context, String title, {String? subtitle}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.fredoka(fontSize: 21, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface, letterSpacing: -.2, height: 1.1)),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle, style: GoogleFonts.manrope(fontSize: 13.5, height: 1.3, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ]),
    );
  }

  Widget _service(BuildContext context, {required String title, required String subtitle, required IconData icon,
    required Color start, required Color end, required Color accent, required VoidCallback onTap, bool wide = false}) {
    return _HomeServiceCard(title: title, subtitle: subtitle, icon: icon, start: start, end: end, accent: accent, onTap: onTap, wide: wide);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final blue = dark ? const Color(0xFF24496D) : const Color(0xFFE4F2FF);
    final lilac = dark ? const Color(0xFF403867) : const Color(0xFFEBEAFE);
    final pink = dark ? const Color(0xFF60303E) : const Color(0xFFFFE8ED);
    final mint = dark ? const Color(0xFF20594E) : const Color(0xFFE1F8F3);
    final yellow = dark ? const Color(0xFF3B3520) : const Color(0xFFFFF5D9);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        const WelcomeBanner(),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: const _LiveWeatherCard(compact: true)),
            const SizedBox(width: 10),
            Expanded(child: const _UpcomingAgendaPreview(compact: true)),
          ],
        ),
        const SizedBox(height: 18),
        _sectionTitle(context, 'Layanan Utama', subtitle: 'Akses layanan dan informasi penting seputar Kalbar'),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: .55),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: theme.dividerColor.withValues(alpha: .85), width: .9),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            IntrinsicHeight(child: Row(children: [
              Expanded(child: _service(context, title: 'Kamus Daerah', subtitle: 'Arti kata dan ungkapan',
                icon: CupertinoIcons.book, start: blue, end: dark ? const Color(0xFF303238) : const Color(0xFFF0F1F3),
                accent: dark ? const Color(0xFF91C9FF) : const Color(0xFF397DB8),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DictionaryPage())))),
              VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor),
              Expanded(child: _service(context, title: 'Sejarah Kalbar', subtitle: 'Cerita 14 kabupaten',
                icon: Icons.account_balance_outlined, start: lilac, end: dark ? const Color(0xFF303238) : const Color(0xFFF0F1F3),
                accent: dark ? const Color(0xFFC1B2FF) : const Color(0xFF7564C5),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage())))),
            ])),
            Divider(height: 1, thickness: 1, color: theme.dividerColor),
            IntrinsicHeight(child: Row(children: [
              Expanded(child: _service(context, title: 'Donor Darah', subtitle: 'Pendonor dan permintaan',
                icon: Icons.bloodtype_outlined, start: pink, end: dark ? const Color(0xFF303238) : const Color(0xFFF0F1F3),
                accent: dark ? const Color(0xFFFF9EAE) : const Color(0xFFD94E68),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonorPage())))),
              VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor),
              Expanded(child: _service(context, title: 'Layanan Publik', subtitle: 'Informasi layanan Kalbar',
                icon: Icons.account_balance_outlined, start: mint, end: dark ? const Color(0xFF303238) : const Color(0xFFF0F1F3),
                accent: dark ? const Color(0xFF80D8C3) : const Color(0xFF328F7B),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage())))),
            ])),
          ]),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _sectionTitle(context, 'Jelajahi Kalbar', subtitle: 'Temukan wisata, budaya, kuliner, dan produk lokal')),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExplorePage())),
              child: Text('Lihat Semua', style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const _ExploreDashboardPreview(),
        const SizedBox(height: 20),
        _sectionTitle(context, 'Informasi Terkini', subtitle: 'Update berita, pengumuman, dan informasi seputar Kalbar'),
        Divider(height: 1, thickness: 1, color: theme.dividerColor.withValues(alpha: .85)),
        const SizedBox(height: 12),
        _LatestDashboardInfo(onOpen: (post) => _openInfo(context, post)),
        const SizedBox(height: 8),
      ],
    );
  }
}


class _LiveWeatherCard extends StatefulWidget {
  final bool compact;
  const _LiveWeatherCard({this.compact = false});
  @override State<_LiveWeatherCard> createState() => _LiveWeatherCardState();
}
class _LiveWeatherCardState extends State<_LiveWeatherCard> {
  bool loading=true;
  String place='Mendeteksi lokasi perangkat', condition='Memuat cuaca…', updated='';
  String? error;
  double? temp, feels, humidity, wind;
  int? code;
  @override void initState(){super.initState(); _load();}
  Future<void> _load() async {
    try {
      var permission=await Geolocator.checkPermission();
      if(permission==LocationPermission.denied) permission=await Geolocator.requestPermission();
      if(permission==LocationPermission.denied||permission==LocationPermission.deniedForever) throw Exception('Izin lokasi belum diberikan');
      if(!await Geolocator.isLocationServiceEnabled()) throw Exception('Aktifkan GPS untuk melihat cuaca');
      final pos=await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy:LocationAccuracy.medium,timeLimit:Duration(seconds:18)));
      final uri=Uri.https('api.open-meteo.com','/v1/forecast',{'latitude':pos.latitude.toString(),'longitude':pos.longitude.toString(),'current':'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m','timezone':'auto'});
      final response=await http.get(uri).timeout(const Duration(seconds:15));
      if(response.statusCode!=200) throw Exception('Layanan cuaca tidak merespons');
      final current=(jsonDecode(response.body) as Map<String,dynamic>)['current'] as Map<String,dynamic>;
      String city='Lokasi perangkat';
      try { final geo=await http.get(Uri.https('nominatim.openstreetmap.org','/reverse',{'format':'jsonv2','lat':pos.latitude.toString(),'lon':pos.longitude.toString()}),headers:{'User-Agent':'KalbarKite/1.0'}).timeout(const Duration(seconds:7)); if(geo.statusCode==200){final addr=(jsonDecode(geo.body)['address'] as Map?)??{};city=(addr['city']??addr['town']??addr['county']??addr['state']??city).toString();} } catch(_){}
      if(!mounted)return;
      setState(() { place=city; temp=(current['temperature_2m'] as num?)?.toDouble(); feels=(current['apparent_temperature'] as num?)?.toDouble(); humidity=(current['relative_humidity_2m'] as num?)?.toDouble(); wind=(current['wind_speed_10m'] as num?)?.toDouble(); code=(current['weather_code'] as num?)?.toInt(); condition=_label((current['weather_code'] as num?)?.toInt()??-1); updated=(current['time']??'').toString().replaceFirst('T',' • '); loading=false; error=null; });
    } catch(e){if(mounted)setState(() { loading=false; error=e.toString().replaceFirst('Exception: ',''); });}
  }
  String _label(int c){if(c==0)return 'Cerah';if(c==1||c==2)return 'Cerah berawan';if(c==3)return 'Berawan';if(c==45||c==48)return 'Berkabut';if(c>=51&&c<=67)return 'Gerimis / hujan';if(c>=80&&c<=82)return 'Hujan';if(c>=95)return 'Badai petir';return 'Kondisi cuaca berubah';}
  @override Widget build(BuildContext context){
    final dark=Theme.of(context).brightness==Brightness.dark;final fg=dark?Colors.white:const Color(0xFF173B5A);
    if (widget.compact) {
      return Container(
        height: 112,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF203D5B) : const Color(0xFFD8EEFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .35)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(children: [
            Icon(Icons.location_on_outlined, size: 13, color: fg),
            const SizedBox(width: 3),
            Expanded(child: Text(place, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: fg, fontSize: 10.5, fontWeight: FontWeight.w700))),
            InkWell(onTap: loading ? null : () { setState(() { loading = true; error = null; }); _load(); },
              child: Icon(Icons.refresh_rounded, size: 16, color: fg)),
          ]),
          const SizedBox(height: 5),
          Row(children: [
            Icon(code == 0 ? Icons.wb_sunny_rounded : Icons.cloud_rounded, size: 30,
              color: dark ? const Color(0xFFFFD166) : const Color(0xFF287FC0)),
            const SizedBox(width: 6),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(loading ? '…' : (temp == null ? '--°C' : '${temp!.round()}°C'),
                style: GoogleFonts.fredoka(fontSize: 25, fontWeight: FontWeight.w600, color: fg)),
              Text(condition, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.fredoka(fontSize: 11, color: fg, fontWeight: FontWeight.w500)),
            ])),
          ]),
          Text('Terasa ${feels?.round() ?? '--'}°  •  RH ${humidity?.round() ?? '--'}%',
            maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg.withValues(alpha: .8), fontSize: 9)),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? const [Color(0xFF203D5B), Color(0xFF26334E)]
              : const [Color(0xFFD8EEFF), Color(0xFFEAF4FF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Row(children:[Icon(Icons.location_on_outlined,size:16,color:fg),const SizedBox(width:4),Expanded(child:Text(place,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(color:fg,fontWeight:FontWeight.w700))),IconButton(onPressed:loading?null:(){setState(() { loading=true; error=null; });_load();},icon:const Icon(Icons.refresh_rounded,size:19))]),
      Row(children:[Icon(code==0?Icons.wb_sunny_rounded:Icons.cloud_rounded,size:45,color:dark?const Color(0xFFFFD166):const Color(0xFF287FC0)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(loading?'Memuat…':(temp==null?'--°C':temp!.round().toString()+'°C'),style:GoogleFonts.fredoka(fontSize:32,fontWeight:FontWeight.w700,color:fg)),Text(condition,style:TextStyle(color:fg,fontWeight:FontWeight.w700)),if(error!=null)Text(error!,style:TextStyle(color:fg,fontSize:11))]))]),
      const Divider(height:18),
      Wrap(spacing:16,runSpacing:6,children:[Text('Terasa '+(feels?.round().toString()??'--')+'°C',style:TextStyle(color:fg,fontSize:11)),Text('Kelembapan '+(humidity?.round().toString()??'--')+'%',style:TextStyle(color:fg,fontSize:11)),Text('Angin '+(wind?.toStringAsFixed(0)??'--')+' km/j',style:TextStyle(color:fg,fontSize:11))]),
      if(updated.isNotEmpty)Text('Diperbarui '+updated,style:TextStyle(color:fg.withValues(alpha:.7),fontSize:10)),
    ]));
  }
}

class _UpcomingAgendaPreview extends StatelessWidget {
  final bool compact;
  const _UpcomingAgendaPreview({this.compact = false});
  @override Widget build(BuildContext context){
    final events=Store.eventPosts.where((e)=>e['status']=='published').toList()..sort((a,b)=>(DateTime.tryParse(a['scheduledAt']??'')??DateTime(2100)).compareTo(DateTime.tryParse(b['scheduledAt']??'')??DateTime(2100)));
    final event=events.isEmpty?null:events.first;
    if (compact) {
      final theme = Theme.of(context);
      return InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventPage())),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 112,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? theme.cardColor : const Color(0xFFEBEAFE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withValues(alpha: .45)),
          ),
          child: Row(children: [
            Container(width: 35, height: 35,
              decoration: BoxDecoration(color: const Color(0xFFDCD5FF), borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF7656D8), size: 21)),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Agenda Mendatang', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 3),
              Text(event?['title'] ?? 'Belum ada agenda', maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(fontSize: 10.5, height: 1.2, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
            ])),
            const Icon(Icons.chevron_right_rounded, size: 18),
          ]),
        ),
      );
    }
    return InkWell(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const EventPage())),child:Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(15),border:Border.all(color:Theme.of(context).dividerColor)),child:Row(children:[Container(width:46,height:46,decoration:BoxDecoration(color:const Color(0xFFECE8FF),borderRadius:BorderRadius.circular(12)),child:const Icon(Icons.calendar_month_rounded,color:Color(0xFF7656D8))),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(event?['title']??'Belum ada agenda mendatang',maxLines:1,overflow:TextOverflow.ellipsis,style:GoogleFonts.fredoka(fontWeight:FontWeight.w700,fontSize:15)),Text(event==null?'Agenda kegiatan Kalbar akan muncul di sini':((event['date']??event['scheduledAt']??'')+' • '+(event['location']??'Kalimantan Barat')),maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:11,color:Theme.of(context).colorScheme.onSurfaceVariant))])),const Icon(Icons.chevron_right_rounded)])));
  }
}

class _ExploreDashboardPreview extends StatelessWidget {
  const _ExploreDashboardPreview();
  @override Widget build(BuildContext context){
    const cards=[('Wisata Alam','https://www.pesonaindo.com/wp-content/uploads/2016/04/P9203020.jpg',Icons.camera_alt_rounded),('Wisata Budaya','https://awsimages.detik.net.id/community/media/visual/2024/11/07/seni-tato-suku-dayak-iban-2.jpeg?q=90&w=650',Icons.groups_rounded),('Kuliner Khas','https://image.popmama.com/post/20260512/upload_4a7fe54d554ab970173472ff8fa3aa73_2392ba97-ccfb-4c7e-b185-07b1eff66bbc.jpg',Icons.restaurant_rounded),('Produk Lokal (UMKM)','https://jadesta.kemenpar.go.id/imgpost/2022/08/02/tenun-sambas.jpg',Icons.storefront_rounded)];
    return SizedBox(height:124,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:cards.length,separatorBuilder:(_,__)=>const SizedBox(width:10),itemBuilder:(context,i){final item=cards[i];final description=switch(item.$1){'Wisata Alam'=>'Destinasi alam dan keindahan Kalimantan Barat','Wisata Budaya'=>'Tradisi, festival, dan budaya masyarakat Kalbar','Kuliner Khas'=>'Makanan khas dan kuliner daerah Kalbar',_=>'Produk dan usaha lokal masyarakat Kalbar'};return InkWell(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ExploreCategoryPage(title:item.$1,description:description))),child:ClipRRect(borderRadius:BorderRadius.circular(15),child:SizedBox(width:166,child:Stack(fit:StackFit.expand,children:[CachedNetworkImage(imageUrl:item.$2,fit:BoxFit.cover,errorWidget:(_,__,___)=>Container(color:const Color(0xFFE5EEF8),child:Icon(item.$3))),DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.transparent,Colors.black.withValues(alpha:.75)]))),Positioned(left:9,right:8,bottom:9,child:Row(children:[Icon(item.$3,color:Colors.white,size:17),const SizedBox(width:5),Expanded(child:Text(item.$1,maxLines:2,style:GoogleFonts.fredoka(color:Colors.white,fontWeight:FontWeight.w600,fontSize:13)))]))]))));}));
  }
}

class _DashboardAnnouncements extends StatelessWidget {
  const _DashboardAnnouncements();
  @override Widget build(BuildContext context)=>StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:_db.collection('info_posts').orderBy('createdAt',descending:true).limit(20).snapshots(),builder:(context,snapshot){final docs=snapshot.data?.docs??[];final items=docs.where((d)=>(d.data()['category']??'').toString().toLowerCase().contains('pengumuman')||(d.data()['displaySection']??'').toString().toLowerCase().contains('pengumuman')).take(2).toList();if(items.isEmpty)return Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(13),border:Border.all(color:Theme.of(context).dividerColor)),child:const Text('Belum ada pengumuman terbaru.'));return Column(children:items.map((d)=>Card(child:ListTile(leading:const Icon(Icons.campaign_outlined,color:Color(0xFF7656D8)),title:Text((d.data()['title']??'Pengumuman').toString(),maxLines:1,overflow:TextOverflow.ellipsis),subtitle:Text((d.data()['body']??'').toString(),maxLines:2,overflow:TextOverflow.ellipsis)))).toList());});
}

class _DidYouKnowCard extends StatelessWidget {
  const _DidYouKnowCard();
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFFEAF9E8),borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0xFFD4EFCB))),child:Row(children:[const Icon(Icons.lightbulb_outline_rounded,color:Color(0xFF259A42),size:30),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Tahukah Kamu?',style:GoogleFonts.fredoka(fontSize:17,fontWeight:FontWeight.w700,color:const Color(0xFF183A22))),const Text('Kalimantan Barat memiliki 14 kabupaten/kota dengan keragaman budaya, suku, dan bahasa.',style:TextStyle(color:Color(0xFF183A22),fontSize:12.5,height:1.35))]))]));
}

class _LatestDashboardInfo extends StatelessWidget {
  final ValueChanged<Map<String, String>> onOpen;
  const _LatestDashboardInfo({required this.onOpen});

  Color _categoryColor(String category) {
    final value = category.toLowerCase();
    if (value.contains('berita')) return const Color(0xFFFF8A24);
    if (value.contains('event')) return const Color(0xFF159B72);
    if (value.contains('pengumuman')) return const Color(0xFF1684F8);
    return const Color(0xFF1684F8);
  }

  String _dateLabel(String raw) {
    if (raw.isEmpty) return 'Terbaru';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('info_posts').orderBy('createdAt', descending: true).limit(8).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('Informasi belum dapat dimuat. Periksa koneksi lalu coba lagi.',
              style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
          );
        }
        if (!snapshot.hasData) {
          return const SizedBox(height: 142, child: Center(
            child: SizedBox(width: 21, height: 21, child: CircularProgressIndicator(strokeWidth: 2))));
        }
        final latest = snapshot.data!.docs.map((doc) {
          final data = doc.data();
          return <String, String>{
            'id': doc.id,
            'title': (data['title'] ?? '').toString(),
            'body': (data['body'] ?? '').toString(),
            'date': (data['date'] ?? '').toString(),
            'category': (data['category'] ?? 'Informasi umum').toString(),
            'displaySection': (data['displaySection'] ?? 'both').toString(),
            'imagePath': _firstImageUrl(data),
          };
        }).where((post) => ['informasi_terkini', 'both'].contains(post['displaySection'])).toList();
        if (latest.isEmpty) {
          return Container(
            height: 132,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF1C2635) : const Color(0xFFF1F6FC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withValues(alpha:.6))),
            child: Row(children: [
              Icon(Icons.newspaper_rounded, size: 34, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text('Belum ada informasi terbaru',
                style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
            ]),
          );
        }
        return SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(right: 4, bottom: 3),
            itemCount: latest.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final post = latest[index];
              final image = _normalizeImageUrl(post['imagePath'] ?? '');
              final category = post['category'] ?? 'Informasi umum';
              final accent = _categoryColor(category);
              return SizedBox(
                width: 236,
                child: Material(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(13),
                  child: InkWell(
                    onTap: () => onOpen(post),
                    borderRadius: BorderRadius.circular(13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: double.infinity, height: 146,
                            child: image.startsWith('https://')
                              ? CachedNetworkImage(imageUrl: image, fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: dark ? const Color(0xFF24364D) : const Color(0xFFE5F1FF),
                                    child: Icon(Icons.image_outlined, color: theme.colorScheme.primary, size: 27)),
                                  errorWidget: (_, __, ___) => Container(
                                    color: dark ? const Color(0xFF24364D) : const Color(0xFFE5F1FF),
                                    child: Icon(Icons.article_outlined, color: theme.colorScheme.primary, size: 27)))
                              : Container(
                                  color: dark ? const Color(0xFF24364D) : const Color(0xFFE5F1FF),
                                  child: Icon(Icons.article_outlined, color: theme.colorScheme.primary, size: 27)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: dark ? .20 : .13),
                            borderRadius: BorderRadius.circular(20)),
                          child: Text(category, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: accent)),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(post['title'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.fredoka(fontSize: 14, height: 1.12, fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface)),
                        ),
                        const SizedBox(height: 7),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(children: [
                          Icon(CupertinoIcons.calendar, size: 11, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(child: Text(_dateLabel(post['date'] ?? ''),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant))),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _HomeServiceCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color start, end, accent;
  final VoidCallback onTap;
  final bool wide;
  const _HomeServiceCard({required this.title, required this.subtitle, required this.icon,
    required this.start, required this.end, required this.accent, required this.onTap, this.wide = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 78),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: wide ? 13 : 11, vertical: 9),
            child: Row(children: [
              Container(
                width: wide ? 34 : 30,
                height: wide ? 34 : 30,
                decoration: BoxDecoration(
                  color: start.withValues(alpha: dark ? .42 : .55),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: accent, size: 19),
              ),
              const SizedBox(width: 9),
              Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(fontSize: 16,
                      height: 1.15, fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 3),
                  Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 11.5, height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant)),
                ],
              )),
              if (wide) Icon(Icons.chevron_right_rounded, size: 19, color: theme.colorScheme.onSurfaceVariant),
            ]),
          ),
        ),
      ),
    );
  }
}



class KalbarEvent {
  final String title, date, time, location, description;
  final String scheduledAt, sourceName, sourceUrl, imageUrl;
  const KalbarEvent(this.title, this.date, this.time, this.location, this.description, {
    this.scheduledAt = '', this.sourceName = '', this.sourceUrl = '', this.imageUrl = '',
  });
  String get displayDate {
    if (date.isNotEmpty) return date;
    final value = DateTime.tryParse(scheduledAt);
    if (value == null) return 'Tanggal belum ditentukan';
    const months = ['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];
    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }
  String get displayTime {
    if (time.isNotEmpty) return time;
    final value = DateTime.tryParse(scheduledAt);
    if (value == null) return 'Waktu belum ditentukan';
    return '${value.hour.toString().padLeft(2, '0')}.${value.minute.toString().padLeft(2, '0')} WIB';
  }
}
class EventPage extends StatefulWidget {
  const EventPage({super.key});
  @override
  State<EventPage> createState() => _EventPageState();
}
class _EventPageState extends State<EventPage> {
  final Set<String> _saved = {};
  final _search = TextEditingController();
  bool _searching = false;

  Future<void> _openMap(BuildContext context, String location) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=' + Uri.encodeComponent(location));
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Peta tidak dapat dibuka.')));
  }
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remote = Store.eventPosts.where((x) => x['status'] == 'published').map((x) => KalbarEvent(
      x['title'] ?? '', x['date'] ?? '', x['time'] ?? '', x['location'] ?? '', x['description'] ?? '',
      scheduledAt: x['scheduledAt'] ?? '', sourceName: x['sourceName'] ?? '',
      sourceUrl: x['sourceUrl'] ?? '',
      imageUrl: _normalizeImageUrl((x['imageUrl'] ?? '').toString()).isNotEmpty ? _normalizeImageUrl((x['imageUrl'] ?? '').toString()) : _normalizeImageUrl(Store.eventFallbackImageUrl),
    )).toList();
    final source = remote;
    final now = DateTime.now();
    final events = source.where((e) {
      final date = DateTime.tryParse(e.scheduledAt) ?? Store._legacyEventDate(e);
      final q = _search.text.trim().toLowerCase();
      return (date == null || !date.isBefore(now.subtract(const Duration(days: 1)))) &&
        (q.isEmpty || e.title.toLowerCase().contains(q) || e.location.toLowerCase().contains(q) || e.description.toLowerCase().contains(q));
    }).toList()..sort((a,b) {
      final da = DateTime.tryParse(a.scheduledAt) ?? Store._legacyEventDate(a);
      final db = DateTime.tryParse(b.scheduledAt) ?? Store._legacyEventDate(b);
      if (da == null) return 1; if (db == null) return -1; return da.compareTo(db);
    });
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF101827) : const Color(0xFFFDFEFF),
      body: SafeArea(child: Column(children: [
        PageHeader(
          title: 'Event Kalbar',
          searchActive: _searching,
          onSearch: () => setState(() {
            _searching = !_searching;
            if (!_searching) _search.clear();
          }),
          titleWidget: _searching ? TextField(
            controller: _search,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari agenda...',
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ) : null,
        ),
        Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 28), children: [
          if (events.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...events.asMap().entries.map((entry) => _poster(context, entry.value, entry.key)),
          ] else Container(width: double.infinity, margin: const EdgeInsets.only(top: 36, bottom: 22),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
            decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(28),
              border: Border.all(color: theme.dividerColor.withValues(alpha: .45))),
            child: Column(children: [
              Icon(CupertinoIcons.calendar, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 14),
              Text('Belum ada agenda', style: GoogleFonts.fredoka(fontSize: 19, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Text('Agenda kegiatan Kalimantan Barat akan muncul di sini.', textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ])),
          const SizedBox(height: 12),
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
              child: Text('Belum ada agenda yang dipublikasikan. Informasi akan muncul setelah ditambahkan melalui website admin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
            ),
        ])),
      ])),
    );
  }

  Widget _poster(BuildContext context, KalbarEvent event, int index) {
    final theme = Theme.of(context);
    final saved = _saved.contains(event.title);
    final dark = theme.brightness == Brightness.dark;
    final posterUrl = event.imageUrl.trim().isNotEmpty ? event.imageUrl.trim() : Store.eventFallbackImageUrl.trim();
    final hasPoster = posterUrl.startsWith('https://');

    return TweenAnimationBuilder<double>(
      key: ValueKey('event-' + event.title + '-' + index.toString()),
      tween: Tween<double>(begin: .96, end: 1),
      duration: Duration(milliseconds: 420 + (index % 4) * 90),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0.0, 1.0).toDouble(),
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 16),
          child: child,
        ),
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withValues(alpha: .65), width: .8),
          // Flat event cards keep the page light and uncluttered.
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 168,
                child: hasPoster
                    ? CachedNetworkImage(
                        imageUrl: posterUrl,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 280),
                        placeholder: (_, __) => Container(color: theme.colorScheme.surfaceContainerHighest),
                        errorWidget: (_, __, ___) => Container(
                          decoration: const BoxDecoration(gradient: LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                            colors: [Color(0xFFEAF1F8), Color(0xFFDCE6F0)],
                          )),
                          child: Icon(Icons.event_available_rounded, size: 42, color: theme.colorScheme.primary),
                        ),
                      )
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.event_available_rounded, size: 38, color: theme.colorScheme.onSurfaceVariant),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 96),
                child: ClipPath(
                  clipper: _EventWaveClipper(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(21, 38, 17, 13),
                    color: theme.cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          maxLines: 3,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: GoogleFonts.fredoka(
                            fontSize: 21,
                            height: 1.10,
                            fontWeight: FontWeight.w700,
                            color: dark ? Colors.white : const Color(0xFF101D4A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _pill(CupertinoIcons.calendar, event.displayDate, true),
                            _pill(CupertinoIcons.clock, event.displayTime, false),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          event.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Divider(
                          height: 1,
                          color: theme.dividerColor.withValues(alpha: .65),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.location,
                              size: 21,
                              color: Color(0xFF0878F5),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.location,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Container(
                              width: 1,
                              height: 32,
                              color: theme.dividerColor,
                            ),
                            const SizedBox(width: 9),
                            OutlinedButton.icon(
                              onPressed: () => _openMap(context, event.location),
                              icon: const Icon(CupertinoIcons.map, size: 19),
                              label: Text(
                                'Peta',
                                style: GoogleFonts.fredoka(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 34),
                                foregroundColor: const Color(0xFF0878E8),
                                backgroundColor: const Color(0xFFEAF6FF),
                                side: const BorderSide(
                                  color: Color(0xFF91CCFF),
                                  width: 1.3,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 13,
                top: 12,
                child: Material(
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: theme.dividerColor, width: .8)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() {
                      if (saved) {
                        _saved.remove(event.title);
                      } else {
                        _saved.add(event.title);
                      }
                    }),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        saved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                        color: saved ? const Color(0xFF0878E8) : const Color(0xFF34415D),
                        size: 23,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String text, bool blue) {
    final bg = blue ? const Color(0xFFE1F2FF) : const Color(0xFFF0F2F6);
    final fg = blue ? const Color(0xFF0878E8) : const Color(0xFF34415D);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(22)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 17, color: fg), const SizedBox(width: 7),
        Text(text, style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
      ]));
  }

}
class _EventWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0,30)
    ..cubicTo(size.width*.06,5,size.width*.20,7,size.width*.36,17)
    ..cubicTo(size.width*.57,30,size.width*.76,40,size.width,25)
    ..lineTo(size.width,size.height)..lineTo(0,size.height)..close();
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class RandomPage extends StatelessWidget {
  const RandomPage({super.key});

  Widget _imageCard(BuildContext context, {
    required String title,
    required String imageUrl,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final hasImage = imageUrl.startsWith('https://');
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: .9), width: 1.1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => const ColoredBox(
                        color: Color(0xFFF1F3F5),
                        child: Center(child: Icon(CupertinoIcons.photo, size: 34, color: Color(0xFF8795A3))),
                      ),
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: Color(0xFFF1F3F5),
                        child: Center(child: Icon(CupertinoIcons.photo, size: 34, color: Color(0xFF8795A3))),
                      ),
                    )
                  : const ColoredBox(
                      color: Color(0xFFF1F3F5),
                      child: Center(child: Icon(CupertinoIcons.photo, size: 34, color: Color(0xFF8795A3))),
                    ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 23),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fredoka(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCard(BuildContext context, Map<String,String> item, int index) async {
    final action = (item['action'] ?? '').trim().isNotEmpty
        ? item['action']!.trim()
        : index == 0 ? 'quran' : index == 1 ? 'pantun' : '';
    if (action == 'quran') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranPage()));
      return;
    }
    if (action == 'pantun') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PantunPage()));
      return;
    }
    if (action == 'url') {
      final uri = Uri.tryParse(item['target'] ?? '');
      if (uri != null && uri.scheme == 'https' && uri.host.isNotEmpty) {
        final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tautan tidak dapat dibuka.')));
        }
        return;
      }
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu ini belum memiliki tujuan.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = Store.randomCards.isEmpty
        ? <Map<String,String>>[
            {'title':'Islami','action':'quran','imageUrl':''},
            {'title':'Pantun Kalbar','action':'pantun','imageUrl':''},
          ]
        : Store.randomCards.take(8).toList();
    return BackPage(
      title: 'Lainnya',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: .80,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...cards.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final title = (item['title'] ?? '').trim().isEmpty
                    ? (index == 0 ? 'Islami' : index == 1 ? 'Pantun Kalbar' : 'Menu')
                    : item['title']!.trim();
                final isQuran = (item['action'] ?? (index == 0 ? 'quran' : '') ) == 'quran';
                return _imageCard(
                  context,
                  title: title,
                  imageUrl: item['imageUrl'] ?? '',
                  icon: isQuran ? CupertinoIcons.moon_stars_fill : CupertinoIcons.book,
                  onTap: () => _openCard(context, item, index),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class PantunItem {
  final String culture, theme, first, second, third, fourth;
  const PantunItem(this.culture, this.theme, this.first, this.second, this.third, this.fourth);
}

class PantunPage extends StatefulWidget {
  final String initialTheme;
  const PantunPage({super.key, this.initialTheme = 'Semua'});
  @override
  State<PantunPage> createState() => _PantunPageState();
}
class _PantunPageState extends State<PantunPage> {
  final TextEditingController search = TextEditingController();

  Widget _pantunFilterField(BuildContext context, {
    required String label,
    required String value,
    required List<String> options,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: InputDecorator(
        isFocused: false,
        isEmpty: false,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.fredoka(
            fontSize: 14, fontWeight: FontWeight.w700,
            color: muted,
          ),
          floatingLabelStyle: GoogleFonts.fredoka(
            fontSize: 14, fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
          isDense: true,
          filled: true,
          fillColor: theme.colorScheme.surface,
          suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, color: muted),
          contentPadding: const EdgeInsets.fromLTRB(13, 12, 9, 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
        ),
        child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: GoogleFonts.fredoka(
            fontSize: 16, fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          )),
      ),
    );
  }
  String culture = 'Semua';
  String themeFilter = 'Semua';

  @override
  void initState() { super.initState(); themeFilter = widget.initialTheme; }

  @override
  void dispose() { search.dispose(); super.dispose(); }

  List<PantunItem> get filtered {
    final query = search.text.trim().toLowerCase();
    final remote = Store.pantunPosts.where((item) => item['status'] == 'published')
      .map((item) => PantunItem(
        item['culture'] ?? 'Melayu', item['theme'] ?? 'Budaya',
        item['first'] ?? '', item['second'] ?? '', item['third'] ?? '', item['fourth'] ?? '',
      )).toList();
    return remote.where((p) {
      final matchesCulture = culture == 'Semua' || p.culture == culture;
      final matchesTheme = themeFilter == 'Semua' || p.theme == themeFilter;
      final searchable = [p.culture, p.theme, p.first, p.second, p.third, p.fourth].join(' ').toLowerCase();
      return matchesCulture && matchesTheme && (query.isEmpty || searchable.contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final list = filtered;
    final cultures = <String>{'Semua', ...Store.pantunPosts.where((x) => x['status'] == 'published')
      .map((x) => x['culture'] ?? '').where((x) => x.trim().isNotEmpty)}.toList()
      ..sort((a, b) => a == 'Semua' ? -1 : b == 'Semua' ? 1 : a.compareTo(b));
    final themes = <String>{'Semua', ...Store.pantunPosts.where((x) => x['status'] == 'published')
      .map((x) => x['theme'] ?? '').where((x) => x.trim().isNotEmpty)}.toList()
      ..sort((a, b) => a == 'Semua' ? -1 : b == 'Semua' ? 1 : a.compareTo(b));
    final ink = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final border = theme.dividerColor;

    return BackPage(title: 'Pantun Kalbar', child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        TextField(
          controller: search, onChanged: (_) => setState(() {}),
          style: GoogleFonts.fredoka(fontSize: 15, color: ink),
          decoration: InputDecoration(
            prefixIcon: Icon(CupertinoIcons.search, color: muted),
            hintText: 'Cari pantun, tema, atau budaya...',
            hintStyle: GoogleFonts.fredoka(fontSize: 14, color: muted),
            filled: true, fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: ink, width: 1.2)),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _pantunFilterField(
            context, label: 'Budaya', value: culture, options: cultures,
            onTap: () async {
              final value = await _showKalbarPicker(context,
                title: 'Pilih budaya', hint: 'Cari budaya...', options: cultures,
                selected: culture);
              if (value != null && mounted) setState(() => culture = value);
            },
          )),
          const SizedBox(width: 10),
          Expanded(child: _pantunFilterField(
            context, label: 'Tema', value: themeFilter, options: themes,
            onTap: () async {
              final value = await _showKalbarPicker(context,
                title: 'Pilih tema pantun', hint: 'Cari tema pantun...', options: themes,
                selected: themeFilter);
              if (value != null && mounted) setState(() => themeFilter = value);
            },
          )),
        ]),
        const SizedBox(height: 12),
        const SizedBox(height: 12),
        Text('${list.length} pantun', style: GoogleFonts.fredoka(fontSize: 13, color: muted, fontWeight: FontWeight.w700)),
        const SizedBox(height: 7),
        if (list.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 18), child: Column(children: [
            Icon(CupertinoIcons.search, size: 34, color: muted),
            const SizedBox(height: 10),
            Text('Pantun tidak ditemukan', style: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 4),
            Text('Coba kata kunci atau pilihan filter lain.', textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(fontSize: 13, color: muted)),
          ]))
        else
          ...list.asMap().entries.map((entry) {
            final p = entry.value;
            return Card(
              color: theme.colorScheme.surface, elevation: 0,
              margin: const EdgeInsets.only(bottom: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13), side: BorderSide(color: border)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(p.theme + ' • ' + p.culture,
                      style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w700, color: ink))),
                    Text((entry.key + 1).toString(), style: GoogleFonts.fredoka(fontSize: 12, color: muted)),
                  ]),
                  const SizedBox(height: 9),
                  for (final line in [p.first, p.second, p.third, p.fourth])
                    Padding(padding: const EdgeInsets.only(bottom: 3),
                      child: Text(line, style: GoogleFonts.fredoka(fontSize: 14, height: 1.35, color: ink, fontWeight: FontWeight.w500))),
                ]),
              ),
            );
          }),
      ],
    ));
  }
}


class HistoryPlace {
  final String name;
  final String pageTitle;
  final String kind;
  final String id, body, imageUrl, sourceUrl;
  const HistoryPlace(this.name, this.pageTitle, this.kind, {
    this.id = '', this.body = '', this.imageUrl = '', this.sourceUrl = '',
  });
}

const List<HistoryPlace> _defaultKalbarPlaces = [
  HistoryPlace('Kabupaten Sambas', 'Kabupaten Sambas', 'Kabupaten'),
  HistoryPlace('Kabupaten Bengkayang', 'Kabupaten Bengkayang', 'Kabupaten'),
  HistoryPlace('Kabupaten Landak', 'Kabupaten Landak', 'Kabupaten'),
  HistoryPlace('Kabupaten Mempawah', 'Kabupaten Mempawah', 'Kabupaten'),
  HistoryPlace('Kabupaten Sanggau', 'Kabupaten Sanggau', 'Kabupaten'),
  HistoryPlace('Kabupaten Ketapang', 'Kabupaten Ketapang', 'Kabupaten'),
  HistoryPlace('Kabupaten Sintang', 'Kabupaten Sintang', 'Kabupaten'),
  HistoryPlace('Kabupaten Kapuas Hulu', 'Kabupaten Kapuas Hulu', 'Kabupaten'),
  HistoryPlace('Kabupaten Sekadau', 'Kabupaten Sekadau', 'Kabupaten'),
  HistoryPlace('Kabupaten Melawi', 'Kabupaten Melawi', 'Kabupaten'),
  HistoryPlace('Kabupaten Kayong Utara', 'Kabupaten Kayong Utara', 'Kabupaten'),
  HistoryPlace('Kabupaten Kubu Raya', 'Kabupaten Kubu Raya', 'Kabupaten'),
  HistoryPlace('Kota Pontianak', 'Kota Pontianak', 'Kota'),
  HistoryPlace('Kota Singkawang', 'Kota Singkawang', 'Kota'),
];

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}
class _HistoryPageState extends State<HistoryPage> {
  String query = '';
  final Map<String, String> _regionImages = {};
  bool _loadingRegionImages = false;
  @override
  void initState() {
    super.initState();
    Store.appConfigRevision.addListener(_onCloudDataChanged);
    _loadRegionImages();
  }

  Future<void> _loadRegionImages() async {
    if (_loadingRegionImages) return;
    _loadingRegionImages = true;
    try {
      final titles = _defaultKalbarPlaces.map((place) => place.pageTitle).join('|');
      final uri = Uri.https('id.wikipedia.org', '/w/api.php', {
        'action': 'query', 'format': 'json', 'formatversion': '2',
        'prop': 'pageimages', 'piprop': 'thumbnail', 'pithumbsize': '480',
        'redirects': '1', 'titles': titles,
      });
      final response = await http.get(uri, headers: const {
        'Accept': 'application/json',
        'User-Agent': 'Kalbar Kite/1.0 (aplikasi informasi sejarah Kalimantan Barat)',
      }).timeout(const Duration(seconds: 18));
      if (response.statusCode != 200) return;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final pages = (json['query']?['pages'] as List<dynamic>?) ?? [];
      final images = <String, String>{};
      for (final raw in pages) {
        final page = Map<String, dynamic>.from(raw as Map);
        final thumb = page['thumbnail'];
        final source = thumb is Map ? _normalizeImageUrl((thumb['source'] ?? '').toString()) : '';
        if (source.isNotEmpty) {
          images[(page['title'] ?? '').toString().toLowerCase()] = source;
        }
      }
      if (mounted) setState(() { _regionImages.addAll(images); });
    } catch (_) {
      // Region names remain usable if Wikipedia thumbnails are unavailable.
    } finally {
      _loadingRegionImages = false;
    }
  }
  void _onCloudDataChanged() { if (mounted) setState(() {}); }
  @override
  void dispose() {
    Store.appConfigRevision.removeListener(_onCloudDataChanged);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final remote = Store.historyPosts
      .where((item) => item['status'] == 'published')
      .map((item) => HistoryPlace(
        item['title'] ?? '', item['pageTitle'] ?? item['title'] ?? '',
        item['kind'] ?? 'Kabupaten', id: item['id'] ?? '',
        body: item['body'] ?? '', imageUrl: _normalizeImageUrl(item['imageUrl'] ?? ''),
        sourceUrl: item['sourceUrl'] ?? '',
      )).toList();
    final source = <HistoryPlace>[
      ..._defaultKalbarPlaces.where((fallback) =>
        !remote.any((item) => item.name.toLowerCase() == fallback.name.toLowerCase())),
      ...remote,
    ];
    final places = source.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    return BackPage(
      title: 'Sejarah Kalbar',
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 22), children: [
        TextField(
          onChanged: (v) => setState(() => query = v),
          decoration: InputDecoration(
            prefixIcon: Icon(CupertinoIcons.search, size: 19, color: Theme.of(context).colorScheme.onSurfaceVariant),
            hintText: 'Cari kabupaten atau kota',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: .45),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant, width: 1.2)),
          ),
        ),
        const SizedBox(height: 10),
        Text(places.length.toString() + ' wilayah', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 5),
        ...places.map((p) => Card(
          elevation: 0,
          shadowColor: Colors.transparent,
          color: Theme.of(context).colorScheme.surface.withValues(alpha: .55),
          margin: const EdgeInsets.only(bottom: 7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Theme.of(context).dividerColor, width: .8)),
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 0),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48, height: 48,
                child: _normalizeImageUrl(p.imageUrl).isNotEmpty
                    ? CachedNetworkImage(imageUrl: _normalizeImageUrl(p.imageUrl), fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _regionImageFallback(p))
                    : (_regionImages[p.pageTitle.toLowerCase()] ?? '').isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _regionImages[p.pageTitle.toLowerCase()]!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _regionImageFallback(p),
                            errorWidget: (_, __, ___) => _regionImageFallback(p),
                          )
                        : _regionImageFallback(p),
              ),
            ),
            title: Text(p.name, style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
            trailing: const Icon(CupertinoIcons.chevron_right, size: 20),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryDetailPage(place: p))),
          ),
        )),
      ]),
    );
  }

  Widget _regionImageFallback(HistoryPlace place) => Container(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    alignment: Alignment.center,
    child: Icon(place.kind == 'Kota' ? Icons.location_city : CupertinoIcons.map,
      color: Theme.of(context).colorScheme.onSurfaceVariant, size: 22),
  );
}

class HistoryDetailPage extends StatefulWidget {
  final HistoryPlace place;
  const HistoryDetailPage({super.key, required this.place});
  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}
class _HistoryDetailPageState extends State<HistoryDetailPage> {
  Map<String, dynamic>? article;
  bool loading = true;
  bool isCached = false;
  String? error;
  String get _cacheKey => 'history_article_${widget.place.pageTitle}';
  @override
  void initState() { super.initState(); _load(); }
  Future<String> _fetchCommonsHistoryImage() async {
    final searchTerms = [
      '"${widget.place.name}" Kalimantan Barat filetype:bitmap',
      '"${widget.place.pageTitle}" Kalbar filetype:bitmap',
    ];
    for (final searchTerm in searchTerms) {
      try {
        final uri = Uri.https('commons.wikimedia.org', '/w/api.php', {
          'action': 'query',
          'format': 'json',
          'formatversion': '2',
          'generator': 'search',
          'gsrsearch': searchTerm,
          'gsrnamespace': '6',
          'gsrlimit': '10',
          'prop': 'imageinfo',
          'iiprop': 'url',
          'iiurlwidth': '1200',
        });
        final response = await http.get(uri, headers: const {
          'Accept': 'application/json',
          'User-Agent': 'Kalbar Kite/1.0 (aplikasi informasi sejarah Kalimantan Barat)',
        }).timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) continue;
        final payload = jsonDecode(response.body) as Map<String, dynamic>;
        final pages = (payload['query']?['pages'] as List<dynamic>?) ?? [];
        for (final raw in pages) {
          final page = Map<String, dynamic>.from(raw as Map);
          final fileName = (page['title'] ?? '').toString().toLowerCase();
          if (RegExp(r'(logo|lambang|coat.of.arms|emblem|flag|bendera|favicon|icon|peta|map)').hasMatch(fileName)) {
            continue;
          }
          final imageInfo = page['imageinfo'] as List<dynamic>?;
          if (imageInfo == null || imageInfo.isEmpty) continue;
          final info = Map<String, dynamic>.from(imageInfo.first as Map);
          final source = _normalizeImageUrl((info['thumburl'] ?? info['url'] ?? '').toString());
          if (source.isNotEmpty) return source;
        }
      } catch (_) {
        // Lanjutkan ke query Commons berikutnya; artikel tetap bisa dibaca.
      }
    }
    return '';
  }

  Future<Map<String, dynamic>> _fetchHistoryOnline() async {
    // Endpoint MediaWiki API lebih stabil untuk aplikasi mobile dibanding endpoint REST summary.
    final uri = Uri.https('id.wikipedia.org', '/w/api.php', {
      'action': 'query', 'format': 'json', 'formatversion': '2',
      'prop': 'extracts|pageimages', 'explaintext': '1',
      'piprop': 'original|thumbnail', 'pithumbsize': '1000',
      'redirects': '1', 'titles': widget.place.pageTitle,
    });
    final response = await http.get(uri, headers: const {
      'Accept': 'application/json',
      'User-Agent': 'Kalbar Kite/1.0 (aplikasi informasi sejarah Kalimantan Barat)',
    }).timeout(const Duration(seconds: 18));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final pages = (json['query']?['pages'] as List<dynamic>?) ?? [];
    if (pages.isEmpty) throw Exception('Halaman sejarah tidak ditemukan.');
    final page = Map<String, dynamic>.from(pages.first as Map);
    if (page['missing'] == true) throw Exception('Artikel belum tersedia.');
    final original = page['original'] as Map?;
    final thumb = page['thumbnail'] as Map?;
    var imageUrl = _normalizeImageUrl(
      (original?['source'] ?? thumb?['source'] ?? '').toString(),
    );
    if (imageUrl.isEmpty) imageUrl = await _fetchCommonsHistoryImage();
    return {
      'title': page['title'] ?? widget.place.name,
      'extract': page['extract'] ?? '',
      'description': '',
      'originalimage': imageUrl.isEmpty ? null : {'source': imageUrl},
      'thumbnail': imageUrl.isEmpty ? null : {'source': imageUrl},
    };
  }
  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    if (widget.place.body.trim().isNotEmpty) {
      var image = _normalizeImageUrl(widget.place.imageUrl);
      if (image.isEmpty) image = await _fetchCommonsHistoryImage();
      if (!mounted) return;
      setState(() {
        article = {
          'title': widget.place.name,
          'extract': widget.place.body,
          'thumbnail': image.isEmpty ? null : {'source': image},
          'originalimage': image.isEmpty ? null : {'source': image},
        };
        isCached = false;
        loading = false;
      });
      return;
    }
    // Tampilkan salinan terakhir dulu agar tetap bisa dibaca tanpa internet.
    final saved = Store.prefs?.getString(_cacheKey);
    if (saved != null) {
      try {
        final cached = Map<String, dynamic>.from(jsonDecode(saved) as Map);
        if (mounted) setState(() { article = cached; isCached = true; loading = false; });
      } catch (_) {}
    }
    try {
      final data = await _fetchHistoryOnline();
      await Store.prefs?.setString(_cacheKey, jsonEncode(data));
      if (!mounted) return;
      setState(() { article = data; isCached = false; loading = false; error = null; });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        if (article == null) error = 'Belum ada data tersimpan. Sambungkan internet lalu tekan Coba lagi.';
        else isCached = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final image = article?['originalimage']?['source'] ?? article?['thumbnail']?['source'];
    final extract = article?['extract']?.toString();
    return BackPage(
      title: widget.place.name,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        if (loading) const Padding(padding: EdgeInsets.all(35), child: Center(child: CircularProgressIndicator())),
        if (error != null) ...[
          Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: _load, icon: const Icon(CupertinoIcons.refresh), label: const Text('Coba lagi')),
        ],
        if (article != null) ...[
          if (image is String && _normalizeImageUrl(image).isNotEmpty)
            ClipRRect(borderRadius: BorderRadius.circular(9), child: CachedNetworkImage(imageUrl: _normalizeImageUrl(image), height: 220, width: double.infinity, fit: BoxFit.cover, placeholder: (_, __) => Container(height: 220, color: pale, child: const Center(child: CircularProgressIndicator())), errorWidget: (_, __, ___) => _historyImageFallback())),
          if (image == null || image is! String || _normalizeImageUrl(image).isEmpty)
            _historyImageFallback(),
          const SizedBox(height: 14),
          Text(widget.place.name, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
          if (article?['description'] != null)
            Padding(padding: const EdgeInsets.only(top: 4), child: Text(article!['description'].toString(), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600))),
          const SizedBox(height: 12),
          Text(extract?.isNotEmpty == true ? extract! : 'Ringkasan sejarah belum tersedia dari sumber online.', style: const TextStyle(fontSize: 15, height: 1.6)),
          const SizedBox(height: 16),
          Text(isCached ? 'Sumber: Wikipedia bahasa Indonesia. Ini adalah salinan terakhir yang tersimpan di perangkat.' : 'Sumber: Wikipedia bahasa Indonesia. Ringkasan dimuat secara online dan dapat diperbarui oleh sumber.', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ]),
    );
  }
  Widget _historyImageFallback() => Container(
    height: 180, decoration: BoxDecoration(color: pale, borderRadius: BorderRadius.circular(9)),
    child: const Center(child: Icon(Icons.account_balance_outlined, color: forest, size: 60)),
  );
}

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});
  @override
  State<QuranPage> createState() => _QuranPageState();
}
class _QuranPageState extends State<QuranPage> {
  final search = TextEditingController();
  List<dynamic> surahs = [];
  bool loading = true;
  String? error;
  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { search.dispose(); super.dispose(); }
  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final response = await http.get(Uri.https('equran.id', '/api/v2/surat')).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) throw Exception('Server Al-Qur’an tidak merespons.');
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final list = json['data'] as List<dynamic>;
      if (!mounted) return;
      setState(() { surahs = list; loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { error = 'Daftar surah gagal dimuat. Periksa koneksi internet lalu coba lagi.'; loading = false; });
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final q = search.text.trim().toLowerCase();
    final shown = surahs.where((s) =>
      (s['namaLatin'] ?? '').toString().toLowerCase().contains(q) ||
      (s['arti'] ?? '').toString().toLowerCase().contains(q) ||
      (s['nomor'] ?? '').toString().contains(q)).toList();
    final ink = dark ? Colors.white : const Color(0xFF171717);
    final muted = dark ? Colors.white70 : const Color(0xFF686868);
    final line = dark ? const Color(0xFF3A3A3A) : const Color(0xFFE5E5E5);
    return BackPage(title: 'Islami', child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 10), child: TextField(
        controller: search, onChanged: (_) => setState(() {}),
        style: GoogleFonts.fredoka(color: ink, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(CupertinoIcons.search, color: muted),
          hintText: 'Cari surah...', hintStyle: GoogleFonts.fredoka(color: muted, fontSize: 15),
          filled: true, fillColor: dark ? const Color(0xFF202020) : const Color(0xFFF7F7F7),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: line)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: ink, width: 1.2)),
        ),
      )),
      Expanded(child: loading
        ? Center(child: CircularProgressIndicator(color: ink))
        : error != null
          ? Center(child: Padding(padding: const EdgeInsets.all(22), child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(error!, textAlign: TextAlign.center, style: TextStyle(color: ink)),
              const SizedBox(height: 10),
              OutlinedButton.icon(onPressed: _load, icon: Icon(CupertinoIcons.refresh, color: ink),
                label: Text('Coba lagi', style: TextStyle(color: ink))),
            ])))
          : RefreshIndicator(color: ink, onRefresh: _load, child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
              itemCount: shown.length,
              itemBuilder: (context, i) {
                final surah = shown[i] as Map<String, dynamic>;
                return Card(
                  elevation: 0, color: dark ? const Color(0xFF1D1D1D) : Colors.white,
                  margin: const EdgeInsets.only(bottom: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13), side: BorderSide(color: line)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    leading: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF353535) : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(surah['nomor'].toString(),
                        style: GoogleFonts.fredoka(color: ink, fontWeight: FontWeight.w700, fontSize: 16))),
                    ),
                    title: Text(surah['namaLatin']?.toString() ?? '',
                      style: GoogleFonts.fredoka(fontWeight: FontWeight.w700, fontSize: 16, color: ink)),
                    subtitle: Text((surah['tempatTurun'] ?? '').toString() + ' • ' + (surah['arti'] ?? '').toString(),
                      style: GoogleFonts.fredoka(color: muted, fontSize: 13)),
                    trailing: Icon(CupertinoIcons.chevron_right, color: ink),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuranDetailPage(
                      surahNumber: int.tryParse(surah['nomor'].toString()) ?? 1,
                      title: surah['namaLatin']?.toString() ?? 'Surah'))),
                  ),
                );
              },
            )),
      ),
    ]));
  }
}

class QuranDetailPage extends StatefulWidget {
  final int surahNumber;
  final String title;
  const QuranDetailPage({super.key, required this.surahNumber, required this.title});
  @override
  State<QuranDetailPage> createState() => _QuranDetailPageState();
}
class _QuranDetailPageState extends State<QuranDetailPage> {
  Map<String, dynamic>? surah;
  bool loading = true;
  bool playing = false;
  String? error;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<void>? _completionSubscription;
  @override
  void initState() {
    super.initState();
    playing = quranAudioPlayer.state == PlayerState.playing;
    _playerStateSubscription = quranAudioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => playing = state == PlayerState.playing);
    });
    _completionSubscription = quranAudioPlayer.onPlayerComplete.listen((_) {
      currentQuranAudioUrl = null;
      if (mounted) setState(() => playing = false);
    });
    _load();
  }
  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _completionSubscription?.cancel();
    // Jangan dispose player di sini: audio harus tetap hidup saat halaman ditutup.
    super.dispose();
  }
  Future<void> _load() async {
    try {
      final response = await http.get(Uri.https('equran.id', '/api/v2/surat/' + widget.surahNumber.toString())).timeout(const Duration(seconds: 25));
      if (response.statusCode != 200) throw Exception('Gagal mengambil surah.');
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() { surah = json['data'] as Map<String, dynamic>; loading = false; });
    } catch (_) {
      if (mounted) setState(() { error = 'Isi surah gagal dimuat. Periksa koneksi internet.'; loading = false; });
    }
  }
  Future<void> _play(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      // Ketuk audio yang sama saat sedang berjalan = stop, bukan mengulang dari awal.
      if (currentQuranAudioUrl == url && quranAudioPlayer.state == PlayerState.playing) {
        await quranAudioPlayer.stop();
        currentQuranAudioUrl = null;
        if (mounted) setState(() => playing = false);
        return;
      }
      // Audio lain akan menggantikan audio yang sedang berjalan.
      await quranAudioPlayer.stop();
      currentQuranAudioUrl = url;
      await quranAudioPlayer.play(UrlSource(url));
      if (mounted) setState(() => playing = true);
    } catch (_) {
      currentQuranAudioUrl = null;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audio gagal diputar. Periksa koneksi internet.')));
    }
  }
  @override
  Widget build(BuildContext context) {
    final verses = (surah?['ayat'] as List<dynamic>?) ?? [];
    final fullAudio = (surah?['audioFull'] as Map?)?['05']?.toString();
    return BackPage(
      title: widget.title,
      child: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
          ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(error!), FilledButton(onPressed: _load, child: const Text('Coba lagi'))])))
          : ListView(padding: const EdgeInsets.all(15), children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: pale, borderRadius: BorderRadius.circular(9), border: Border.all(color: Theme.of(context).dividerColor)),
                child: Column(children: [
                  Text(surah?['nama']?.toString() ?? '', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5),
                  Text((surah?['namaLatin'] ?? widget.title).toString() + ' • ' + (surah?['jumlahAyat'] ?? verses.length).toString() + ' ayat'),
                  const SizedBox(height: 12),
                  FilledButton.icon(onPressed: fullAudio == null ? null : () => _play(fullAudio), icon: Icon(playing ? Icons.graphic_eq : CupertinoIcons.play_arrow_solid), label: const Text('Putar audio surah lengkap')),
                ]),
              ),
              const SizedBox(height: 12),
              ...verses.map((v) {
                final verse = v as Map<String, dynamic>;
                final audio = (verse['audio'] as Map?)?['05']?.toString();
                return Card(
                  elevation: 0, margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Theme.of(context).dividerColor)),
                  child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [
                      CircleAvatar(radius: 16, backgroundColor: pale, child: Text(verse['nomorAyat'].toString(), style: const TextStyle(color: forest, fontWeight: FontWeight.w800))),
                      const Spacer(),
                      IconButton(tooltip: 'Putar ayat', onPressed: audio == null ? null : () => _play(audio), icon: const Icon(Icons.play_circle_outline, color: forest)),
                    ]),
                    const SizedBox(height: 12),
                    Text(verse['teksArab']?.toString() ?? '', textAlign: TextAlign.right, style: const TextStyle(fontSize: 26, height: 1.9, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text(verse['teksLatin']?.toString() ?? '', style: const TextStyle(color: forest, fontStyle: FontStyle.italic, height: 1.5)),
                    const SizedBox(height: 7),
                    Text(verse['teksIndonesia']?.toString() ?? '', style: const TextStyle(height: 1.5)),
                  ])),
                );
              }),
            ]),
    );
  }
}

class MarqueeHighlight extends StatefulWidget {
  final String text;
  const MarqueeHighlight({super.key, required this.text});
  @override
  State<MarqueeHighlight> createState() => _MarqueeHighlightState();
}
class _MarqueeHighlightState extends State<MarqueeHighlight> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 20, height: 1.1, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF222222) : const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha:.28)),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final painter = TextPainter(text: TextSpan(text: widget.text, style: textStyle), textDirection: Directionality.of(context), maxLines: 1)..layout();
        final textWidth = painter.width;
        if (textWidth <= constraints.maxWidth) {
          return Text(widget.text, maxLines: 1, softWrap: false, style: textStyle);
        }
        const gap = 36.0;
        final cycleWidth = textWidth + gap;
        return ClipRect(child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Transform.translate(
            offset: Offset(-cycleWidth * _controller.value, 0),
            child: SizedBox(
              width: cycleWidth * 2,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(widget.text, maxLines: 1, softWrap: false, style: textStyle),
                const SizedBox(width: gap),
                Text(widget.text, maxLines: 1, softWrap: false, style: textStyle),
              ]),
            ),
          ),
        ));
      }),
    );
  }
}
class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final Color? iconColor, iconBackground;
  const FeatureTile({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap, this.iconColor, this.iconBackground});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Card(
      elevation: 0, color: theme.cardColor, margin: const EdgeInsets.only(bottom: 7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: theme.dividerColor, width: .7)),
      child: InkWell(borderRadius: BorderRadius.circular(8), onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: dark ? const Color(0xFF222222) : (iconBackground ?? pale), borderRadius: BorderRadius.circular(7)), child: Icon(icon, color: dark ? const Color(0xFFCCCCCC) : (iconColor ?? forest), size: 20)),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 2), Text(subtitle, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
        ])),
        Icon(CupertinoIcons.chevron_right, color: dark ? const Color(0xFFCCCCCC) : forest, size: 18),
      ]))),
    );
  }
}

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;
  final Widget? titleWidget;
  final bool searchActive;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.onSearch,
    this.titleWidget,
    this.searchActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    const navy = Color(0xFF101D48);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 18, 10),
      child: Row(children: [
        IconButton(
          onPressed: onBack ?? () => Navigator.maybePop(context),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 38, height: 48),
          icon: Icon(CupertinoIcons.back, size: 30,
            color: dark ? Colors.white : const Color(0xFF17659B)),
          tooltip: 'Kembali',
        ),
        const SizedBox(width: 12),
        Expanded(child: titleWidget ?? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.fredoka(fontSize: 27, height: 1.05,
                fontWeight: FontWeight.w700, color: dark ? Colors.white : navy)),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w500,
                  color: dark ? Colors.white70 : const Color(0xFF52627A))),
            ],
          ],
        )),
        if (onSearch != null) ...[
          const SizedBox(width: 8),
          _circleButton(context,
            searchActive ? CupertinoIcons.xmark : CupertinoIcons.search, onSearch!),
        ],
      ]),
    );
  }

  Widget _circleButton(BuildContext context, IconData icon, VoidCallback onTap) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark ? const Color(0xFF20344B) : const Color(0xFFEAF5FC),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 56, height: 56,
          child: Icon(icon, size: 27,
            color: dark ? Colors.white : const Color(0xFF17659B))),
      ),
    );
  }
}

class BackPage extends StatelessWidget {
  final String title;
  final Widget child;
  const BackPage({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: SafeArea(child: Column(children: [
      PageHeader(title: title),
      Expanded(child: child),
    ])),
  );
}


class DonorPage extends StatefulWidget {
  const DonorPage({super.key});
  @override
  State<DonorPage> createState() => _DonorPageState();
}

class _DonorPageState extends State<DonorPage> with SingleTickerProviderStateMixin {
  List<Map<String, String>> _remoteForms = [];
  bool _refreshing = false;
  String? _refreshError;
  late final AnimationController _waveController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  )..repeat();

  static const _red = Color(0xFFEF242B);
  static const _blue = Color(0xFF087FF5);

  @override
  void initState() {
    super.initState();
    _refreshRemote();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _refreshRemote() async {
    if (_refreshing) return;
    setState(() { _refreshing = true; _refreshError = null; });
    try {
      await Store.loadCloudData();
      final rows = await _loadRemoteBloodPosts();
      if (mounted) setState(() => _remoteForms = rows);
    } catch (error) {
      if (mounted) setState(() => _refreshError = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _openForm(bool request) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => DonorForm(request: request)));
    if (mounted) await _refreshRemote();
  }

  Future<void> _openKomdasGroup() async {
    final raw = Store.donorGroupWhatsapp.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link grup KOMDAS KALBAR belum diatur admin. Silakan cek kembali nanti.')),
      );
      return;
    }
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.scheme != 'https' || uri.host != 'chat.whatsapp.com') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link grup WhatsApp belum valid.')),
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
      );
    }
  }

  Future<void> _openMap(String place, String district) async {
    final query = [place, district, 'Kalimantan Barat'].where((v) => v.trim().isNotEmpty).join(', ');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=' + Uri.encodeComponent(query));
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka aplikasi peta.')));
    }
  }

  Future<void> _openDonorChat(Map<String, String> item) async {
    final myUid = _auth.currentUser?.uid ?? '';
    if (myUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masuk untuk menghubungi pendonor.')),
      );
      return;
    }

    var peerUid = (item['uid'] ?? item['ownerUid'] ?? '').trim();
    final ownerEmail = (item['ownerEmail'] ?? '').trim().toLowerCase();

    // Recover the UID for legacy blood posts created before ownerUid was stored.
    if (peerUid.isEmpty && ownerEmail.isNotEmpty) {
      try {
        final profiles = await _db.collection('profiles')
            .where('email', isEqualTo: ownerEmail)
            .limit(1).get().timeout(const Duration(seconds: 8));
        if (profiles.docs.isNotEmpty) peerUid = profiles.docs.first.id;
      } catch (_) {}
    }

    if (peerUid.isEmpty) {
      final rawPhone = (item['phone'] ?? '').replaceAll(RegExp(r'[^0-9+]'), '');
      final phone = rawPhone.startsWith('+')
          ? rawPhone.substring(1)
          : rawPhone.startsWith('0') ? '62${rawPhone.substring(1)}' : rawPhone;
      if (phone.isNotEmpty) {
        final uri = Uri.parse('https://wa.me/$phone');
        final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!opened && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('WhatsApp tidak dapat dibuka.')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kontak pendonor belum tersedia.')),
        );
      }
      return;
    }

    if (peerUid == myUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ini postingan milik akunmu sendiri.')),
      );
      return;
    }

    // Make sure the chat rules can verify the donor owner and the public post.
    try {
      await _db.collection('blood_posts').doc(item['id']).update({'ownerUid': peerUid});
    } catch (_) {
      // Existing records are still opened; Firestore rules remain authoritative.
    }

    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChatThreadPage(
        peerUid: peerUid,
        donorContact: true,
        donorPostId: item['id'] ?? '',
        initialProfile: {
          'uid': peerUid,
          'name': item['name'] ?? 'Pengguna Kalbar Kite',
          if ((item['phone'] ?? '').isNotEmpty) 'phone': item['phone'],
        },
      ),
    ));
  }

  Widget _waveSurface({
    required Widget child,
    required Color tint,
    required double radius,
    Color? borderColor,
    EdgeInsetsGeometry? padding,
    List<Color>? gradient,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? theme.colorScheme.surface : null,
        gradient: gradient == null ? null : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? tint.withValues(alpha:.18), width: 1.15),
        boxShadow: [
          BoxShadow(color: tint.withValues(alpha:.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _actionTile({
    required bool donor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final color = donor ? _red : _blue;
    final pale = dark
        ? (donor ? const Color(0xFF512B36) : const Color(0xFF1D3D5A))
        : (donor ? const Color(0xFFFFE6E9) : const Color(0xFFE2F1FF));
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(minHeight: 142),
            padding: const EdgeInsets.fromLTRB(14, 15, 13, 13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: dark
                    ? (donor
                        ? const [Color(0xFF39232B), Color(0xFF291D24)]
                        : const [Color(0xFF20364B), Color(0xFF192A3A)])
                    : (donor
                        ? const [Color(0xFFFFF9FA), Color(0xFFFFE9EC)]
                        : const [Color(0xFFF8FCFF), Color(0xFFE7F3FF)]),
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha:.20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: pale,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: color.withValues(alpha:.10), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Icon(donor ? Icons.volunteer_activism_rounded : Icons.bloodtype_rounded,
                    color: color, size: 26),
                ),
                const SizedBox(height: 9),
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(fontSize: 17, height: 1.08,
                    fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 5),
                Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(fontSize: 10.5, height: 1.25,
                    fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recordCard(Map<String, String> item, {required bool request}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final district = item['district'] ?? item['place'] ?? '';
    final hospital = item['hospital'] ?? '';
    final rawDonorLocation = item['donorLocation'] ?? '';
    final donorLocation = rawDonorLocation.isNotEmpty &&
            _donorLocationMatchesHospital(rawDonorLocation, district, hospital)
        ? rawDonorLocation
        : '';
    final blood = item['blood'] ?? '-';
    final name = item['name'] ?? 'Pengguna Kalbar Kite';
    final place = request ? hospital : (donorLocation.isNotEmpty ? donorLocation : (hospital.isNotEmpty ? hospital : district));
    final tint = request ? _blue : _red;
    final initial = name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
    final avatarUrl = _normalizeImageUrl((item['avatarUrl'] ?? '').toString());

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      child: _waveSurface(
        tint: tint,
        radius: 25,
        borderColor: (request ? const Color(0xFFBBD8FF) : const Color(0xFFE8D8E8)),
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            SizedBox(
              width: 49, height: 49,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: avatarUrl.startsWith('https://')
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: const Color(0xFFDFF0FF),
                          alignment: Alignment.center,
                          child: Text(initial, style: GoogleFonts.fredoka(fontSize: 23, fontWeight: FontWeight.w700, color: _blue)),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFDFF0FF),
                          alignment: Alignment.center,
                          child: Text(initial, style: GoogleFonts.fredoka(fontSize: 23, fontWeight: FontWeight.w700, color: _blue)),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFDFF0FF),
                        alignment: Alignment.center,
                        child: Text(initial, style: GoogleFonts.fredoka(fontSize: 23, fontWeight: FontWeight.w700, color: _blue)),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: _VerifiedDisplayName(
              uid: item['uid'] ?? item['ownerUid'] ?? '',
              name: name,
              style: GoogleFonts.fredoka(fontSize: 19, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF512B36) : const Color(0xFFFFE5E8),
                borderRadius: BorderRadius.circular(16)),
              child: Text(blood, style: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w700, color: _red)),
            ),
          ]),
          const SizedBox(height: 9),
          if (district.isNotEmpty) Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 5),
            child: Row(children: [
              const Icon(CupertinoIcons.location_solid, size: 19, color: Color(0xFF8792A5)),
              const SizedBox(width: 12),
              Expanded(child: Text(district, style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant))),
            ]),
          ),
          if (hospital.isNotEmpty) Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 5),
            child: Row(children: [
              const Icon(Icons.local_hospital_rounded, size: 19, color: Color(0xFF8792A5)),
              const SizedBox(width: 12),
              Expanded(child: Text(hospital, style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant))),
            ]),
          ),
          if (donorLocation.isNotEmpty) Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 5),
            child: Row(children: [
              const Icon(Icons.bloodtype_outlined, size: 19, color: Color(0xFF8792A5)),
              const SizedBox(width: 12),
              Expanded(child: Text(donorLocation, style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant))),
            ]),
          ),
          if ((item['note'] ?? '').trim().isNotEmpty) Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 7, left: 8),
            child: Text(item['note']!, style: GoogleFonts.manrope(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(height: 7),
          Divider(height: 1, thickness: 1, color: const Color(0xFFDCE3ED).withValues(alpha:.85)),
          const SizedBox(height: 9),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: place.isEmpty ? null : () => _openMap(place, district),
              icon: const Icon(CupertinoIcons.map, size: 21),
              label: Text('Peta', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                backgroundColor: dark ? const Color(0xFF1D3449) : const Color(0xFFF0F8FF),
                side: const BorderSide(color: Color(0xFF64B8FF), width: 1.1),
                minimumSize: const Size(0, 43),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
            )),
            const SizedBox(width: 7),
            Expanded(child: OutlinedButton.icon(
              onPressed: request ? null : () => _openDonorChat(item),
              icon: const Icon(CupertinoIcons.chat_bubble_text, size: 21),
              label: Text('Hubungi', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _red,
                backgroundColor: dark ? const Color(0xFF42252D) : const Color(0xFFFFF1F2),
                side: const BorderSide(color: Color(0xFFFF7B85), width: 1.1),
                minimumSize: const Size(0, 43),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _recordSection(String title, List<Map<String, String>> records, {required bool request}) {
    final color = request ? _blue : _red;
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(title, style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
      const SizedBox(height: 13),
      if (records.isEmpty)
        SizedBox(
          width: double.infinity,
          child: _waveSurface(
          tint: request ? _red : _blue,
          radius: 22,
          borderColor: request ? const Color(0xFFFFD1D8) : const Color(0xFFC8E1FF),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 23),
          gradient: Theme.of(context).brightness == Brightness.dark
              ? const [Color(0xFF30232A), Color(0xFF241D24)]
              : const [Color(0xFFFFFCFD), Color(0xFFFFF5F6)],
          child: Column(children: [
            SizedBox(
              height: 65,
              child: Icon(request ? Icons.water_drop_rounded : Icons.volunteer_activism_rounded, size: 54, color: color.withValues(alpha:.85)),
            ),
            const SizedBox(height: 7),
            Text(request ? 'Belum ada permintaan darah' : 'Belum ada pendonor',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 5),
            Text(request ? 'Saat ini tidak ada permintaan yang tersedia.' : 'Pendonor yang mendaftar akan muncul di sini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
          ),
        )
      else
        ...records.map((item) => _recordCard(item, request: request)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final donors = _remoteForms.where((item) => item['type'] == 'Calon pendonor').toList();
    final requests = _remoteForms.where((item) => item['type'] == 'Permintaan darah').toList();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshRemote,
          color: _red,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              const PageHeader(
                title: 'Donor Darah',
                subtitle: 'Bersama selamatkan lebih banyak nyawa',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? const [Color(0xFF28202A), Color(0xFF1C2733)]
                        : const [Color(0xFFFFF4F5), Color(0xFFF0F7FF)],
                  ),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha:.7)),
                ),
                child: Row(children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(color: _red.withValues(alpha:.12), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.favorite_rounded, color: _red, size: 23),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Setetes darah, harapan baru', style: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 3),
                    Text('Temukan pendonor atau bantu seseorang mendapatkan darah yang dibutuhkan.', style: GoogleFonts.manrope(fontSize: 11.5, height: 1.4, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ])),
                ]),
              ),
              const SizedBox(height: 12),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: _openKomdasGroup,
                  borderRadius: BorderRadius.circular(18),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: Theme.of(context).brightness == Brightness.dark ? .15 : .09),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF25D366).withValues(alpha:.35)),
                    ),
                    child: Row(children: [
                      const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 31),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('JOIN GRUP KOMDAS KALBAR', style: GoogleFonts.fredoka(fontSize: 15.5, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 2),
                        Text('Gabung komunitas donor dan informasi darah Kalbar', style: GoogleFonts.manrope(fontSize: 10.5, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ])),
                      const Icon(Icons.open_in_new_rounded, color: Color(0xFF25D366), size: 19),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _actionTile(
                  donor: true,
                  title: 'Menjadi Pendonor',
                  subtitle: 'Daftarkan golongan darah dan kontak',
                  onTap: () => _openForm(false),
                ),
                const SizedBox(width: 9),
                _actionTile(
                  donor: false,
                  title: 'Membutuhkan Darah',
                  subtitle: 'Buat permintaan bantuan darah',
                  onTap: () => _openForm(true),
                ),
              ])),
              if (_refreshError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(13)),
                  child: Text('Gagal memuat data donor: $_refreshError',
                    style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                ),
                Align(alignment: Alignment.centerRight,
                  child: TextButton.icon(onPressed: _refreshRemote, icon: const Icon(Icons.refresh), label: const Text('Coba lagi'))),
              ],
              if (_refreshing && _remoteForms.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 26),
                  child: Center(child: CircularProgressIndicator()),
                ),
              const SizedBox(height: 24),
              _recordSection('Daftar Pendonor', donors, request: false),
              const SizedBox(height: 25),
              _recordSection('Permintaan Darah', requests, request: true),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> _showKalbarPicker(BuildContext context, {
  required String title,
  required String hint,
  required List<String> options,
  String? selected,
}) {
  final search = TextEditingController();
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1C1C1C)
        : Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) {
        final query = search.text.trim().toLowerCase();
        final filtered = options.where((item) => item.toLowerCase().contains(query)).toList();
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * .78,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(9)))),
                const SizedBox(height: 15),
                Text(title, style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(options.length.toString() + ' pilihan • pilih dari daftar',
                  style: GoogleFonts.fredoka(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                TextField(
                  controller: search,
                  onChanged: (_) => setSheetState(() {}),
                  decoration: InputDecoration(
                    hintText: hint,
                    prefixIcon: const Icon(CupertinoIcons.search),
                    suffixIcon: search.text.isEmpty ? null : IconButton(
                      onPressed: () { search.clear(); setSheetState(() {}); },
                      icon: const Icon(CupertinoIcons.xmark),
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF292929)
                        : const Color(0xFFF7F8FA),
                    hintStyle: GoogleFonts.fredoka(fontSize: 14, color: Theme.of(context).hintColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                    ? const Center(child: Text('Tidak ada hasil yang cocok.'))
                    : ListView.separated(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerColor),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final active = item == selected;
                          return ListTile(
                            dense: false,
                            minVerticalPadding: 13,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            leading: Icon(active ? Icons.radio_button_checked : CupertinoIcons.location, color: active ? forest : Theme.of(context).colorScheme.onSurfaceVariant),
                            title: Text(item, style: GoogleFonts.fredoka(
                              fontWeight: FontWeight.w700, fontSize: 15,
                              color: Theme.of(context).colorScheme.onSurface)),
                            trailing: active ? const Icon(Icons.check_circle, color: forest, size: 19) : null,
                            onTap: () => Navigator.pop(context, item),
                          );
                        },
                      ),
                ),
              ]),
            ),
          ),
        );
      },
    ),
  ).whenComplete(search.dispose);
}

class DonorForm extends StatefulWidget {
  final bool request;
  const DonorForm({super.key, required this.request});
  @override
  State<DonorForm> createState() => _DonorFormState();
}

class _DonorFormState extends State<DonorForm> {
  String donorLocation = '';
  final name = TextEditingController();
  final phone = TextEditingController();
  final note = TextEditingController();
  String blood = 'O+';
  String district = '';
  String hospital = '';
  bool showInDonorList = false;
  final types = const ['A+', 'A−', 'B+', 'B−', 'AB+', 'AB−', 'O+', 'O−'];

  @override
  void dispose() { name.dispose(); phone.dispose(); note.dispose(); super.dispose(); }

  Future<void> _pickDistrict() async {
    final options = Store.districtOptions;
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daftar wilayah belum tersedia. Kelola Sejarah Kalbar melalui website admin.')));
      return;
    }
    final value = await _showKalbarPicker(context, title: 'Pilih kabupaten / kota', hint: 'Cari kabupaten atau kota...', options: options, selected: district);
    if (value != null && mounted) setState(() { district = value; hospital = ''; donorLocation = ''; });
  }

  Future<void> _pickHospital() async {
    if (district.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kabupaten/kota terlebih dahulu.')));
      return;
    }
    final options = <String>{...kalbarHospitals, ...Store.hospitalOptions}
        .where((name) => _hospitalBelongsToDistrict(name, district))
        .toList()..sort();
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Belum ada data rumah sakit untuk $district.')));
      return;
    }
    final value = await _showKalbarPicker(context, title: 'Rumah sakit di $district', hint: 'Cari rumah sakit di wilayah ini...', options: options, selected: hospital);
    if (value != null && mounted) setState(() { hospital = value; donorLocation = ''; });
  }

  List<String> _donorLocationOptions() {
    if (district.trim().isEmpty || hospital.trim().isEmpty) return const [];
    String key(String value) => value.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .replaceFirst(RegExp(r'^(rsud|rs umum daerah|rs|rumah sakit)\s+'), '');
    final selectedHospital = key(hospital);
    final selectedDistrict = district.trim().toLowerCase();

    // Di Kota Pontianak, UTD RSUD Soedarso dan UDD PMI sama-sama
    // melayani wilayah kota, jadi keduanya tampil untuk rumah sakit tujuan
    // di Pontianak. Untuk Sambas, batasi berdasarkan kecamatan/area RS.
    if (selectedDistrict == 'kota pontianak') {
      return kalbarDonorLocations
          .where((entry) => (entry['district'] ?? '').trim().toLowerCase() == selectedDistrict)
          .map((entry) => entry['name']!)
          .toSet()
          .toList()..sort();
    }

    if (selectedDistrict == 'kabupaten sambas') {
      final area = selectedHospital.contains('pemangkat')
          ? 'pemangkat'
          : selectedHospital.contains('teluk keramat')
              ? 'teluk keramat'
              : 'sambas';
      return kalbarDonorLocations
          .where((entry) =>
              (entry['district'] ?? '').trim().toLowerCase() == selectedDistrict &&
              (entry['area'] ?? '').trim().toLowerCase() == area)
          .map((entry) => entry['name']!)
          .toSet()
          .toList()..sort();
    }

    return kalbarDonorLocations.where((entry) {
      if ((entry['district'] ?? '').trim().toLowerCase() != selectedDistrict) return false;
      final relatedHospital = key(entry['hospital'] ?? '');
      return relatedHospital.isNotEmpty &&
          (relatedHospital == selectedHospital ||
              relatedHospital.contains(selectedHospital) ||
              selectedHospital.contains(relatedHospital));
    }).map((entry) => entry['name']!).toSet().toList()..sort();
  }

  Future<void> _pickDonorLocation() async {
    final options = _donorLocationOptions();
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(hospital.isEmpty
            ? 'Pilih rumah sakit tujuan terlebih dahulu.'
            : 'Belum ada unit UTD/PMI terverifikasi untuk $hospital. Admin perlu menambahkan unit setempat.'),
      ));
      return;
    }
    final value = await _showKalbarPicker(
      context,
      title: 'Pilih tempat donor darah',
      hint: 'Cari nama UTD / PMI / unit donor...',
      options: options,
      selected: donorLocation,
    );
    if (value != null && mounted) setState(() => donorLocation = value);
  }

  Widget _selectionField({required String label, required String value, required IconData icon, required VoidCallback onTap}) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant),
        floatingLabelStyle: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
        prefixIcon: Icon(icon),
        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(value.isEmpty ? 'Ketuk untuk memilih' : value, maxLines: 2, overflow: TextOverflow.ellipsis,
        style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w600, color: value.isEmpty ? Theme.of(context).hintColor : Theme.of(context).colorScheme.onSurface)),
    ),
  );

  @override
  Widget build(BuildContext context) => BackPage(
    title: widget.request ? 'Permintaan darah' : 'Pendaftaran pendonor',
    child: ListView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      children: [
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF222222) : const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(10)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(widget.request ? Icons.bloodtype_outlined : Icons.volunteer_activism_outlined, color: forest, size: 27),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.request ? 'Formulir kebutuhan darah' : 'Formulir calon pendonor', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 4),
              Text(widget.request ? 'Pilih kabupaten dan rumah sakit tujuan dari daftar.' : 'Pilih kabupaten/kota domisili dari daftar yang tersedia.', style: TextStyle(fontSize: 12, height: 1.4, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ])),
          ]),
        ),
        const SizedBox(height: 20),
        Text('Informasi pribadi', style: GoogleFonts.fredoka(fontSize: 19, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 10),
        _field(name, 'Nama lengkap', CupertinoIcons.person_fill),
        const SizedBox(height: 11),
        _field(phone, 'Nomor telepon / WhatsApp', CupertinoIcons.phone, keyboard: TextInputType.phone),
        const SizedBox(height: 20),
        Text('Informasi darah dan lokasi', style: GoogleFonts.fredoka(fontSize: 19, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: blood,
          decoration: InputDecoration(
            labelText: 'Golongan darah',
            labelStyle: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant),
            floatingLabelStyle: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
            prefixIcon: const Icon(Icons.water_drop_outlined),
          ),
          items: types.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => blood = v ?? blood),
        ),
        const SizedBox(height: 11),
        _selectionField(label: 'Kabupaten / kota', value: district, icon: Icons.location_city_outlined, onTap: _pickDistrict),
        const SizedBox(height: 11),
        _selectionField(label: widget.request ? 'Rumah sakit tujuan' : 'Rumah sakit terdekat (opsional)', value: hospital, icon: Icons.local_hospital_outlined, onTap: _pickHospital),
        if (widget.request) ...[
          const SizedBox(height: 11),
          _selectionField(
            label: 'Tempat donor darah (UTD / PMI)',
            value: donorLocation,
            icon: Icons.bloodtype_outlined,
            onTap: _pickDonorLocation,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'Pilih unit UTD/PMI yang melayani rumah sakit tujuan. Pilihan dibatasi sesuai rumah sakit dan wilayahnya.',
              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF222222) : const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(9)),
          child: CheckboxListTile(
            value: showInDonorList,
            onChanged: (value) => setState(() => showInDonorList = value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(widget.request ? 'Tampilkan permintaan saya di daftar kebutuhan darah' : 'Tampilkan saya di daftar pendonor', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            subtitle: const Text('Jika dicentang, data ini dapat dilihat pengguna aplikasi lain. Jika tidak dicentang, data tidak ditampilkan secara publik.', style: TextStyle(fontSize: 11, height: 1.35)),
          ),
        ),
        const SizedBox(height: 11),
        TextField(controller: note, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'Catatan tambahan (opsional)', alignLabelWithHint: true, prefixIcon: Padding(padding: EdgeInsets.only(bottom: 48), child: Icon(CupertinoIcons.doc_text)))),
        const SizedBox(height: 18),
        FilledButton.icon(
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: () async {
            if ([name.text, phone.text, district].any((v) => v.trim().isEmpty) ||
                (widget.request && (hospital.isEmpty || donorLocation.isEmpty))) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.request
                  ? 'Lengkapi nama, nomor kontak, kabupaten/kota, rumah sakit, dan unit donor darah (UTD/PMI).'
                  : 'Lengkapi nama, nomor kontak, dan kabupaten/kota.')));
              return;
            }
            final form = <String, String>{
              'type': widget.request ? 'Permintaan darah' : 'Calon pendonor',
              'name': name.text.trim(), 'phone': phone.text.trim(),
              'blood': blood.replaceAll('−', '-'), 'district': district, 'hospital': hospital,
              'donorLocation': widget.request ? donorLocation : '',
              'place': widget.request ? hospital : district, 'note': note.text.trim(),
              'status': 'Menunggu', 'showInDonorList': showInDonorList.toString(), 'syncStatus': 'pending',
            };
            var remoteMessage = '';
            try {
              await _submitBloodPostRemote(form);
              form['syncStatus'] = 'synced';
              Store.forms.add(form); await Store.save();
              remoteMessage = 'Kiriman berhasil dikirim.';
            } catch (error) {
              remoteMessage = 'Gagal menyimpan ke database: ${error.toString().replaceFirst('Exception: ', '')}';
            }
            if (!context.mounted) return;
            showDialog<void>(context: context, builder: (d) => AlertDialog(
              icon: const Icon(CupertinoIcons.check_mark_circled, color: forest, size: 34),
              title: const Text('Formulir tersimpan'),
              content: Text(remoteMessage),
              actions: [FilledButton(onPressed: () { Navigator.pop(d); Navigator.pop(context); }, child: const Text('Selesai'))],
            ));
          },
          icon: const Icon(Icons.send_outlined),
          label: const Text('Kirim formulir'),
        ),
        const SizedBox(height: 10),
        const Text('Daftar pilihan rumah sakit disusun dari data terbuka. Periksa kembali nama dan lokasi rumah sakit sebelum mengirim permintaan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, height: 1.4, color: Colors.black54)),
      ],
    ),
  );

  Widget _field(TextEditingController controller, String label, IconData icon, {TextInputType keyboard = TextInputType.text}) => TextField(
    controller: controller, keyboardType: keyboard, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
  );
}


class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});
  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  List<String> get districts => kalbarDistricts;
  List<String> get tribes => kalbarTribes;
  StreamSubscription<QuerySnapshot<Map<String,dynamic>>>? _dictionarySubscription;
  String mode = 'Semua';
  String? selectedTribe;
  String? selectedDistrict;
  String query = '';
  final searchController = TextEditingController();
  final Set<String> favorites = <String>{};

  @override
  void initState() {
    super.initState();
    _dictionarySubscription = _db.collection('dictionary').snapshots().listen((snapshot) {
      if (!mounted) return;
      setState(() {
        Store.words
          ..clear()
          ..addAll(snapshot.docs.map((doc) => <String,String>{
            'id':doc.id,
            'word':(doc.data()['word'] ?? '').toString(),
            'language':(doc.data()['language'] ?? '').toString(),
            'meaning':(doc.data()['meaning'] ?? '').toString(),
            'district':(doc.data()['district'] ?? '').toString(),
          }));
      });
    }, onError: (_) {
      if (mounted) setState(() => Store.words.clear());
    });
  }

  @override
  void dispose() {
    _dictionarySubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }

  String _key(Map<String, String> item) =>
    '${item['word'] ?? ''}| ${item['language'] ?? ''}| ${item['meaning'] ?? ''}';

  Future<void> _chooseDistrict() async {
    final value = await _showKalbarPicker(context,
      title: 'Pilih kabupaten / kota',
      hint: 'Cari kabupaten atau kota...',
      options: districts,
      selected: selectedDistrict);
    if (value != null && mounted) {
      setState(() { selectedDistrict = value; mode = 'Daerah'; });
    }
  }

  Future<void> _chooseTribe() async {
    final value = await _showKalbarPicker(context,
      title: 'Pilih suku',
      hint: 'Cari suku...',
      options: tribes,
      selected: selectedTribe);
    if (value != null && mounted) {
      setState(() { selectedTribe = value; mode = 'Suku'; });
    }
  }

  List<Map<String, String>> _visibleEntries() {
    Iterable<Map<String, String>> items = Store.words;
    if (mode == 'Suku' && selectedTribe != null) {
      items = items.where((w) => (w['language'] ?? '').toLowerCase().startsWith(selectedTribe!.toLowerCase()));
    } else if (mode == 'Daerah') {
      final region = selectedDistrict;
      items = region == null ? const <Map<String, String>>[] :
        items.where((w) => (w['district'] ?? w['region'] ?? '').toLowerCase() == region.toLowerCase());
    } else if (mode == 'Favorit') {
      items = items.where((w) => favorites.contains(_key(w)));
    }
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((w) =>
        (w['word'] ?? '').toLowerCase().contains(q) ||
        (w['meaning'] ?? '').toLowerCase().contains(q) ||
        (w['language'] ?? '').toLowerCase().contains(q));
    }
    return items.toList();
  }

  Widget _modeChip(String label, IconData icon) {
    final active = mode == label;
    return Expanded(
      child: Material(
        color: active ? Colors.black : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            if (label == 'Daerah') {
              setState(() => mode = 'Daerah');
              await _chooseDistrict();
            } else if (label == 'Suku') {
              setState(() => mode = 'Suku');
              await _chooseTribe();
            } else {
              setState(() => mode = label);
            }
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: active ? Theme.of(context).colorScheme.onSurface : Theme.of(context).dividerColor, width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: active ? Colors.white : Theme.of(context).colorScheme.onSurface),
                const SizedBox(width: 4),
                Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.w800,
                    color: active ? Colors.white : Theme.of(context).colorScheme.onSurface))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = _visibleEntries();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: SafeArea(child: PageHeader(title: 'Kamus Daerah')),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(18, 15, 18, 28), children: [
        Row(children: [
          _modeChip('Semua', CupertinoIcons.square_grid_2x2),
          const SizedBox(width: 7),
          _modeChip('Daerah', CupertinoIcons.location),
          const SizedBox(width: 7),
          _modeChip('Suku', CupertinoIcons.person_2),
          const SizedBox(width: 7),
          _modeChip('Favorit', CupertinoIcons.bookmark),
        ]),
        if (mode == 'Suku') ...[
          const SizedBox(height: 13),
          InkWell(
            onTap: _chooseTribe,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(color: theme.cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: theme.dividerColor)),
              child: Row(children: [
                Icon(CupertinoIcons.person_2, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 11),
                Expanded(child: Text(selectedTribe ?? 'Pilih suku',
                  style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w700,
                    color: selectedTribe == null ? theme.hintColor : theme.colorScheme.onSurface))),
                const Icon(CupertinoIcons.chevron_down, size: 17),
              ]),
            ),
          ),
        ],
        if (mode == 'Daerah') ...[
          const SizedBox(height: 13),
          InkWell(
            onTap: _chooseDistrict,
            borderRadius: BorderRadius.circular(15),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(15),
                border: Border.all(color: theme.dividerColor)),
              child: Row(children: [
                Icon(CupertinoIcons.location, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 11),
                Expanded(child: Text(selectedDistrict ?? 'Pilih kabupaten atau kota',
                  style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w700,
                    color: selectedDistrict == null ? theme.hintColor : theme.colorScheme.onSurface))),
                const Icon(CupertinoIcons.chevron_down, size: 17),
              ]),
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: searchController,
          onChanged: (value) => setState(() => query = value),
          style: GoogleFonts.fredoka(color: theme.colorScheme.onSurface, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Cari kosakata...',
            hintStyle: GoogleFonts.fredoka(color: theme.hintColor, fontSize: 14),
            prefixIcon: const Icon(CupertinoIcons.search),
            suffixIcon: query.isEmpty ? null : IconButton(
              onPressed: () { searchController.clear(); setState(() => query = ''); },
              icon: const Icon(CupertinoIcons.xmark)),
            filled: true,
            fillColor: theme.brightness == Brightness.dark ? theme.cardColor : const Color(0xFFF7F8FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.dividerColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.dividerColor)),
          ),
        ),
        const SizedBox(height: 17),
        if (mode == 'Daerah' && selectedDistrict == null)
          _emptyDictionaryState(context, 'Pilih daerah terlebih dahulu',
            'Daerah akan muncul setelah admin menambahkan kosakata melalui website.')
        else if (mode == 'Suku' && selectedTribe == null)
          _emptyDictionaryState(context, 'Pilih suku terlebih dahulu',
            'Pilih suku untuk melihat kosakata yang tersedia.')
        else if (entries.isEmpty)
          _emptyDictionaryState(context,
            mode == 'Favorit' ? 'Belum ada kosakata favorit' : 'Belum ada kosakata',
            mode == 'Daerah'
              ? 'Belum ada kosakata yang ditandai untuk $selectedDistrict. Maksimal 5 kosakata ditampilkan per daerah.'
              : 'Kosakata akan tampil di sini setelah tersedia. Kamu juga bisa menandai kata dengan ikon favorit.')
        else
          for (final item in entries) _dictionaryWordCard(item),
      ]),
    );
  }

  Widget _dictionaryWordCard(Map<String, String> item) {
    final theme = Theme.of(context);
    final key = _key(item);
    final favorite = favorites.contains(key);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(17),
        border: Border.all(color: theme.dividerColor)),
      child: Row(children: [
        SizedBox(width: 34, child: Icon(CupertinoIcons.book, size: 23, color: theme.colorScheme.onSurface)),
        Container(width: 1, height: 42, margin: const EdgeInsets.symmetric(horizontal: 13),
          color: theme.dividerColor),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['word'] ?? '', style: GoogleFonts.fredoka(fontSize: 18,
            fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 3),
          Text('${item['language'] ?? 'Daerah'} • ${item['meaning'] ?? ''}',
            style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
        ])),
        IconButton(
          tooltip: favorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
          onPressed: () => setState(() {
            if (favorite) { favorites.remove(key); } else { favorites.add(key); }
          }),
          icon: Icon(favorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color: favorite ? const Color(0xFFE64B69) : theme.colorScheme.onSurface, size: 25),
        ),
      ]),
    );
  }

  Widget _emptyDictionaryState(BuildContext context, String title, String detail) {
    final theme = Theme.of(context);
    return Container(padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(17),
        border: Border.all(color: theme.dividerColor)),
      child: Column(children: [
        Icon(CupertinoIcons.book, size: 30, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 9),
        Text(title, textAlign: TextAlign.center,
          style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface)),
        const SizedBox(height: 5),
        Text(detail, textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final user = _auth.currentUser;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('info_posts').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        final posts = (snapshot.data?.docs ?? const []).where((doc) {
          final section = (doc.data()['displaySection'] ?? 'both').toString();
          return section == 'informasi_terbaru' || section == 'both';
        }).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            Text('Informasi Terbaru',
              style: GoogleFonts.fredoka(fontSize: 27, fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
            const SizedBox(height: 18),
            if (snapshot.hasError)
              _infoStateCard(context, Icons.cloud_off_rounded,
                'Informasi gagal dimuat', 'Periksa koneksi internet lalu coba lagi.')
            else if (!snapshot.hasData)
              const Padding(padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
            else if (posts.isEmpty)
              _infoStateCard(context, CupertinoIcons.doc_text,
                'Belum ada informasi', 'Pengumuman terbaru dari Kalbar akan tampil di sini.')
            else
              for (var i = 0; i < posts.length; i++)
                _InfoTimelineItem(
                  postId: posts[i].id,
                  data: posts[i].data(),
                  isLast: i == posts.length - 1,
                  uid: user?.uid ?? '',
                  dark: dark,
                ),
          ],
        );
      },
    );
  }

  Widget _infoStateCard(BuildContext context, IconData icon, String title, String detail) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha:.65)),
      ),
      child: Column(children: [
        Icon(icon, size: 30, color: theme.colorScheme.primary),
        const SizedBox(height: 9),
        Text(title, style: GoogleFonts.fredoka(fontSize: 17,
          fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text(detail, textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

class _InfoTimelineItem extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> data;
  final bool isLast;
  final String uid;
  final bool dark;
  const _InfoTimelineItem({required this.postId, required this.data,
    required this.isLast, required this.uid, required this.dark});

  String get _title => (data['title'] ?? 'Informasi Kalbar').toString();
  String get _body => (data['body'] ?? '').toString();
  String get _date {
    final raw = (data['date'] ?? '').toString();
    if (raw.isNotEmpty) return raw;
    final created = data['createdAt'];
    if (created is Timestamp) {
      final d = created.toDate();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    return 'Tanggal tidak tersedia';
  }

  void _openDetails(BuildContext context) {
    final theme = Theme.of(context);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (routeContext) => BackPage(
        title: 'Informasi',
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(_date, style: GoogleFonts.inter(fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 10),
            Text(_title, style: GoogleFonts.fredoka(fontSize: 25,
              fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 14),
            if ((data['imageUrl'] ?? '').toString().startsWith('https://'))
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: _normalizeImageUrl(data['imageUrl'].toString()),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const SizedBox(
                    height: 160,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 14),
            Text(_body, style: GoogleFonts.inter(fontSize: 15, height: 1.6,
              color: theme.colorScheme.onSurface)),
          ],
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final likeRef = _db.collection('info_posts').doc(postId).collection('likes');
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(width: 38, child: Column(children: [
          Container(width: 2, height: 22, color: accent),
          Container(width: 34, height: 34,
            decoration: BoxDecoration(shape: BoxShape.circle,
              border: Border.all(color: accent, width: 2),
              color: theme.scaffoldBackgroundColor),
            child: Center(child: Container(width: 13, height: 13,
              decoration: BoxDecoration(shape: BoxShape.circle, color: accent))),
          ),
          Expanded(child: Container(width: 2, color: isLast
            ? Colors.transparent : accent.withValues(alpha:.7))),
        ])),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: theme.dividerColor.withValues(alpha:.75)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:dark ? .08 : .045),
                blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(_title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(fontSize: 21, fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface))),
                const SizedBox(width: 8),
                Text(_date, style: GoogleFonts.inter(fontSize: 12,
                  fontWeight: FontWeight.w700, color: theme.colorScheme.onSurfaceVariant)),
              ]),
              if (_body.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_body, maxLines: 4, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 14, height: 1.45,
                    color: theme.colorScheme.onSurface)),
              ],
              if ((data['imageUrl'] ?? '').toString().startsWith('https://')) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: CachedNetworkImage(
                    imageUrl: _normalizeImageUrl(data['imageUrl'].toString()),
                    width: double.infinity, height: 190, fit: BoxFit.cover,
                    placeholder: (_, __) => Container(height: 190,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Divider(height: 1, color: theme.dividerColor),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _InfoAction(
                  icon: CupertinoIcons.info_circle,
                  label: 'Info',
                  selected: true,
                  onTap: () => _openDetails(context),
                )),
                Container(width: 1, height: 28, color: theme.dividerColor),
                Expanded(child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: uid.isEmpty ? null : likeRef.doc(uid).snapshots(),
                  builder: (context, ownLike) {
                    final liked = ownLike.data?.exists == true;
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: likeRef.snapshots(),
                      builder: (context, likes) {
                        final count = likes.data?.docs.length ?? 0;
                        return _InfoAction(
                          icon: liked ? CupertinoIcons.hand_thumbsup_fill : CupertinoIcons.hand_thumbsup,
                          label: count > 0 ? 'Like $count' : 'Like',
                          selected: liked,
                          onTap: uid.isEmpty ? null : () async {
                            final ref = likeRef.doc(uid);
                            try {
                              if (liked) {
                                await ref.delete();
                              } else {
                                await ref.set({'uid': uid, 'createdAt': FieldValue.serverTimestamp()});
                              }
                            } catch (_) {
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Like belum dapat disimpan. Coba lagi.')));
                            }
                          },
                        );
                      },
                    );
                  },
                )),
                Container(width: 1, height: 28, color: theme.dividerColor),
                Expanded(child: _InfoAction(
                  icon: CupertinoIcons.share, label: 'Bagikan',
                  onTap: () => Share.share('$_title\n\n$_body\n\nKalbar Kite'),
                )),
              ]),
            ]),
          ),
        )),
      ]),
    );
  }
}

class _InfoAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _InfoAction({required this.icon, required this.label,
    this.selected = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    return Material(color: Colors.transparent, child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.w600, color: color))),
        ]),
      ),
    ));
  }
}

Widget _remoteAvatar(String rawUrl, {
  double radius = 24,
  Color backgroundColor = const Color(0xFFF0F0F0),
  Color iconColor = const Color(0xFF171717),
}) {
  final url = _normalizeImageUrl(rawUrl);
  final fallback = Icon(CupertinoIcons.person_fill,
      color: iconColor, size: radius * 1.05);
  return CircleAvatar(
    radius: radius,
    backgroundColor: backgroundColor,
    child: url.isEmpty
        ? fallback
        : ClipOval(
            child: CachedNetworkImage(
              imageUrl: url,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 160),
              placeholder: (_, __) => fallback,
              errorWidget: (_, __, ___) => fallback,
            ),
          ),
  );
}

Widget _accountAvatar(String email, {double radius = 38}) {
  final url = _normalizeImageUrl(Store.avatarUrls[email] ?? '');
  if (url.isNotEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFEAEAEA),
      child: ClipOval(child: CachedNetworkImage(
        imageUrl: url, width: radius * 2, height: radius * 2, fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 180),
        placeholder: (_, __) => Icon(CupertinoIcons.person_fill, size: radius, color: const Color(0xFF777777)),
        errorWidget: (_, __, ___) => Icon(CupertinoIcons.person_fill, size: radius, color: const Color(0xFF777777)),
      )),
    );
  }
  final path = Store.avatarPaths[email] ?? '';
  if (path.isNotEmpty && File(path).existsSync()) {
    return CircleAvatar(radius: radius, backgroundColor: const Color(0xFFEAEAEA), backgroundImage: FileImage(File(path)));
  }
  return CircleAvatar(radius: radius, backgroundColor: const Color(0xFFEAEAEA),
    child: Icon(CupertinoIcons.person_fill, size: radius * 1.05, color: const Color(0xFF777777)));
}


class MemberQrPage extends StatelessWidget {
  const MemberQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('QR akun')),
        body: const Center(child: Text('Silakan masuk untuk melihat QR akun.')),
      );
    }
    final payload = 'kalbarkite://profile/${user.uid}';
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('QR akun')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _db.collection('public_profiles').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          final profile = snapshot.data?.data() ?? <String, dynamic>{};
          final name = (profile['name'] ?? user.displayName ?? 'Pengguna Kalbar Kite').toString();
          final username = (profile['username'] ?? user.email?.split('@').first ?? 'warga').toString();
          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 76),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF168DE2), Color(0xFF0874CC)],
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, size: 122, color: Colors.white),
                    const SizedBox(height: 10),
                    const Text(
                      'QR ANGGOTA KALBAR KITE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Pindai untuk membuka profil anggota',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha:.9), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -36),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: theme.dividerColor.withValues(alpha:.65)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:.07),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Bagikan profilmu',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Minta anggota lain memindai QR ini untuk langsung membuka profil Kalbar Kite milikmu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, height: 1.4, color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: theme.dividerColor.withValues(alpha:.7)),
                          ),
                          child: QrImageView(
                            data: payload,
                            version: QrVersions.auto,
                            size: 230,
                            backgroundColor: Colors.white,
                            errorCorrectionLevel: QrErrorCorrectLevel.M,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(name, textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 3),
                        Text('@$username', textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  children: [
                    FilledButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberQrScannerPage())),
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: Text('Pindai QR anggota', style: TextStyle(fontFamily: GoogleFonts.fredoka().fontFamily, fontWeight: FontWeight.w700)),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'QR ini untuk menemukan profil anggota Kalbar Kite, bukan untuk pembayaran QRIS.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, height: 1.4, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MemberQrScannerPage extends StatefulWidget {
  const MemberQrScannerPage({super.key});

  @override
  State<MemberQrScannerPage> createState() => _MemberQrScannerPageState();
}

class _MemberQrScannerPageState extends State<MemberQrScannerPage> {
  bool _openingProfile = false;
  bool _torchOn = false;
  final MobileScannerController _cameraController = MobileScannerController(
    autoStart: true,
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 250,
    cameraResolution: const Size(1920, 1080),
    formats: const [BarcodeFormat.qrCode],
    autoZoom: true,
    torchEnabled: false,
  );

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    try {
      await _cameraController.toggleTorch();
      if (mounted) setState(() => _torchOn = !_torchOn);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flash tidak tersedia pada kamera ini.')),
      );
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _cameraController.switchCamera();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamera lain tidak tersedia.')),
      );
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_openingProfile) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw == null || raw.isEmpty) continue;
      final uri = Uri.tryParse(raw);
      if (uri == null || uri.scheme != 'kalbarkite' ||
          uri.host != 'profile' || uri.pathSegments.length != 1) {
        continue;
      }
      final uid = uri.pathSegments.single.trim();
      if (uid.isEmpty) continue;
      _openingProfile = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PublicProfilePage(uid: uid)),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scanSize = (size.width - 64).clamp(220.0, 270.0).toDouble();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _cameraController,
            fit: BoxFit.cover,
            onDetect: _onDetect,
            errorBuilder: (context, error) => ColoredBox(
              color: const Color(0xFF101827),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.no_photography_outlined, color: Colors.white, size: 48),
                    const SizedBox(height: 14),
                    Text('Kamera tidak dapat dibuka. Periksa izin kamera perangkat.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(error.errorCode.name,
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
                  ]),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 18, 0),
                  child: Row(children: [
                    Material(
                      color: Colors.black.withValues(alpha:.28),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Kembali',
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Pindai QR anggota',
                      style: GoogleFonts.fredoka(fontSize: 21, fontWeight: FontWeight.w700,
                        color: Colors.white))),
                    IconButton(
                      tooltip: _torchOn ? 'Matikan flash' : 'Nyalakan flash',
                      onPressed: _toggleTorch,
                      icon: Icon(_torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha:.28)),
                    ),
                    IconButton(
                      tooltip: 'Ganti kamera',
                      onPressed: _switchCamera,
                      icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha:.28)),
                    ),
                  ]),
                ),
                const Spacer(),
                SizedBox(
                  width: scanSize,
                  height: scanSize,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2.5),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33FFFFFF), blurRadius: 14, spreadRadius: 1),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Arahkan kamera ke QR profil pengguna Kalbar Kite. Profil akan terbuka otomatis setelah QR terbaca.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, height: 1.5,
                      color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 26),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha:.35),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text('QR profil Kalbar Kite',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white70,
                        fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Future<void> _openDetails() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileDetailsPage()));
    if (mounted) setState(() {});
  }

  void _openMemberQr() {
    final user = _auth.currentUser;
    if (user == null) return;
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _db.collection('public_profiles').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          final profile = snapshot.data?.data() ?? <String, dynamic>{};
          final username = (profile['username'] ?? user.email?.split('@').first ?? 'warga').toString();
          final code = username.replaceAll('@', '').toUpperCase();
          final payload = 'kalbarkite://profile/${user.uid}';
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:.18), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('QR PROFILE', style: TextStyle(
                    fontFamily: GoogleFonts.fredoka().fontFamily,
                    fontSize: 18, fontWeight: FontWeight.w900,
                    letterSpacing: 1.1, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 3),
                  Text(code, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: payload,
                      version: QrVersions.auto,
                      size: 238,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Pindai QR ini untuk langsung membuka profil anggota Kalbar Kite.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(fontSize: 14, height: 1.4,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keluar dari akun?', style: GoogleFonts.fredoka(fontSize: 23, fontWeight: FontWeight.w700, color: Theme.of(dialogContext).colorScheme.onSurface)),
                const SizedBox(height: 10),
                Text('Kamu akan kembali ke halaman masuk.', style: GoogleFonts.inter(fontSize: 14, height: 1.45, fontWeight: FontWeight.w500, color: Theme.of(dialogContext).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: forest,
                          side: const BorderSide(color: forest, width: 1.4),
                          minimumSize: const Size.fromHeight(48),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text('Tetap di sini', textAlign: TextAlign.center, style: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF2B8BE),
                          foregroundColor: const Color(0xFF8F303B),
                          minimumSize: const Size.fromHeight(48),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text('Ya, keluar', textAlign: TextAlign.center, style: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (leave != true) return;
    await _auth.signOut(); Store.currentEmail = ''; Store.currentUid = ''; Store.adminRole = false;
    await Store.saveSession();
    if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Login()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final authUser = _auth.currentUser;
    final email = authUser?.email ?? Store.currentEmail;
    if (authUser != null) { Store.currentUid = authUser.uid; Store.currentEmail = email; }
    final name = Store.memberNames[email] ?? authUser?.displayName ?? (Store.isAdmin ? 'Administrator' : 'Pengguna Kalbar Kite');
    final username = Store.usernames[email] ?? email.split('@').first;
    final profileFont = GoogleFonts.fredoka().fontFamily!;
    final profileTheme = theme.copyWith(
      textTheme: theme.textTheme.apply(fontFamily: profileFont),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        textStyle: TextStyle(fontFamily: profileFont, fontWeight: FontWeight.w800))),
    );
    return Theme(data: profileTheme, child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF202A38) : const Color(0xFFFAFBFD),
            border: Border.all(color: theme.dividerColor.withValues(alpha: .8), width: .9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(children: [
            Container(width: 48, height: 48,
              decoration: BoxDecoration(color: pale, shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1684E8).withValues(alpha: .16))),
              child: ClipOval(child: _accountAvatar(email, radius: 24))),
            const SizedBox(width: 11),
            Expanded(child: StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
              stream: authUser == null ? null : _db.collection('public_profiles').doc(authUser.uid).snapshots(),
              builder: (context, snapshot) {
                final live = snapshot.data?.data() ?? <String,dynamic>{};
                final liveName = (live['name'] ?? name).toString();
                final liveUsername = (live['username'] ?? username).toString();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(child: Text(liveName, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fredoka(fontSize: 21, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface))),
                    if (live['ownerVerified'] == true) const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Icon(Icons.verified_rounded, color: Color(0xFF1684E8), size: 20)),
                  ]),
                  const SizedBox(height: 2),
                  Text('@$liveUsername', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
                ]);
              },
            )),
            const SizedBox(width: 8),
            _profileActionIcon(Icons.qr_code_2_rounded, 'QR profil saya', _openMemberQr, dark),
            const SizedBox(width: 6),
            _profileActionIcon(Icons.camera_alt_rounded, 'Pindai QR anggota', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberQrScannerPage()));
            }, dark),
            const SizedBox(width: 6),
            _profileActionIcon(Icons.edit_rounded, 'Edit profil', _openDetails, dark),
          ]),
        ),
        const SizedBox(height: 18),
        _profileSection('Akun', [
          _profileTile(Icons.account_circle_outlined, 'Akun saya', 'Pengaturan data profil akun', _openDetails),
          _profileTile(CupertinoIcons.lock, 'Password', 'Ubah password akun', _openDetails, showDivider: false),
        ]),
        const SizedBox(height: 16),
        _profileSection('Menu lainnya', [
          _profileTile(Icons.support_agent_outlined, 'Pusat bantuan', 'Bantuan dan kontak resmi Kalbar Kite',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactPage()))),
          _profileTile(Icons.shield_outlined, 'Privasi & Kebijakan', 'Ringkasan pengelolaan data pengguna',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()))),
          _profileTile(Icons.verified_outlined, 'Versi aplikasi', 'Kalbar Kite • Versi 1.0.0', null,
            showDivider: false, showArrow: false),
        ]),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: _confirmLogout,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Keluar dari akun'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFFE1E1), foregroundColor: const Color(0xFFB42318),
            minimumSize: const Size.fromHeight(44),
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        )),
        const SizedBox(height: 28),
        Center(child: Column(children: [
          Container(width: 76, height: 76,
            decoration: const BoxDecoration(color: pale, shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded, color: forest, size: 36)),
          const SizedBox(height: 12),
          Text('Kalbar Kite • Versi 1.0.0',
            style: GoogleFonts.fredoka(fontSize: 19, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 5),
          Text('Budaya, cerita, dan kepedulian Kalimantan Barat.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
        ])),
      ],
    ));
  }

  Widget _profileActionIcon(IconData icon, String tooltip, VoidCallback action, bool dark) =>
    Tooltip(message: tooltip, child: InkWell(
      onTap: action, borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.all(2),
        child: Icon(icon, size: 22, color: dark ? Colors.white : const Color(0xFF34383F))),
    ));

  Widget _profileSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 5, bottom: 9),
        child: Text(title, style: GoogleFonts.fredoka(fontSize: 19,
          fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: .55),
          border: Border.all(color: theme.dividerColor.withValues(alpha: .8), width: .8),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(children: children),
      ),
    ]);
  }

  Widget _profileTile(IconData icon, String title, String subtitle, VoidCallback? action,
      {bool showDivider = true, bool showArrow = true}) {
    final theme = Theme.of(context);
    return Container(
      decoration: showDivider ? BoxDecoration(border: Border(bottom: BorderSide(
        color: theme.dividerColor.withValues(alpha: .7), width: .7))) : null,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
        minLeadingWidth: 34,
        horizontalTitleGap: 8,
        visualDensity: const VisualDensity(vertical: -2),
        onTap: action,
        leading: Container(width: 34, height: 34,
          decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .55),
            borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 18)),
        title: Text(title, style: GoogleFonts.fredoka(fontSize: 16,
          fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant)),
        trailing: showArrow ? Icon(CupertinoIcons.chevron_right, size: 18,
          color: theme.colorScheme.onSurfaceVariant) : null,
      ),
    );
  }

}


class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final content = Store.privacyPolicyContent.trim().isNotEmpty
        ? Store.privacyPolicyContent.trim()
        : 'Kebijakan privasi resmi belum diatur oleh admin. Informasi akan ditampilkan setelah pengelola menerbitkannya.';

    final normalizedContent = content
        .replaceAll('\\r\\n', '\\n')
        .replaceAll('\\r', '\\n');
    final policyBlocks = <Widget>[];

    for (final rawLine in normalizedContent.split('\\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        policyBlocks.add(const SizedBox(height: 10));
        continue;
      }

      final numbered = RegExp(r'^(\\d+)\\.\\s+(.+)$').firstMatch(line);
      final isUpperHeading = line.length > 3 &&
          line == line.toUpperCase() &&
          RegExp(r'[A-Z]').hasMatch(line);
      final isBullet = line.startsWith('• ') ||
          line.startsWith('- ') ||
          line.startsWith('▪ ');

      if (numbered != null) {
        policyBlocks.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F1FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    numbered.group(1)!,
                    style: GoogleFonts.fredoka(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF087FF5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    numbered.group(2)!,
                    style: GoogleFonts.fredoka(
                      fontSize: 21,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (isUpperHeading) {
        policyBlocks.add(
          Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 2),
            child: Text(
              line,
              style: GoogleFonts.fredoka(
                fontSize: 18,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        );
      } else if (isBullet) {
        final bulletText = line.substring(2).trim();
        policyBlocks.add(
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 2, bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 7),
                  child: Icon(
                    CupertinoIcons.circle_fill,
                    size: 8,
                    color: Color(0xFF087FF5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    bulletText,
                    style: GoogleFonts.fredoka(
                      fontSize: 15.5,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        policyBlocks.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              line,
              style: GoogleFonts.fredoka(
                fontSize: 15.5,
                height: 1.5,
                fontWeight: FontWeight.w400,
                color: foreground,
              ),
            ),
          ),
        );
      }
    }

    return BackPage(
      title: 'Kebijakan Privasi',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 34),
        children: [
          Text(
            'Privasi pengguna Kalbar Kite',
            style: GoogleFonts.fredoka(
              fontSize: 29,
              height: 1.18,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Informasi mengenai kebijakan dan pengelolaan data pengguna.',
            style: GoogleFonts.fredoka(
              fontSize: 15.5,
              height: 1.45,
              fontWeight: FontWeight.w400,
              color: muted,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Icon(
                CupertinoIcons.doc_text,
                size: 29,
                color: Color(0xFF1769AA),
              ),
              const SizedBox(width: 12),
              Text(
                'Kebijakan resmi',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...policyBlocks,
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CupertinoIcons.info_circle, size: 16, color: muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Konten kebijakan pada halaman ini mengikuti informasi yang diterbitkan oleh admin Kalbar Kite.',
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    height: 1.4,
                    color: muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _openContact(BuildContext context, String title, String value) async {
    Uri? target;
    if (title == 'Email') {
      final email = value.trim();
      if (!email.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alamat email admin belum valid.')));
        return;
      }
      final gmail = Uri.https('mail.google.com', '/mail/', {
        'view': 'cm', 'fs': '1', 'to': email,
        'su': 'Bantuan Kalbar Kite',
        'body': 'Halo Admin Kalbar Kite, saya ingin meminta bantuan.',
      });
      if (await launchUrl(gmail, mode: LaunchMode.externalApplication)) return;
      target = Uri(scheme: 'mailto', path: email, queryParameters: {
        'subject': 'Bantuan Kalbar Kite',
        'body': 'Halo Admin Kalbar Kite, saya ingin meminta bantuan.',
      });
    } else if (title == 'WhatsApp') {
      final raw = value.trim();
      if (raw.startsWith('https://wa.me/')) {
        target = Uri.tryParse(raw);
      } else {
        var number = raw.replaceAll(RegExp(r'[^0-9]'), '');
        if (number.startsWith('0')) number = '62${number.substring(1)}';
        if (number.startsWith('8')) number = '62$number';
        if (number.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nomor WhatsApp admin belum valid.')));
          return;
        }
        target = Uri.https('wa.me', '/$number');
      }
    } else {
      final raw = value.trim();
      target = Uri.tryParse(raw.startsWith('http') ? raw : 'https://$raw');
    }
    if (target == null || !await launchUrl(target, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tidak dapat membuka $title.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Store.helpCenterContent.trim();
    return BackPage(title: 'Pusat bantuan', child: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? const Color(0xFF1D1D1D) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BANTUAN KALBAR KITE',
              style: GoogleFonts.inter(fontSize: 11, letterSpacing: 1.1,
                fontWeight: FontWeight.w800, color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Kontak resmi Kalbar Kite',
              style: GoogleFonts.fredoka(fontSize: 21, fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(content.isNotEmpty ? content :
              'Konten pusat bantuan belum diatur oleh admin. Gunakan kanal kontak resmi berikut untuk menghubungi pengelola.',
              style: GoogleFonts.inter(fontSize: 15, height: 1.7, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
          ]),
        ),
        const SizedBox(height: 12),
        _contactItem(context, CupertinoIcons.envelope, 'Email', Store.contactEmail),
        _contactItem(context, CupertinoIcons.bubble_left, 'WhatsApp', Store.contactWhatsapp),
        _contactItem(context, CupertinoIcons.globe, 'Website', Store.contactWebsite),
      ],
    ));
  }

  Widget _contactItem(BuildContext context, IconData icon, String title, String value) =>
    Card(elevation: 0, margin: const EdgeInsets.only(bottom: 9),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor)),
      child: ListTile(
        leading: title == 'WhatsApp'
          ? const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 25)
          : Icon(icon, color: Theme.of(context).colorScheme.onSurface),
        title: Text(title, style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface)),
        subtitle: Text(value.isEmpty ? 'Belum diatur oleh admin' : value),
        trailing: value.isEmpty ? const Icon(Icons.schedule_outlined) :
          const Icon(CupertinoIcons.arrow_up_right_square),
        onTap: value.isEmpty ? null : () => _openContact(context, title, value)));
}

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});
  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}
class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  late final name = TextEditingController(text: Store.memberNames[Store.currentEmail] ?? '');
  late final phone = TextEditingController(text: Store.phones[Store.currentEmail] ?? '');
  late final username = TextEditingController(text: Store.usernames[Store.currentEmail] ?? Store.currentEmail.split('@').first);
  late final bio = TextEditingController(text: Store.bios[Store.currentEmail] ?? '');
  final password = TextEditingController();
  bool saving = false;
  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final snapshot = await _db.collection('profiles').doc(user.uid)
          .get().timeout(const Duration(seconds: 10));
      // Dokumen privat bisa belum ada pada akun lama. Jangan berhenti di sini:
      // foto/banner dan data publik tetap dapat dibaca dari public_profiles.
      final data = snapshot.data() ?? <String, dynamic>{};
      if (!mounted) return;
      name.text = (data['name'] ?? name.text).toString();
      phone.text = (data['phone'] ?? phone.text).toString();
      username.text = (data['username'] ?? username.text).toString();
      bio.text = (data['bio'] ?? bio.text).toString();
      Map<String, dynamic> publicData = <String, dynamic>{};
      if (_firstImageUrl(data, const ['avatarUrl', 'photoURL', 'photoUrl']).isEmpty ||
          _firstImageUrl(data, const ['bannerUrl', 'coverUrl', 'headerImageUrl']).isEmpty) {
        try {
          final publicSnapshot = await _db.collection('public_profiles').doc(user.uid)
              .get().timeout(const Duration(seconds: 8));
          publicData = publicSnapshot.data() ?? <String, dynamic>{};
        } catch (_) {}
      }
      if (data['name'] == null || data['name'].toString().trim().isEmpty) {
        name.text = (publicData['name'] ?? name.text).toString();
      }
      if (data['username'] == null || data['username'].toString().trim().isEmpty) {
        username.text = (publicData['username'] ?? username.text).toString();
      }
      if (data['bio'] == null || data['bio'].toString().trim().isEmpty) {
        bio.text = (publicData['bio'] ?? bio.text).toString();
      }
      final privateAvatar = _firstImageUrl(data, const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl']);
      final publicAvatar = _firstImageUrl(publicData, const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl']);
      final postAvatar = privateAvatar.isEmpty && publicAvatar.isEmpty
          ? await _loadAvatarFromPublicContent(user.uid) : '';
      final avatar = privateAvatar.isNotEmpty ? privateAvatar
          : (publicAvatar.isNotEmpty ? publicAvatar
              : (postAvatar.isNotEmpty ? postAvatar : _normalizeImageUrl(user.photoURL ?? '')));
      final banner = _firstImageUrl(data, const ['bannerUrl', 'coverUrl', 'headerImageUrl']).isNotEmpty
          ? _firstImageUrl(data, const ['bannerUrl', 'coverUrl', 'headerImageUrl'])
          : _firstImageUrl(publicData, const ['bannerUrl', 'coverUrl', 'headerImageUrl']);
      if (avatar.isNotEmpty) Store.avatarUrls[Store.currentEmail] = avatar;
      else Store.avatarUrls.remove(Store.currentEmail);
      if (banner.isNotEmpty) Store.bannerUrls[Store.currentEmail] = banner;
      else Store.bannerUrls.remove(Store.currentEmail);
      Store.memberNames[Store.currentEmail] = name.text;
      Store.phones[Store.currentEmail] = phone.text;
      Store.usernames[Store.currentEmail] = username.text;
      Store.bios[Store.currentEmail] = bio.text;
      setState(() {});
    } catch (error) {
      debugPrint('Gagal memuat data profil: $error');
    }
  }

  @override
  void dispose() { name.dispose(); phone.dispose(); username.dispose(); bio.dispose(); password.dispose(); super.dispose(); }
  Future<void> _saveProfile() async {
    if (name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama lengkap tidak boleh kosong.')));
      return;
    }
    if (saving) return;
    setState(() => saving = true);
    try {
      await Store.saveProfile(name.text.trim(), phone.text.trim(), username.text.trim(), bio.text.trim());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data profil berhasil disimpan.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan profil: $error')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
  Future<void> _pickBanner() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 55, maxWidth: 1024, maxHeight: 1024);
    if (file == null) return;
    try {
      await Store.saveBanner(file.path);
      if (mounted) setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner profil berhasil diperbarui.')));
    } catch (error) {
      if (mounted) {
        // Cloudinary may already have returned a URL even if Firestore sync fails.
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Banner gagal disinkronkan: $error')));
      }
    }
  }
  Future<void> _savePassword() async {
    if (Store.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi admin demo tidak dapat diubah dari halaman ini.')));
      return;
    }
    if (password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi minimal 6 karakter.')));
      return;
    }
    try { await _auth.currentUser!.updatePassword(password.text); }
    on FirebaseAuthException catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_authMessage(error.code)))); return; }
    password.clear();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi berhasil diperbarui.')));
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final fredoka = GoogleFonts.fredoka;
    final bannerUrl = _normalizeImageUrl(Store.bannerUrls[Store.currentEmail] ?? '');
    final neutralScheme = theme.colorScheme.copyWith(
      primary: theme.colorScheme.onSurface,
      secondary: theme.colorScheme.onSurfaceVariant,
      surface: dark ? const Color(0xFF151515) : Colors.white,
      surfaceContainerHighest: dark ? const Color(0xFF292929) : const Color(0xFFF1F1F1),
      onSurface: dark ? Colors.white : const Color(0xFF171717),
      onSurfaceVariant: dark ? const Color(0xFFBDBDBD) : const Color(0xFF555555),
    );
    final profileTheme = theme.copyWith(
      colorScheme: neutralScheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF101010) : Colors.white,
      cardColor: dark ? const Color(0xFF1C1C1C) : Colors.white,
      dividerColor: dark ? const Color(0xFF383838) : const Color(0xFFE4E4E4),
      textTheme: theme.textTheme.apply(fontFamily: GoogleFonts.inter().fontFamily),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        textStyle: fredoka(fontWeight: FontWeight.w700))),
    );
    return Theme(data: profileTheme, child: BackPage(
      title: 'Data Profil',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
        children: [
          Text('Kelola informasi profil akunmu',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                height: 155,
                child: bannerUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: bannerUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Center(child: Icon(Icons.landscape_rounded,
                            size: 42, color: theme.colorScheme.onSurfaceVariant))),
                        errorWidget: (_, __, ___) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Center(child: Icon(Icons.broken_image_outlined,
                            size: 42, color: theme.colorScheme.onSurfaceVariant))),
                      )
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.landscape_rounded, size: 42, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(height: 5),
                          Text('Banner profil Kalbar Kite',
                            style: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface)),
                        ])),
                      ),
              ),
            ),
            Positioned(right: 12, bottom: 12,
              child: Material(color: Colors.black.withValues(alpha:.48), shape: const CircleBorder(),
                child: IconButton(onPressed: _pickBanner,
                  tooltip: 'Ganti banner profil',
                  icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 24)))),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: _pickBanner,
              icon: Icon(Icons.image_rounded, color: theme.colorScheme.onSurface, size: 23),
              label: Text('Atur Banner Profil', style: GoogleFonts.fredoka(
                color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.dividerColor, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 7),
                shape: const StadiumBorder(),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(
              onPressed: () async {
                final file = await ImagePicker().pickImage(source: ImageSource.gallery,
                  imageQuality: 55, maxWidth: 1024, maxHeight: 1024);
                if (file == null) return;
                try { await Store.saveAvatar(file.path); if (mounted) setState(() {}); }
                catch (error) {
                  if (mounted) {
                    // Keep a successfully uploaded Cloudinary URL visible while
                    // reporting that Firestore synchronization still needs attention.
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Foto profil gagal disinkronkan: $error')));
                  }
                }
              },
              icon: Icon(Icons.person_rounded, color: theme.colorScheme.onSurface, size: 23),
              label: Text('Ganti Foto Profil', style: GoogleFonts.fredoka(
                color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.dividerColor, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 7),
                shape: const StadiumBorder(),
              ),
            )),
          ]),
          const SizedBox(height: 16),
          Center(child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border.all(color: theme.dividerColor, width: 1.2),
            ),
            child: ClipOval(child: _accountAvatar(Store.currentEmail, radius: 38)),
          )),
          const SizedBox(height: 16),
          Text('Informasi Akun', style: GoogleFonts.fredoka(fontSize: 23,
            fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 3),
          Text('Pastikan data kontakmu selalu benar dan aktif.',
            style: GoogleFonts.inter(fontSize: 14.5,
              color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 14),
          _section('Data Pribadi', CupertinoIcons.person_fill, [
            _profileInput('Nama Lengkap', name, Icons.badge_outlined, hint: 'Masukkan nama lengkap'),
            const SizedBox(height: 14),
            _profileInput('Username', username, Icons.alternate_email, hint: 'Buat username akunmu'),
            const SizedBox(height: 14),
            _profileBioInput(),
            const SizedBox(height: 14),
            _profileInput('Nomor Telepon / WhatsApp', phone, CupertinoIcons.phone,
              keyboardType: TextInputType.phone, hint: 'Contoh: 08xxxxxxxxxx'),
          ]),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: saving ? null : _saveProfile,
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.onSurface, foregroundColor: theme.colorScheme.surface,
              minimumSize: const Size.fromHeight(44),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: fredoka(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            child: Text(saving ? 'Menyimpan…' : 'Simpan Data Profil'),
          )),
          const SizedBox(height: 16),
          _section('Keamanan Akun', CupertinoIcons.lock, [
            Text('Gunakan kata sandi minimal 6 karakter.',
              style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            TextField(controller: password, obscureText: true,
              style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w700),
              decoration: _fieldDecoration('Kata sandi baru', CupertinoIcons.lock)),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton(
              onPressed: _savePassword,
              child: Text('Perbarui kata sandi', style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w700)))),
          ]),
        ],
      ),
    ));
  }

  Widget _profileInput(String label, TextEditingController controller, IconData icon,
      {TextInputType? keyboardType, String? hint}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 7),
        child: Text(label, style: GoogleFonts.fredoka(
          fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: .1,
          color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: label == 'Nama Lengkap' ? TextCapitalization.words : TextCapitalization.none,
        style: GoogleFonts.fredoka(fontSize: 16, height: 1.35, fontWeight: FontWeight.w600),
        textInputAction: label == 'Nomor Telepon / WhatsApp' ? TextInputAction.done : TextInputAction.next,
        textAlignVertical: TextAlignVertical.center,
        decoration: _fieldDecoration('', icon, hint: hint),
      ),
    ],
  );

  Widget _profileBioInput() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 7),
        child: Text('Bio', style: GoogleFonts.fredoka(
          fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: .1,
          color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ),
      TextField(
        controller: bio,
        minLines: 3,
        maxLines: 4,
        maxLength: 160,
        textCapitalization: TextCapitalization.sentences,
        style: GoogleFonts.fredoka(fontSize: 16, height: 1.45, fontWeight: FontWeight.w600),
        textAlignVertical: TextAlignVertical.top,
        decoration: _fieldDecoration('', CupertinoIcons.doc_text, hint: 'Ceritakan sedikit tentang dirimu'),
      ),
    ],
  );

  InputDecoration _fieldDecoration(String label, IconData icon, {String? hint}) => InputDecoration(
    labelText: label.isEmpty ? null : label,
    hintText: hint,
    prefixIcon: Icon(icon, size: 21),
    filled: true,
    fillColor: Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF242424) : const Color(0xFFF5F5F5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 56),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: .45), width: .8)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: .85), width: 1)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 1.6)),
    counterStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11),
  );

  Widget _section(String title, IconData icon, List<Widget> children) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(17, 17, 17, 19),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .85), width: .9),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 30, height: 30, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
      ]),
      const SizedBox(height: 16), ...children,
    ]),
  );
}

class ProfileItem extends StatelessWidget {
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  const ProfileItem({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(elevation: 0, child: ListTile(onTap: onTap, leading: Icon(icon, color: forest), title: Text(title), subtitle: Text(subtitle), trailing: const Icon(CupertinoIcons.chevron_right)));
}

class BroadcastNotificationsPage extends StatelessWidget {
  const BroadcastNotificationsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notifikasi Kalbar Kite')),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('notifications').where('status', isEqualTo: 'sent').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Notifikasi belum dapat dimuat: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.toList()
          ..sort((a,b) {
            final at = a.data()['createdAt'];
            final bt = b.data()['createdAt'];
            final av = at is Timestamp ? at.millisecondsSinceEpoch : 0;
            final bv = bt is Timestamp ? bt.millisecondsSinceEpoch : 0;
            return bv.compareTo(av);
          });
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(28),
              child: Text('Belum ada pengumuman dari admin.', textAlign: TextAlign.center),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16), itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final image = _normalizeImageUrl((data['imageUrl'] ?? '').toString());
            final stamp = data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate().toLocal() : null;
            return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text((data['title'] ?? 'Kalbar Kite').toString(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                if (stamp != null) Padding(padding: const EdgeInsets.only(top: 3),
                  child: Text('${stamp.day}/${stamp.month}/${stamp.year} • ${stamp.hour.toString().padLeft(2,'0')}.${stamp.minute.toString().padLeft(2,'0')}',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                if (image.startsWith('https://')) ...[
                  const SizedBox(height: 10),
                  ClipRRect(borderRadius: BorderRadius.circular(12),
                    child: Image.network(image, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink())),
                ],
                const SizedBox(height: 8),
                Text((data['body'] ?? '').toString(), style: const TextStyle(height: 1.45)),
              ],
            )));
          },
        );
      },
    ),
  );
}

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});
  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _url = TextEditingController();
  String _routeType = 'none';
  String _imageUrl = '';
  String _localImage = '';
  bool _sending = false;

  @override
  void dispose() { _title.dispose(); _body.dispose(); _url.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 55, maxWidth: 1024, maxHeight: 1024);
    if (file == null) return;
    setState(() { _localImage = file.path; _imageUrl = ''; });
  }

  Future<void> _send() async {
    if (!Store.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hanya admin yang dapat mengirim notifikasi.')));
      return;
    }
    final title = _title.text.trim(), body = _body.text.trim(), target = _url.text.trim();
    if (title.isEmpty || body.isEmpty || title.length > 80 || body.length > 240) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul wajib diisi (maks. 80 karakter) dan isi wajib diisi (maks. 240 karakter).')));
      return;
    }
    if (_routeType == 'url' && (!target.startsWith('https://') || Uri.tryParse(target) == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan tautan HTTPS yang valid.')));
      return;
    }
    setState(() => _sending = true);
    try {
      var imageUrl = _imageUrl;
      if (_localImage.isNotEmpty) imageUrl = await Store.uploadImage(_localImage, 'notifications');
      await _db.collection('notifications').add({
        'title': title, 'body': body, 'imageUrl': imageUrl,
        'routeType': _routeType == 'dashboard_info' ? 'info' : _routeType,
        'routeValue': _routeType == 'dashboard_info' ? 'dashboard' : (_routeType == 'url' ? target : ''),
        'audience': 'all', 'status': 'queued',
        'createdBy': _auth.currentUser?.uid ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _title.clear(); _body.clear(); _url.clear();
      setState(() { _imageUrl = ''; _localImage = ''; _routeType = 'none'; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifikasi masuk antrean pengiriman.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notifikasi gagal dibuat: $error')));
    } finally { if (mounted) setState(() => _sending = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pusat notifikasi', style: TextStyle(fontWeight: FontWeight.w900))),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 28), children: [
      Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE7EFE8), Color(0xFFF8F4E9)]),
          border: Border.all(color: const Color(0xFFD7DED4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PRATINJAU NOTIFIKASI', style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w900, color: forest)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha:.78), borderRadius: BorderRadius.circular(17), border: Border.all(color: Colors.white.withValues(alpha:.9)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:.07), blurRadius: 18, offset: const Offset(0, 7))]),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: pale, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.eco_rounded, color: forest)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Expanded(child: Text('Kalbar Kite', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))), Text('sekarang', style: TextStyle(fontSize: 10, color: Colors.black.withValues(alpha:.48)))]),
                const SizedBox(height: 3),
                Text(_title.text.isEmpty ? 'Judul notifikasi' : _title.text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(_body.text.isEmpty ? 'Isi notifikasi akan tampil di sini.' : _body.text, style: const TextStyle(fontSize: 12, height: 1.25), maxLines: 3, overflow: TextOverflow.ellipsis),
                if (_localImage.isNotEmpty) ...[const SizedBox(height: 9), ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(_localImage), height: 115, width: double.infinity, fit: BoxFit.cover))],
                if (_imageUrl.isNotEmpty) ...[const SizedBox(height: 9), ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(_imageUrl, height: 115, width: double.infinity, fit: BoxFit.cover))],
              ])),
            ]),
          ),
          const SizedBox(height: 8),
          const Text('Pratinjau visual di aplikasi. Bentuk notifikasi saat terkunci mengikuti Android/iOS.', style: TextStyle(fontSize: 10, color: Color(0xFF667064))),
        ]),
      ),
      const SizedBox(height: 20),
      const Text('Buat notifikasi baru', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
      const SizedBox(height: 5),
      Text('Dikirim ke perangkat pengguna yang mengizinkan notifikasi.', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const SizedBox(height: 14),
      TextField(controller: _title, maxLength: 80, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Judul notifikasi', prefixIcon: Icon(Icons.title_rounded))),
      const SizedBox(height: 10),
      TextField(controller: _body, maxLength: 240, minLines: 2, maxLines: 4, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Caption / isi notifikasi', alignLabelWithHint: true, prefixIcon: Icon(Icons.notes_rounded))),
      const SizedBox(height: 10),
      OutlinedButton.icon(onPressed: _pickImage, icon: const Icon(CupertinoIcons.photo), label: Text(_localImage.isEmpty ? 'Pilih foto notifikasi' : 'Ganti foto')),
      if (_localImage.isNotEmpty) Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () => setState(() => _localImage = ''), icon: const Icon(CupertinoIcons.trash), label: const Text('Hapus foto'))),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: _routeType,
        decoration: const InputDecoration(labelText: 'Saat notifikasi ditekan', prefixIcon: Icon(Icons.open_in_new_rounded)),
        items: const [
          DropdownMenuItem(value: 'none', child: Text('Tidak membuka halaman khusus')),
          DropdownMenuItem(value: 'info', child: Text('Buka halaman Informasi / Berita')),
          DropdownMenuItem(value: 'dashboard_info', child: Text('Buka Informasi Terkini di Dashboard')),
          DropdownMenuItem(value: 'url', child: Text('Buka tautan website (HTTPS)')),
        ],
        onChanged: (v) => setState(() => _routeType = v ?? 'none'),
      ),
      if (_routeType == 'url') ...[
        const SizedBox(height: 10),
        TextField(controller: _url, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'URL tujuan', hintText: 'https://contoh.id/event', prefixIcon: Icon(Icons.link_rounded))),
      ],
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _sending ? null : _send,
        icon: _sending ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(CupertinoIcons.paperplane_fill),
        label: Text(_sending ? 'Menyiapkan...' : 'Kirim ke semua pengguna'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
      ),
      const SizedBox(height: 24),
      const Text('Riwayat pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('notifications').orderBy('createdAt', descending: true).limit(20).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Riwayat belum dapat dimuat: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Text('Belum ada notifikasi yang dikirim.');
          return Column(children: docs.map((doc) {
            final data = doc.data();
            return Card(elevation: 0, child: ListTile(
              leading: const CircleAvatar(backgroundColor: pale, child: Icon(CupertinoIcons.bell, color: forest)),
              title: Text((data['title'] ?? 'Notifikasi').toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${data['status'] ?? 'queued'} • ${data['sentCount'] ?? 0} perangkat', maxLines: 1),
              trailing: IconButton(icon: const Icon(CupertinoIcons.trash), onPressed: () async { await doc.reference.delete(); }),
            ));
          }).toList());
        },
      ),
    ]),
  );
}

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});
  @override
  State<AdminHome> createState() => _AdminHomeState();
}
class _AdminHomeState extends State<AdminHome> {
  int tab = 0;
  void refresh() => setState(() {});
  void open(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) => refresh());
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Brand(),
      actions: const [SizedBox(width: 8)],
    ),
    body: IndexedStack(index: tab, children: [AdminDashboard(onRefresh: refresh), const InfoPage(), const AdminProfile()]),
    bottomNavigationBar: _iosBottomBar(context, NavigationBar(
      selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [
      NavigationDestination(icon: Icon(CupertinoIcons.square_grid_2x2), selectedIcon: Icon(CupertinoIcons.square_grid_2x2_fill), label: 'Dashboard'),
      NavigationDestination(icon: Icon(CupertinoIcons.info), selectedIcon: Icon(CupertinoIcons.info_circle_fill), label: 'Informasi'),
      NavigationDestination(icon: Icon(CupertinoIcons.person_fill), selectedIcon: Icon(CupertinoIcons.person_fill), label: 'Profil'),
    ])),
  );
}

class AdminProfile extends StatelessWidget {
  const AdminProfile({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    const SizedBox(height: 18),
    _accountAvatar(Store.currentEmail, radius: 34),
    const SizedBox(height: 12),
    const Center(child: Text('Administrator', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ink))),
    const Center(child: Text('Kelola aplikasi Kalbar Kite', style: TextStyle(color: Colors.black54))),
    const SizedBox(height: 20),
    ProfileItem(icon: Icons.logout, title: 'Keluar admin', subtitle: 'Akhiri sesi administrator', onTap: () async {
          final leave = await showDialog<bool>(context: context, builder: (d) => AlertDialog(
            title: const Text('Keluar dari akun admin?'),
            content: const Text('Kamu akan kembali ke halaman masuk.'),
            actions: [
              OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: forest, side: const BorderSide(color: forest, width: 1.2), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))), onPressed: () => Navigator.pop(d, false), child: const Text('Tetap di sini')),
              FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB94E49), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))), onPressed: () => Navigator.pop(d, true), child: const Text('Ya, keluar')),
            ],
          ));
          if (leave != true) return;
          await _auth.signOut(); Store.currentEmail = ''; Store.currentUid = ''; Store.adminRole = false; await Store.saveSession();
          if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Login()), (_) => false);
        }),
  ]);
}

class AdminDashboard extends StatelessWidget {
  final VoidCallback onRefresh;
  const AdminDashboard({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
    children: [
      const Text('Pengelolaan Kalbar Kite', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: ink)),
      const SizedBox(height: 8),
      const Text(
        'Semua konten, kamus, informasi, anggota, dan pengaturan dikelola melalui website admin. Aplikasi hanya menampilkan data yang tersimpan di server.',
        style: TextStyle(color: Colors.black54, height: 1.5, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 18),
      FilledButton.icon(
        onPressed: () async {
          final uri = Uri.parse('https://kalbarkite.dcxcomunity.my.id');
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Website admin tidak dapat dibuka.')));
          }
        },
        icon: const Icon(CupertinoIcons.globe),
        label: const Text('Buka website admin'),
      ),
    ],
  );
}

class AdminInfo extends StatefulWidget {
  const AdminInfo({super.key});
  @override
  State<AdminInfo> createState() => _AdminInfoState();
}
class _AdminInfoState extends State<AdminInfo> {
  final title = TextEditingController(), body = TextEditingController();
  String imagePath = '';
  String displaySection = 'informasi_terkini';
  final picker = ImagePicker();
  @override
  void dispose() { title.dispose(); body.dispose(); super.dispose(); }
  Future<void> _pickImage() async {
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 55, maxWidth: 1024, maxHeight: 1024);
    if (file == null) return;
    imagePath = await LocalMedia.save(file.path, 'info_images', 'jpg');
    if (mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: paper,
    appBar: AppBar(title: const Text('Kelola informasi', style: TextStyle(fontWeight: FontWeight.w600))),
    body: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 28), children: [
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: pale, borderRadius: BorderRadius.circular(7)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PUSAT KONTEN KALBARKU', style: TextStyle(fontSize: 10, letterSpacing: 1, color: forest, fontWeight: FontWeight.w700)),
          SizedBox(height: 7), Text('Buat informasi baru', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: ink)),
          SizedBox(height: 4), Text('Tulis pengumuman yang mudah dibaca dan tambahkan foto pendukung.', style: TextStyle(fontSize: 12, height: 1.4, color: Colors.black54)),
        ]),
      ),
      const SizedBox(height: 16),
      _adminSection('Konten informasi', CupertinoIcons.doc_text, [
        DropdownButtonFormField<String>(
          initialValue: displaySection,
          decoration: const InputDecoration(labelText: 'Tampilkan di bagian'),
          items: const [
            DropdownMenuItem(value: 'informasi_terbaru', child: Text('Informasi Terbaru (menu Info)')),
            DropdownMenuItem(value: 'informasi_terkini', child: Text('Informasi Terkini (Home)')),
            DropdownMenuItem(value: 'both', child: Text('Keduanya')),
          ],
          onChanged: (value) { if (value != null) setState(() => displaySection = value); },
        ),
        const SizedBox(height: 11),
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Judul informasi', prefixIcon: Icon(Icons.title))),
        const SizedBox(height: 11),
        TextField(controller: body, minLines: 5, maxLines: 8, decoration: const InputDecoration(labelText: 'Isi informasi', alignLabelWithHint: true)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), padding: const EdgeInsets.symmetric(vertical: 13)),
          onPressed: _pickImage, icon: const Icon(Icons.image_outlined), label: const Text('Pilih foto dari perangkat'),
        ),
        if (imagePath.isNotEmpty && File(imagePath).existsSync()) ...[
          const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.file(File(imagePath), height: 170, width: double.infinity, fit: BoxFit.cover)),
          Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () => setState(() => imagePath = ''), icon: const Icon(CupertinoIcons.trash), label: const Text('Hapus foto'))),
        ],
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: FilledButton(
          style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: () async {
            if (title.text.trim().isEmpty || body.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul dan isi informasi wajib diisi.'))); return;
            }
            final now = DateTime.now();
            try { await Store.publishInfo({'title': title.text.trim(), 'body': body.text.trim(), 'date': "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}", 'imagePath': imagePath, 'displaySection': displaySection}); }
            catch (error) { if (!context.mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menerbitkan informasi: $error'))); return; }
            title.clear(); body.clear();
            if (!context.mounted) return;
            setState(() => imagePath = '');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informasi berhasil diterbitkan ke database.')));
          },
          child: const Text('Terbitkan informasi'),
        )),
      ]),
      const SizedBox(height: 18),
      Row(children: [const Expanded(child: Text('Informasi tersimpan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: ink))), Text('${Store.infoPosts.length} konten', style: const TextStyle(fontSize: 12, color: Colors.black54))]),
      const SizedBox(height: 8),
      if (Store.infoPosts.isEmpty) const Text('Belum ada informasi.', style: TextStyle(color: Colors.black54)),
      for (var i = 0; i < Store.infoPosts.length; i++) Card(
        elevation: 0, margin: const EdgeInsets.only(bottom: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: const BorderSide(color: Color(0xFFEAEAEA))),
        child: ListTile(
          title: Text(Store.infoPosts[i]['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(Store.infoPosts[i]['date'] ?? ''),
          trailing: IconButton(icon: const Icon(CupertinoIcons.trash, color: Color(0xFFB94E49)), onPressed: () async { final id = Store.infoPosts[i]['id'] ?? ''; try { await Store.deleteInfo(id); if (mounted) setState(() {}); } catch (error) { if (!context.mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $error'))); } }),
        ),
      ),
    ]),
  );
}
Widget _adminSection(String title, IconData icon, List<Widget> children) => Container(
  padding: const EdgeInsets.all(15),
  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFEAEAEA)), borderRadius: BorderRadius.circular(7)),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Icon(icon, color: forest), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ink))]),
    const SizedBox(height: 14), ...children,
  ]),
);

class AdminMembers extends StatelessWidget {
  const AdminMembers({super.key});
  @override
  Widget build(BuildContext context) {
    final members = Store.accounts.keys.where((email) => email != 'admin').toList();
    return BackPage(title: 'Daftar anggota', child: ListView(padding: const EdgeInsets.all(18), children: [
      Text('Anggota terdaftar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
      const SizedBox(height: 5),
      Text('${members.length} akun pengguna terdaftar di Firebase', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      if (members.isEmpty) const Padding(padding: EdgeInsets.all(22), child: Text('Belum ada anggota terdaftar.', textAlign: TextAlign.center)),
      for (final email in members) Card(elevation: 0, margin: const EdgeInsets.only(bottom: 8), color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Theme.of(context).dividerColor)),
        child: ListTile(leading: CircleAvatar(backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF222222) : pale, child: Icon(CupertinoIcons.person_fill, color: Theme.of(context).colorScheme.primary)),
          title: Text(Store.memberNames[email] ?? 'Pengguna Kalbar Kite', style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text([email, if ((Store.phones[email] ?? '').isNotEmpty) Store.phones[email]!].join(' • ')))),
      const SizedBox(height: 8),
      Text('Daftar anggota dimuat dari profil Firebase.', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]));
  }
}

class AdminForms extends StatefulWidget {
  final VoidCallback onRefresh; const AdminForms({super.key, required this.onRefresh});
  @override
  State<AdminForms> createState() => _AdminFormsState();
}
class _AdminFormsState extends State<AdminForms> {
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    const Text('Formulir anggota', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: ink)),
    const SizedBox(height: 6), const Text('Tinjau pendaftaran pendonor dan permintaan darah.'),
    if (Store.forms.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Belum ada formulir masuk pada sesi ini.', textAlign: TextAlign.center)),
    for (var i = 0; i < Store.forms.length; i++) Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(Store.forms[i]['type'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, color: forest)),
      const SizedBox(height: 5), Text('${Store.forms[i]['name'] ?? ''} • ${Store.forms[i]['blood'] ?? ''}'),
      Text('${Store.forms[i]['phone'] ?? ''} • ${Store.forms[i]['place'] ?? ''}'),
      if ((Store.forms[i]['note'] ?? '').isNotEmpty) Text(Store.forms[i]['note'] ?? ''),
      const SizedBox(height: 5), Text('Status: ${Store.forms[i]['status'] ?? ''}'),
      Wrap(children: [
        TextButton(onPressed: () async { try { await Store.updateBloodStatus(Store.forms[i], 'approved'); if (mounted) setState(() {}); } catch (error) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui: $error'))); } }, child: const Text('Terima')),
        TextButton(onPressed: () async { try { await Store.updateBloodStatus(Store.forms[i], 'rejected'); if (mounted) setState(() {}); } catch (error) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui: $error'))); } }, child: const Text('Tolak')),
      ]),
    ]))),
  ]);
}

class AdminSettings extends StatefulWidget {
  final VoidCallback onSaved; const AdminSettings({super.key, required this.onSaved});
  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}
class _AdminSettingsState extends State<AdminSettings> {
  late final name = TextEditingController(text: Store.appName);
  late final tagline = TextEditingController(text: Store.tagline);
  late final email = TextEditingController(text: Store.contactEmail);
  late final whatsapp = TextEditingController(text: Store.contactWhatsapp);
  late final website = TextEditingController(text: Store.contactWebsite);
  late final helpContent = TextEditingController(text: Store.helpCenterContent);
  late final privacyContent = TextEditingController(text: Store.privacyPolicyContent);
  late String logo = Store.logo;
  final logos = const ['◈', '⌂', '✦', '◎', '◇'];
  @override
  void dispose() {
    name.dispose(); tagline.dispose(); email.dispose(); whatsapp.dispose();
    website.dispose(); helpContent.dispose(); privacyContent.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => BackPage(title: 'Pengaturan aplikasi', child: ListView(padding: const EdgeInsets.all(18), children: [
    Text('Identitas aplikasi', style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
    const SizedBox(height: 14), TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama aplikasi')),
    const SizedBox(height: 10), TextField(controller: tagline, decoration: const InputDecoration(labelText: 'Teks sambutan')),
    const SizedBox(height: 14), Text('Kontak resmi Kalbar Kite', style: GoogleFonts.fredoka(fontSize: 19, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
     const SizedBox(height: 10),
     TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Alamat Gmail / email', prefixIcon: Icon(CupertinoIcons.envelope))),
     const SizedBox(height: 10),
     TextField(controller: whatsapp, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor WhatsApp', prefixIcon: Icon(CupertinoIcons.bubble_left))),
     const SizedBox(height: 10),
     TextField(controller: website, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Website resmi', hintText: 'https://contoh.id', prefixIcon: Icon(CupertinoIcons.globe))),
     const SizedBox(height: 18),
     Text('Konten aplikasi', style: GoogleFonts.fredoka(fontSize: 19, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
     const SizedBox(height: 8),
     TextField(controller: helpContent, minLines: 5, maxLines: 9, maxLength: 12000,
       decoration: const InputDecoration(labelText: 'Pusat Bantuan', alignLabelWithHint: true,
         hintText: 'Panduan, pertanyaan umum, dan cara menghubungi pengelola.')),
     const SizedBox(height: 12),
     TextField(controller: privacyContent, minLines: 6, maxLines: 12, maxLength: 12000,
       decoration: const InputDecoration(labelText: 'Kebijakan Privasi', alignLabelWithHint: true,
         hintText: 'Jelaskan data yang dikumpulkan, penggunaan, penyimpanan, dan hak pengguna.')),
     const SizedBox(height: 14), const Text('Pilih logo'),
    const SizedBox(height: 8), Wrap(spacing: 8, children: logos.map((v) => ChoiceChip(label: Text(v, style: const TextStyle(fontSize: 21)), selected: logo == v, onSelected: (_) => setState(() => logo = v))).toList()),
    const SizedBox(height: 18),
    FilledButton(onPressed: () async {
      if (name.text.trim().isEmpty) return;
      Store.appName = name.text.trim(); Store.tagline = tagline.text.trim(); Store.logo = logo;
      Store.contactEmail = email.text.trim(); Store.contactWhatsapp = whatsapp.text.trim(); Store.contactWebsite = website.text.trim();
      Store.helpCenterContent = helpContent.text.trim();
      Store.privacyPolicyContent = privacyContent.text.trim();
      try {
        await Store.saveAppSettings();
        if (!context.mounted) return;
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengaturan aplikasi dan kontak berhasil disimpan ke Firebase.')));
      } catch (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan pengaturan: $error')));
      }
    }, child: const Text('Simpan pengaturan')),
    const SizedBox(height: 10),
  ]));
}
