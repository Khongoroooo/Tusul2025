import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travana_mobile/generated/l10n.dart';

class PlacePage extends StatefulWidget {
  @override
  State<PlacePage> createState() => _PlacePage();
}

class _PlacePage extends State<PlacePage> {
  List<dynamic> places = [];
  List<dynamic> filteredPlaces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  Future<void> fetchPlaces() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/places/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        places = data;
        filteredPlaces = data;
        isLoading = false;
      });
    } else {
      print("Error:${response.statusCode}");
    }
  }

  void _filterSearch(String query) async {
    final url = Uri.parse("http://127.0.0.1:8000/api/places/");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        filteredPlaces = data;
      });
    } else {
      print("Error:${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Place')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      place['name'] ?? 'No name',
                      style: const TextStyle(fontSize: 18),
                    ),
                    onTap: () {
                      Navigator.pop(context, place);
                    },
                  ),
                );
              },
            ),
    );
  }
}
