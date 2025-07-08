import 'package:floor/floor.dart';
import 'item.dart';

@dao
abstract class ItemsDao {
  //this performs a SQL query and returns a List of your @entity class
  @Query('SELECT * FROM Item')
  Future<List<Item>> findAllItems();


  //This performs a SQL delete operation where the p.id matches that in the database
  @delete
  Future<void> deleteItem(Item item);

  //This performs a SQL insert operation, but you must create a unique id variable
  @insert
  Future<void> insertItem(Item item);
}