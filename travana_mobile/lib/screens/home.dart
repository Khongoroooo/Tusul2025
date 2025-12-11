import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final storage = const FlutterSecureStorage();
  List<dynamic> blogs = [];
  bool isLoading = true;

  String fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://localhost:8000$url';
  }

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  Future<String?> _getToken() async {
    if (kIsWeb) {
      return html.window.localStorage['access_token'];
    } else {
      return await storage.read(key: 'access_token');
    }
  }

  // -----------------------------
  //  FETCH BLOGS
  // -----------------------------
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
        dynamic blogData = jsonDecode(res.body);

        if (blogData is Map && blogData.containsKey("results")) {
          blogs = blogData["results"];
        } else {
          blogs = blogData;
        }
      }
    } catch (e) {
      print("Blog fetch error: $e");
    }

    setState(() => isLoading = false);
  }

  // -----------------------------
  // LIKE / UNLIKE
  // -----------------------------
  // LIKE / UNLIKE
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
          // Blog map доторхи утгуудыг шууд update хийж байна
          blogs[index]["is_liked"] = data["liked"];
          blogs[index]["likes_count"] = data["likes_count"];
        });
      }
    } catch (e) {
      print("LIKE error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset('images/logo.png', width: 80),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.search, color: Colors.black, size: 30),
              ),
              SizedBox(width: 20),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                final blog = blogs[index];
                final images = blog["images"] as List? ?? [];

                final user = blog["user"];
                final profile = user["profile"];

                final username = profile["username"] ?? "Unknown";
                final profileImg = fixUrl(profile["profile_img"]);

                final bool isLiked = blog["is_liked"] ?? false;
                final content = blog['content'] ?? '';
                // final createDate = blog['created_at']??'',
                final int likesCount = blog["likes_count"] ?? 0;

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
                      // -------------------------
                      // USER HEADER
                      // -------------------------
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
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                children: [
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text('data'),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.more_horiz, color: Colors.black),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      // const SizedBox(height: 5),

                      // CONTENT
                      if (content.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          content,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                      // -------------------------
                      // IMAGES CAROUSEL
                      // -------------------------
                      if (images.isNotEmpty)
                        SizedBox(
                          height: 250,
                          child: PageView.builder(
                            itemCount: images.length,
                            itemBuilder: (context, i) {
                              final imgUrl = fixUrl(images[i]["image"]);
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imgUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 10),

                      // -------------------------
                      // LIKE + COMMENT + SAVE
                      // -------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // ❤️ LIKE BUTTON
                              InkWell(
                                onTap: () => toggleLike(
                                  blog["id"],
                                  index,
                                ), // <-- blog id + index
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),

                              const Icon(
                                Iconsax.message_text,
                                size: 24,
                                color: Colors.black,
                              ),
                            ],
                          ),

                          const Icon(
                            Icons.bookmark_border,
                            size: 26,
                            color: Colors.black,
                          ),
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
