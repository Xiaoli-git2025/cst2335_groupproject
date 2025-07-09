import 'package:flutter/material.dart';
import '../database.dart';
import '../database_provider.dart';

class CarListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Car List')),
      body: Center(child: Text('This is the Car List Page')),
    );
  }
}