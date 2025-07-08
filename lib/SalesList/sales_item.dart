import 'package:floor/floor.dart';

@entity
class SalesItem {
  static int ID = 1;

  @primaryKey
  final int id;
  final String name;
  final int quantity;

  SalesItem(this.id, this.name, this.quantity);
}