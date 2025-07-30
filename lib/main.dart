import 'package:flutter/material.dart';
import 'homepage_buttons.dart';
import 'database_provider.dart';
import 'database.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The main function that initializes the database and runs the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the Floor database and assign it to [appDatabase].
  appDatabase = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .build();
  /// Launch the Flutter application.
  runApp(MyApp());
}

/// The root widget of the flight reservation app.
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

/// State class for [MyApp] responsible for handling locale changes.
class _MyAppState extends State<MyApp> {
  ///Define _locale
  Locale? _locale;

  /// Callback method to update the app locale.
  void onLocaleChanged(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  /// Builds the app widget tree with localization support.
    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vehicle Sales',
      locale: _locale, // Use state variable
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
        Locale('tr'),
      ],
      home: HomePageWithButtons(onLocaleChanged: onLocaleChanged),
    );
  }
}