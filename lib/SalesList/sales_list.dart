import 'package:flutter/material.dart';
import 'sales_item.dart';
import 'sales_items_dao.dart';
import '../database.dart';
import '../database_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SalesListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //appDatabase is from database_provider
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
  final _secureStorage = FlutterSecureStorage();
  late final SalesItemsDao _itemsDao;
  List<SalesItem> _items = [];
  SalesItem? _selectedItem;

  late TextEditingController _customerController = TextEditingController();
  late TextEditingController _carController = TextEditingController();
  late TextEditingController _dealershipController = TextEditingController();
  late TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _itemsDao = widget.database.salesItemsDao;
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _itemsDao.findAllItems();
    setState(() {
      _items = items;
      if (_items.isEmpty) {
        // Show SnackBar AFTER frame builds
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("There are no items in the list.")),
          );
        });
      }
    });
  }

  void _showLastData() async {
    final lastCustomer = await _secureStorage.read(key: 'last_sales_customer');
    final lastCar = await _secureStorage.read(key: 'last_sales_car');
    final lastDealership = await _secureStorage.read(key: 'last_sales_dealership');
    final lastDate = await _secureStorage.read(key: 'last_sales_pdate');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Sales Item"),
        content: Text("Do you want to copy the previous item's data?"),
        actions: [
          TextButton(
            onPressed: () {
              _customerController.text = lastCustomer ?? '';
              _carController.text = lastCar ?? '';
              _dealershipController.text = lastDealership ?? '';
              _dateController.text = lastDate ?? '';
              Navigator.pop(context);
            },
            child: Text("Copy Previous"),
          ),
          TextButton(
            onPressed: () {
              _customerController.clear();
              _carController.clear();
              _dealershipController.clear();
              _dateController.clear();
              Navigator.pop(context);
            },
            child: Text("Start Fresh"),
          ),
        ],
      ),
    );
  }

  Future<void> _addItem() async {
    //Get the current date and time and convert it into the number of milliseconds since January 1, 1970 (UTC) — also known as the Unix Epoch.
    final id = DateTime.now().millisecondsSinceEpoch;
    String customer = _customerController.text.trim();
    String car = _carController.text.trim();
    String dealership = _dealershipController.text.trim();
    String date = _dateController.text.trim();

    if (customer.isNotEmpty && car.isNotEmpty && dealership.isNotEmpty && date.isNotEmpty) {
      final newItem = SalesItem(
        id,
        int.parse(customer),
        int.parse(car),
        int.parse(dealership),
        date,
      );
      await _itemsDao.insertItem(newItem);
      await _secureStorage.write(key: 'last_sales_customer', value: customer);
      await _secureStorage.write(key: 'last_sales_car', value: car);
      await _secureStorage.write(key: 'last_sales_dealership', value: dealership);
      await _secureStorage.write(key: 'last_sales_pdate', value: date);
      _customerController.clear();
      _carController.clear();
      _dealershipController.clear();
      _dateController.clear();
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
    _customerController.dispose();
    _carController.dispose();
    _dealershipController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Widget reactiveLayout(double width, double height) {
    const int a = 3;
    const int b = 2;

    Widget listWidget = Column(
      children: [
        // FORM AREA
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              runSpacing: 12,
              spacing: 12,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _customerController,
                    decoration: InputDecoration(
                      labelText: 'Customer ID',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onTap: () => _showLastData(),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _carController,
                    decoration: InputDecoration(
                      labelText: 'Car ID',
                      prefixIcon: Icon(Icons.directions_car),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _dealershipController,
                    decoration: InputDecoration(
                      labelText: 'Dealership ID',
                      prefixIcon: Icon(Icons.store),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Purchase Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dateController.text =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: Icon(Icons.add),
                  label: Text("Add Item"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // LIST AREA
        Expanded(
          child: _items.isEmpty
              ? Center(
            child: Text(
              "There are no items in the list.",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          )
              : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              var item = _items[index];
              return GestureDetector(
                onTap: () => _selectItem(item),
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      "Customer ID: ${item.customer_id} - Car ID: ${item.car_id}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Dealership ID: ${item.dealership_id}\nPurchase Date: ${item.purchase_date}",
                      style: TextStyle(height: 1.5),
                    ),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    // Handle responsive layout
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
      padding: const EdgeInsets.all(24.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Item Details",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                SizedBox(height: 24),
                _detailRow(Icons.person, "Customer ID", item.customer_id.toString()),
                SizedBox(height: 12),
                _detailRow(Icons.directions_car, "Car ID", item.car_id.toString()),
                SizedBox(height: 12),
                _detailRow(Icons.store, "Dealership ID", item.dealership_id.toString()),
                SizedBox(height: 12),
                _detailRow(Icons.calendar_today, "Purchase Date", item.purchase_date.toString()),
                SizedBox(height: 12),
                _detailRow(Icons.numbers, "Record ID", item.id.toString()),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline),
                      label: Text("Delete"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: onClose,
                      icon: Icon(Icons.close),
                      label: Text("Close"),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper widget to show an icon + label + value in a row
  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            "$label: $value",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
