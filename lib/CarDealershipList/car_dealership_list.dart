import 'package:flutter/material.dart';
import '../database.dart';
import '../database_provider.dart';

class DealershipListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Car Dealership List')),
      body: Center(child: Text('This is the Dealership List Page')),
    );
  }
}