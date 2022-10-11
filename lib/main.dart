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
        colorScheme: const ColorScheme.light(
            primary: Colors.white, secondary: Colors.purple),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
            primary: Color.fromARGB(255, 75, 75, 75), secondary: Colors.purple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(),
        '/passage': (context) => PassagePage(),
        '/search': (context) => SearchPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
