import 'package:floor/floor.dart';
import 'sales_item.dart';

@dao
abstract class SalesItemsDao {
  //this performs a SQL query and returns a List of your @entity class
  @Query('SELECT * FROM SalesItem')
  Future<List<SalesItem>> findAllItems();


  //This performs a SQL delete operation where the p.id matches that in the database
  @delete
  Future<void> deleteItem(SalesItem item);

  //This performs a SQL insert operation, but you must create a unique id variable
  @insert
  Future<void> insertItem(SalesItem item);
}