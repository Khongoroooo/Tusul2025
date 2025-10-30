import 'package:flutter/material.dart';
import 'package:travana_mobile/screens/bucket_list.dart';
import 'package:travana_mobile/screens/home.dart';
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
    BucketListPage(),
    Center(child: Text('Flights Page', style: TextStyle(fontSize: 20))),
    Center(child: Text('Activity Page', style: TextStyle(fontSize: 20))),
    Center(child: Text('Profile Page', style: TextStyle(fontSize: 20))),
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
