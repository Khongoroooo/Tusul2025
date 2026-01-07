import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'comments.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;
  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final storage = const FlutterSecureStorage();

  bool isLoading = true;
  Map<String, dynamic>? user;
  List blogs = [];

  // ================== COMMON ==================
  String fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://localhost:8000$url';
  }

  String formatTime(String dateString) {
    final date = DateTime.parse(dateString).toLocal();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "Дөнгөж сая";
    if (diff.inMinutes < 60) return "${diff.inMinutes} минутын өмнө";
    if (diff.inHours < 24) return "${diff.inHours} цагийн өмнө";
    if (diff.inDays == 1) return "Өчигдөр";
    if (diff.inDays < 7) return "${diff.inDays} өдрийн өмнө";
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<String?> _getToken() async {
    if (kIsWeb) {
      return html.window.localStorage['access_token'];
    }
    return await storage.read(key: 'access_token');
  }

  // ================== FETCH ==================
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final token = await _getToken();
    if (token == null) return;

    final userUrl = Uri.parse(
      'http://localhost:8000/api/users/${widget.userId}/',
    );
    final blogUrl = Uri.parse(
      'http://localhost:8000/api/blogs/?user_id=${widget.userId}',
    );

    try {
      final userRes = await http.get(
        userUrl,
        headers: {'Authorization': 'Bearer $token'},
      );
      final blogRes = await http.get(
        blogUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (userRes.statusCode == 200) {
        user = jsonDecode(userRes.body);
      }
      if (blogRes.statusCode == 200) {
        final data = jsonDecode(blogRes.body);
        blogs = data is Map ? data['results'] : data;
      }
    } catch (e) {
      debugPrint("PROFILE ERROR: $e");
    }

    setState(() => isLoading = false);
  }

  // ================== LIKE / SAVE ==================
  Future<void> toggleLike(int blogId, int index) async {
    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse("http://localhost:8000/api/blogs/$blogId/like/");
    final res = await http.post(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        blogs[index]["is_liked"] = data["liked"];
        blogs[index]["likes_count"] = data["likes_count"];
      });
    }
  }

  Future<void> toggleSave(int blogId, int index) async {
    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse("http://localhost:8000/api/blogs/$blogId/save/");
    final res = await http.post(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      setState(() {
        blogs[index]["is_saved"] = !blogs[index]["is_saved"];
      });
    }
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profile = user?['profile'] ?? {};
    final username = profile['username'] ?? '';
    final avatar = fixUrl(profile['profile_img']);
    final profileImg = fixUrl(profile["profile_img"]);
    print('--------------$avatar');
    final bio = profile['bio'] ?? '';
    final blogCount = user?['blog_count'] ?? blogs.length;
    final tripCount = user?['trip_count'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(username),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ================= PROFILE HEADER (ЯГ PROFILE PAGE) =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    (profile['profile_img'] != null &&
                        profile['profile_img'].toString().isNotEmpty)
                    ? NetworkImage(fixUrl(profile['profile_img']))
                    : const AssetImage("assets/images/default_profile.avif")
                          as ImageProvider,
              ),

              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              blogCount.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Blogs'),
                          ],
                        ),
                        const SizedBox(width: 60),
                        Column(
                          children: [
                            Text(
                              tripCount.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Trips'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (bio.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.notes_rounded, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Expanded(child: Text(bio)),
              ],
            ),
          ],

          const SizedBox(height: 30),

          // ================= BLOG LIST (HOME.DART-тай ЯГ ИЖИЛ) =================
          ...List.generate(blogs.length, (index) {
            final blog = blogs[index];
            final images = blog["images"] ?? [];

            final profile = blog["user"]["profile"];
            final username = profile["username"] ?? "Unknown";
            final profileImg = fixUrl(profile["profile_img"]);
            final createdAt = blog["created_at"];
            final placeName = blog['place']?['name'] ?? 'Тодорхойгүй газар';

            final isLiked = blog["is_liked"] ?? false;
            final likesCount = blog["likes_count"] ?? 0;
            final commentsCount = blog["comment_count"] ?? 0;
            final content = blog["content"] ?? "";

            return Container(
              margin: const EdgeInsets.only(bottom: 25),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// USER HEADER
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: profileImg.isNotEmpty
                            ? NetworkImage(profileImg)
                            : const AssetImage("assets/images/default.png")
                                  as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (createdAt != null)
                            Text(
                              formatTime(createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  if (content.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(content, style: const TextStyle(fontSize: 15)),
                  ],

                  const SizedBox(height: 12),

                  /// IMAGES
                  if (images.isNotEmpty)
                    SizedBox(
                      height: 250,
                      child: PageView.builder(
                        itemCount: images.length,
                        itemBuilder: (_, i) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              fixUrl(images[i]["image"]),
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 10),

                  /// PLACE
                  Row(
                    children: [
                      const Icon(
                        Icons.place,
                        color: Color.fromARGB(255, 238, 128, 139),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        placeName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// ACTIONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => toggleLike(blog["id"], index),
                            child: Row(
                              children: [
                                Icon(
                                  isLiked ? Iconsax.heart5 : Iconsax.heart,
                                  color: isLiked ? Colors.red : Colors.black,
                                ),
                                const SizedBox(width: 6),
                                Text("$likesCount"),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(Iconsax.message_text),
                            onPressed: () async {
                              final token = await _getToken();
                              if (token == null) return;

                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) {
                                  return FractionallySizedBox(
                                    heightFactor: 0.7,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(30),
                                        ),
                                      ),
                                      child: CommentsPage(
                                        blog: blog,
                                        token: token,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          Text(commentsCount.toString()),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          blog['is_saved']
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          color: blog['is_saved'] ? Colors.pink : Colors.grey,
                        ),
                        onPressed: () => toggleSave(blog['id'], index),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
