import 'package:floor/floor.dart';

@Entity(tableName: 'CustomerItem')
class CustomerItem {
  @primaryKey
  final int id;
  final String firstname;
  final String lastname;
  final String address;
  final String dateOfBirth;

  CustomerItem(this.id, this.firstname, this.lastname, this.address, this.dateOfBirth);
}
