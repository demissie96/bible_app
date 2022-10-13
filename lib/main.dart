import 'package:flutter/material.dart';
import 'main_page.dart';
import 'passage_page.dart';
import 'search_page.dart';
import 'settings_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        colorScheme:
            const ColorScheme.light(primary: Colors.red, secondary: Colors.red),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme:
            const ColorScheme.dark(primary: Colors.red, secondary: Colors.red),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            onPrimary: Colors.white,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(),
        '/passage': (context) => PassagePage(
              text: "Szent Biblia",
            ),
        '/search': (context) => SearchPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
