import 'package:GroupProject/CustomerList/customer_items_dao.dart';
import 'package:flutter/material.dart';
import 'sales_item.dart';
import 'sales_items_dao.dart';
import '../database.dart';
import '../database_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  late TextEditingController _flightController = TextEditingController();
  late TextEditingController _nameController = TextEditingController();
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
            SnackBar(content: Text(AppLocalizations.of(context)!.msg_sales_no_item),),
          );
        });
      }
    });
  }

  void _showLastData() async {
    final lastCustomer = await _secureStorage.read(key: 'last_sales_customer');
    final lastFlight = await _secureStorage.read(key: 'last_sales_flight');
    final lastName = await _secureStorage.read(key: 'last_sales_name');
    final lastDate = await _secureStorage.read(key: 'last_sales_pdate');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.msg_sales_add),
        content: Text(AppLocalizations.of(context)!.msg_sales_add_choice),
        actions: [
          TextButton(
            onPressed: () {
              _customerController.text = lastCustomer ?? '';
              _flightController.text = lastFlight ?? '';
              _nameController.text = lastName ?? '';
              _dateController.text = lastDate ?? '';
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.yes),
          ),
          TextButton(
            onPressed: () {
              _customerController.clear();
              _flightController.clear();
              _nameController.clear();
              _dateController.clear();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.no),
          ),
        ],
      ),
    );
  }

  Future<void> _addItem() async {
    //Get the current date and time and convert it into the number of milliseconds since January 1, 1970 (UTC) — also known as the Unix Epoch.
    final id = DateTime.now().millisecondsSinceEpoch;
    String customer = _customerController.text.trim();
    String flight = _flightController.text.trim();
    String name = _nameController.text.trim();
    String date = _dateController.text.trim();

    if (customer.isNotEmpty && flight.isNotEmpty && name.isNotEmpty && date.isNotEmpty) {
      final newItem = SalesItem(
        id,
        int.parse(customer),
        flight,
        name,
        date,
      );
      await _itemsDao.insertItem(newItem);
      await _secureStorage.write(key: 'last_sales_customer', value: customer);
      await _secureStorage.write(key: 'last_sales_flight', value: flight);
      await _secureStorage.write(key: 'last_sales_name', value: name);
      await _secureStorage.write(key: 'last_sales_pdate', value: date);
      _customerController.clear();
      _flightController.clear();
      _nameController.clear();
      _dateController.clear();
      _loadItems(); // reload after adding
    }
  }

  Future<void> _confirmDelete(SalesItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.title_sales_delete),
          content: Text(AppLocalizations.of(context)!.msg_sales_delete_confirm),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.no),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yes),
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
    _flightController.dispose();
    _nameController.dispose();
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
                  width: 230,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.lbl_sales_reservation_name,
                      prefixIcon: Icon(Icons.abc),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onTap: () => _showLastData(),
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: TextField(
                    controller: _customerController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.lbl_sales_customer_id,
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: TextField(
                    controller: _flightController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.lbl_sales_flight_id,
                      prefixIcon: Icon(Icons.airplanemode_active),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.lbl_sales_purchase_date,
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
                  label: Text(AppLocalizations.of(context)!.msg_sales_add),
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
              AppLocalizations.of(context)!.msg_sales_no_item,
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
                        AppLocalizations.of(context)!.lbl_sales_reservation_name + ": ${item.reservation_name}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        AppLocalizations.of(context)!.lbl_sales_customer_id + ": ${item.customer_id}\n" +
                            AppLocalizations.of(context)!.lbl_sales_flight_id + ": ${item.flight_id}\n" +
                            AppLocalizations.of(context)!.lbl_sales_purchase_date + ": ${item.purchase_date}",
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
        title: Text(AppLocalizations.of(context)!.title_sales,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Go back to previous screen
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'instructions') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)!.title_sales_help),
                      content: Text(
                        AppLocalizations.of(context)!.msg_sales_help_description,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)!.lbl_sales_close),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'instructions',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.black54),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.menu_help),
                  ],
                ),
              ),
            ],
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: reactiveLayout(width, height),
    );
  }

}

