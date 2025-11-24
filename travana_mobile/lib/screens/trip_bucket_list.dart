import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:travana_mobile/screens/add_new_trip.dart';
import 'package:travana_mobile/screens/trip_detail.dart';

class TripListPage extends StatefulWidget {
  const TripListPage({super.key});

  @override
  State<TripListPage> createState() => _TripListPageState();
}

class _TripListPageState extends State<TripListPage> {
  List<dynamic> trips = [];
  bool isLoading = true;
  List<dynamic> filterTrips = [];
  String selected = 'planned';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    final url = Uri.parse("http://localhost:8000/api/trips/");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('results')) {
          data = data['results'];
        }

        if (data is List) {
          setState(() {
            trips = data;
            filterTrips = data;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  List<dynamic> get displayedTrips {
    final query = _searchController.text.toLowerCase();
    return filterTrips.where((trip) {
      final statusMatch = trip['status'] == selected;
      final titleMatch = (trip['title'] ?? '')
          .toString()
          .toLowerCase()
          .contains(query);
      final placeMatch = (trip['place_name'] ?? '')
          .toString()
          .toLowerCase()
          .contains(query);

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

      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: SearchBarWidget(
                controller: _searchController,
                hintText: 'Trips search...',
                onChanged: (_) => setState(() {}),
              ),
            ),

            // Choice Chips
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : displayedTrips.isEmpty
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
                              builder: (context) => const TripDetail(),
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
                                      // IMAGE OR GREY BOX
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(15),
                                            ),
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          color: const Color.fromARGB(255, 251, 251, 251),
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
                                                    Icons.image_not_supported,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                        ),
                                      ),

                                      // STATUS
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: item['status'] == 'planned'
                                                ? Colors.lightBlue
                                                : Colors.green,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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

                                      // TITLE + DATE
                                      Positioned(
                                        bottom: 10,
                                        left: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.55,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['title'] ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
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
              padding: EdgeInsets.all(16.0),
              child: AddNewTripModal(),
            ),
          );

          if (newTrip != null) {
            setState(() => trips.add(newTrip));
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
        prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
