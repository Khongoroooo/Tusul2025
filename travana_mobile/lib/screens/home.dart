import 'package:flutter/material.dart';
import 'package:travana_mobile/widgets/search_bar.dart';
import 'package:travana_mobile/widgets/top_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> countries = [
    {
      'name': 'Thailand',
      'description': 'Нарлаг далайн эрэг, сонирхолтой соёлын орон.',
      'image': 'assets/images/thailand.jpg',
    },
    {
      'name': 'China',
      'description': 'Эртний соёл иргэншил, гайхамшигт газарзүй.',
      'image': 'assets/images/china.webp',
    },
    {
      'name': 'Vietnam',
      'description': 'Халуун орны байгаль, амтат хоол, энгийн амьдрал.',
      'image': 'assets/images/vietnam.jpg',
    },
    {
      'name': 'Mongolia',
      'description': 'Өргөн уудам тал нутаг, нүүдэлчин соёл.',
      'image': 'assets/images/mongolia.jpg',
    },
  ];

  // ✳️ filteredCountries жагсаалт
  late List<Map<String, dynamic>> filteredCountries;

  @override
  void initState() {
    super.initState();
    filteredCountries = countries;
  }

  // 🔍 Search filter function
  void _filterSearch(String query) {
    final results = countries.where((country) {
      final name = country['name']!.toLowerCase();
      final desc = country['description']!.toLowerCase();
      final input = query.toLowerCase();
      return name.contains(input) || desc.contains(input);
    }).toList();

    setState(() {
      filteredCountries = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopBar(), // ← өөрийн top_bar чинь
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: SearchBarWidget(
                controller: _searchController,
                hintText: 'Улс хайх...',
                onChanged: _filterSearch,
              ),
            ),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 багана
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = filteredCountries[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.asset(
                            country['image'],
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Text(
                            country['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            country['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
