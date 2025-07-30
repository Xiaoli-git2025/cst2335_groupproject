import 'package:floor/floor.dart';

@entity
class Flight {
  @primaryKey
  final int? id; // auto-generated or assigned id

  final String departureCity;
  final String destinationCity;
  final String departureTime; // store as String or better DateTime serialized
  final String arrivalTime;

  Flight({
    this.id,
    required this.departureCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
  });

  Flight copyWith({
    int? id,
    String? departureCity,
    String? destinationCity,
    String? departureTime,
    String? arrivalTime,
  }) {
    return Flight(
      id: id ?? this.id,
      departureCity: departureCity ?? this.departureCity,
      destinationCity: destinationCity ?? this.destinationCity,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
    );
  }
}
