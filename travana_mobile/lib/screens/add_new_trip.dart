import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:travana_mobile/screens/place.dart';
import 'package:travana_mobile/screens/trip_bucket_list.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class AddNewTripModal extends StatefulWidget {
  const AddNewTripModal({super.key});

  @override
  State<AddNewTripModal> createState() => _AddNewTripModalState();
}

class _AddNewTripModalState extends State<AddNewTripModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  String _selectedCountry = '₮';
  File? _selectedImageFile; // Mobile
  Uint8List? _selectedImageMemory; // Web

  DateTime? startDate;
  DateTime? endDate;
  int? _selectedPlaceId;

  // ------------------------------
  //     SAVE TRIP → BACKEND
  // ------------------------------
  Future<void> _saveTrip() async {
    if (_titleController.text.isEmpty ||
        _placeController.text.isEmpty ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final url = Uri.parse("http://127.0.0.1:8000/api/trips/");

    var request = http.MultipartRequest("POST", url);

    request.fields['title'] = _titleController.text;
    request.fields['notes'] = _noteController.text;
    request.fields['budget'] = _budgetController.text;
    request.fields['currency'] = _selectedCountry;
    request.fields['place'] = _selectedPlaceId.toString();
    request.fields['start_date'] = DateFormat('yyyy-MM-dd').format(startDate!);
    request.fields['end_date'] = DateFormat('yyyy-MM-dd').format(endDate!);

    // ---- MOBILE IMAGE ----
    if (_selectedImageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImageFile!.path),
      );
    }

    // ---- WEB IMAGE ----
    if (_selectedImageMemory != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          _selectedImageMemory!,
          filename: 'upload.png',
        ),
      );
    }

    var response = await request.send();
    var respStr = await response.stream.bytesToString();

    if (response.statusCode == 201 || response.statusCode == 200) {
      Navigator.pop(context, jsonDecode(respStr));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Trip saved successfully!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed (${response.statusCode})")),
      );
    }
  }

  // ------------------------------
  //       PICK IMAGE (WEB/MOBILE)
  // ------------------------------
  Future<void> _pickImage() async {
    if (kIsWeb) {
      final html.InputElement input = html.InputElement(type: "file");
      input.accept = "image/*";
      input.click();

      input.onChange.listen((event) {
        final file = input.files!.first;
        final reader = html.FileReader();

        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((event) {
          setState(() {
            _selectedImageMemory = reader.result as Uint8List;
          });
        });
      });
    } else {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      setState(() {
        _selectedImageFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 580,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const Text(
            'Add trip',
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 254, 238, 248),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 200, 218),
                        ),
                      ),
                      child: _selectedImageMemory != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _selectedImageMemory!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : _selectedImageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _selectedImageFile!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
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
                        borderSide: const BorderSide(color: Color.fromARGB(255, 238, 128, 139)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  TextField(
                    maxLines: null,
                    minLines: 3,
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
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
                        borderSide: const BorderSide(color: Color.fromARGB(255, 238, 128, 139)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  Row(
                    children: [
                      SizedBox(
                        width: 170,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => startDate = picked);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              254,
                              238,
                              248,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const Icon(
                            Icons.calendar_month,
                            color: Colors.black,
                          ),
                          label: FittedBox(
                            child: Text(
                              startDate == null
                                  ? 'Start Date'
                                  : DateFormat('yyyy-MM-dd').format(startDate!),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),
                      SizedBox(
                        width: 170,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => endDate = picked);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              254,
                              238,
                              248,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const Icon(
                            Icons.calendar_month,
                            color: Colors.black,
                          ),
                          label: FittedBox(
                            child: Text(
                              endDate == null
                                  ? 'End Date'
                                  : DateFormat('yyyy-MM-dd').format(endDate!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Budget',
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
                            prefixIcon: const Icon(
                              Icons.savings,
                              color: Colors.black,
                              size: 20,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 238, 128, 139),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCountry,
                          items: const [
                            DropdownMenuItem(value: '₮', child: Text('🇲🇳 ₮')),
                            DropdownMenuItem(value: '¥', child: Text('🇯🇵 ¥')),
                            DropdownMenuItem(
                              value: '\$',
                              child: Text('🇺🇸 \$'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCountry = value!;
                            });
                          },
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 255, 200, 218),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 255, 200, 218),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedPlace = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlacePage()),
                      );
                      if (selectedPlace != null) {
                        setState(() {
                          _placeController.text = selectedPlace['name'];
                          _selectedPlaceId = selectedPlace['id'];
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
                ],
              ),
            ),
          ),

          // Bottom
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
                  icon: const Icon(Icons.close, color: Colors.black, size: 14),
                  label: const Text(
                    'Close',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _saveTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 238, 128, 139),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.check, color: Colors.white, size: 14),
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
    );
  }
}
