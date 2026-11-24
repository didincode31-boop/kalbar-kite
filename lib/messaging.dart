part of 'main.dart';

List<String> _chatParticipantsFor(String firstUid, String secondUid) => [firstUid, secondUid]..sort();

String _chatIdFor(String firstUid, String secondUid) {
  final ids = [firstUid, secondUid]..sort();
  return ids.join('__');
}

Future<bool> _areMutualFriends(String firstUid, String secondUid) async {
  if (firstUid.isEmpty || secondUid.isEmpty || firstUid == secondUid) return false;
  final first = await _db.collection('follows').doc('${firstUid}_$secondUid').get();
  if (!first.exists) return false;
  final second = await _db.collection('follows').doc('${secondUid}_$firstUid').get();
  return second.exists;
}

String _lastSeenText(dynamic value) {
  if (value is! Timestamp) return 'Status terakhir belum tersedia';
  final date = value.toDate().toLocal();
  final now = DateTime.now();
  final time = '${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')}';
  final elapsed = now.difference(date);
  if (elapsed.inMinutes < 1) return 'Terakhir aktif kurang dari semenit lalu';
  if (elapsed.inHours < 1) return 'Terakhir aktif ${elapsed.inMinutes} menit lalu';
  if (elapsed.inDays < 1) return 'Terakhir aktif ${elapsed.inHours} jam lalu';
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Terakhir dilihat hari ini pukul $time';
  }
  if (elapsed.inDays == 1) {
    return 'Terakhir dilihat kemarin pukul $time';
  }
  return 'Terakhir dilihat ${date.day}/${date.month}/${date.year} pukul $time';
}

Future<String> _uploadChatRawFile(String localPath, String folder, {bool audio = false}) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('Silakan masuk kembali sebelum mengirim lampiran.');
  if (cloudinaryCloudName.isEmpty || cloudinaryUploadPreset.isEmpty ||
      cloudinaryCloudName == 'ISI_CLOUD_NAME' ||
      cloudinaryUploadPreset == 'ISI_UNSIGNED_UPLOAD_PRESET') {
    throw Exception('Konfigurasi Cloudinary belum lengkap. Periksa cloud name dan unsigned upload preset.');
  }
  final file = File(localPath);
  if (!await file.exists()) throw Exception('Berkas tidak ditemukan.');
  final size = await file.length();
  if (size == 0) throw Exception('Berkas kosong dan tidak dapat dikirim.');
  final maxBytes = audio ? 10 * 1024 * 1024 : 15 * 1024 * 1024;
  if (size > maxBytes) {
    throw Exception(audio ? 'Pesan suara maksimal 10 MB.' : 'Ukuran lampiran maksimal 15 MB.');
  }
  // Cloudinary stores audio assets through its video resource endpoint.
  final resourceType = audio ? 'video' : 'raw';
  final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudinaryCloudName/$resourceType/upload');
  final request = http.MultipartRequest('POST', uri)
    ..fields['upload_preset'] = cloudinaryUploadPreset
    ..fields['public_id'] = 'kalbarku/$folder/${user.uid}/${DateTime.now().microsecondsSinceEpoch}'
    ..files.add(await http.MultipartFile.fromPath(
      'file',
      localPath,
      contentType: audio ? MediaType('audio', 'mp4') : null,
    ));
  final streamed = await request.send().timeout(const Duration(seconds: 90));
  final response = await http.Response.fromStream(streamed).timeout(const Duration(seconds: 30));
  dynamic data;
  try { data = jsonDecode(response.body); }
  catch (_) { throw Exception('Server unggah mengirim respons HTML atau format tidak valid (HTTP ${response.statusCode}). Periksa Cloudinary upload preset.'); }
  if (response.statusCode < 200 || response.statusCode >= 300) {
    final error = data is Map ? data['error'] : null;
    throw Exception(error is Map ? (error['message'] ?? 'Unggah lampiran gagal.') : 'Unggah lampiran gagal.');
  }
  final url = (data['secure_url'] ?? '').toString();
  if (url.isEmpty) throw Exception('Server tidak mengembalikan tautan lampiran.');
  if (audio) {
    final returnedType = (data['resource_type'] ?? '').toString();
    final format = (data['format'] ?? '').toString().toLowerCase();
    if (returnedType != 'video' || !['m4a', 'mp4', 'aac', 'mp3', 'ogg', 'wav', 'webm'].contains(format)) {
      throw Exception('Cloudinary tidak menyimpan rekaman sebagai audio yang didukung (format: ${format.isEmpty ? 'tidak diketahui' : format}). Periksa upload preset dan resource type.');
    }
  }
  return url;
}

class ChatListPage extends StatefulWidget {
  final bool embedded;
  const ChatListPage({super.key, this.embedded = false});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  String? _friendsUid;
  Future<List<Map<String, dynamic>>>? _friendsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  String _filter = 'Semua';
  Set<String> _archived = <String>{};
  Set<String> _important = <String>{};
  bool _settingsLoaded = false;

  String get _settingsKey => _auth.currentUser?.uid ?? 'guest';

  @override
  void initState() {
    super.initState();
    _loadChatSettings();
    _searchController.addListener(() {
      if (mounted) setState(() => _search = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChatSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final uid = _settingsKey;
    setState(() {
      _archived = (prefs.getStringList('chat_archived_$uid') ?? <String>{}.toList()).toSet();
      _important = (prefs.getStringList('chat_important_$uid') ?? <String>{}.toList()).toSet();
      _settingsLoaded = true;
    });
  }

  Future<void> _saveChatSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _settingsKey;
    await prefs.setStringList('chat_archived_$uid', _archived.toList());
    await prefs.setStringList('chat_important_$uid', _important.toList());
  }

  Future<List<Map<String, dynamic>>> _loadFriends(String uid) async {
    if (uid.isEmpty) return [];
    final outgoing = await _db.collection('follows')
        .where('followerUid', isEqualTo: uid).get()
        .timeout(const Duration(seconds: 15));
    final peerUids = outgoing.docs
        .map((follow) => (follow.data()['followingUid'] ?? '').toString())
        .where((peerUid) => peerUid.isNotEmpty)
        .toSet().toList(growable: false);
    if (peerUids.isEmpty) return [];
    final reciprocalDocs = await Future.wait(peerUids.map((peerUid) =>
        _db.collection('follows').doc('${peerUid}_$uid').get()));
    final mutualUids = <String>[
      for (var i = 0; i < peerUids.length; i++)
        if (reciprocalDocs[i].exists) peerUids[i],
    ];
    if (mutualUids.isEmpty) return [];
    final profiles = await Future.wait(mutualUids.map((peerUid) =>
        _db.collection('public_profiles').doc(peerUid).get()));
    final missingAvatarUids = <String>[
      for (var i = 0; i < mutualUids.length; i++)
        if (_firstImageUrl(profiles[i].data() ?? <String, dynamic>{},
            const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl']).isEmpty)
          mutualUids[i],
    ];
    final fallbackAvatars = await _loadAvatarsForUsers(missingAvatarUids);
    return [
      for (var i = 0; i < mutualUids.length; i++)
        {
          'uid': mutualUids[i],
          ...?profiles[i].data(),
          'avatarUrl': _firstImageUrl(profiles[i].data() ?? <String, dynamic>{},
                  const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl'])
              .isNotEmpty
              ? _firstImageUrl(profiles[i].data() ?? <String, dynamic>{},
                  const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl'])
              : (fallbackAvatars[mutualUids[i]] ?? ''),
          'friend': true,
        },
    ];
  }

  Future<List<Map<String, dynamic>>> _friendsFor(String uid) {
    if (_friendsUid != uid || _friendsFuture == null) {
      _friendsUid = uid;
      _friendsFuture = _loadFriends(uid);
    }
    return _friendsFuture!;
  }

  Future<void> _refresh() async {
    final uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    setState(() {
      _friendsUid = uid;
      _friendsFuture = _loadFriends(uid);
    });
    await _friendsFuture;
  }

  void _openChat(String peerUid, Map<String, dynamic> profile) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChatThreadPage(peerUid: peerUid, initialProfile: profile),
    ));
  }

  String _chatTime(dynamic value) {
    if (value is! Timestamp) return '';
    final date = value.toDate().toLocal();
    final now = DateTime.now();
    final diff = now.difference(date);
    final clock = '${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')}';
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 24 && date.day == now.day && date.month == now.month && date.year == now.year) return clock;
    if (diff.inDays < 1) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin $clock';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} $clock';
  }

