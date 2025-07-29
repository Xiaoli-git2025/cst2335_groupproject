import 'package:GroupProject/CustomerList/customer_items_dao.dart';
import 'package:flutter/material.dart';
import 'sales_item.dart';
import 'sales_items_dao.dart';
import '../database.dart';
import '../database_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///Main Screen widget for displaying the reservation list
class SalesListPage extends StatelessWidget {
  /// Builds the widget tree for the SalesListPage.
  ///
  /// Returns the main content widget [ListPage], passing the
  /// initialized [appDatabase] instance to it for data operations.
  @override
  Widget build(BuildContext context) {
    //appDatabase is from database_provider
    return ListPage(database: appDatabase); // Just return the actual content page
  }
}

/// A stateful widget that displays and manages a list of sales items.
///
/// Requires an instance of [AppDatabase] to perform database operations.
class ListPage extends StatefulWidget {
  /// The database instance used for accessing sales data.
  final AppDatabase database;
  /// Creates a [ListPage] widget with the given [database].
  const ListPage({required this.database, super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  /// Secure storage instance to save and retrieve persistent key-value data.
  final _secureStorage = FlutterSecureStorage();
  /// DAO for accessing sales items in the database.
  late final SalesItemsDao _itemsDao;
  /// The list of sales items loaded from the database.
  List<SalesItem> _items = [];
  /// Currently selected sales item, if any.
  SalesItem? _selectedItem;

  /// Controller for the customer input TextField.
  late TextEditingController _customerController = TextEditingController();
  /// Controller for the flight input TextField.
  late TextEditingController _flightController = TextEditingController();
  /// Controller for the name input TextField.
  late TextEditingController _nameController = TextEditingController();
  /// Controller for the date input TextField.
  late TextEditingController _dateController = TextEditingController();

  /// Initializes the state and loads sales items from the database.
  ///
  /// Retrieves the DAO instance from the injected database and triggers
  /// the initial data load.
  @override
  void initState() {
    super.initState();
    _itemsDao = widget.database.salesItemsDao;
    _loadItems();
  }

  /// Load items from the database
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

  ///show last added item information
  void _showLastData() async {
    ///last input Customer
    final lastCustomer = await _secureStorage.read(key: 'last_sales_customer');
    ///last input flight
    final lastFlight = await _secureStorage.read(key: 'last_sales_flight');
    ///last input name
    final lastName = await _secureStorage.read(key: 'last_sales_name');
    ///last input date
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
  ///add item
  Future<void> _addItem() async {
    ///Get the current date and time and convert it into the number of milliseconds since January 1, 1970 (UTC) — also known as the Unix Epoch.
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

  ///confirm delete dialog
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
  ///clear up the controllers
  @override
  void dispose()
  {
    _customerController.dispose();
    _flightController.dispose();
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// Builds a responsive layout that adapts to screen size and orientation.
  ///
  /// When the screen is wide enough (e.g., landscape on tablets or desktops),
  /// it displays the list and details side-by-side.
  /// Otherwise, it shows either the list or the details view.
  ///
  /// Parameters:
  /// - [width]: the width of the available screen area.
  /// - [height]: the height of the available screen area.
  ///
  /// Returns a [Widget] containing the appropriate layout.
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

  ///Build the reservation list widget
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

/// Displays detailed information about a single reservation item,
/// including customer and flight information, with options to delete or close.
class DetailsPage extends StatefulWidget {
  /// The reservation item to display details for.
  final SalesItem item;
  /// Callback when the delete button is pressed.
  final VoidCallback onDelete;
  /// Callback when the close button is pressed.
  final VoidCallback onClose;

  /// Creates a DetailsPage widget with the given item and callbacks.
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
  /// Full name of the customer associated with the sales item.
  String? customerFullName;

  /// Departure city of the flight (currently commented out).
  String? departCity;

  /// Destination city of the flight (currently commented out).
  String? destCity;

  /// Departure time of the flight (currently commented out).
  String? departTime;

  /// Arrival time of the flight (currently commented out).
  String? arriveTime;

  @override
  void initState() {
    super.initState();
    _loadCustomerFullNameAndFlightInfo();
  }

  /// Loads the customer's full name and flight information asynchronously,
  /// then updates the widget's state to display this information.
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

  ///build detail widget
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

  /// Helper widget to create a row with an icon, label, and value.
  ///
  /// Used for displaying fields in the details view.
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
