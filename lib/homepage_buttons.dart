import 'package:flutter/material.dart';
import 'SalesList/sales_list.dart';

class HomePageWithButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home with 4 Buttons')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 1; i <= 4; i++)
              ElevatedButton(
                child: Text('Button $i'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SalesListPage()),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}