  Future<void> _toggleArchive(String uid) async {
    setState(() {
      if (_archived.contains(uid)) { _archived.remove(uid); } else { _archived.add(uid); }
    });
    await _saveChatSettings();
  }

  Future<void> _toggleImportant(String uid) async {
    setState(() {
      if (_important.contains(uid)) { _important.remove(uid); } else { _important.add(uid); }
    });
    await _saveChatSettings();
  }

  Widget _contactTile(Map<String, dynamic> item) {
    final uid = (item['uid'] ?? '').toString();
    final avatar = (item['avatarUrl'] ?? '').toString();
    final displayName = (item['name'] ?? item['displayName'] ?? 'Pengguna Kalbar Kite').toString();
    final username = (item['username'] ?? 'warga').toString();
    final preview = (item['lastMessage'] ?? 'Mulai percakapan').toString();
    final isRequest = item['requestType'] == 'story_reaction' && item['friend'] != true;
    final isArchived = _archived.contains(uid);
    final isImportant = _important.contains(uid);
    final lastTime = _chatTime(item['lastMessageAt']);
    final read = item['lastSenderUid'] == _auth.currentUser?.uid && item['lastMessageRead'] == true;

    return InkWell(
      onTap: () => _openChat(uid, item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: .7), width: .7))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Stack(children: [
            _remoteAvatar(avatar, radius: 26,
              backgroundColor: const Color(0xFFF0F0F0),
              iconColor: Theme.of(context).colorScheme.onSurfaceVariant),
            if (isRequest) Positioned(right: 0, bottom: 0, child: Container(
              width: 13, height: 13,
              decoration: BoxDecoration(color: harvestGold, shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2)),
            )),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(child: Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface))),
              if (item['ownerVerified'] == true) const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.verified_rounded, color: Color(0xFF2196F3), size: 16),
              ),
              if (isImportant) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 17)),
            ]),
            const SizedBox(height: 1),
            Text('@$username', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.fredoka(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.fredoka(fontSize: 13.5, color: isRequest ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant)),
            if (isRequest) Padding(padding: const EdgeInsets.only(top: 3),
              child: Text('Permintaan story • Ikuti kembali untuk membuka chat',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.fredoka(fontSize: 11.5, color: const Color(0xFF9A762A)))),
          ])),
          const SizedBox(width: 8),
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(lastTime, style: GoogleFonts.fredoka(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Row(mainAxisSize: MainAxisSize.min, children: [
              if (read) const Icon(Icons.done_all_rounded, size: 17, color: Color(0xFF1687E8)),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 185),
                icon: Icon(CupertinoIcons.chevron_right, size: 19, color: Theme.of(context).colorScheme.onSurfaceVariant),
                onSelected: (value) {
                  if (value == 'archive') _toggleArchive(uid);
                  if (value == 'important') _toggleImportant(uid);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'archive', child: Row(children: [
                    Icon(isArchived ? Icons.unarchive_outlined : Icons.archive_outlined, size: 19),
                    const SizedBox(width: 10), Text(isArchived ? 'Keluarkan dari arsip' : 'Arsipkan chat'),
                  ])),
                  PopupMenuItem(value: 'important', child: Row(children: [
                    Icon(isImportant ? Icons.star_outline : Icons.star, size: 19, color: const Color(0xFFFFB300)),
                    const SizedBox(width: 10), Text(isImportant ? 'Hapus dari penting' : 'Tandai penting'),
                  ])),
                ],
              ),
            ]),
          ]),
        ]),
      ),
    );
  }

  Widget _filterChip(String label, IconData icon) {
    final selected = _filter == label;
    final theme = Theme.of(context);
    final selectedColor = theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF171717);
    final selectedTextColor = theme.brightness == Brightness.dark ? const Color(0xFF171717) : Colors.white;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: selected ? selectedColor : theme.cardColor,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: () => setState(() => _filter = label),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: selected ? selectedColor : theme.dividerColor,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16,
                    color: selected ? selectedTextColor : theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.w600,
                      color: selected ? selectedTextColor : theme.colorScheme.onSurface))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.embedded ? null : AppBar(
        title: Text('Pesan', style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w600)),
        actions: [IconButton(tooltip: 'Perbarui daftar pesan', onPressed: _refresh, icon: const Icon(CupertinoIcons.refresh))],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<User?>(
          stream: _auth.authStateChanges(),
          initialData: _auth.currentUser,
          builder: (context, authSnapshot) {
            final user = authSnapshot.data;
            if (user == null) {
              return ListView(physics: const AlwaysScrollableScrollPhysics(), children: const [
                SizedBox(height: 180), Center(child: Text('Silakan masuk untuk melihat pesan.')),
              ]);
            }
            final me = user.uid;
            final chatStream = _db.collection('chats').where('participants', arrayContains: me).snapshots();
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: chatStream,
              builder: (context, chatsSnapshot) => FutureBuilder<List<Map<String, dynamic>>>(
                future: _friendsFor(me),
                builder: (context, friendsSnapshot) {
                  final contacts = <String, Map<String, dynamic>>{};
                  for (final friend in friendsSnapshot.data ?? []) {
                    final uid = (friend['uid'] ?? '').toString();
                    if (uid.isNotEmpty) contacts[uid] = Map<String, dynamic>.from(friend);
                  }
                  for (final chat in chatsSnapshot.data?.docs ?? []) {
                    final data = chat.data();
                    final raw = data['participants'];
                    if (raw is! List) continue;
                    final participants = raw.whereType<String>().toList(growable: false);
                    if (!participants.contains(me) || participants.length != 2) continue;
                    final peerUid = participants.firstWhere((id) => id != me, orElse: () => '');
                    if (peerUid.isEmpty) continue;
                    contacts.putIfAbsent(peerUid, () => {'uid': peerUid});
                    contacts[peerUid]!.addAll({
                      'chatId': chat.id,
                      'lastMessage': data['lastMessage'] ?? '',
                      'lastMessageAt': data['lastMessageAt'],
                      'requestType': data['requestType'] ?? '',
                      'lastSenderUid': data['lastSenderUid'] ?? '',
                      'lastMessageRead': data['lastMessageRead'] == true,
                    });
                  }
                  final allItems = contacts.values.toList()..sort((a, b) {
                    final av = a['lastMessageAt'] is Timestamp ? (a['lastMessageAt'] as Timestamp).millisecondsSinceEpoch : 0;
                    final bv = b['lastMessageAt'] is Timestamp ? (b['lastMessageAt'] as Timestamp).millisecondsSinceEpoch : 0;
                    return bv.compareTo(av);
                  });
                  if (!_settingsLoaded) return const Center(child: CircularProgressIndicator());
                  final filtered = allItems.where((item) {
                    final uid = (item['uid'] ?? '').toString();
                    final archived = _archived.contains(uid);
                    final important = _important.contains(uid);
                    final request = item['requestType'] == 'story_reaction' && item['friend'] != true;
                    if (_filter == 'Arsip' && !archived) return false;
                    if (_filter != 'Arsip' && archived) return false;
                    if (_filter == 'Diminta' && !request) return false;
                    if (_filter == 'Penting' && !important) return false;
                    if (_search.isNotEmpty) {
                      final haystack = ['name', 'displayName', 'username', 'lastMessage']
                        .map((key) => (item[key] ?? '').toString().toLowerCase()).join(' ');
                      if (!haystack.contains(_search)) return false;
                    }
                    return true;
                  }).toList();
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 18),
                    children: [
                      SizedBox(height: widget.embedded ? 8 : 4),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.fredoka(fontSize: 15, color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Cari pesan, pengguna, atau kata kunci...',
                            hintStyle: GoogleFonts.fredoka(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                            prefixIcon: const Icon(CupertinoIcons.search),
                            suffixIcon: _search.isEmpty ? const Icon(CupertinoIcons.slider_horizontal_3, color: Color(0xFF171717))
                              : IconButton(onPressed: _searchController.clear, icon: const Icon(Icons.close)),
                            filled: true, fillColor: theme.brightness == Brightness.dark ? const Color(0xFF242832) : const Color(0xFFF0F3F8),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                          ),
                        )),
                      const SizedBox(height: 13),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: Row(children: [
                          _filterChip('Semua', CupertinoIcons.chat_bubble_2),
                          _filterChip('Diminta', CupertinoIcons.paperplane),
                          _filterChip('Arsip', CupertinoIcons.archivebox),
                          _filterChip('Penting', CupertinoIcons.star),
                        ]),
                      ),
                      const SizedBox(height: 7),
                      if (chatsSnapshot.hasError || friendsSnapshot.hasError)
                        Padding(padding: const EdgeInsets.all(14), child: Text('Gagal memuat percakapan. Periksa koneksi atau izin Firestore.',
                          style: TextStyle(color: theme.colorScheme.error))),
                      if (filtered.isEmpty)
                        Padding(padding: const EdgeInsets.fromLTRB(26, 54, 26, 40), child: Column(children: [
                          Icon(_filter == 'Arsip' ? CupertinoIcons.archivebox : CupertinoIcons.chat_bubble_text,
                            size: 43, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(height: 10),
                          Text(_search.isNotEmpty ? 'Tidak ada hasil pencarian' : _filter == 'Arsip' ? 'Arsip masih kosong' : _filter == 'Penting' ? 'Belum ada chat penting' : 'Belum ada pesan',
                            style: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                          const SizedBox(height: 5),
                          Text(_search.isNotEmpty ? 'Coba kata kunci lain.' : 'Percakapan dan permintaan story akan muncul di sini.',
                            textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                        ])),
                      for (final item in filtered)
                        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future: (item['name'] != null || item['username'] != null)
                            ? null : _db.collection('public_profiles').doc((item['uid'] ?? '').toString()).get(),
                          builder: (context, profileSnapshot) => _contactTile({
                            ...?profileSnapshot.data?.data(),
                            ...item,
                          }),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class LikedPostsPage extends StatelessWidget {
  const LikedPostsPage({super.key});

  Future<List<Map<String, String>>> _loadLiked() async {
    final uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return [];
    final posts = await _db.collection('activity_posts').orderBy('createdAt', descending: true).get().timeout(const Duration(seconds: 15));
    final likedDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (final post in posts.docs) {
      final ownLike = await post.reference.collection('likes').doc(uid).get();
      if (ownLike.exists) likedDocs.add(post);
    }
    final missingAvatarOwners = likedDocs
        .where((post) => _firstImageUrl(post.data(),
            const ['avatarUrl', 'photoURL', 'photoUrl', 'photo']).isEmpty)
        .map((post) => (post.data()['ownerUid'] ?? '').toString());
    final fallbackAvatars = await _loadAvatarsForUsers(missingAvatarOwners);
    return likedDocs.map((post) {
      final data = post.data();
      final ownerUid = (data['ownerUid'] ?? '').toString();
      final storedAvatar = _firstImageUrl(data,
          const ['avatarUrl', 'photoURL', 'photoUrl', 'photo']);
      return <String, String>{
        'id': post.id, 'uid': ownerUid,
        'email': (data['email'] ?? '').toString(),
        'author': (data['author'] ?? 'Warga Kalbar').toString(),
        'username': (data['username'] ?? 'warga').toString(),
        'avatarUrl': storedAvatar.isNotEmpty ? storedAvatar : (fallbackAvatars[ownerUid] ?? ''),
        'body': (data['body'] ?? '').toString(),
        'imagePath': (data['imageUrl'] ?? '').toString(),
        'date': (data['date'] ?? '').toString(),
        'comments': jsonEncode(data['comments'] ?? []),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Disukai', style: TextStyle(fontWeight: FontWeight.w900))),
    body: FutureBuilder<List<Map<String, String>>>(
      future: _loadLiked(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Favorit belum dapat dimuat: ${snapshot.error}')));
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) return const Center(child: Text('Belum ada postingan yang kamu sukai.'));
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: posts.map((post) => _ActivityPostCard(
            post: post,
            onComments: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityCommentsPage(postId: post['id'] ?? ''))),
          )).toList(),
        );
      },
    ),
  );
}

class ChatThreadPage extends StatefulWidget {
  final String peerUid;
  final Map<String, dynamic> initialProfile;
  final bool donorContact;
  final String donorPostId;
  const ChatThreadPage({super.key, required this.peerUid, this.initialProfile = const {}, this.donorContact = false, this.donorPostId = ''});
  @override
  State<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<ChatThreadPage> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  final _recorder = AudioRecorder();
  late final String _myUid;
  late final String _chatId;
  late String _wallpaper;
  int _bubbleColorIndex = 0;
  Map<String, dynamic> _peer = {};
  bool _friend = false;
  bool _donorContactChat = false;
  String _donorPostId = '';
  bool get _canChat => _friend || _donorContactChat;
  bool _followingPeer = false;
  bool _checking = false;
  bool _sending = false;
  bool _recording = false;
  String _recordPath = '';
  final Set<String> _selectedMessageIds = <String>{};

  @override
  void initState() {
    super.initState();
    _myUid = _auth.currentUser?.uid ?? '';
    _chatId = _chatIdFor(_myUid, widget.peerUid);
    _peer = Map<String, dynamic>.from(widget.initialProfile);
    _friend = _peer['friend'] == true;
    _donorContactChat = widget.donorContact;
    _donorPostId = widget.donorPostId;
    _checking = true;
    _wallpaper = Store.prefs?.getString('chat_wallpaper_$_chatId') ?? 'preset:0';
    _bubbleColorIndex = ((Store.prefs?.getInt('chat_bubble_$_chatId') ?? 0)
        .clamp(0, _chatBubbleColors.length - 1)).toInt();
    _loadPeer();
  }

  Future<void> _loadPeer() async {
    try {
      final results = await Future.wait<DocumentSnapshot<Map<String, dynamic>>>([
        _db.collection('public_profiles').doc(widget.peerUid).get(),
        _db.collection('follows').doc('${_myUid}_${widget.peerUid}').get(),
        _db.collection('follows').doc('${widget.peerUid}_$_myUid').get(),
        _db.collection('chats').doc(_chatId).get(),
      ]);
      final publicProfile = results[0];
      final ownFollow = results[1];
      final reverseFollow = results[2];
      final chat = results[3];
      final publicData = publicProfile.data() ?? <String, dynamic>{};
      var avatar = _firstImageUrl(publicData,
          const ['avatarUrl', 'photoURL', 'photoUrl', 'photo', 'imageUrl']);
      if (avatar.isEmpty) {
        avatar = ( _peer['avatarUrl'] ?? '').toString();
      }
      if (avatar.isEmpty) {
        avatar = (await _loadAvatarsForUsers([widget.peerUid]))[widget.peerUid] ?? '';
      }
      final chatData = chat.data() ?? <String, dynamic>{};
      if (!mounted) return;
      setState(() {
        // Only public_profiles is readable for other members. A private
        // profiles.get here denied the entire Future.wait for normal accounts.
        _peer = {
          ..._peer,
          ...publicData,
          'uid': widget.peerUid,
          if (avatar.isNotEmpty) 'avatarUrl': avatar,
        };
        _friend = ownFollow.exists && reverseFollow.exists;
        if (chatData['requestType'] == 'donor_contact') {
          _donorContactChat = true;
          if (_donorPostId.isEmpty) _donorPostId = (chatData['donorPostId'] ?? '').toString();
        }
        _followingPeer = ownFollow.exists;
        _checking = false;
      });
    } catch (_) {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _followPeer() async {
    if (_followingPeer || _myUid.isEmpty) return;
    try {
      await _db.collection('follows').doc('${_myUid}_${widget.peerUid}').set({
        'followerUid': _myUid,
        'followingUid': widget.peerUid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      unawaited(_dispatchSocialNotification(type: 'follow', id: widget.peerUid, itemId: DateTime.now().microsecondsSinceEpoch.toString()));
      if (mounted) {
        setState(() => _followingPeer = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kamu sudah mengikuti akun ini. Chat terbuka setelah dia mengikuti balik.')),
        );
      }
      await _loadPeer();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengikuti akun: $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    unawaited(_recorder.dispose());
    super.dispose();
  }

  Future<void> _writeMessage(String type, {String text = '', String url = '', String fileName = '', Map<String, dynamic> extra = const {}, bool alreadySending = false}) async {
    if (!_canChat || _myUid.isEmpty || widget.peerUid.isEmpty || (_sending && !alreadySending)) return;
    if (!alreadySending) setState(() => _sending = true);
    var stage = _donorContactChat ? 'memeriksa postingan donor' : 'memeriksa pertemanan';
    try {
      if (_donorContactChat) {
        if (_donorPostId.isEmpty) throw Exception('Postingan donor tidak ditemukan. Buka chat dari tombol Hubungi pada daftar donor.');
      } else if (!await _areMutualFriends(_myUid, widget.peerUid)) {
        throw Exception('Chat hanya tersedia untuk anggota yang saling mengikuti.');
      }
      final chatRef = _db.collection('chats').doc(_chatId);
      stage = 'memeriksa percakapan';
      final existing = await chatRef.get();
      final participants = _chatParticipantsFor(_myUid, widget.peerUid);
      final storedParticipants = List<String>.from(existing.data()?['participants'] ?? const <String>[]);
      if (existing.exists && (storedParticipants.length != 2 || !storedParticipants.contains(_myUid) || !storedParticipants.contains(widget.peerUid))) {
        throw Exception('Data peserta chat tidak cocok. Muat ulang percakapan.');
      }

      // Do not rewrite participants on an existing chat. Older chat documents
      // may store the same two UIDs in the opposite order, and rewriting that
      // array makes the strict participant-preservation rule reject the update.
      stage = 'memperbarui ringkasan percakapan';
      await chatRef.set({
        if (!existing.exists) 'participants': participants,
        if (!existing.exists) 'initiatedByUid': _myUid,
        if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
        'requestType': _donorContactChat ? 'donor_contact' : 'friend',
        if (_donorContactChat) 'donorPostId': _donorPostId,
        'lastMessage': type == 'text' ? text : type == 'image' ? (text.trim().isEmpty ? '📷 Foto' : '📷 $text') :
          type == 'audio' ? '🎤 Pesan suara' : type == 'location' ? '📍 Lokasi' : '📎 $fileName',
        'lastSenderUid': _myUid,
        'lastMessageRead': false,
        'lastMessageAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      stage = 'menyimpan pesan';
      final messageRef = chatRef.collection('messages').doc();
      await messageRef.set({
        'senderUid': _myUid, 'receiverUid': widget.peerUid, 'type': type,
        'text': text, 'url': url, 'fileName': fileName, ...extra,
        'createdAt': FieldValue.serverTimestamp(), 'read': false,
      });
      unawaited(_dispatchSocialNotification(type: 'chat', id: _chatId, itemId: messageRef.id));
      _text.clear();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pesan gagal dikirim saat $stage: $error')),
        );
      }
    } finally {
      if (mounted && !alreadySending) setState(() => _sending = false);
    }
  }

  Future<void> _pickImage({required bool camera}) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 55, maxWidth: 1024, maxHeight: 1024);
      if (picked == null || !mounted) return;
      final result = await Navigator.push<ChatPhotoResult>(
        context, MaterialPageRoute(builder: (_) => ChatPhotoComposerPage(imagePath: picked.path)),
      );
      if (result == null || !mounted) return;
      setState(() => _sending = true);
      final url = await Store.uploadImage(result.path, 'chat_images');
      await _writeMessage('image', url: url, text: result.caption, fileName: 'Foto',
        extra: {'viewOnce': result.viewOnce, 'viewedBy': <String>[]}, alreadySending: true);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto gagal dikirim: $error')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickDocument() async {
    try {
      final picked = await FilePicker.platform.pickFiles(type: FileType.any);
      final file = picked?.files.single;
      if (file?.path == null) return;
      setState(() => _sending = true);
      final url = await _uploadChatRawFile(file!.path!, 'chat_files');
      setState(() => _sending = false);
      await _writeMessage('file', url: url, fileName: file.name);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berkas gagal dikirim: $error')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) throw Exception('Izin lokasi belum diberikan.');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 20));
      final url = 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
      await _writeMessage('location', text: 'Lokasi saya', url: url, extra: {
        'latitude': position.latitude, 'longitude': position.longitude,
      });
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lokasi gagal dibagikan: $error')));
    }
  }

  DateTime? _recordStartedAt;

  Future<void> _startVoiceRecording() async {
    if (!_canChat || _sending || _recording) return;
    try {
      if (!await _recorder.hasPermission()) throw Exception('Izin mikrofon belum diberikan.');
      final dir = await getTemporaryDirectory();
      _recordPath = '${dir.path}/kalbar_voice_${DateTime.now().microsecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: _recordPath,
      );
      _recordStartedAt = DateTime.now();
      if (mounted) setState(() => _recording = true);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rekaman suara tidak dapat dimulai: $error')));
    }
  }

  Future<void> _stopVoiceRecording() async {
    if (!_recording || _sending) return;
    try {
      final elapsed = DateTime.now().difference(_recordStartedAt ?? DateTime.now());
      final path = await _recorder.stop();
      if (mounted) setState(() => _recording = false);
      final recordedPath = path ?? _recordPath;
      if (recordedPath.isEmpty || !await File(recordedPath).exists()) {
        throw Exception('File rekaman tidak ditemukan. Coba rekam ulang.');
      }
      if (elapsed < const Duration(seconds: 1)) {
        try { await File(recordedPath).delete(); } catch (_) {}
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesan suara minimal 1 detik. Tahan tombol lebih lama.')));
        return;
      }
      final send = await _previewVoice(recordedPath, elapsed);
      if (send != true || !mounted) {
        try { await File(recordedPath).delete(); } catch (_) {}
        return;
      }
      setState(() => _sending = true);
      final url = await _uploadChatRawFile(recordedPath, 'chat_voice', audio: true);
      await _writeMessage(
        'audio',
        url: url,
        fileName: 'Pesan suara',
        extra: {'durationMs': elapsed.inMilliseconds, 'format': 'm4a'},
        alreadySending: true,
      );
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pesan suara gagal dikirim: $error')));
    } finally {
      if (mounted) setState(() { _recording = false; _sending = false; });
    }
  }

  Future<bool?> _previewVoice(String path, Duration duration) async {
    final player = AudioPlayer();
    var playing = false;
    try {
      return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pratinjau pesan suara'),
          content: Row(children: [
            IconButton.filledTonal(
              onPressed: () async {
                try {
                  if (playing) { await player.pause(); setDialogState(() => playing = false); }
                  else {
                    await player.play(DeviceFileSource(path));
                    setDialogState(() => playing = true);
                    player.onPlayerComplete.first.then((_) {
                      if (dialogContext.mounted) setDialogState(() => playing = false);
                    });
                  }
                } catch (_) {}
              },
              icon: Icon(playing ? Icons.pause_rounded : CupertinoIcons.play_arrow_solid),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('Pesan suara • ${duration.inSeconds} detik')),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Hapus')),
            FilledButton.icon(onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(CupertinoIcons.paperplane_fill), label: const Text('Kirim')),
          ],
        )),
      );
    } finally {
      await player.dispose();
    }
  }

  Future<void> _chooseWallpaper() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              const Text('Tema chat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text('Atur warna gelembung dan latar percakapan.',
                style: TextStyle(color: Theme.of(sheetContext).colorScheme.onSurfaceVariant, fontSize: 12)),
              const SizedBox(height: 20),
              const Text('Gelembung obrolan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(spacing: 14, runSpacing: 12, children: [
                for (var i = 0; i < _chatBubbleColors.length; i++)
                  InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => Navigator.pop(sheetContext, 'bubble:$i'),
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: _chatBubbleColors[i],
                        border: Border.all(color: _bubbleColorIndex == i ? forest : Theme.of(sheetContext).dividerColor,
                          width: _bubbleColorIndex == i ? 3 : 1)),
                      child: _bubbleColorIndex == i ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  ),
              ]),
              const SizedBox(height: 22),
              Row(children: [
                const Expanded(child: Text('Wallpaper', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14))),
                TextButton.icon(
                  onPressed: () => Navigator.pop(sheetContext, 'gallery'),
                  icon: const Icon(CupertinoIcons.photo, size: 18),
                  label: const Text('Unggah sendiri'),
                ),
              ]),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.25,
                children: [
                  for (var i = 0; i < _chatWallpaperColors.length; i++)
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pop(sheetContext, 'preset:$i'),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: _chatWallpaperGradients[i],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _wallpaper == 'preset:$i' ? forest : Theme.of(sheetContext).dividerColor,
                            width: _wallpaper == 'preset:$i' ? 3 : 1),
                        ),
                        child: _wallpaper == 'preset:$i'
                          ? const Align(alignment: Alignment.topRight, child: Padding(
                              padding: EdgeInsets.all(7), child: Icon(Icons.check_circle, color: forest)))
                          : const SizedBox.shrink(),
                      ),
                    ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
    if (choice == null) return;
    if (choice.startsWith('bubble:')) {
      _bubbleColorIndex = int.tryParse(choice.substring(7)) ?? 0;
      await Store.prefs?.setInt('chat_bubble_$_chatId', _bubbleColorIndex);
      if (mounted) setState(() {});
      return;
    }
    if (choice == 'gallery') {
      try {
        final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 55, maxWidth: 1024, maxHeight: 1024);
        if (image == null) return;
        final path = await LocalMedia.save(image.path, 'chat_wallpapers', 'jpg');
        _wallpaper = 'file:$path';
      } catch (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wallpaper gagal dipilih: $error')));
        return;
      }
    } else {
      _wallpaper = choice;
    }
    await Store.prefs?.setString('chat_wallpaper_$_chatId', _wallpaper);
    if (mounted) setState(() {});
  }

  void _openAttachmentSheet() {
    showModalBottomSheet<void>(
      context: context, showDragHandle: true, backgroundColor: Theme.of(context).cardColor,
      builder: (sheetContext) => SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: GridView.count(
          crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16, crossAxisSpacing: 8,
          children: [
            _AttachmentOption(icon: Icons.photo_library_rounded, color: Colors.blue, label: 'Galeri', onTap: () { Navigator.pop(sheetContext); _pickImage(camera: false); }),
            _AttachmentOption(icon: Icons.camera_alt_rounded, color: Colors.pink, label: 'Kamera', onTap: () { Navigator.pop(sheetContext); _pickImage(camera: true); }),
            _AttachmentOption(icon: Icons.location_on_rounded, color: Colors.teal, label: 'Lokasi', onTap: () { Navigator.pop(sheetContext); _sendLocation(); }),
            _AttachmentOption(icon: Icons.insert_drive_file_rounded, color: Colors.deepPurple, label: 'Dokumen', onTap: () { Navigator.pop(sheetContext); _pickDocument(); }),
          ],
        ),
      )),
    );
  }

  Future<void> _deleteChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus percakapan?'),
        content: const Text('Semua pesan dan percakapan ini akan dihapus untuk kedua peserta. Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    var stage = 'memeriksa hak akses chat';
    try {
      final ref = _db.collection('chats').doc(_chatId);
      final chatSnapshot = await ref.get();
      final participants = List<String>.from(chatSnapshot.data()?['participants'] ?? const []);
      final uid = _auth.currentUser?.uid ?? '';
      if (!chatSnapshot.exists || uid.isEmpty || !participants.contains(uid)) {
        throw Exception('Akun ini bukan peserta percakapan tersebut. Keluar lalu masuk kembali untuk menyegarkan sesi.');
      }

      stage = 'menghapus pesan';
      final messagesRef = ref.collection('messages');
      while (true) {
        final page = await messagesRef.limit(10).get();
        if (page.docs.isEmpty) break;
        final batch = _db.batch();
        for (final doc in page.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      stage = 'menghapus percakapan';
      await ref.delete();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Percakapan dan semua pesannya berhasil dihapus.')),
        );
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal $stage (${error.code}): ${error.message ?? 'Periksa Firestore Rules Firebase.'}")),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal $stage: $error')),
        );
      }
    }
  }

  void _showMenu(String value) {
    if (value == 'wallpaper') _chooseWallpaper();
    if (value == 'delete_chat') _deleteChat();
    if (value == 'details') {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Info kontak'),
          content: Text('${_peer['name'] ?? 'Pengguna Kalbar Kite'}\n@${_peer['username'] ?? 'warga'}\n${_peer['phone'] ?? ''}'),
          actions: [FilledButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Tutup'))],
        ),
      );
    }
  }

  Widget _wallpaperLayer() {
    if (_wallpaper.startsWith('file:')) {
      final path = _wallpaper.substring(5);
      if (File(path).existsSync()) return Positioned.fill(child: Image.file(File(path), fit: BoxFit.cover));
    }
    final index = _wallpaper.startsWith('preset:')
      ? (int.tryParse(_wallpaper.substring(7)) ?? 0).clamp(0, _chatWallpaperGradients.length - 1).toInt() : 0;
    return Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: _chatWallpaperGradients[index])));
  }

  Future<void> _openViewOnceImage(String messageId, String url) async {
    try {
      final ref = _db.collection('chats').doc(_chatId).collection('messages').doc(messageId);
      await ref.update({'viewedBy': FieldValue.arrayUnion([_myUid])});
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.black, insetPadding: const EdgeInsets.all(12),
          child: Stack(children: [
            InteractiveViewer(child: Image.network(url, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Padding(padding: EdgeInsets.all(24),
                child: Icon(Icons.broken_image_outlined, color: Colors.white, size: 42)))),
            Positioned(right: 4, top: 4, child: IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
            )),
          ]),
        ),
      );
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto sekali lihat gagal dibuka: $error')));
    }
  }

  void _selectMessage(String messageId) {
    if (!mounted) return;
    setState(() => _selectedMessageIds.add(messageId));
  }

  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (!_selectedMessageIds.add(messageId)) _selectedMessageIds.remove(messageId);
    });
  }

  Future<void> _deleteSelectedMessages() async {
    if (_selectedMessageIds.isEmpty) return;
    final ids = _selectedMessageIds.toList(growable: false);
    final refs = ids.map((id) => _db.collection('chats').doc(_chatId).collection('messages').doc(id)).toList();
    final snapshots = await Future.wait(refs.map((ref) => ref.get()));
    final allMine = snapshots.every((snapshot) => snapshot.exists && snapshot.data()?['senderUid'] == _myUid);
    if (!mounted) return;
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus pesan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, 'cancel'), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, 'me'), child: const Text('Hapus untuk saya')),
          if (allMine) FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, 'everyone'),
            child: const Text('Hapus untuk semua orang')),
        ],
      ),
    );
    if (choice == null || choice == 'cancel' || !mounted) return;
    try {
      final batch = _db.batch();
      for (final ref in refs) {
        if (choice == 'everyone') {
          batch.delete(ref);
        } else {
          batch.update(ref, {'hiddenFor': FieldValue.arrayUnion([_myUid])});
        }
      }
      await batch.commit();
      if (mounted) setState(() => _selectedMessageIds.clear());
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pesan gagal dihapus: $error')),
        );
      }
    }
  }

  void _markIncomingMessagesRead(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final unread = docs.where((doc) {
      final data = doc.data();
      return data['receiverUid'] == _myUid && data['read'] != true;
    }).take(450).toList(growable: false);

    if (unread.isNotEmpty) {
      final batch = _db.batch();
      for (final doc in unread) {
        batch.update(doc.reference, {'read': true});
      }
      unawaited(batch.commit().catchError((_) {}));
    }

    final chatRef = _db.collection('chats').doc(_chatId);
    unawaited(chatRef.get().then<void>((snapshot) async {
      final data = snapshot.data();
      if (snapshot.exists &&
          data?['lastSenderUid'] != _myUid &&
          data?['lastMessageRead'] != true) {
        await chatRef.update({'lastMessageRead': true});
      }
    }).catchError((_) {}));
  }

  Widget _messageBubble(Map<String, dynamic> data) {
    final mine = data['senderUid'] == _myUid;
    final type = (data['type'] ?? 'text').toString();
    final text = (data['text'] ?? '').toString();
    final url = (data['url'] ?? '').toString();
    final fileName = (data['fileName'] ?? 'Lampiran').toString();
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final bubbleColor = mine
        ? (dark ? const Color(0xFFE7E7E7) : const Color(0xFF171717))
        : (dark ? const Color(0xFF292929) : Colors.white);
    final foreground = mine
        ? (dark ? const Color(0xFF171717) : Colors.white)
        : theme.colorScheme.onSurface;
    Widget content;
    if (type == 'image' && url.startsWith('https://')) {
      final viewOnce = data['viewOnce'] == true;
      final viewedBy = List<String>.from(data['viewedBy'] ?? const <String>[]);
      final messageId = (data['_messageId'] ?? '').toString();
      final alreadyViewed = viewedBy.contains(_myUid);
      if (viewOnce && !mine && alreadyViewed) {
        content = const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.visibility_off_outlined), SizedBox(width: 8), Text('Foto sekali lihat sudah dibuka'),
        ]);
      } else if (viewOnce && !mine) {
        content = InkWell(
          onTap: messageId.isEmpty ? null : () => _openViewOnceImage(messageId, url),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.image_search_outlined, size: 28), SizedBox(width: 9),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Foto sekali lihat', style: TextStyle(fontWeight: FontWeight.w800)),
              Text('Ketuk untuk membuka', style: TextStyle(fontSize: 11)),
            ]),
          ]),
        );
      } else if (viewOnce && mine) {
        content = Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 31, height: 31,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: foreground.withValues(alpha: .8), width: 2),
            ),
            child: Center(child: Text('1', style: TextStyle(color: foreground, fontSize: 17, fontWeight: FontWeight.w900))),
          ),
          const SizedBox(width: 9),
          Text('Foto', style: TextStyle(color: foreground, fontSize: 15, fontWeight: FontWeight.w800)),
        ]);
      } else {
        content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(borderRadius: BorderRadius.circular(10),
            child: Image.network(url, width: 250, height: 190, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Padding(padding: EdgeInsets.all(14), child: Icon(Icons.broken_image_outlined)))),
          if (text.trim().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 7),
            child: Text(text, style: TextStyle(color: foreground, fontSize: 14, height: 1.35))),
        ]);
      }
    } else if (type == 'audio' && url.startsWith('https://')) {
      content = _ChatAudioBubble(url: url, mine: mine);
    } else if (type == 'file' && url.startsWith('https://')) {
      content = InkWell(
        onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        borderRadius: BorderRadius.circular(9),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 230),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: foreground.withValues(alpha: .18), width: .45),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.insert_drive_file_outlined, color: foreground, size: 20),
            const SizedBox(width: 7),
            Flexible(child: Text(fileName, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: foreground, fontSize: 14, fontWeight: FontWeight.w600))),
            const SizedBox(width: 4), Icon(Icons.open_in_new, size: 13, color: foreground.withValues(alpha: .7)),
          ]),
        ),
      );
    } else if (type == 'location' && url.startsWith('https://')) {
      final latitude = (data['latitude'] as num?)?.toDouble();
      final longitude = (data['longitude'] as num?)?.toDouble();
      content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (latitude != null && longitude != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 230,
              height: 140,
              child: MapLibreMap(
                styleString: 'https://tiles.openfreemap.org/styles/liberty',
                initialCameraPosition: CameraPosition(
                  target: LatLng(latitude, longitude),
                  zoom: 15,
                ),
                compassEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                myLocationEnabled: false,
              ),
            ),
          ),
        const SizedBox(height: 6),
        InkWell(onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.location_on_rounded, color: foreground, size: 20),
            const SizedBox(width: 6),
            Text('Buka di peta', style: TextStyle(color: foreground, fontWeight: FontWeight.w800)),
            const SizedBox(width: 5), Icon(Icons.open_in_new, size: 14, color: foreground.withValues(alpha: .7)),
          ])),
      ]);
    } else if (type == 'story_reaction') {
      content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Reaksi story', style: TextStyle(color: foreground.withValues(alpha: .78), fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3), Text(text, style: const TextStyle(fontSize: 31)),
      ]);
    } else {
      content = Text(text, style: TextStyle(color: foreground, fontSize: 14, height: 1.35));
    }
    final stamp = data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate().toLocal() : null;
    final time = stamp == null ? '' : '${stamp.hour.toString().padLeft(2, '0')}.${stamp.minute.toString().padLeft(2, '0')}';
    final messageId = (data['_messageId'] ?? '').toString();
    final selected = _selectedMessageIds.contains(messageId);
    final photoOnly = type == 'image' && url.startsWith('https://') &&
        data['viewOnce'] != true && text.trim().isEmpty;
    final viewOnceOutgoing = type == 'image' && data['viewOnce'] == true && mine;
    return GestureDetector(
      onLongPress: messageId.isEmpty ? null : () => _selectMessage(messageId),
      onTap: _selectedMessageIds.isEmpty || messageId.isEmpty ? null : () => _toggleMessageSelection(messageId),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .86),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          padding: photoOnly ? EdgeInsets.zero : const EdgeInsets.fromLTRB(5, 3, 5, 2),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary.withValues(alpha: .18) : bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(13), topRight: const Radius.circular(13),
              bottomLeft: Radius.circular(mine ? 13 : 4), bottomRight: Radius.circular(mine ? 4 : 13),
            ),
            border: Border.all(
              color: selected ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha: mine ? .12 : .55),
              width: selected ? 1.2 : .25,
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (photoOnly)
              Stack(alignment: Alignment.bottomRight, children: [
                content,
                if (time.isNotEmpty)
                  Positioned(right: 5, bottom: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .52),
                        borderRadius: BorderRadius.circular(7)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(time, style: const TextStyle(color: Colors.white, fontSize: 9)),
                        if (mine) ...[
                          const SizedBox(width: 3),
                          Icon(data['read'] == true ? Icons.done_all_rounded : Icons.done_rounded,
                            size: 12, color: data['read'] == true ? const Color(0xFF54B5FF) : Colors.white70),
                        ],
                      ]),
                    )),
              ])
            else if (viewOnceOutgoing && time.isNotEmpty)
              Row(mainAxisSize: MainAxisSize.min, children: [
                content,
                const SizedBox(width: 12),
                Text(time, style: TextStyle(color: foreground.withValues(alpha: .7), fontSize: 9)),
                const SizedBox(width: 3),
                Icon(data['read'] == true ? Icons.done_all_rounded : Icons.done_rounded,
                  size: 13, color: data['read'] == true ? const Color(0xFF1687E8) : foreground.withValues(alpha: .55)),
              ])
            else content,
            if (time.isNotEmpty && !photoOnly && !viewOnceOutgoing) Padding(padding: const EdgeInsets.only(top: 3),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(time, style: TextStyle(color: foreground.withValues(alpha: .7), fontSize: 9)),
                if (mine) ...[
                  const SizedBox(width: 3),
                  Icon(data['read'] == true ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 13, color: data['read'] == true ? const Color(0xFF1687E8) : foreground.withValues(alpha: .55)),
                ],
              ])),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = (_peer['name'] ?? _peer['displayName'] ?? 'Pengguna Kalbar Kite').toString();
    final avatar = (_peer['avatarUrl'] ?? '').toString();
    final chatRef = _db.collection('chats').doc(_chatId);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 42, titleSpacing: 0,
        title: _selectedMessageIds.isNotEmpty
          ? Text('${_selectedMessageIds.length}', style: const TextStyle(fontWeight: FontWeight.w800))
          : InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PublicProfilePage(uid: widget.peerUid),
                ));
              },
              child: Row(children: [
                _remoteAvatar(avatar, radius: 19,
                  backgroundColor: pale, iconColor: forest),
                const SizedBox(width: 9),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900))),
                    if (_peer['ownerVerified'] == true)
                      const Padding(padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.verified_rounded, color: Color(0xFF2196F3), size: 16)),
                  ]),
                  Text(_lastSeenText(_peer['lastSeenAt']), maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ])),
              ]),
            ),
        actions: _selectedMessageIds.isNotEmpty ? [
          IconButton(tooltip: 'Hapus pesan', onPressed: _deleteSelectedMessages,
            icon: const Icon(CupertinoIcons.delete)),
          IconButton(tooltip: 'Batal memilih', onPressed: () => setState(() => _selectedMessageIds.clear()),
            icon: const Icon(CupertinoIcons.xmark)),
        ] : [
          if (!_canChat && !_checking)
            IconButton(
              tooltip: _followingPeer ? 'Menunggu dia mengikuti balik' : 'Ikuti untuk membuka chat',
              onPressed: _followingPeer ? null : _followPeer,
              icon: Icon(_followingPeer ? Icons.hourglass_top_rounded : Icons.person_add_alt_1_rounded),
            ),
          PopupMenuButton<String>(
            onSelected: _showMenu,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'wallpaper', child: ListTile(leading: Icon(Icons.palette_outlined), title: Text('Tema chat'))),
              PopupMenuItem(value: 'details', child: ListTile(leading: Icon(CupertinoIcons.info), title: Text('Info kontak'))),
              PopupMenuItem(value: 'delete_chat', child: ListTile(leading: Icon(CupertinoIcons.trash, color: Colors.redAccent), title: Text('Hapus chat'))),
            ],
          ),
        ],
      ),
      body: Stack(children: [
        _wallpaperLayer(),
        Column(children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: chatRef.collection('messages').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Padding(padding: const EdgeInsets.all(24),
                    child: Text('Pesan belum dapat dimuat. Periksa Firestore Rules.\n${snapshot.error}', textAlign: TextAlign.center)));
                }
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return Center(child: Padding(padding: const EdgeInsets.all(24),
                    child: Text('Percakapan siap. Pesan akan muncul saat tersinkron.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))));
                }
                final docs = (snapshot.data?.docs ?? []).where((doc) {
                  final hiddenFor = List<String>.from(doc.data()['hiddenFor'] ?? const <String>[]);
                  return !hiddenFor.contains(_myUid);
                }).toList();
                _markIncomingMessagesRead(docs);
                if (docs.isEmpty) {
                  return Center(child: Padding(padding: const EdgeInsets.all(26),
                    child: Text(_canChat ? 'Mulai percakapan dengan sopan.' : 'Reaksi story hanya bisa dikirim satu kali. Untuk mulai chat biasa, kalian harus saling mengikuti.',
                      textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.45))));
                }
                return ListView(reverse: true, controller: _scroll, padding: const EdgeInsets.symmetric(vertical: 12),
                  children: docs.map((doc) => _messageBubble({...doc.data(), '_messageId': doc.id})).toList());
              },
            ),
          ),
          if (_checking)
            const LinearProgressIndicator(minHeight: 2)
          else if (!_canChat)
            Container(
              width: double.infinity, padding: const EdgeInsets.fromLTRB(18, 13, 18, 17),
              color: Theme.of(context).cardColor,
              child: const Text('Pesan belum bisa dikirim. Ikuti satu sama lain terlebih dahulu atau buka chat dari tombol Hubungi donor.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            )
          else
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 7), color: Colors.transparent,
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  IconButton(tooltip: 'Lampiran dan media', onPressed: _sending ? null : _openAttachmentSheet, icon: const Icon(CupertinoIcons.plus)),
                  Expanded(child: Container(
                    constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(25)),
                    child: TextField(
                      controller: _text, minLines: 1, maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(hintText: 'Ketik pesan', filled: false, fillColor: Colors.transparent,
                        border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                        isCollapsed: true, contentPadding: EdgeInsets.symmetric(vertical: 10)),
                      onChanged: (_) { if (mounted) setState(() {}); },
                      onSubmitted: (_) => _writeMessage('text', text: _text.text),
                    ),
                  )),
                  if (_text.text.trim().isEmpty)
                    GestureDetector(
                      onLongPressStart: _sending ? null : (_) => _startVoiceRecording(),
                      onLongPressEnd: _sending ? null : (_) => _stopVoiceRecording(),
                      child: Container(width: 44, height: 44, alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _recording ? Colors.redAccent.withValues(alpha: .12) : Colors.transparent,
                          shape: BoxShape.circle),
                        child: Icon(_recording ? CupertinoIcons.mic_fill : CupertinoIcons.mic,
                          color: _recording ? Colors.redAccent : forest)),
                    )
                  else
                    IconButton.filled(tooltip: 'Kirim pesan', onPressed: _sending ? null : () => _writeMessage('text', text: _text.text),
                      icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(CupertinoIcons.arrow_up_circle_fill)),
                ]),
              ),
            ),
        ]),
      ]),
    );
  }
}

