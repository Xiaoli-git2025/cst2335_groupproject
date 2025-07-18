import 'package:floor/floor.dart';
import 'customer_item.dart';

@dao
abstract class CustomerItemsDao {
  //this performs a SQL query and returns a List of your @entity class
  @Query('SELECT * FROM CustomerItem')
  Future<List<CustomerItem>> findAllItems();


  //This performs a SQL delete operation where the p.id matches that in the database
  @delete
  Future<void> deleteItem(CustomerItem item);

  //This performs a SQL insert operation, but you must create a unique id variable
  @insert
  Future<void> insertItem(CustomerItem item);

  @Query('SELECT firstname || " " || lastname FROM CustomerItem WHERE id = :id')
  Future<String?> getCustomerFullNameById(int id);

}