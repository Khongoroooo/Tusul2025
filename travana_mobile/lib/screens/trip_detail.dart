import 'package:flutter/material.dart';

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
      body: CustomScrollView(
        slivers: [
          // ------------ FULLSCREEN HEADER IMAGE ------------
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.black,
            elevation: 0,
            automaticallyImplyLeading: false,

            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),

            title: Text(
              trip['title'] ?? "",
              style: const TextStyle(color: Colors.white),
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // -------- IMAGE FULLSCREEN --------
                  Positioned.fill(
                    child: imgUrl != null
                        ? Image.network(imgUrl, fit: BoxFit.cover)
                        : Container(color: Colors.grey),
                  ),

                  // -------- EDIT BUTTON WITH TEXT --------
                  Positioned(
                    right: 16,
                    top: 40,
                    child: GestureDetector(
                      onTap: () {
                        print("Edit clicked");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.edit, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "Edit",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // -------- GRADIENT OVERLAY --------
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black54,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -------------- CONTENT SECTION --------------
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(
                      trip['status'] == 'planned' ? "Planned" : "Completed",
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor:
                        trip['status'] == 'planned' ? Colors.blue : Colors.green,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    trip['notes'] ?? "No details",
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