class ChatPhotoResult {
  final String path;
  final String caption;
  final bool viewOnce;
  const ChatPhotoResult({required this.path, required this.caption, required this.viewOnce});
}

class ChatPhotoComposerPage extends StatefulWidget {
  final String imagePath;
  const ChatPhotoComposerPage({super.key, required this.imagePath});
  @override
  State<ChatPhotoComposerPage> createState() => _ChatPhotoComposerPageState();
}

class _ChatPhotoComposerPageState extends State<ChatPhotoComposerPage> {
  final _caption = TextEditingController();
  final _paintKey = GlobalKey();
  String _path = '';
  bool _drawing = false;
  bool _viewOnce = false;
  bool _exporting = false;
  Color _color = Colors.red;
  final List<Offset?> _points = [];
  static const _colors = <Color>[
    Colors.red, Colors.orange, Colors.yellow, Colors.green,
    Colors.blue, Colors.purple, Colors.white, Colors.black,
  ];

  @override
  void initState() { super.initState(); _path = widget.imagePath; }
  @override
  void dispose() { _caption.dispose(); super.dispose(); }

  Future<void> _crop() async {
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: _path,
        maxWidth: 1600,
        maxHeight: 1600,
        compressQuality: 85,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(toolbarTitle: 'Potong foto', toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white, backgroundColor: Colors.black,
            activeControlsWidgetColor: Colors.white, lockAspectRatio: false),
          IOSUiSettings(title: 'Potong foto'),
        ],
      );
      if (cropped != null && mounted) setState(() { _path = cropped.path; _points.clear(); });
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto gagal dipotong: $error')));
    }
  }

  Future<String> _exportEditedImage() async {
    if (_points.isEmpty) return _path;
    final boundary = _paintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return _path;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) return _path;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/kalbar_chat_edit_${DateTime.now().microsecondsSinceEpoch}.png');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file.path;
  }

  Future<void> _send() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final path = await _exportEditedImage();
      if (!mounted) return;
      Navigator.pop(context, ChatPhotoResult(
        path: path, caption: _caption.text.trim(), viewOnce: _viewOnce,
      ));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto gagal disiapkan: $error')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black, foregroundColor: Colors.white,
      leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(CupertinoIcons.xmark)),
      actions: [
        IconButton(tooltip: 'Potong foto', onPressed: _crop, icon: const Icon(Icons.crop)),
        IconButton(tooltip: 'Coret foto', onPressed: () => setState(() => _drawing = !_drawing),
          icon: Icon(Icons.edit, color: _drawing ? Colors.amber : Colors.white)),
      ],
    ),
    body: SafeArea(child: Column(children: [
      if (_drawing) SizedBox(height: 46, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (final color in _colors) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: InkWell(onTap: () => setState(() => _color = color), child: Container(
            width: 27, height: 27,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle,
              border: Border.all(color: _color == color ? Colors.white : Colors.white38, width: _color == color ? 3 : 1)),
          )),
        ),
        IconButton(onPressed: () => setState(() => _points.clear()),
          icon: const Icon(CupertinoIcons.trash, color: Colors.white)),
      ])),
      Expanded(child: Center(child: RepaintBoundary(
        key: _paintKey,
        child: LayoutBuilder(builder: (context, constraints) => SizedBox(
          width: constraints.maxWidth, height: constraints.maxHeight,
          child: Stack(fit: StackFit.expand, children: [
            Image.file(File(_path), fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 48))),
            if (_drawing)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) => setState(() => _points.add(details.localPosition)),
                onPanUpdate: (details) => setState(() => _points.add(details.localPosition)),
                onPanEnd: (_) => setState(() => _points.add(null)),
                child: CustomPaint(painter: _ChatDoodlePainter(_points, _color), size: Size.infinite),
              )
            else
              CustomPaint(painter: _ChatDoodlePainter(_points, _color), size: Size.infinite),
          ]),
        )),
      ))),
      Container(
        color: Colors.black, padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _caption, minLines: 1, maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tambahkan keterangan...',
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true, fillColor: const Color(0xFF202020),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: InkWell(
              onTap: () => setState(() => _viewOnce = !_viewOnce),
              child: Row(children: [
                Icon(_viewOnce ? Icons.looks_one_rounded : Icons.image_outlined,
                  color: _viewOnce ? Colors.amber : Colors.white),
                const SizedBox(width: 8),
                Text(_viewOnce ? 'Sekali lihat aktif' : 'Kirim seperti biasa',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ]),
            )),
            FilledButton.icon(
              onPressed: _exporting ? null : _send,
              icon: _exporting ? const SizedBox(width: 17, height: 17,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(CupertinoIcons.paperplane_fill),
              label: Text(_exporting ? 'Menyiapkan...' : 'Kirim'),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF168C55), foregroundColor: Colors.white),
            ),
          ]),
        ]),
      ),
    ])),
  );
}

