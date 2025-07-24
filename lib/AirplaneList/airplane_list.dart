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
            onPressed:
                () => Navigator.pop(context), // Go back to previous screen
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
  AirplaneItem? selectedItem;

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController();
    _maxPassengersController = TextEditingController();
    _maxSpeedController = TextEditingController();
    _maxMileageController = TextEditingController();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await widget.database.airplaneItemsDao.findAllItems();
    setState(() {
      _items = items;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Loaded ${items.length} airplanes')));
  }

  void _addItem() async {
    final item = AirplaneItem(
      null,
      _modelController.text,
      int.parse(_maxPassengersController.text),
      int.parse(_maxSpeedController.text),
      int.parse(_maxMileageController.text),
    );
    await widget.database.airplaneItemsDao.insertItem(item);
    await _loadItems();
    _modelController.clear();
    _maxPassengersController.clear();
    _maxSpeedController.clear();
    _maxMileageController.clear();
  }

  void _updateItem(AirplaneItem item) async {
    showUpdatePage(item);
    if (selectedItem != null) {
      final updatedItem = AirplaneItem(
        selectedItem!.id,
        _modelController.text,
        int.parse(_maxPassengersController.text),
        int.parse(_maxSpeedController.text),
        int.parse(_maxMileageController.text),
      );
      await widget.database.airplaneItemsDao.updateItem(updatedItem);
      await _loadItems();
      _modelController.clear();
      _maxPassengersController.clear();
      _maxSpeedController.clear();
      _maxMileageController.clear();
    }
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
    return Expanded(
      child:
      _items.isEmpty
          ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('There is no more records'),
      )
          : ListView.builder(
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
            onTap: () {
              showUpdatePage(item);
            },
          );
        },
      ),
    );
  }

  Widget detailedPage(AirplaneItem item) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Model: ${item.airplane_model}'),
            Text('Passengers: ${item.max_passengers}'),
            Text('Speed: ${item.max_speed}'),
            Text('Mileage: ${item.max_mileage}'),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _updateItem(item);
                    setState(() {
                      selectedItem = null;
                      _loadItems();
                    });
                  },
                  child: Text('Update'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _deleteItem(item);
                    setState(() {
                      selectedItem = null;
                    });
                  },
                  child: Text('Delete'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedItem = null;
                    });
                  },
                  child: Text('close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showUpdatePage(AirplaneItem item) async {
    _modelController.text = item.airplane_model;
    _maxPassengersController.text = item.max_passengers.toString();
    _maxSpeedController.text = item.max_speed.toString();
    _maxMileageController.text = item.max_mileage.toString();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Airplane'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _modelController,
                  decoration: InputDecoration(labelText: 'Model'),
                  keyboardType: TextInputType.text,
                ),
                TextField(
                  controller: _maxPassengersController,
                  decoration: InputDecoration(labelText: 'Passengers'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _maxSpeedController,
                  decoration: InputDecoration(labelText: 'Speed'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _maxMileageController,
                  decoration: InputDecoration(labelText: 'Mileage'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _updateItem(item);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteItem(item);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 600;
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
                        decoration: InputDecoration(labelText: 'Model'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _maxPassengersController,
                        decoration: InputDecoration(
                          labelText: 'Max Passengers',
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
                  child:
                  isWide
                      ? Row(
                    children: [
                      Expanded(flex: 1, child: listView()),
                      VerticalDivider(),
                      Expanded(
                        flex: 1,
                        child:
                        selectedItem != null
                            ? detailedPage(selectedItem!)
                            : Center(child: Text('Select an item')),
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
