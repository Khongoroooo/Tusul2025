import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:travana_mobile/screens/add_new_trip.dart';
import 'package:travana_mobile/screens/trip_bucket_list.dart';

class TripDetail extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripDetail({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final imgUrl = trip['image']?.toString().replaceFirst(
      '127.0.0.1',
      'localhost',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 330,
                pinned: true,
                backgroundColor: Colors.black,
                automaticallyImplyLeading: false,
                elevation: 0,

                leading: Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                title: Text(
                  trip['title'] ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // IMAGE
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(35),
                            bottomRight: Radius.circular(35),
                          ),
                          child: imgUrl != null
                              ? Image.network(imgUrl, fit: BoxFit.cover)
                              : Container(color: Colors.grey.shade300),
                        ),
                      ),

                      // DARK OVERLAY
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // EDIT BTN
                      Positioned(
                        left: 20,
                        top: 60,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddNewTripModal(trip: trip),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.edit, color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  "Edit",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // CONTENT
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 30,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // STATUS
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          label: Text(
                            trip['status'] == 'planned'
                                ? "Planned"
                                : "Completed",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: trip['status'] == 'planned'
                              ? Colors.blue
                              : Colors.green,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // INFO CARD (budget, place, date)
                      _buildInfoCard(),

                      const SizedBox(height: 20),

                      Text(
                        "Notes",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          trip['notes'] ?? "No details provided.",
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 3),
            blurRadius: 12,
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        children: [
          _item("Place", trip['place_name'] ?? "—", Icons.location_on),
          const Divider(height: 22),
          _item("Budget", "${trip['budget'] ?? 0} ₮", Icons.wallet),
          const Divider(height: 22),
          _item("Start Date", trip['start_date'] ?? "—", Icons.calendar_today),
          const Divider(height: 22),

          _item("End Date", trip['end_date'] ?? "—", Icons.calendar_month),
        ],
      ),
    );
  }

  Widget _item(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Color.fromARGB(255, 238, 128, 139), size: 22),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: Colors.black54),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
