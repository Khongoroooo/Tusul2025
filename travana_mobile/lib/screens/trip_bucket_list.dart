import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TripListPage extends StatefulWidget {
  const TripListPage({super.key});

  @override
  State<TripListPage> createState() => _TripListPageState();
}

class _TripListPageState extends State<TripListPage> {
  String selected = 'want'; // "want" эсвэл "visited" гэсэн төлөв
  int selectedIndex = -1;

  // Жишээ дата (хүсвэл API эсвэл backend-ээс авч болно)
  final List<Map<String, dynamic>> data = [
    {
      'name': 'Great Wall of China',
      'country': 'China',
      'image': 'assets/images/china.webp',
      'status': 'want',
    },
    {
      'name': 'Eiffel Tower',
      'country': 'France',
      'image': 'assets/images/paris.jpg',
      'status': 'visited',
    },
    {
      'name': 'Tokyo Tower',
      'country': 'Japan',
      'image': 'assets/images/japan.jpg',
      'status': 'want',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Сонгогдсон төрлийн жагсаалт шүүх
    final filtered = data.where((e) => e['status'] == selected).toList();

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
      body: Column(
        children: [
          const SizedBox(height: 30),
          // Сонгох chip-үүд
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text(
                  'Want to visit',
                  style: TextStyle(
                    color: selected == 'want' ? Colors.white : Colors.black,
                  ),
                ),
                selected: selected == 'want',
                selectedColor: Colors.pinkAccent,
                checkmarkColor: Colors.white,
                onSelected: (_) {
                  setState(() => selected = 'want');
                },
              ),
              const SizedBox(width: 20),
              ChoiceChip(
                label: Text(
                  'Visited',
                  style: TextStyle(
                    color: selected == 'visited' ? Colors.white : Colors.black,
                  ),
                ),
                selected: selected == 'visited',
                selectedColor: Colors.pinkAccent,
                checkmarkColor: Colors.white,
                onSelected: (_) {
                  setState(() => selected = 'visited');
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Жагсаалт хэсэг
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          item['image'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(item['country']),
                      trailing: Icon(
                        selected == 'want' ? Iconsax.map : Iconsax.tick_circle,
                        color: Colors.pinkAccent,
                      ),
                      onTap: () {
                        setState(() => selectedIndex = index);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => 'gd',
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Iconsax.add, size: 28, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    );
  }
}
