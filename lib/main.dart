import 'package:flutter/material.dart';
import 'homepage_buttons.dart';
import 'database_provider.dart';
import 'database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  appDatabase = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .build();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group project',
      home: HomePageWithButtons(), // New home page
    );
  }
}