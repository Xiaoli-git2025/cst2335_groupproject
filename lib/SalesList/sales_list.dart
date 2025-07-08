import 'package:flutter/material.dart';
import 'sales_item.dart';
import 'sales_items_dao.dart';
import '../database.dart';
import '../database_provider.dart';

//class SalesListPage extends StatelessWidget {

//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'Sales List',
//      theme: ThemeData(

//        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//        useMaterial3: true,
//      ),
//      home: ListPage(database: appDatabase),
//    );
//  }
//}

class SalesListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListPage(database: appDatabase); // Just return the actual content page
  }
}

class ListPage extends StatefulWidget {
  final AppDatabase database;
  const ListPage({required this.database, super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late final SalesItemsDao _itemsDao;
  List<SalesItem> _items = [];
  SalesItem? _selectedItem;

  late TextEditingController _itemController = TextEditingController();
  late TextEditingController _quantityController = TextEditingController();

  //List<Map<String, String>> _items = [];

  @override
  void initState() {
    //_itemController = TextEditingController();
    //_quantityController = TextEditingController();
    super.initState();
    _itemsDao = widget.database.salesItemsDao;
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _itemsDao.findAllItems();
    print('Items count: ${items.length}');
    setState(() {
      _items = items;
    });
  }

  Future<void> _addItem() async {
    //Get the current date and time and convert it into the number of milliseconds since January 1, 1970 (UTC) — also known as the Unix Epoch.
    final id = DateTime.now().millisecondsSinceEpoch;
    String item = _itemController.text.trim();
    String quantity = _quantityController.text.trim();

    if (item.isNotEmpty && quantity.isNotEmpty) {
      final newItem = SalesItem(id, item, int.tryParse(quantity) ?? 1);
      await _itemsDao.insertItem(newItem);
      _itemController.clear();
      _quantityController.clear();
      _loadItems(); // reload after adding
    }
  }

  Future<void> _confirmDelete(SalesItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Item"),
          content: Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              child: Text("No"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    if (shouldDelete == true) {
      await _itemsDao.deleteItem(item);
      setState(() {
        _selectedItem = null;
      });
      _loadItems();
    }
  }

  void _selectItem(SalesItem item) {
    setState(() {
      _selectedItem = item;
    });
  }

  void _closeDetails() {
    setState(() {
      _selectedItem = null;
    });
  }

  @override
  void dispose()
  {
    _itemController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Widget reactiveLayout(double width, double height) {
    const int a = 2; // list width portion
    const int b = 3; // details width portion

    Widget listWidget = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _itemController,
                  decoration: InputDecoration(
                    hintText: 'Item name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    hintText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addItem,
                child: Text("Add item"),
              ),
            ],
          ),
        ),
        Expanded(
          child: _items.isEmpty
              ? Center(child: Text("There are no items in the list."))
              : ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              var item = _items[index];
              return GestureDetector(
                onTap: () => _selectItem(item),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${index + 1}: ${item.name} - Quantity: ${item.quantity}",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    Widget? detailsWidget = _selectedItem != null
        ? DetailsPage(
      item: _selectedItem!,
      onDelete: () => _confirmDelete(_selectedItem!),
      onClose: _closeDetails,
    )
        : Container();

    if ((width > height) && (width > 720)) {
      return Row(
        children: [
          Expanded(flex: a, child: listWidget),
          VerticalDivider(width: 1),
          Expanded(flex: b, child: detailsWidget),
        ],
      );
    } else {
      return _selectedItem == null ? listWidget : detailsWidget;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sales List'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Go back to previous screen
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: reactiveLayout(width, height),
    );
  }
}

class DetailsPage extends StatelessWidget {
  final SalesItem item;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const DetailsPage({
    required this.item,
    required this.onDelete,
    required this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.topCenter, // Ensures top + horizontally centered
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center, // horizontal centering
          children: [
            Text("Item Details", style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 24),
            Text("Name: ${item.name}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Quantity: ${item.quantity}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("ID: ${item.id}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onDelete,
              child: Text("Delete"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            SizedBox(height: 12),
            OutlinedButton(
              onPressed: onClose,
              child: Text("Close"),
            ),
          ],
        ),
      )
    );
  }
}
