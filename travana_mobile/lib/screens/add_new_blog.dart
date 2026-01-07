import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show File;

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'place.dart';

class AddNewBlogPage extends StatefulWidget {
  final Map<String, dynamic>? blog;

  const AddNewBlogPage({Key? key, this.blog}) : super(key: key);

  @override
  State<AddNewBlogPage> createState() => _AddNewBlogPageState();
}

class _AddNewBlogPageState extends State<AddNewBlogPage> {
  final _contentController = TextEditingController();
  final _placeController = TextEditingController();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  int? _selectedPlaceId;
  bool _isPublic = true;

  final List<Uint8List> _imagesWeb = [];
  final List<XFile> _imagesMobile = [];

  @override
  void initState() {
    super.initState();
    final blog = widget.blog;
    if (blog != null) {
      _contentController.text = blog['content']?.toString() ?? '';
      _isPublic = blog['is_public'] ?? true;

      final place = blog['place'];
      if (place is Map<String, dynamic>) {
        _placeController.text = place['name']?.toString() ?? '';
        _selectedPlaceId = place['id'];
      }
    }
  }

  Future<String?> _getToken() async {
    if (kIsWeb) {
      return html.window.localStorage['access_token'];
    }
    return _storage.read(key: 'access_token');
  }

  Future<void> _pickImages() async {
    if (kIsWeb) {
      final input = html.FileUploadInputElement()
        ..multiple = true
        ..accept = 'image/*';
      input.click();

      input.onChange.listen((_) {
        for (final file in input.files ?? []) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((_) {
            setState(() {
              _imagesWeb.add(reader.result as Uint8List);
            });
          });
        }
      });
    } else {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() => _imagesMobile.addAll(picked));
      }
    }
  }

  Future<void> _saveBlog() async {
    final token = await _getToken();
    if (token == null) return;

    final isEdit = widget.blog != null;
    final url = isEdit
        ? Uri.parse('http://127.0.0.1:8000/api/blogs/${widget.blog!['id']}/')
        : Uri.parse('http://127.0.0.1:8000/api/blogs/');

    final request = http.MultipartRequest(isEdit ? 'PUT' : 'POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['content'] = _contentController.text;
    request.fields['is_public'] = _isPublic.toString();

    if (_selectedPlaceId != null) {
      request.fields['place_id'] = _selectedPlaceId.toString();
    }

    if (kIsWeb) {
      for (final img in _imagesWeb) {
        request.files.add(
          http.MultipartFile.fromBytes('images', img, filename: 'image.png'),
        );
      }
    } else {
      for (final img in _imagesMobile) {
        request.files.add(
          await http.MultipartFile.fromPath('images', img.path),
        );
      }
    }

    final response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!mounted) return;
      Navigator.pop(context, {'refresh': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagesCount = kIsWeb ? _imagesWeb.length : _imagesMobile.length;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              widget.blog == null ? 'Add Blog' : 'Edit Blog',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2F7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFCDE0)),
                        ),
                        child: const Center(
                          child: Icon(Icons.add_a_photo, size: 32),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    if (imagesCount > 0)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: imagesCount,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemBuilder: (_, i) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb
                                    ? Image.memory(
                                        _imagesWeb[i],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                    : Image.file(
                                        File(_imagesMobile[i].path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (kIsWeb) {
                                        _imagesWeb.removeAt(i);
                                      } else {
                                        _imagesMobile.removeAt(i);
                                      }
                                    });
                                  },
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black54,
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                    const SizedBox(height: 6),

                    TextField(
                      maxLines: null,
                      minLines: 2,
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 135, 134, 134),
                          fontSize: 14,
                        ),
                        floatingLabelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 255, 200, 218),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 238, 128, 139),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: () async {
                        final selectedPlace = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PlacePage()),
                        );
                        if (selectedPlace != null) {
                          setState(() {
                            _placeController.text =
                                selectedPlace['name'] ?? _placeController.text;
                            _selectedPlaceId =
                                selectedPlace['id'] ?? _selectedPlaceId;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF2F7),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: const BorderSide(color: Color(0xFFFFCDE0)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.place,
                                color: Colors.black,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _placeController.text.isEmpty
                                    ? 'Place'
                                    : _placeController.text,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Public blog',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        secondary: Icon(
                          Icons.lock_open,
                          color: _isPublic ? Colors.green : Colors.red,
                        ),
                        value: _isPublic,
                        onChanged: (v) => setState(() => _isPublic = v),
                        activeTrackColor: Colors.green,
                        inactiveTrackColor: Colors.red.shade200,
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            // save cancel button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 255, 200, 218),
                      ),
                    ),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 14,
                    ),
                    label: const Text(
                      'Close',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saveBlog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 238, 128, 139),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                    label: const Text(
                      'Save',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
