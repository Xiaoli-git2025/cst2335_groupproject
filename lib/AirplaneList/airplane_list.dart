import 'package:GroupProject/AirplaneList/airplane_item.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import '../database.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//Main Screen wideget for displaying the airplane list
class AirplaneListPage extends StatelessWidget {
  final AppDatabase database;
  const AirplaneListPage({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.title_airplane),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Go back to previous screen
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.airplane_question_title),
                  content: Text(AppLocalizations.of(context)!.airplane_question_instruction),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.airplane_question_button),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: AirplaneList(database: database),
    );
  }
}
//Widget that manages the airplane list state
class AirplaneList extends StatefulWidget {
  const AirplaneList({super.key, required this.database});
  final AppDatabase database;

  @override
  State<AirplaneList> createState() => _AirplaneListState();
}

class _AirplaneListState extends State<AirplaneList> {
  late TextEditingController _modelController;
  late TextEditingController _maxPassengersController;
  late TextEditingController _maxSpeedController;
  late TextEditingController _maxMileageController;
  List<AirplaneItem> _items = [];// List of airplane items
  AirplaneItem? selectedItem; // currently selected item for detail view

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController();
    _maxPassengersController = TextEditingController();
    _maxSpeedController = TextEditingController();
    _maxMileageController = TextEditingController();
    _loadItems();// load from database
    _loadLastAirplane(); // load from the shared preferences
  }
// Load items from the database
  Future<void> _loadItems() async {
    final items = await widget.database.airplaneItemsDao.findAllItems();
    setState(() {
      _items = items;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Loaded ${items.length} airplanes')));
  }// Show a snackbar with the number of items loaded
 // Add a new airplane item to the database
  void _addItem() async {
    final error = _validateInput(); // validation
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final item = AirplaneItem(
      null,
      _modelController.text,
      int.parse(_maxPassengersController.text),
      int.parse(_maxSpeedController.text),
      int.parse(_maxMileageController.text),
    );
    await widget.database.airplaneItemsDao.insertItem(item);
    await _loadItems();
    await _saveToEncryptedSharedPreferences();
    _modelController.clear();
    _maxPassengersController.clear();
    _maxSpeedController.clear();
    _maxMileageController.clear();
  }
//Delete an airplane item from the database
  void _deleteItem(AirplaneItem item) async {
    await widget.database.airplaneItemsDao.deleteItem(item);
    await _loadItems();
  }
//clear up the controllers
  @override
  void dispose() {
    _modelController.dispose();
    _maxPassengersController.dispose();
    _maxSpeedController.dispose();
    _maxMileageController.dispose();
    super.dispose();
  }
//Load last save airplane item from the shared preferences
  Future<void> _loadLastAirplane() async {
    final EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    String? model = await prefs.getString('airplane_model');
    String? maxPassengers = await prefs.getString('airplane_max_passengers');
    String? maxSpeed = await prefs.getString('airplane_max_speed');
    String? maxMileage = await prefs.getString('airplane_max_mileage');

    if(model != null) _modelController.text = model;
    if(maxPassengers != null) _maxPassengersController.text = maxPassengers;
    if(maxSpeed != null) _maxSpeedController.text = maxSpeed;
    if(maxMileage != null) _maxMileageController.text = maxMileage;
  }
// Save current airplane item to the shared preferences
  Future<void> _saveToEncryptedSharedPreferences() async {
    final EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    await prefs.setString('airplane_model', _modelController.text);
    await prefs.setString('airplane_max_passengers', _maxPassengersController.text);
    await prefs.setString('airplane_max_speed', _maxSpeedController.text);
    await prefs.setString('airplane_max_mileage', _maxMileageController.text);
  }
//Check if the input is valid
  String? _validateInput() {
    if(_modelController.text.isEmpty || _maxPassengersController.text.isEmpty ||
        _maxSpeedController.text.isEmpty || _maxMileageController.text.isEmpty) {
      return AppLocalizations.of(context)!.airplane_error_message_String;
    }
    if (int.tryParse(_maxPassengersController.text) == null) {
      return AppLocalizations.of(context)!.airplane_error_message_Number;
    }
    if (int.tryParse(_maxSpeedController.text) == null) {
      return AppLocalizations.of(context)!.airplane_error_message_Number;
    }
    if (int.tryParse(_maxMileageController.text) == null) {
      return AppLocalizations.of(context)!.airplane_error_message_Number;
    }
    return null;
  }
//Show confirmation dialog before saving the list
  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.add_airplane),
          content: Text(AppLocalizations.of(context)!.airplane_save_list_message),
          actions: [
            ElevatedButton(
              onPressed: () {
                _addItem();
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.airplane_save_list_yes),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.airplane_save_list_no),
            ),
          ],
        );
      },
    );
  }
