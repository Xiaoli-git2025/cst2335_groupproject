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
  List<Flight> _flights = [];
  Flight? _selectedFlight;

  final _departureCityController = TextEditingController();
  final _destinationCityController = TextEditingController();
  final _departureTimeController = TextEditingController();
  final _arrivalTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _flightDao = widget.database.flightDao;
    _loadFlights();
  }

  Future<void> _loadFlights() async {
    final flights = await _flightDao.findAllFlights();
    setState(() {
      _flights = flights;
    });
  }

  Future<void> _addOrUpdateFlight() async {
    final depCity = _departureCityController.text.trim();
    final destCity = _destinationCityController.text.trim();
    final depTime = _departureTimeController.text.trim();
    final arrTime = _arrivalTimeController.text.trim();

    if (depCity.isEmpty || destCity.isEmpty || depTime.isEmpty || arrTime.isEmpty) return;

    if (_selectedFlight == null) {
      // Add flight
      final newFlight = Flight(
        departureCity: depCity,
        destinationCity: destCity,
        departureTime: depTime,
        arrivalTime: arrTime,
      );
      await _flightDao.insertFlight(newFlight);
      _showMessage(AppLocalizations.of(context)!.msg_sales_add);
    } else {
      // Update flight
      final updatedFlight = Flight(
        id: _selectedFlight!.id,
        departureCity: depCity,
        destinationCity: destCity,
        departureTime: depTime,
        arrivalTime: arrTime,
      );
      await _flightDao.updateFlight(updatedFlight);
      _showMessage('Flight updated');
    }

    _clearForm();
    _loadFlights();
  }

  Future<void> _confirmDeleteFlight(Flight flight) async {
    final loc = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.title_sales),
        content: Text(loc.msg_sales_confirm_delete ?? 'Delete this flight?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.no)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(loc.yes)),
        ],
      ),
    );

    if (confirm == true) {
      await _flightDao.deleteFlight(flight);
      _clearForm();
      _loadFlights();
      _showMessage(loc.flight_deleted);
    }
  }

  void _selectFlight(Flight flight) {
    setState(() {
      _selectedFlight = flight;
      _departureCityController.text = flight.departureCity;
      _destinationCityController.text = flight.destinationCity;
      _departureTimeController.text = flight.departureTime;
      _arrivalTimeController.text = flight.arrivalTime;
    });
  }

  void _clearForm() {
    setState(() {
      _departureCityController.clear();
      _destinationCityController.clear();
      _departureTimeController.clear();
      _arrivalTimeController.clear();
      _selectedFlight = null;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: Duration(seconds: 2)));
  }

  Widget _responsiveLayout(double width, double height) {
    Widget formAndList = Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _departureCityController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.lbl_sales_depart_city,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _destinationCityController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.lbl_sales_destination_city,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _departureTimeController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.lbl_sales_depart_time,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _arrivalTimeController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.lbl_sales_arrive_time,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addOrUpdateFlight,
                  icon: Icon(_selectedFlight == null ? Icons.add : Icons.save),
                  label: Text(_selectedFlight == null
                      ? AppLocalizations.of(context)!.msg_sales_add
                      : 'Update'),
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (_selectedFlight != null)
                  ElevatedButton.icon(
                    onPressed: _clearForm,
                    icon: Icon(Icons.cancel),
                    label: Text(AppLocalizations.of(context)!.cancel_edit),
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _flights.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.msg_sales_no_item))
              : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _flights.length,
            itemBuilder: (context, index) {
              final flight = _flights[index];
              return GestureDetector(
                onTap: () => _selectFlight(flight),
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text('${flight.departureCity} → ${flight.destinationCity}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${AppLocalizations.of(context)!.lbl_sales_depart_time}: ${flight.departureTime}\n${AppLocalizations.of(context)!.lbl_sales_arrive_time}: ${flight.arrivalTime}',
                        style: TextStyle(height: 1.5)),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    Widget? detailPanel = _selectedFlight != null
        ? FlightDetailPanel(
      flight: _selectedFlight!,
      onDelete: () => _confirmDeleteFlight(_selectedFlight!),
      onClose: _clearForm,
    )
        : Container();

    if (width > height && width > 720) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: formAndList),
          VerticalDivider(width: 1),
          Expanded(flex: 2, child: Align(alignment: Alignment.topCenter, child: detailPanel)),
        ],
      );
    } else {
      return _selectedFlight == null ? formAndList : detailPanel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.title_sales,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'instructions') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.menu_help),
                    content: Text(AppLocalizations.of(context)!.msg_sales_help_description),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.customerClose),
                      )
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) =>
            [PopupMenuItem(value: 'instructions', child: Text('Instructions'))],
          ),
        ],
      ),
      body: _responsiveLayout(w, h),
    );
  }

  @override
  void dispose() {
    _departureCityController.dispose();
    _destinationCityController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    super.dispose();
  }
}

class FlightDetailPanel extends StatelessWidget {
  final Flight flight;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const FlightDetailPanel({required this.flight, required this.onDelete, required this.onClose, super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text(loc.detail, style: Theme.of(context).textTheme.headlineSmall)),
              SizedBox(height: 24),
              Text('ID: ${flight.id ?? "-"}', style: TextStyle(fontSize: 18)),
              Text('${loc.lbl_sales_depart_city}: ${flight.departureCity}', style: TextStyle(fontSize: 18)),
              Text('${loc.lbl_sales_destination_city}: ${flight.destinationCity}', style: TextStyle(fontSize: 18)),
              Text('${loc.lbl_sales_depart_time}: ${flight.departureTime}', style: TextStyle(fontSize: 18)),
              Text('${loc.lbl_sales_arrive_time}: ${flight.arrivalTime}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline),
                    label: Text(loc.delete),
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: onClose,
                    icon: Icon(Icons.close),
                    label: Text(loc.customerClose),
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
