import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../database.dart';
import 'flights.dart';
import 'flight_dao.dart';

class FlightsPage extends StatefulWidget {
  final AppDatabase database;

  const FlightsPage({Key? key, required this.database}) : super(key: key);

  @override
  _FlightsPageState createState() => _FlightsPageState();
}

class _FlightsPageState extends State<FlightsPage> {
  late FlightDao _flightDao;
  late Future<List<Flight>> _flightsFuture;

  void _confirmDeleteFlight(Flight flight) {
    print('Long pressed on flight: ${flight.departureCity} -> ${flight.destinationCity}');  // Debug print

    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.title_sales),
        content: Text(loc.msg_sales_confirm_delete ?? 'Are you sure you want to delete this flight?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.no),
          ),
          ElevatedButton(
            onPressed: () async {
              await _flightDao.deleteFlight(flight);
              Navigator.pop(context);
              _loadFlights();  // _loadFlights already calls setState now

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.flight_deleted)),
              );
            },
            child: Text(loc.yes),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _flightDao = widget.database.flightDao;
    _loadFlights();
  }

  void _loadFlights() {
    setState(() {
      _flightsFuture = _flightDao.findAllFlights();
    });
  }

  void _showAddFlightDialog() {
    final loc = AppLocalizations.of(context)!;
    final departureController = TextEditingController();
    final destinationController = TextEditingController();
    final departureTimeController = TextEditingController();
    final arrivalTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.title_sales),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: departureController,
                  decoration: InputDecoration(labelText: loc.lbl_sales_depart_city),
                ),
                TextField(
                  controller: destinationController,
                  decoration: InputDecoration(labelText: loc.lbl_sales_destination_city),
                ),
                TextField(
                  controller: departureTimeController,
                  decoration: InputDecoration(labelText: loc.lbl_sales_depart_time),
                ),
                TextField(
                  controller: arrivalTimeController,
                  decoration: InputDecoration(labelText: loc.lbl_sales_arrive_time),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.no),
            ),
            ElevatedButton(
              onPressed: () async {
                if (departureController.text.isEmpty ||
                    destinationController.text.isEmpty ||
                    departureTimeController.text.isEmpty ||
                    arrivalTimeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.msg_sales_no_item)),
                  );
                  return;
                }

                final flight = Flight(
                  departureCity: departureController.text,
                  destinationCity: destinationController.text,
                  departureTime: departureTimeController.text,
                  arrivalTime: arrivalTimeController.text,
                );

                await _flightDao.insertFlight(flight);
                Navigator.pop(context);

                _loadFlights();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${loc.title_sales} ${loc.msg_sales_add}')),
                );
              },
              child: Text(loc.msg_sales_add),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFlightList(List<Flight> flights) {
    final loc = AppLocalizations.of(context)!;
    if (flights.isEmpty) {
      return Center(child: Text(loc.msg_sales_no_item));
    }
    return ListView.builder(
      itemCount: flights.length,
      itemBuilder: (context, index) {
        final flight = flights[index];
        return GestureDetector(
          onLongPress: () => _confirmDeleteFlight(flight),
          child: ListTile(
            title: Text('${flight.departureCity} → ${flight.destinationCity}'),
            subtitle: Text(
                '${loc.lbl_sales_depart_time}: ${flight.departureTime}, ${loc.lbl_sales_arrive_time}: ${flight.arrivalTime}'),
            onTap: () {
              // TODO: show flight details or edit page
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.title_sales),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(loc.menu_help),
                  content: Text(loc.msg_sales_help_description),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(loc.yes)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Flight>>(
        future: _flightsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(loc.msg_sales_no_item));
          }
          return _buildFlightList(snapshot.data ?? []);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFlightDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
