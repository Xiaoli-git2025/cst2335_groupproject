import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../database.dart';
import '../database_provider.dart';
import 'customer_item.dart';
import 'customer_items_dao.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();

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
      // _showMessage('No customer records found');
      _showMessage(AppLocalizations.of(context)!.noRecords);
    }
  }

  Future<void> _addOrUpdateItem() async {
    final fn = _firstNameController.text.trim();
    final ln = _lastNameController.text.trim();
    final addr = _addressController.text.trim();
    final dob = _dobController.text.trim();

    if (fn.isEmpty || ln.isEmpty || addr.isEmpty || dob.isEmpty) return;

    if (_selectedItem == null) {
      final id = DateTime.now().millisecondsSinceEpoch;
      final newItem = CustomerItem(id, fn, ln, addr, dob);
      await _itemsDao.insertItem(newItem);
      // _showMessage('Customer added successfully');
      _showMessage(AppLocalizations.of(context)!.customerAdd);
    } else {
      final updated = CustomerItem(_selectedItem!.id, fn, ln, addr, dob);
      await _itemsDao.updateItem(updated);
      // _showMessage('Customer updated successfully');
      _showMessage(AppLocalizations.of(context)!.customerUpdate);
    }

    _clearForm();
    _loadItems();
  }

  Future<void> _copyLastCustomer() async {
    final last = await _itemsDao.getLastCustomer();
    if (last != null) {
      setState(() {
        _firstNameController.text = last.firstname;
        _lastNameController.text = last.lastname;
        _addressController.text = last.address;
        _dobController.text = last.dateOfBirth;
      });
    }
  }

  Future<void> _confirmDelete(CustomerItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.delete),
        content: Text(AppLocalizations.of(context)!.deleteMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.no_customer)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context)!.yes_customer)),
        ],
      ),
    );
    if (confirm == true) {
      await _itemsDao.deleteItem(item);
      _clearForm();
      _loadItems();
      _showMessage(AppLocalizations.of(context)!.customerDelete);
    }
  }

  void _selectItem(CustomerItem item) {
    setState(() {
      _selectedItem = item;
      _firstNameController.text = item.firstname;
      _lastNameController.text = item.lastname;
      _addressController.text = item.address;
      _dobController.text = item.dateOfBirth;
    });
  }

  void _clearForm() {
    setState(() {
      _firstNameController.clear();
      _lastNameController.clear();
      _addressController.clear();
      _dobController.clear();
      _selectedItem = null;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
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
                    controller: _firstNameController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.first_name, border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.last_name, border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.address, border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _dobController,
                    readOnly: true,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.date_of_birth, border: OutlineInputBorder()),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        _dobController.text =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      }
                    },
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addOrUpdateItem,
                  icon: Icon(_selectedItem == null ? Icons.add : Icons.save),
                  label: Text(_selectedItem == null ? AppLocalizations.of(context)!.addCustomer : AppLocalizations.of(context)!.saveCustomer),
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _copyLastCustomer,
                  icon: Icon(Icons.copy),
                  label: Text(AppLocalizations.of(context)!.copy_last),
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (_selectedItem != null)
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
          child: _items.isEmpty
              ? Center(
            child: Text(
              AppLocalizations.of(context)!.noRecords,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          )
              : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return GestureDetector(
                onTap: () => _selectItem(item),
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text('${item.firstname} ${item.lastname}', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      // 'Address: ${item.address}\nDate of Birth: ${item.dateOfBirth}',
                      '${AppLocalizations.of(context)!.address}: ${item.address}\n${AppLocalizations.of(context)!.date_of_birth}: ${item.dateOfBirth}',
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

    Widget? detailPanel = _selectedItem != null
        ? DetailsPage(
      item: _selectedItem!,
      onDelete: () => _confirmDelete(_selectedItem!),
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
      return _selectedItem == null ? formAndList : detailPanel;
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
          AppLocalizations.of(context)!.customer_list,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'instructions') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.instrcution_customer),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        Text(AppLocalizations.of(context)!.instruction1),
                        Text(AppLocalizations.of(context)!.instruction2),
                        Text(AppLocalizations.of(context)!.instruction3),
                        Text(AppLocalizations.of(context)!.instruction4),
                      ],
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.customerClose))],
                  ),
                );
              }
            },
            itemBuilder: (context) => [PopupMenuItem(value: 'instructions', child: Text('Instructions'))],
          ),
        ],
      ),
      body: _responsiveLayout(w, h),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}

class DetailsPage extends StatelessWidget {
  final CustomerItem item;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const DetailsPage({required this.item, required this.onDelete, required this.onClose, super.key});

  @override
  Widget build(BuildContext context) {
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
              Center(child: Text(AppLocalizations.of(context)!.detail, style: Theme.of(context).textTheme.headlineSmall)),
              SizedBox(height: 24),
              Text('ID: ${item.id}', style: TextStyle(fontSize: 18)),
              Text('${AppLocalizations.of(context)!.first_name}${AppLocalizations.of(context)!.last_name}: ${item.firstname} ${item.lastname}', style: TextStyle(fontSize: 18)),
              Text('${AppLocalizations.of(context)!.address}: ${item.address}', style: TextStyle(fontSize: 18)),
              Text('${AppLocalizations.of(context)!.date_of_birth}:${item.dateOfBirth}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline),
                    label: Text(AppLocalizations.of(context)!.delete),
                    style: ElevatedButton.styleFrom(
                      elevation: 3,

                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: onClose,
                    icon: Icon(Icons.close),
                    label: Text(AppLocalizations.of(context)!.customerClose),
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
