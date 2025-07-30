import 'package:floor/floor.dart';
import 'flights.dart';

@dao
abstract class FlightDao {
  @Query('SELECT * FROM Flight')
  Future<List<Flight>> findAllFlights();

  @Query('SELECT * FROM Flight WHERE id = :id')
  Stream<Flight?> findFlightById(int id);

  @insert
  Future<int> insertFlight(Flight flight);

  @update
  Future<int> updateFlight(Flight flight);

  @delete
  Future<int> deleteFlight(Flight flight);
}
