import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'AirplaneList/airplane_item.dart';
import 'AirplaneList/airplane_items_dao.dart';
import 'SalesList/sales_items_dao.dart';
import 'SalesList/sales_item.dart';
import 'CustomerList/customer_item.dart';
import 'CustomerList/customer_items_dao.dart';
part 'database.g.dart'; // the generated code will be there



@Database(
  version: 1,
  entities: [
    SalesItem,
    CustomerItem,
    AirplaneItem
    // Add more entities like Car, Dealership if needed
  ],
)
abstract class AppDatabase extends FloorDatabase {
  SalesItemsDao get salesItemsDao;
  CustomerItemsDao get customerItemsDao;
  AirplaneItemsDao get airplaneItemsDao;
// Add more DAOs as needed
}

