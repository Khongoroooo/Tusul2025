import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class CommentsPage extends StatefulWidget {
  final Map<String, dynamic> blog;
  final String? token;
  const CommentsPage({super.key, required this.blog, this.token});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  List<dynamic> comments = [];
  String currentUserProfileImg = '';

  @override
  void initState() {
    super.initState();
    comments = widget.blog['comments'] as List<dynamic>? ?? [];
    _fetchCurrentUser();
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

  String fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://127.0.0.1:8000$url';
  }

  Future<void> _fetchCurrentUser() async {
    final token = widget.token;
    if (token == null) return;

    try {
      final res = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final user = jsonDecode(res.body);
        setState(() {
          final profileImg = user['profile']?['profile_img'] ?? '';
          currentUserProfileImg = profileImg.isNotEmpty
              ? 'http://127.0.0.1:8000$profileImg'
              : '';
        });
      }
    } catch (e) {
      debugPrint("Current user fetch error: $e");
    }
  }

  Future<void> _sendComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSending = true);
    final token = widget.token;
    if (token == null) return;

    final blogId = widget.blog['id'];
    final url = Uri.parse('http://127.0.0.1:8000/api/add_comment/$blogId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 201) {
        final newComment = jsonDecode(response.body);
        setState(() {
          comments.insert(0, newComment);
          _controller.clear();
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Алдаа гарлаа: $e')));
    }

    setState(() => _isSending = false);
  }

  void _showCommentOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Засах'),
              onTap: () {
                Navigator.pop(context);
                _editComment(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Устгах', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteComment(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _editComment(int index) {
    final comment = comments[index];
    _controller.text = comment['content'] ?? '';
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> _deleteComment(int index) async {
    final comment = comments[index];
    final commentId = comment['id'];
    final token = widget.token;
    if (token == null) return;

    final url = Uri.parse(
      'http://127.0.0.1:8000/api/comments/$commentId/delete/',
    );

    try {
      final res = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 204) {
        setState(() {
          comments.removeAt(index);
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
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: comments.isEmpty
                ? const Center(child: Text("Одоогоор сэтгэгдэл алга байна"))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final user =
                          comment["user"]?["profile"]?["username"] ?? "User";
                      final content = comment["content"] ?? "";
                      final profileImg = fixUrl(
                        comment["user"]?["profile"]?["profile_img"],
                      );
                      final createdAt = comment['created_at'] ?? "";

                      return GestureDetector(
                        onLongPress: () => _showCommentOptions(context, index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: profileImg.isNotEmpty
                                    ? NetworkImage(profileImg)
                                    : const AssetImage(
                                            "assets/images/default.png",
                                          )
                                          as ImageProvider,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          user,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          formatTime(createdAt),
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(content),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Iconsax.heart, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: currentUserProfileImg.isNotEmpty
                        ? NetworkImage(currentUserProfileImg)
                        : const AssetImage("assets/images/default.png")
                              as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 3,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: "Сэтгэгдэл бичих...",
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 238, 128, 139),
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: _isSending ? null : _sendComment,
                          icon: const Icon(
                            Icons.send,
                            color: Color.fromARGB(255, 238, 128, 139),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
