import 'package:floor/floor.dart';

@entity
class Item {
  static int ID = 1;

  @primaryKey
  final int id;
  final String name;
  final int quantity;

  Item(this.id, this.name, this.quantity);
}