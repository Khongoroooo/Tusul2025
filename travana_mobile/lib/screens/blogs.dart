import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

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
      print('No token found');
      setState(() => isLoading = false);
      return;
    }

    final uid = await _getUserIdFromToken();
    if (uid == null) {
      print("User ID not found in token");
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
        setState(() {
          profileImgUrl = fixUrl(profile['profile_img']);
          userName = profile['username'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
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
        if (blogData is Map<String, dynamic> &&
            blogData.containsKey('results')) {
          blogData = blogData['results'];
        }
        if (blogData is List) {
          setState(() {
            blogs = blogData;
          });
        }
      }
    } catch (e) {
      print('Error fetching blogs: $e');
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Blogs'), backgroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Profile top bar ----
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
                          SizedBox(width: 10),
                          Text(
                            userName ?? '',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.more_horiz, color: Colors.black),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // ---- BLOG POSTS ----
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: blogs.length,
                    itemBuilder: (context, index) {
                      final blog = blogs[index];
                      final content = blog['content'] ?? '';
                      final imageUrl = fixUrl(blog['image']);

                      return Container(
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
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
                            // If image exists → show image
                            if (imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  height: 230,
                                  fit: BoxFit.cover,
                                ),
                              ),

                            // If content exists → show text
                            if (content.isNotEmpty) ...[
                              SizedBox(height: 12),
                              Text(
                                content,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
