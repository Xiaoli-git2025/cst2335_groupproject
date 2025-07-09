import 'package:floor/floor.dart';

@Entity(tableName: 'SalesItem')
class SalesItem {
  //static int ID = 1;

  @primaryKey
  final int id;
  final int customer_id;
  final int car_id;
  final int dealership_id;
  final String purchase_date;
  SalesItem(this.id, this.customer_id, this.car_id, this.dealership_id, this.purchase_date);
}