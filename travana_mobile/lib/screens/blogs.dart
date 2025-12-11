import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:travana_mobile/screens/add_new_trip.dart';

class BlogsPage extends StatefulWidget {
  const BlogsPage({super.key});

  @override
  State<BlogsPage> createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage> {
  final storage = const FlutterSecureStorage();
  List<dynamic> blogs = [];
  bool isLoading = true;
  String? userId;
  String? profileImgUrl;
  String? userName;

  String fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://localhost:8000$url';
  }

  @override
  void initState() {
    super.initState();
    fetchProfileAndBlogs();
  }

  Future<String?> _getToken() async {
    if (kIsWeb) {
      return html.window.localStorage['access_token'];
    } else {
      return await storage.read(key: 'access_token');
    }
  }

  Future<String?> _getUserIdFromToken() async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = jsonDecode(payload);
      return data['user_id'].toString();
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  Future<void> fetchProfileAndBlogs() async {
    setState(() => isLoading = true);

    final token = await _getToken();
    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    final uid = await _getUserIdFromToken();
    if (uid == null) {
      setState(() => isLoading = false);
      return;
    }
    userId = uid;

    // Profile авах
    final profileUrl = Uri.parse('http://localhost:8000/api/me/');
    try {
      final profileRes = await http.get(
        profileUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (profileRes.statusCode == 200) {
        final profileData = jsonDecode(profileRes.body);
        final profile = profileData['profile'] ?? {};
        profileImgUrl = fixUrl(profile['profile_img']);
        userName = profile['username'] ?? '';
      }
    } catch (e) {
      print('Profile fetch error: $e');
    }

    // Blogs авах
    final blogUrl = Uri.parse(
      'http://localhost:8000/api/blogs/?user_id=$userId',
    );

    try {
      final blogRes = await http.get(
        blogUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (blogRes.statusCode == 200) {
        dynamic blogData = jsonDecode(blogRes.body);

        if (blogData is Map && blogData.containsKey('results')) {
          blogData = blogData['results'];
        }

        if (blogData is List) {
          // Зөвхөн өөрийн блогийг filter хийж авах
          blogs = blogData
              .where((b) => b['user']['id'].toString() == userId)
              .toList();
        }
      }
    } catch (e) {
      print('Blog fetch error: $e');
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
      print("LIKE error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'My blogs',
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: blogs.length,
                    itemBuilder: (context, index) {
                      final blog = blogs[index];
                      final content = blog['content'] ?? '';
                      final images = blog['images'] as List? ?? [];

                      final bool isLiked = blog["is_liked"] ?? false;
                      final int likesCount = blog["likes_count"] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
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
                            // PROFILE TOP
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage:
                                          (profileImgUrl != null &&
                                              profileImgUrl!.isNotEmpty)
                                          ? NetworkImage(profileImgUrl!)
                                          : const AssetImage(
                                                  "assets/images/default_profile.avif",
                                                )
                                                as ImageProvider,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      userName ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.more_horiz,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),

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

                            if (images.isNotEmpty)
                              SizedBox(
                                height: 230,
                                child: PageView.builder(
                                  itemCount: images.length,
                                  itemBuilder: (context, i) {
                                    final imgUrl = fixUrl(images[i]['image']);
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        imgUrl,
                                        width: double.infinity,
                                        height: 230,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              ),

                            const SizedBox(height: 10),

                            // ACTION ICONS + LIKE COUNT
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () =>
                                          toggleLike(blog['id'], index),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isLiked
                                                ? Iconsax.heart5
                                                : Iconsax.heart,
                                            color: isLiked
                                                ? Colors.red
                                                : Colors.black,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "$likesCount",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    const Icon(
                                      Iconsax.message_text,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.bookmark_border,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTrip = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const Padding(
              padding: EdgeInsets.all(16),
              child: AddNewTripModal(),
            ),
          );
          if (newTrip != null) {
            setState(() {
              blogs.add(newTrip);
            });
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: const Color.fromARGB(255, 238, 128, 139),
        child: const Icon(Iconsax.add, size: 28, color: Colors.white),
      ),
    );
  }
}
