import 'package:flutter/material.dart';

class TripDetail extends StatefulWidget {
  const TripDetail({super.key});

  @override
  State<TripDetail> createState() => _TripDetail();
}

class _TripDetail extends State<TripDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TripDetail')),
      body: Text('textSpan'),
    );
  }
}
