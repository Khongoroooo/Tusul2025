import 'package:flutter/material.dart';
import 'package:travana_mobile/screens/blogs.dart';
import 'package:travana_mobile/screens/home.dart';
import 'package:travana_mobile/screens/profile.dart';
import 'package:travana_mobile/screens/trip_bucket_list.dart';
// import '../widgets/top_bar.dart';
import '../widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Home(),
    TripListPage(),
    Center(child: Text('Flights Page', style: TextStyle(fontSize: 20))),

    BlogsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // appBar: TopBar(
      //   onNotificationTap: () {
      //     ScaffoldMessenger.of(
      //       context,
      //     ).showSnackBar(const SnackBar(content: Text('Notifications tapped')));
      //   },
      // ),
      body: _pages[_currentIndex],

      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
