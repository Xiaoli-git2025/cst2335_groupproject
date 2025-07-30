import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'AirplaneList/airplane_item.dart';
import 'AirplaneList/airplane_items_dao.dart';
import 'SalesList/sales_items_dao.dart';
import 'SalesList/sales_item.dart';
import 'FlightList/flight_dao.dart';
import 'FlightList/flights.dart';
import 'CustomerList/customer_item.dart';
import 'CustomerList/customer_items_dao.dart';
part 'database.g.dart'; // the generated code will be there


/// The main database class annotated with `@Database`.
///
/// This class defines the version and the list of entities (tables)
/// included in the database. It also provides access to the associated
/// DAO (Data Access Object) interfaces.
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
  /// Gets the DAO for accessing reservation item records.
  SalesItemsDao get salesItemsDao;
  /// Gets the DAO for accessing customer item records.
  CustomerItemsDao get customerItemsDao;
  /// Gets the DAO for accessing airplane item records.
  AirplaneItemsDao get airplaneItemsDao;
  FlightDao get flightDao;

// Add more DAOs as needed
}

