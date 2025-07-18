import 'package:floor/floor.dart';

@Entity(tableName: 'SalesItem')
class SalesItem {
  //static int ID = 1;

  @primaryKey
  final int id;
  final int customer_id;
  final String flight_id;
  final String reservation_name;
  final String purchase_date;
  SalesItem(this.id, this.customer_id, this.flight_id, this.reservation_name, this.purchase_date);
}