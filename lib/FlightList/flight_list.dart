import 'package:flutter/material.dart';
import '../database.dart';
import '../database_provider.dart';

class FlightListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FLight List')),
      body: Center(child: Text('This is the Flight List Page')),
    );
  }
}