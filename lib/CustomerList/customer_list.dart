import 'package:flutter/material.dart';
import '../database.dart';
import '../database_provider.dart';

class CustomerListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer List')),
      body: Center(child: Text('This is the Customer List Page')),
    );
  }
}