class _ChatDoodlePainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  const _ChatDoodlePainter(this.points, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i], b = points[i + 1];
      if (a != null && b != null) canvas.drawLine(a, b, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _ChatDoodlePainter oldDelegate) =>
    oldDelegate.points != points || oldDelegate.color != color;
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _AttachmentOption({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(12),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 54, height: 46,
        decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor), borderRadius: BorderRadius.circular(25)),
        child: Icon(icon, color: color, size: 25)),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
    ]),
  );
}

class _ChatAudioBubble extends StatefulWidget {
  final String url;
  final bool mine;
  const _ChatAudioBubble({required this.url, required this.mine});
  @override
  State<_ChatAudioBubble> createState() => _ChatAudioBubbleState();
}

class _ChatAudioBubbleState extends State<_ChatAudioBubble> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _completeSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;
  bool _playing = false;
  bool _loading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _completeSubscription = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() { _playing = false; _position = _duration; _loading = false; });
    });
    _stateSubscription = _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playing = state == PlayerState.playing;
          if (state == PlayerState.playing || state == PlayerState.paused ||
              state == PlayerState.completed) {
            _loading = false;
          }
        });
      }
    });
    _player.onPositionChanged.listen((value) {
      if (mounted) setState(() => _position = value);
    });
    _player.onDurationChanged.listen((value) {
      if (mounted) setState(() => _duration = value);
    });
  }

  @override
  void dispose() {
    _completeSubscription?.cancel();
    _stateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  String _time(Duration value) {
    final seconds = value.inSeconds;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _toggle() async {
    if (_loading) return;
    try {
      if (_playing) {
        await _player.pause();
      } else {
        setState(() => _loading = true);
        await _player.play(UrlSource(widget.url));
        if (mounted) setState(() => _loading = false);
      }
    } catch (error) {
      if (mounted) {
        setState(() { _loading = false; _playing = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pesan suara tidak dapat diputar: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final foreground = widget.mine ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final totalMs = _duration.inMilliseconds;
    final progress = totalMs > 0
        ? (_position.inMilliseconds / totalMs).clamp(0.0, 1.0)
        : 0.0;
    return SizedBox(
      width: 184,
      child: Row(children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: _loading ? null : _toggle,
          icon: _loading
              ? SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: foreground))
              : Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  size: 28, color: foreground),
        ),
        Expanded(child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox.shrink(),
            Row(children: [
              Expanded(child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: progress,
                  onChanged: totalMs <= 0 ? null : (value) {
                    final target = Duration(milliseconds: (totalMs * value).round());
                    _player.seek(target);
                  },
                ),
              )),
              Text(_time(_position), style: TextStyle(color: foreground, fontSize: 12)),
            ]),
          ],
        )),
      ]),
    );
  }
}

const _chatBubbleColors = <Color>[
  Color(0xFF171717), Color(0xFF333333), Color(0xFF555555),
  Color(0xFF6B6B6B), Color(0xFF8A8A8A), Color(0xFF242424),
];
const _chatWallpaperColors = <Color>[
  Color(0xFFF0F0F0), Color(0xFFE7E7E7), Color(0xFFDADADA), Color(0xFFF5F5F5), Color(0xFF292929),
];
const _chatWallpaperGradients = <LinearGradient>[
  LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFF4E5), Color(0xFFEED5B7)]),
  LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF0F5E9), Color(0xFFD1E2D0)]),
  LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFEDF5FB), Color(0xFFC9DCEC)]),
  LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFF0E8), Color(0xFFE8D5CB)]),
  LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3B4840), Color(0xFF202A24)]),
];
