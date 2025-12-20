import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final storage = const FlutterSecureStorage();
  List<dynamic> blogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  String fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://localhost:8000$url';
  }

  String formatTime(String dateString) {
    final date = DateTime.parse(dateString).toLocal();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return "Дөнгөж сая";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} минутын өмнө";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} цагийн өмнө";
    } else if (diff.inDays == 1) {
      return "Өчигдөр";
    } else if (diff.inDays < 7) {
      return "${diff.inDays} өдрийн өмнө";
    } else {
      return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<String?> _getToken() async {
    if (kIsWeb) {
      return html.window.localStorage['access_token'];
    }
    return await storage.read(key: 'access_token');
  }

  Future<void> fetchBlogs() async {
    setState(() => isLoading = true);

    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse("http://localhost:8000/api/blogs/");

    try {
      final res = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        blogs = data is Map ? data["results"] : data;
      }
    } catch (e) {
      debugPrint("Blog fetch error: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> toggleLike(int blogId, int index) async {
    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse("http://localhost:8000/api/blogs/$blogId/like/");

    try {
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
    } catch (e) {
      debugPrint("LIKE error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset('images/logo.png', width: 80),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.black, size: 30),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                final blog = blogs[index];
                final images = blog["images"] ?? [];

                final profile = blog["user"]["profile"];
                final username = profile["username"] ?? "Unknown";
                final profileImg = fixUrl(profile["profile_img"]);
                final createdAt = blog["created_at"];

                final isLiked = blog["is_liked"] ?? false;
                final likesCount = blog["likes_count"] ?? 0;
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundImage: profileImg.isNotEmpty
                                    ? NetworkImage(profileImg)
                                    : const AssetImage(
                                            "assets/images/default.png",
                                          )
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
                          const Icon(Icons.more_horiz),
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
                            itemBuilder: (context, i) {
                              final imgUrl = fixUrl(images[i]["image"]);
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        opaque: false,
                                        pageBuilder: (_, animation, __) =>
                                            FadeTransition(
                                              opacity: animation,
                                              child: FullScreenImageGallery(
                                                images: images
                                                    .map<String>(
                                                      (e) => fixUrl(e["image"]),
                                                    )
                                                    .toList(),
                                                initialIndex: i,
                                                blogIndex: index,
                                              ),
                                            ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: 'image$index$i',
                                    child: Image.network(
                                      imgUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
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
                                      color: isLiked
                                          ? Colors.red
                                          : Colors.black,
                                      size: 26,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "$likesCount",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Icon(Iconsax.message_text),
                            ],
                          ),
                          const Icon(Icons.bookmark_border),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

/// 🔥 FULLSCREEN IMAGE + ZOOM + SWIPE
class FullScreenImageGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final int blogIndex;

  const FullScreenImageGallery({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.blogIndex,
  });

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          itemBuilder: (context, i) {
            return Hero(
              tag: 'image${widget.blogIndex}$i',
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Image.network(widget.images[i], fit: BoxFit.contain),
              ),
            );
          },
        ),
      ),
    );
  }
}
