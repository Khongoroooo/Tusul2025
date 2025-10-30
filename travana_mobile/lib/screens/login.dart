import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:travana_mobile/screens/home_page.dart';
import '../generated/l10n.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback toggleLanguage;
  final Locale locale;

  const LoginScreen({
    super.key,
    required this.toggleLanguage,
    required this.locale,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  void handleLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
    // Login логик энд
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text(''),
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
                  color: Colors.pinkAccent,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/travana_logo.png',
              width: screenWidth * 0.8,
              height: screenHeight * 0.25,
            ),
            SizedBox(height: screenHeight * 0.03),

            // Email input
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: S.of(context).email,
                labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Colors.pinkAccent,
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

            // Password input
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: S.of(context).password,
                labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Colors.pinkAccent,
                    width: 1,
                  ),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(Iconsax.key, size: 22, color: Colors.grey[600]),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(S.of(context).forgotPasswordDialogTitle),
                      content: Text(S.of(context).forgotPasswordDialogContent),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(S.of(context).close),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(S.of(context).forgotPassword),
              ),
            ),

            SizedBox(height: screenHeight * 0.1),

            // Sign in button
            ElevatedButton(
              onPressed: handleLogin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                S.of(context).signIn,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Sign up button
            ElevatedButton(
              onPressed: handleLogin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 215, 183, 196),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                S.of(context).signUp,
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
