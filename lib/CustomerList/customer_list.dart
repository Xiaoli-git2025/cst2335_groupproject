import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../database.dart';
import '../database_provider.dart';
import 'customer_item.dart';
import 'customer_items_dao.dart';

class CustomerListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListPage(database: appDatabase);
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
  late final CustomerItemsDao _itemsDao;
  List<CustomerItem> _items = [];
  CustomerItem? _selectedItem;

  late TextEditingController _firstNameController = TextEditingController();
  late TextEditingController _lastNameController = TextEditingController();
  late TextEditingController _addressController = TextEditingController();
  late TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _itemsDao = widget.database.customerItemsDao;
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _itemsDao.findAllItems();
    setState(() {
      _items = items;
    });

    if (items.isEmpty) {
      // Wait until the current frame is done before showing SnackBar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No customer records.'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }


  Future<void> _addItem() async {
    final id = DateTime.now().millisecondsSinceEpoch;
    final fn = _firstNameController.text.trim();
    final ln = _lastNameController.text.trim();
    final addr = _addressController.text.trim();
    final dob = _dobController.text.trim();

    if (fn.isNotEmpty && ln.isNotEmpty && addr.isNotEmpty && dob.isNotEmpty) {
      final item = CustomerItem(id, fn, ln, addr, dob);
      await _itemsDao.insertItem(item);
      _secureStorage.write(key: 'last_fn', value: fn);
      _secureStorage.write(key: 'last_ln', value: ln);
      _secureStorage.write(key: 'last_addr', value: addr);
      _secureStorage.write(key: 'last_dob', value: dob);

      _firstNameController.clear();
      _lastNameController.clear();
      _addressController.clear();
      _dobController.clear();

      _loadItems();
    }
  }

  Future<void> _confirmDelete(CustomerItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete'),
        content: Text('Are you sure you want to delete this customer?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
        ],
      ),
    );
    if (confirm == true) {
      await _itemsDao.deleteItem(item);
      setState(() => _selectedItem = null);
      _loadItems();
    }
  }

  void _selectItem(CustomerItem item) {
    setState(() => _selectedItem = item);
  }

  void _closeDetails() {
    setState(() => _selectedItem = null);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Widget _responsiveLayout(double width, double height) {
    Widget list = Column(
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
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _dobController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Date of Birth', border: OutlineInputBorder()),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addItem,
                icon: Icon(Icons.add),
                label: Text('Add Customer'),
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
        Expanded(
          child: _items.isEmpty
              ? Center(
            child: Text(
              'No customer records.',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          )

              : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              // return ListTile(
                // title: Text('${item.firstname} ${item.lastname}'),
                // subtitle: Text('Address: ${item.address}\nDOB: ${item.dateOfBirth}'),
                // trailing: Icon(Icons.chevron_right),
                // onTap: () => _selectItem(item),
              // );
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
                        '${item.firstname} ${item.lastname}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        'Address: ${item.address}\nDate of Birth: ${item.dateOfBirth}',
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

    Widget? details = _selectedItem != null
        ? DetailsPage(
      item: _selectedItem!,
      onDelete: () => _confirmDelete(_selectedItem!),
      onClose: _closeDetails,
    )
        : Container();

    if ((width > height) && width > 720) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start, // ADD THIS LINE
        children: [
          Expanded(flex: 3, child: list),
          VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.topCenter, // ENSURE IT'S ALIGNED TO TOP
              child: details,
            ),
          ),
        ],
      );
    }

  else {
      return _selectedItem == null ? list : details;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Customer List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'instructions') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Instructions'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• Fill in customer details using the form.'),
                          Text('• Tap "Add Customer" to save to the database.'),
                          Text('• Tap on a customer in the list to view more details.'),
                          Text('• Inside the detail view, you can delete or close the customer.'),
                          Text('• The app shows a message if no customer records exist.'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'instructions',
                child: Text('Instructions'),
              ),
            ],
          ),
        ],
      ),

      body: _responsiveLayout(w, h),
    );
  }
}

class DetailsPage extends StatelessWidget {
  final CustomerItem item;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const DetailsPage({
    required this.item,
    required this.onDelete,
    required this.onClose,
    super.key,
  });

  @override
  @override
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // ensure scrollable if content grows
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // align children to the left
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center( // Wrap ONLY the title in Center
                    child: Text(
                      'Item Details',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center, // Optional, but good to include
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('ID: ${item.id}', style: const TextStyle(fontSize: 18)),
                  Text('Name: ${item.firstname} ${item.lastname}', style: const TextStyle(fontSize: 18)),
                  Text('Address: ${item.address}', style: const TextStyle(fontSize: 18)),
                  Text('Date of Birth: ${item.dateOfBirth}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
        ],
      ),
    );
  }


}
