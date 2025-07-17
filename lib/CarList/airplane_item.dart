import 'package:floor/floor.dart';

@Entity(tableName: 'AirplaneItem')
class AirplaneItem {
  //static int ID = 1;

  @primaryKey
  final int? id;
  final String airplane_model;
  final int max_passengers;
  final int max_speed;
  final int max_mileage;
  AirplaneItem(this.id, this.airplane_model, this.max_passengers, this.max_speed, this.max_mileage);
}