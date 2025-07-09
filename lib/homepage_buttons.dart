import 'package:flutter/material.dart';
import 'SalesList/sales_list.dart';
import 'CustomerList/customer_list.dart';
import 'CarList/car_list.dart';
import 'CarDealershipList/car_dealership_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePageWithButtons extends StatelessWidget {
  final Function(Locale) onLocaleChanged;
  const HomePageWithButtons({super.key, required this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> buttonData = [
      {
        'label': AppLocalizations.of(context)!.main_lab_customer_list,
        'icon': Icons.person,
        'route': CustomerListPage(),
      },
      {
        'label': AppLocalizations.of(context)!.main_lab_car_list,
        'icon': Icons.directions_car,
        'route': CarListPage(),
      },
      {
        'label': AppLocalizations.of(context)!.main_lab_dealership_list,
        'icon': Icons.store,
        'route': DealershipListPage(),
      },
      {
        'label': AppLocalizations.of(context)!.main_lab_sales_list,
        'icon': Icons.receipt_long,
        'route': SalesListPage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)!.main_title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
        ),
        actions: [
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

  /// Builds one button with styling
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