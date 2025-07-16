import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'CarList/airplane_item.dart';
import 'CarList/airplane_items_dao.dart';
import 'SalesList/sales_items_dao.dart';
import 'SalesList/sales_item.dart';
part 'database.g.dart'; // the generated code will be there

@Database(
  version: 1,
  entities: [SalesItem,AirplaneItem],)
//@Database(version: 1, entities: [SalesItem, Customer, Car, Dealership])
abstract class AppDatabase extends FloorDatabase {
  SalesItemsDao get salesItemsDao;
  AirplaneItemsDao get airplaneItemsDao;
//CarDao get carDao;
//DealershipDao get dealershipDao;
}