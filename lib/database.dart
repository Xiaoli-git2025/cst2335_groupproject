import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'items_dao.dart';
import 'item.dart';

part 'database.g.dart'; // the generated code will be there


@Database(version: 1, entities: [Item])
abstract class AppDatabase extends FloorDatabase {
  ItemsDao get itemsDao;
}