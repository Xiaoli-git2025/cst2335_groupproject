import 'package:flutter/material.dart';
import 'homepage_buttons.dart';
import 'database_provider.dart';
import 'database.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  appDatabase = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .build();
  runApp(MyApp());
}

/*class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vehicle Sales',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('zh'), // Chinese
        // Add more locales here
      ],
      //locale: Locale('zh'), // force Chinese
      locale: _locale, // Use a state variable
      home: HomePageWithButtons(onLocaleChanged: (locale) => setState(() => _locale = locale),),
    );
  }
}*/

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ✅ Define _locale
  Locale? _locale;

  // ✅ Define onLocaleChanged
  void onLocaleChanged(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

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
      ],
      home: HomePageWithButtons(onLocaleChanged: onLocaleChanged),
    );
  }
}