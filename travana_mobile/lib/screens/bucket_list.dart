import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Шинэ item нэмэх page
class BucketListAddPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const BucketListAddPage({super.key, required this.onSave});

  @override
  State<BucketListAddPage> createState() => _BucketListAddPageState();
}

class _BucketListAddPageState extends State<BucketListAddPage> {
  final _formKey = GlobalKey<FormState>();
  String? title;
  String? description;
  DateTime? startDate;
  DateTime? endDate;
  File? imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Bucket Item'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Image picker
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: imageFile == null
                      ? const Center(child: Text('Tap to add image'))
                      : Image.file(imageFile!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => title = value,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) => description = value,
              ),
              const SizedBox(height: 16),

              // Date range
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => startDate = picked);
                      },
                      child: Text(startDate == null
                          ? 'Start Date'
                          : DateFormat('yyyy-MM-dd').format(startDate!)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => endDate = picked);
                      },
                      child: Text(endDate == null
                          ? 'End Date'
                          : DateFormat('yyyy-MM-dd').format(endDate!)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Save button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    widget.onSave({
                      "title": title,
                      "description": description,
                      "startDate": startDate,
                      "endDate": endDate,
                      "done": false,
                      "image": imageFile != null
                          ? imageFile!.path
                          : "assets/images/travana_logo.png",
                    });

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Гол BucketList page
class BucketListPage extends StatefulWidget {
  const BucketListPage({super.key});

  @override
  State<BucketListPage> createState() => _BucketListPageState();
}

class _BucketListPageState extends State<BucketListPage> {
  final List<Map<String, dynamic>> bucketItems = [
    {
      "title": "Visit Paris",
      "image": "assets/images/travana_logo.png",
      "done": false,
    },
    {
      "title": "Climb Mount Fuji",
      "image": "assets/images/travana_logo.png",
      "done": true,
    },
    {
      "title": "Go Skydiving",
      "image": "assets/images/travana_logo.png",
      "done": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'MY BUCKET LIST',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: bucketItems.length,
        itemBuilder: (context, index) {
          final item = bucketItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item["image"].toString().startsWith("assets")
                    ? Image.asset(
                        item["image"],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(item["image"]),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
              ),
              title: Text(
                item["title"] ?? "Untitled",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: item["done"] == true
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              trailing: Checkbox(
                value: item["done"] ?? false,
                activeColor: Colors.pinkAccent,
                onChanged: (value) {
                  setState(() {
                    item["done"] = value;
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BucketListAddPage(
                onSave: (newItem) {
                  setState(() {
                    bucketItems.add(newItem);
                  });
                },
              ),
            ),
          );
        },
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Iconsax.add, size: 28, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    );
  }
}
