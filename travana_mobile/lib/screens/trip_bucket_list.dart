import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travana_mobile/screens/add_new_trip.dart';
import 'package:travana_mobile/screens/trip_detail.dart';

// Web-д зориулсан localStorage
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class TripListPage extends StatefulWidget {
  const TripListPage({super.key});

  @override
  State<TripListPage> createState() => _TripListPageState();
}

class _TripListPageState extends State<TripListPage>
    with SingleTickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  List<dynamic> trips = [];
  List<dynamic> filterTrips = [];
  bool isLoading = true;
  String selected = 'planned';
  final TextEditingController _searchController = TextEditingController();
  String? userId;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Animation initialize
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    fetchTrips();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    if (kIsWeb) {
      print("WEB TOKEN: ${html.window.localStorage['access_token']}");
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

  Future<void> fetchTrips() async {
    setState(() => isLoading = true);

    final token = await _getToken();
    if (token == null) {
      print("No token found");
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

    final url = Uri.parse("http://localhost:8000/api/trips/?user_id=$userId");

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('results')) {
          data = data['results'];
        }
        if (data is List) {
          setState(() {
            trips = data;
            filterTrips = List.from(data);
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        print("Unauthorized. Token may be invalid.");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteTrip(int id) async {
    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse("http://localhost:8000/api/trips/$id/");

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 204 || response.statusCode == 200) {
        setState(() {
          trips.removeWhere((t) => t['id'] == id);
          filterTrips.removeWhere((t) => t['id'] == id);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _showRenameDialog(dynamic trip) {
    final controller = TextEditingController(text: trip['title']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename trip"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "New title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => trip['title'] = controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  List<dynamic> get displayedTrips {
    final query = _searchController.text.toLowerCase();
    return filterTrips.where((trip) {
      final statusMatch = trip['status'] == selected;
      final titleMatch = (trip['title'] ?? '').toLowerCase().contains(query);
      final placeMatch = (trip['place_name'] ?? '').toLowerCase().contains(
        query,
      );
      return statusMatch && (titleMatch || placeMatch);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Travel Goals',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trips.isEmpty
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
                      "Танд одоогоор аялал байхгүй байна",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SearchBarWidget(
                      controller: _searchController,
                      hintText: 'Trips search...',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildChip('planned', 'Want to visit'),
                      const SizedBox(width: 16),
                      _buildChip('completed', 'Completed'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: displayedTrips.isEmpty
                        ? const Center(child: Text("No trips found"))
                        : GridView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: displayedTrips.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemBuilder: (context, index) {
                              final item = displayedTrips[index];
                              String formattedDate = "";
                              if (item['created_at'] != null) {
                                final date = DateTime.parse(item['created_at']);
                                formattedDate =
                                    "${date.year}-${date.month}-${date.day}";
                              }
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TripDetail(trip: item),
                                  ),
                                ),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 4,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(15),
                                                    bottom: Radius.circular(15),
                                                  ),
                                              child: Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                color: const Color.fromARGB(
                                                  255,
                                                  251,
                                                  251,
                                                  251,
                                                ),
                                                child: item['image'] != null
                                                    ? Image.network(
                                                        item['image']
                                                            .toString()
                                                            .replaceFirst(
                                                              '127.0.0.1',
                                                              'localhost',
                                                            ),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const Center(
                                                        child: Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          size: 50,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 10,
                                              left: 10,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      item['status'] ==
                                                          'planned'
                                                      ? Colors.lightBlue
                                                      : Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  item['status'] == 'planned'
                                                      ? 'Planned'
                                                      : 'Completed',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 10,
                                              right: 1,
                                              child: PopupMenuButton<String>(
                                                onSelected: (value) async {
                                                  if (value == 'edit') {
                                                    final updatedTrip =
                                                        await showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          backgroundColor:
                                                              Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.vertical(
                                                                  top:
                                                                      Radius.circular(
                                                                        20,
                                                                      ),
                                                                ),
                                                          ),
                                                          builder: (_) =>
                                                              AddNewTripModal(
                                                                trip: item,
                                                              ),
                                                        );
                                                    if (updatedTrip != null) {
                                                      setState(() {
                                                        final index = trips
                                                            .indexWhere(
                                                              (t) =>
                                                                  t['id'] ==
                                                                  updatedTrip['id'],
                                                            );
                                                        trips[index] =
                                                            updatedTrip;
                                                        filterTrips[index] =
                                                            updatedTrip;
                                                      });
                                                    }
                                                  } else if (value ==
                                                      'rename') {
                                                    _showRenameDialog(item);
                                                  } else if (value ==
                                                      'delete') {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) => AlertDialog(
                                                        title: const Text(
                                                          'Delete trip?',
                                                        ),
                                                        content: const Text(
                                                          "Are you sure you want to delete this trip?",
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  context,
                                                                ),
                                                            child: const Text(
                                                              "Cancel",
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () async {
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                              await deleteTrip(
                                                                item['id'],
                                                              );
                                                            },
                                                            child: const Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                },
                                                color: Colors.white,
                                                elevation: 6,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.more_vert,
                                                  color: Color.fromARGB(
                                                    255,
                                                    200,
                                                    200,
                                                    200,
                                                  ),
                                                  size: 22,
                                                ),
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.edit,
                                                          size: 18,
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text("Edit trip"),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'rename',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .drive_file_rename_outline,
                                                          size: 18,
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text("Rename"),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                          size: 18,
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          "Delete",
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              left: 10,
                                              right: 10,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.55),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item['title'] ?? '',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      formattedDate,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
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
              trips.add(newTrip);
              if (newTrip['status'] == selected || selected == 'all') {
                filterTrips.add(newTrip);
              }
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetail(trip: newTrip),
              ),
            );
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: const Color.fromARGB(255, 238, 128, 139),
        child: const Icon(Iconsax.add, size: 28, color: Colors.white),
      ),
    );
  }

  Widget _buildChip(String value, String label) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected == value ? Colors.white : Colors.black,
        ),
      ),
      selected: selected == value,
      checkmarkColor: Colors.white,
      selectedColor: const Color.fromARGB(255, 238, 128, 139),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color.fromARGB(255, 238, 128, 139)),
      ),
      onSelected: (_) => setState(() => selected = value),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
