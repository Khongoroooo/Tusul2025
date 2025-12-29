import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final storage = const FlutterSecureStorage();
  final TextEditingController _searchCtrl = TextEditingController();

  List<dynamic> results = [];
  bool isLoading = false;
  Timer? _debounce;

  // -----------------------------
  // Helpers
  // -----------------------------
  String fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://localhost:8000$url';
  }

  Future<String?> _getToken() async {
    if (kIsWeb) {
      return html.window.localStorage['access_token'];
    }
    return await storage.read(key: 'access_token');
  }

  // -----------------------------
  // Search logic (with debounce)
  // -----------------------------
  void onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      searchBlogs(keyword);
    });
  }

  Future<void> searchBlogs(String keyword) async {
    if (keyword.trim().isEmpty) {
      if (!mounted) return;
      setState(() => results = []);
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    final token = await _getToken();
    if (token == null) {
      if (!mounted) return;
      setState(() => isLoading = false);
      return;
    }

    final encoded = Uri.encodeQueryComponent(keyword);
    final url = Uri.parse("http://localhost:8000/api/blogs/?search=$encoded");

    try {
      final res = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (!mounted) return;
        setState(() {
          // pagination байвал results, байхгүй бол шууд array
          results = data is Map ? data["results"] ?? [] : data;
        });
      } else {
        debugPrint("Search failed: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Хайх...",
            border: InputBorder.none,
          ),
          onChanged: onSearchChanged,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty
          ? const Center(
              child: Text(
                "Илэрц олдсонгүй",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final blog = results[index];
                final profile = blog["user"]?["profile"];

                final username =
                    profile?["username"] ?? blog["user"]?["username"] ?? "";
                final profileImg = fixUrl(profile?["profile_img"]);
                final content = blog["content"] ?? "";

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: profileImg.isNotEmpty
                        ? NetworkImage(profileImg)
                        : const AssetImage("assets/images/default.png")
                              as ImageProvider,
                  ),
                  title: Text(
                    username,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Iconsax.arrow_right_3),
                  onTap: () {
                    // 🔜 энд blog detail page руу оруулж болно
                    Navigator.pop(context);
                  },
                );
              },
            ),
    );
  }
}
