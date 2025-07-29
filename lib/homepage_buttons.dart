import 'package:flutter/material.dart';
import 'SalesList/sales_list.dart';
import 'CustomerList/customer_list.dart';
import 'AirplaneList/airplane_list.dart';
import 'FlightList/flight_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'database_provider.dart';

/// Stateless widget for the home page with 4 navigation buttons and a language switcher
class HomePageWithButtons extends StatelessWidget {
  final Function(Locale) onLocaleChanged;
  const HomePageWithButtons({super.key, required this.onLocaleChanged});

  /// Builds the widget tree for the homepage buttons screen.
  @override
  Widget build(BuildContext context) {
    /// Button configuration: label, icon, and destination route
    final List<Map<String, dynamic>> buttonData = [
      {
        'label': AppLocalizations.of(context)!.main_lab_customer_list,
        'icon': Icons.person,
        'route': CustomerListPage(),
      },
      {
        'label': AppLocalizations.of(context)!.main_lab_airplane_list,
        'icon': Icons.flight,
        'route': AirplaneListPage(database: appDatabase),
      },
      {
        'label': AppLocalizations.of(context)!.main_lab_flight_list,
        'icon': Icons.airplane_ticket,
        'route': FlightListPage(),
      },
      {
        'label': AppLocalizations.of(context)!.main_lab_sales_list,
        'icon': Icons.receipt_long,
        'route': SalesListPage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        // Localized title in bold indigo color
        title: Text(
            AppLocalizations.of(context)!.main_title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
        ),
        actions: [
          // Language switcher dropdown
          PopupMenuButton<Locale>(
            icon: Icon(Icons.language),
            onSelected: onLocaleChanged,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: const Locale('en'),
                child: Text('English'),
              ),
              PopupMenuItem(
                value: const Locale('zh'),
                child: Text('中文'),
              ),
            ],
          ),
        ],
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            // First row of buttons
            Expanded(
              child: Row(
                children: [
                  _buildPaddedButton(context, buttonData[0]),
                  SizedBox(width: 32),
                  _buildPaddedButton(context, buttonData[1]),
                ],
              ),
            ),
            SizedBox(height: 32),
            // Second row of buttons
            Expanded(
              child: Row(
                children: [
                  _buildPaddedButton(context, buttonData[2]),
                  SizedBox(width: 32),
                  _buildPaddedButton(context, buttonData[3]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a styled button with an icon and label, and navigates to the given route
  Widget _buildPaddedButton(BuildContext context, Map<String, dynamic> data) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 6,
            padding: const EdgeInsets.all(24),
          ),
          onPressed: () {
            // Navigate to the assigned page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => data['route']),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(data['icon'], size: 44),
              SizedBox(height: 16),
              Text(
                data['label'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}