// Display list of airplane items
  Widget listView() {
    return Expanded(
      child: _items.isEmpty
          ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(AppLocalizations.of(context)!.airplane_message_no_items),
      )
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            title: Text("${AppLocalizations.of(context)!.airplane_model}: ${item.airplane_model}"),
            subtitle: Text(
                "${AppLocalizations.of(context)!.airplane_max_passengers}: ${item.max_passengers}, "
                    "${AppLocalizations.of(context)!.airplane_max_speed}: ${item.max_speed}, "
                    "${AppLocalizations.of(context)!.airplane_max_mileage}: ${item.max_mileage}"
            ),
            onTap: () {
              showUpdatePage(item); // Show update page
            },
          );
        },
      ),
    );
  }
//Display detailed view of an airplane item
  Widget detailedPage(AirplaneItem item) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${AppLocalizations.of(context)!.airplane_model}: ${item.airplane_model}"),
            Text("${AppLocalizations.of(context)!.airplane_max_passengers}: ${item.max_passengers}"),
            Text("${AppLocalizations.of(context)!.airplane_max_speed}: ${item.max_speed}"),
            Text("${AppLocalizations.of(context)!.airplane_max_mileage}: ${item.max_mileage}"),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    showUpdatePage(item);
                    setState(() {
                      selectedItem = null;
                      _loadItems();
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.airplane_update_button),
                ),
                ElevatedButton(
                  onPressed: () {
                    _deleteItem(item);
                    setState(() {
                      selectedItem = null;
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.airplane_delete_button),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedItem = null;
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.airplane_cancel_button),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
// Show update page for an airplane item
  Future<void> showUpdatePage(AirplaneItem item) async {
    _modelController.text = item.airplane_model;
    _maxPassengersController.text = item.max_passengers.toString();
    _maxSpeedController.text = item.max_speed.toString();
    _maxMileageController.text = item.max_mileage.toString();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.airplane_update),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _modelController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.airplane_model),
                  keyboardType: TextInputType.text,
                ),
                TextField(
                  controller: _maxPassengersController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.airplane_max_passengers),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _maxSpeedController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.airplane_max_speed),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _maxMileageController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.airplane_max_mileage),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final errorMessage = _validateInput();
                if(errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
                  return;
                }
                final updatedItem = AirplaneItem(
                  item.id,
                  _modelController.text,
                  int.parse(_maxPassengersController.text),
                  int.parse(_maxSpeedController.text),
                  int.parse(_maxMileageController.text),
                );
                widget.database.airplaneItemsDao.updateItem(updatedItem);
                _loadItems();
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.airplane_update_button),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteItem(item);
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.airplane_delete_button),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.airplane_cancel_button),
            ),
          ],
        );
      },
    );
  }
// Build the airplane list widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 600; // Check if the screen is wide
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _modelController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.airplane_model),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _maxPassengersController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.airplane_max_passengers,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _maxSpeedController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.airplane_max_speed),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _maxMileageController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.airplane_max_mileage),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showDialog,
                  child: Text(AppLocalizations.of(context)!.airplane_save_list),
                ),
                SizedBox(height: 16),
                // Display either split view or list only
                Expanded(
                  child: isWide
                      ? Row(
                    children: [
                      Expanded(flex: 1, child: listView()),
                      VerticalDivider(),
                      Expanded(
                        flex: 1,
                        child: selectedItem != null
                            ? detailedPage(selectedItem!)
                            : Center(child: Text(AppLocalizations.of(context)!.airplane_message_selected_item)),
                      ),
                    ],
                  )
                      : selectedItem != null
                      ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: detailedPage(selectedItem!),
                  )
                      : listView(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}