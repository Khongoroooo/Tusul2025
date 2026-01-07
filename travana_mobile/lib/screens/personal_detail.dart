import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import 'package:iconsax/iconsax.dart';

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
  String? lastName = '';
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

  // GET USER INFO
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
          lastName = data['last_name'] ?? "";
          username = profile['username'] ?? "";
          email = data["email"] ?? "";
          profileImageUrl = fixUrl(profile["profile_img"]);
          location = profile["location"] ?? "Ulaanbaatar, Mongolia";
          phone = profile["phone"];
          aboutMe = profile["bio"] ?? "bio";
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  // PATCH UPDATE
  Future<void> updateProfileToBackend({
    String? username,
    String? bio,
    int? phone,
  }) async {
    String? token;

    if (kIsWeb) {
      token = html.window.localStorage['access_token'];
    } else {
      token = await storage.read(key: 'access_token');
    }

    if (token == null) return;

    final url = Uri.parse("http://localhost:8000/api/profile/update/");

    final Map<String, dynamic> body = {};
    if (username != null) body["username"] = username;
    if (bio != null) body["bio"] = bio;
    if (phone != null) body["phone"] = phone;

    try {
      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },

        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        fetchUserInfo();
      }
    } catch (e) {
      print("Update error: $e");
    }
  }

  // EDIT DIALOG
  Future<void> showEditDialog({
    required String title,
    required String initialValue,
    required Function(String) onSave,
  }) async {
    TextEditingController controller = TextEditingController(
      text: initialValue,
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEE808B),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
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
                        onTap: () {},
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
          const SizedBox(height: 50),
          buildProfileCard(
            userName: username ?? "Example User",
            lastName: lastName ?? "Example User",
            phone: phone,
            email: email ?? "example_user@gmail.com",
            bio: aboutMe ?? "bio",
            onEditUsername: () {
              showEditDialog(
                title: "Edit Username",
                initialValue: username ?? "",
                onSave: (val) => updateProfileToBackend(username: val),
              );
            },
            onEditBio: () {
              showEditDialog(
                title: "Edit Bio",
                initialValue: aboutMe ?? "",
                onSave: (val) => updateProfileToBackend(bio: val),
              );
            },
            onEditPhone: () {
              showEditDialog(
                title: "Edit Phone",
                initialValue: phone.toString(),
                onSave: (val) =>
                    updateProfileToBackend(phone: int.tryParse(val)),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget buildProfileCard({
  required String lastName,
  required int? phone,
  required String email,
  required String userName,
  required String bio,
  required VoidCallback onEditUsername,
  required VoidCallback onEditBio,
  required VoidCallback onEditPhone,
}) {
  return Card(
    color: Color.fromARGB(255, 255, 252, 254),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Color.fromARGB(255, 255, 227, 230)),
    ),
    margin: const EdgeInsets.all(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.black54),
                  const SizedBox(width: 10),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onEditUsername,
                icon: Icon(
                  Iconsax.edit,
                  color: Color.fromARGB(255, 42, 81, 255),
                ),
              ),
            ],
          ),

          const Divider(height: 20, thickness: 1),

          // Bio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.black54),
                  const SizedBox(width: 10),
                  Text(
                    bio,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onEditBio,
                icon: Icon(
                  Iconsax.edit,
                  color: Color.fromARGB(255, 42, 81, 255),
                ),
              ),
            ],
          ),

          const Divider(height: 20, thickness: 1),

          // Phone
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              IconButton(
                onPressed: onEditPhone,
                icon: Icon(
                  Iconsax.edit,
                  color: Color.fromARGB(255, 42, 81, 255),
                ),
              ),
            ],
          ),

          const Divider(height: 20, thickness: 1),

          // Email
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.email, color: Colors.black54),
                  const SizedBox(width: 10),
                  Text(email, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
