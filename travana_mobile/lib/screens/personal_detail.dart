import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class PersonalDetailPage extends StatefulWidget {
  const PersonalDetailPage({super.key});

  @override
  State<PersonalDetailPage> createState() => _PersonalDetailState();
}

class _PersonalDetailState extends State<PersonalDetailPage> {
  final storage = const FlutterSecureStorage();
  String? aboutMe = '';
  String? username = '';
  String? profileImageUrl = '';
  String? fullName = '';
  String? email = '';
  String? location = '';
  int? phone = 95154097;

  String fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith("http")) return url;
    return "http://localhost:8000$url";
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    String? token;

    if (kIsWeb) {
      token = html.window.localStorage['access_token'];
    } else {
      token = await storage.read(key: 'access_token');
    }

    if (token == null) return;

    final url = Uri.parse("http://localhost:8000/api/me/");

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profile = data["profile"] ?? {};

        setState(() {
          fullName = "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}";
          username = profile['username'] ?? "";
          email = data["email"] ?? "";
          profileImageUrl = fixUrl(profile["profile_img"]);
          location = profile["location"] ?? "Ulaanbaatar, Mongolia";
          phone = profile["phone"] ?? 94148451;
          aboutMe = profile["bio"] ?? "bio";
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          (profileImageUrl != null &&
                              profileImageUrl!.isNotEmpty)
                          ? NetworkImage(profileImageUrl!)
                          : const AssetImage(
                              "assets/images/default_profile.png",
                            ),
                    ),
                    Positioned(
                      bottom: -5,
                      right: -1,
                      child: GestureDetector(
                        onTap: () {
                          // Энд зураг солих функц нэмнэ
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEE808B),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          buildProfileCard(
            fullName: fullName ?? "Example User",
            phone: phone,
            email: email ?? "example_user@gmail.com",
          ),
        ],
      ),
    );
  }
}

Widget buildProfileCard({
  required String fullName,
  required int? phone,
  required String email,
}) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: const Color.fromARGB(255, 244, 250, 255),
        width: 1,
      ),
    ),
    margin: const EdgeInsets.all(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Row(
            children: [
              const Icon(Icons.person, color: Colors.black54),
              const SizedBox(width: 10),
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          // Phone
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.black54),
              const SizedBox(width: 10),
              Text(
                phone != null ? phone.toString() : "No phone",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          // Email
          Row(
            children: [
              const Icon(Icons.email, color: Colors.black54),
              const SizedBox(width: 10),
              Text(email, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    ),
  );
}
