import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import '../generated/l10n.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback toggleLanguage;
  final Locale locale;

  const RegisterScreen({
    super.key,
    required this.toggleLanguage,
    required this.locale,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureRePassword = true;

  // -------------------------
  // API холболт
  // -------------------------
  void handleRegister() async {
    if (passwordController.text != repasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).passwordNotMatch),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url = Uri.parse(
      'http://127.0.0.1:8000/auth/users/',
    ); // Django API endpoint
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
          're_password': repasswordController.text,
        }),
      );

      if (response.statusCode == 201) {
        // Амжилттай бүртгэл
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully registered!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Login руу буцах
      } else {
        // Алдаа гарсан тохиолдолд
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data.toString()), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: InkWell(
              onTap: widget.toggleLanguage,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color.fromARGB(255, 238, 128, 139),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.language, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      widget.locale.languageCode.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/logo.png',
                width: screenWidth * 0.8,
                height: screenHeight * 0.23,
              ),
              SizedBox(height: screenHeight * 0.03),

              // Email
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: S.of(context).email,
                  labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFFF8AEB6),
                      width: 1,
                    ),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(Iconsax.sms, size: 22, color: Colors.grey[600]),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: screenHeight * 0.02),

              // Password
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: S.of(context).password,
                  labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFFEE808B),
                      width: 1,
                    ),
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Iconsax.key, size: 22),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Re-enter password
              TextField(
                controller: repasswordController,
                obscureText: _obscureRePassword,
                decoration: InputDecoration(
                  labelText: S.of(context).reEnterPassword,
                  labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFFEE808B),
                      width: 1,
                    ),
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Iconsax.key, size: 22),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureRePassword ? Iconsax.eye_slash : Iconsax.eye,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() => _obscureRePassword = !_obscureRePassword);
                    },
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.07),

              ElevatedButton(
                onPressed: handleRegister,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFFEE808B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  S.of(context).signUp,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  S.of(context).haveAccountSignIn,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
