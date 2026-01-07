import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:travana_mobile/screens/add_new_blog.dart';
import 'package:travana_mobile/screens/comments.dart';
import 'package:travana_mobile/screens/search_page.dart';

class BlogsPage extends StatefulWidget {
  const BlogsPage({super.key});

  @override
  State<BlogsPage> createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage>
    with SingleTickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  List<dynamic> blogs = [];
  bool isLoading = true;
  String? userId;
  String? profileImgUrl;
  String? userName;

  late AnimationController _animationController;
  late Animation<double> _animation;

  String fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://localhost:8000$url';
  }

  @override
  void initState() {
    super.initState();
    fetchProfileAndBlogs();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  void _editBlog(dynamic blog) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: AddNewBlogPage(blog: blog),
      ),
    );

    if (result != null) {
      await fetchProfileAndBlogs();
    }
  }

  Future<void> _deleteBlog(int blogId, int index) async {
    final token = await _getToken();
    if (token == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Устгах уу?'),
        content: const Text('Энэ блогийг бүр мөсөн устгах уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Болих'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Устгах', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final url = Uri.parse('http://localhost:8000/api/blogs/$blogId/delete/');

    try {
      final res = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 204 || res.statusCode == 200) {
        setState(() {
          blogs.removeAt(index);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blog устгах боломжгүй байна')),
        );
      }
    } catch (e) {
      print('DELETE error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Алдаа гарлаа')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'My blogs',
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
            icon: const Icon(Icons.search, color: Colors.black, size: 30),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : blogs.isEmpty
          ? Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _animation,
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Image.asset(
                          "assets/images/cute.gif",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Танд одоогоор блог байхгүй байна",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) => FractionallySizedBox(
                            heightFactor: 0.55,
                            child: AddNewBlogPage(),
                          ),
                        );

                        if (result != null) {
                          await fetchProfileAndBlogs();
                        }
                      },
                      icon: const Icon(Iconsax.add),
                      label: const Text("Блог нэмэх"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          238,
                          128,
                          139,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
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
                      final placeName =
                          blog['place']?['name'] ?? 'Тодорхойгүй газар';
                      final images = blog['images'] as List? ?? [];
                      final createdAt = blog["created_at"];
                      final commentsCount = blog["comment_count"] ?? '0';
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
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
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.black,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editBlog(blog);
                                    } else if (value == 'delete') {
                                      _deleteBlog(blog['id'], index);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Засах'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Устгах',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                                                    child:
                                                        FullScreenImageGallery(
                                                          images: images
                                                              .map<String>(
                                                                (e) => fixUrl(
                                                                  e["image"],
                                                                ),
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
                            // PLACE NAME
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
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
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
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            final token = await _getToken();
                                            if (token == null) return;

                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (context) {
                                                return FractionallySizedBox(
                                                  heightFactor: 0.7,
                                                  child: Container(
                                                    decoration: const BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  30,
                                                                ),
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
                                          icon: const Icon(
                                            Iconsax.message_text,
                                          ),
                                        ),
                                        Text(
                                          commentsCount.toString(),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
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
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => FractionallySizedBox(
              heightFactor: 0.5,
              child: AddNewBlogPage(),
            ),
          );

          if (result != null) {
            await fetchProfileAndBlogs();
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: const Color.fromARGB(255, 238, 128, 139),
        child: const Icon(Iconsax.add, size: 28, color: Colors.white),
      ),
    );
  }
}

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
