import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SavePage extends StatefulWidget {
  final String? token;
  const SavePage({super.key, this.token});

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  List<dynamic> savedBlogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSavedBlogs();
  }

  Future<void> _fetchSavedBlogs() async {
    final token = widget.token ?? await _getToken();
    if (token == null) {
      debugPrint("Token is null");
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/api/saved_blogs/');

    try {
      final res = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final List<dynamic> blogs = jsonDecode(res.body);
        setState(() {
          savedBlogs = blogs;
          isLoading = false;
        });
      } else {
        debugPrint('Failed to fetch saved blogs: ${res.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching saved blogs: $e');
      setState(() => isLoading = false);
    }
  }

  String fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (kIsWeb) return 'http://localhost:8000$url';
    return 'http://10.0.2.2:8000$url';
  }

  Future<String?> _getToken() async {
    if (widget.token != null) return widget.token;
    if (kIsWeb) return html.window.localStorage['access_token'];
    return await const FlutterSecureStorage().read(key: 'access_token');
  }

  Future<void> toggleSave(int blogId) async {
    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse('http://10.0.2.2:8000/api/blogs/$blogId/save/');

    try {
      final res = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        setState(() {
          // toggle хийх
          final index = savedBlogs.indexWhere((b) => b['id'] == blogId);
          if (index != -1) savedBlogs.removeAt(index);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Алдаа гарлаа: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Хадгалсан блогууд')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedBlogs.isEmpty
          ? const Center(child: Text('Одоогоор хадгалсан блог алга байна'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedBlogs.length,
              itemBuilder: (context, index) {
                final blog = savedBlogs[index];
                final user =
                    blog["user"]?["profile"]?["username"] ??
                    blog["user"]?["email"] ??
                    "User";
                final content = blog["content"] ?? "";
                final profileImg = fixUrl(
                  blog["user"]?["profile"]?["profile_img"],
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: profileImg.isNotEmpty
                            ? NetworkImage(profileImg)
                            : const AssetImage("assets/images/default.png")
                                  as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(content),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => toggleSave(blog['id']),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
