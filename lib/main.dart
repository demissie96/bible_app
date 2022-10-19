import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            primary: Colors.red,
            secondary: Colors.white,
            tertiary: Colors.red,
            background: Colors.white,
          ),
          appBarTheme: AppBarTheme(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyText1: TextStyle(
                color: Colors.black87,
                fontSize: 20.0,
                fontWeight: FontWeight.normal),
            headline5: TextStyle(color: Colors.black87),
            headline6: TextStyle(color: Colors.black87),
          ),
          listTileTheme: ListTileThemeData(
            textColor: Colors.black87,
            iconColor: Colors.red,
          )),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color.fromARGB(255, 15, 52, 96),
          tertiary: Color.fromARGB(255, 233, 69, 96),
          background: Color.fromARGB(255, 22, 33, 62),
        ),
        appBarTheme: AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 15, 52, 96),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: Color.fromARGB(255, 22, 33, 62),
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 22, 33, 62),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 15, 52, 96),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(
              color: Colors.white,
            ),
            backgroundColor: Color.fromARGB(255, 15, 52, 96),
          ),
        ),
        textTheme: const TextTheme(
          bodyText1: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
            color: Colors.white70,
          ),
          headline5: TextStyle(
            color: Colors.white70,
          ),
          headline6: TextStyle(
            color: Colors.white70,
          ),
        ),
        listTileTheme: ListTileThemeData(
          textColor: Colors.white,
          iconColor: Color.fromARGB(255, 233, 69, 96),
        ),
      ),
      home: MainPage(),
    );
  }
}
