import 'package:floor/floor.dart';
import 'airplane_item.dart';

@dao
abstract class AirplaneItemsDao {
  //This performs a SQL select operation where the p.id matches that in the database
  @Query('SELECT * FROM AirplaneItem')
  Future<List<AirplaneItem>> findAllItems();

  //This performs a SQL delete operation where the p.id matches that in the database
  @delete
  Future<void> deleteItem(AirplaneItem item);

  //This performs a SQL insert operation, but you must create a unique id variable
  @insert
  Future<void> insertItem(AirplaneItem item);
  //This performs a SQL update operation, but you must create a unique id variable
  @update
  Future<void> updateItem(AirplaneItem item);
}