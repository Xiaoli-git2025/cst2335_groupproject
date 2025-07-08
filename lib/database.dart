import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'SalesList/sales_items_dao.dart';
import 'SalesList/sales_item.dart';

part 'database.g.dart'; // the generated code will be there


@Database(version: 1, entities: [SalesItem])
abstract class AppDatabase extends FloorDatabase {
  SalesItemsDao get salesItemsDao;
}