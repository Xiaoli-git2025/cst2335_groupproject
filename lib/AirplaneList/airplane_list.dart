import 'package:GroupProject/AirplaneList/airplane_item.dart';
import 'package:flutter/material.dart';
import '../database.dart';


class AirplaneListPage extends StatelessWidget {
  final AppDatabase database;
  const AirplaneListPage({super.key, required this.database});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airplane List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Airplane List'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context), // Go back to previous screen
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: AirplaneList(database: database),
      ),
    );
  }
}


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
  List<AirplaneItem> _items = [];

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController();
    _maxPassengersController = TextEditingController();
    _maxSpeedController = TextEditingController();
    _maxMileageController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final snackBar = SnackBar(
        content: Text('Loaded ${_items.length} airplanes'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await widget.database.airplaneItemsDao.findAllItems();
    setState(() {
      _items = items;
    });
  }

  void _addItem() async {
    final item = AirplaneItem(
      null,
      _modelController.text,
      int.parse(_maxPassengersController.text) ?? 0,
      int.parse(_maxSpeedController.text) ?? 0,
      int.parse(_maxMileageController.text) ?? 0,
    );
    await widget.database.airplaneItemsDao.insertItem(item);
    await _loadItems();
    _modelController.clear();
    _maxPassengersController.clear();
    _maxSpeedController.clear();
    _maxMileageController.clear();
  }

  void _deleteItem(AirplaneItem item) async {
    await widget.database.airplaneItemsDao.deleteItem(item);
    await _loadItems();
  }

  @override
  void dispose() {
    _modelController.dispose();
    _maxPassengersController.dispose();
    _maxSpeedController.dispose();
    _maxMileageController.dispose();
    super.dispose();
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save List'),
          content: Text('Do you want to save this list？'),
          actions: [
            ElevatedButton(
              onPressed: () {
                _addItem();
                Navigator.of(context).pop();
              },
              child: Text('yes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }
  Widget listView() {
    print('🟢 building listView with ${_items.length} items');
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          title: Text('Model: ${item.airplane_model}'),
          subtitle: Text(
            'Passengers: ${item.max_passengers}, '
                'Speed: ${item.max_speed}, '
                'Mileage: ${item.max_mileage}',
          ),
          onLongPress: () => _deleteItem(item),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Text('Loaded ${_items.length} airplanes'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextField(
                    controller: _modelController,
                    decoration: InputDecoration(labelText: 'Model'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxPassengersController,
                    decoration: InputDecoration(labelText: 'Max Passengers'),
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
                    decoration: InputDecoration(labelText: 'Max Speed'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxMileageController,
                    decoration: InputDecoration(labelText: 'Max Mileage'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showDialog,
              child: Text('Add Airplane'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: listView(),
            ),
          ],
        ),
      ),
    );
  }


}