class DetailsPage extends StatefulWidget {
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
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String? customerFullName;
  String? departCity;
  String? destCity;
  String? departTime;
  String? arriveTime;

  @override
  void initState() {
    super.initState();
    _loadCustomerFullNameAndFlightInfo();
  }

  Future<void> _loadCustomerFullNameAndFlightInfo() async {
    final fullName = await appDatabase.customerItemsDao.getCustomerFullNameById(widget.item.customer_id);
    //final dpCity = await appDatabase.flightItemsDao.getFlightById(widget.item.flight_id).depart_city);
    //final dtCity = await appDatabase.flightItemsDao.getFlightById(widget.item.flight_id).destination_city);
    //final dpTime = await appDatabase.flightItemsDao.getFlightById(widget.item.flight_id).depart_time);
    //final arTime = await appDatabase.flightItemsDao.getFlightById(widget.item.flight_id).arrive_time);
    setState(() {
      customerFullName = fullName ?? 'Unknown Customer';
      //departCity = dpCity ?? "N/A";
      //destCity = dtCity ?? "N/A";
      //departTime = dpTime ?? "N/A";
      //arriveTime = arTime ?? "N/A";
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadCustomerFullNameAndFlightInfo();
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
                    AppLocalizations.of(context)!.title_sales_items,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 24),
                _detailRow(
                    Icons.abc,
                    AppLocalizations.of(context)!.lbl_sales_reservation_name,
                    widget.item.reservation_name.toString()),
                const SizedBox(height: 12),
                _detailRow(
                  Icons.person,
                  AppLocalizations.of(context)!.lbl_sales_customer_name,
                  customerFullName ?? 'Loading...',
                ),
                const SizedBox(height: 12),
                _detailRow(
                    Icons.airplanemode_active,
                    AppLocalizations.of(context)!.lbl_sales_flight_id,
                    widget.item.flight_id.toString()),
                const SizedBox(height: 12),
                Text(
                  '       ${AppLocalizations.of(context)!.lbl_sales_depart_city}: ${departCity ?? 'Loading...'}',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  '       ${AppLocalizations.of(context)!.lbl_sales_destination_city}: ${destCity ?? 'Loading...'}',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  '       ${AppLocalizations.of(context)!.lbl_sales_depart_time}: ${departTime ?? 'Loading...'}',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  '       ${AppLocalizations.of(context)!.lbl_sales_arrive_time}: ${arriveTime ?? 'Loading...'}',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                _detailRow(
                    Icons.calendar_today,
                    AppLocalizations.of(context)!.lbl_sales_purchase_date,
                    widget.item.purchase_date.toString()),
                const SizedBox(height: 12),
                _detailRow(
                    Icons.numbers,
                    AppLocalizations.of(context)!.lbl_sales_id,
                    widget.item.id.toString()),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(AppLocalizations.of(context)!.lbl_sales_delete),
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
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close),
                      label: Text(AppLocalizations.of(context)!.lbl_sales_close),
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
      ),
    );
  }

  /// Helper widget
  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "$label: $value",
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}

/*class DetailsPage extends StatelessWidget {
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
                    AppLocalizations.of(context)!.title_sales_items,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                SizedBox(height: 24),
                _detailRow(Icons.person, AppLocalizations.of(context)!.lbl_sales_customer_id, item.customer_id.toString()),
                SizedBox(height: 12),
                _detailRow(Icons.directions_car, AppLocalizations.of(context)!.lbl_sales_car_id, item.car_id.toString()),
                SizedBox(height: 12),
                _detailRow(Icons.store, AppLocalizations.of(context)!.lbl_sales_dealership_id, item.dealership_id.toString()),
                SizedBox(height: 12),
                _detailRow(Icons.calendar_today, AppLocalizations.of(context)!.lbl_sales_purchase_date, item.purchase_date.toString()),
                SizedBox(height: 12),
                _detailRow(Icons.numbers, AppLocalizations.of(context)!.lbl_sales_id, item.id.toString()),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline),
                      label: Text(AppLocalizations.of(context)!.lbl_sales_delete),
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
                      label: Text(AppLocalizations.of(context)!.lbl_sales_close),
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
}*/
