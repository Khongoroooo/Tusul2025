import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:travana_mobile/screens/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = const FlutterSecureStorage();

  bool isLoading = true;

  String? profileImageUrl = '';
  String? fullName = '';
  String? email = '';
  String? location = '';
  int? phone = 95154097;
  int? blogCount = 0;
  int? tripCount = 0;
  String? aboutMe = '';
  String? username = '';

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
          aboutMe = profile["bio"] ?? "Flutter developer & traveler.";
          blogCount = data['blog_count'] ?? 0;
          tripCount = data['trip_count'] ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> _logout() async {
    if (kIsWeb) {
      html.window.localStorage.remove('access_token');
    } else {
      await storage.delete(key: 'access_token');
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LoginScreen(toggleLanguage: () {}, locale: const Locale('en')),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEE808B),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                        "assets/images/default_profile.avif",
                                      )
                                      as ImageProvider,
                          ),
                          Positioned(
                            bottom: -1,
                            right: -1,

                            child: GestureDetector(
                              onTap: () => 'ff',
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFEE808B),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
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
                      SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username ?? "",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      blogCount.toString() ?? '0',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    SizedBox(height: 5),
                                    Text('Blogs'),
                                  ],
                                ),
                                SizedBox(width: 35),
                                Column(
                                  children: [
                                    Text(
                                      tripCount.toString() ?? '0',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    SizedBox(height: 5),
                                    Text('Trips'),
                                  ],
                                ),
                                SizedBox(width: 35),
                                Column(
                                  children: [
                                    Text(
                                      tripCount.toString() ?? '0',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    SizedBox(height: 5),
                                    Text('Trips'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.notes_rounded, color: Colors.red, size: 24),
                      SizedBox(width: 8),
                      Text(
                        aboutMe ?? '',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),
                  SizedBox(
                    width: 340,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          245,
                          247,
                          250,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.black, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Personal Detail',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 340,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          245,
                          247,
                          250,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lock, color: Colors.black, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Change Password',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 340,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          245,
                          247,
                          250,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 10),
                              Text(
                                'Change Language',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                          Icon(Icons.language, color: Colors.black, size: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 340,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          245,
                          247,
                          250,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 10),
                              Text(
                                'Dark Mode',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                          Icon(Icons.dark_mode, color: Colors.black, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
