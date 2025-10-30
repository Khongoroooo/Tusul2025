import 'package:flutter/material.dart';
import 'package:travana_mobile/screens/login.dart';
import 'generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('mn');

  void toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'mn'
          ? const Locale('en')
          : const Locale('mn');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'travana',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: LoginScreen(toggleLanguage: toggleLanguage, locale: _locale),
    );
  }
}
