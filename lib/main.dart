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
        cardColor: Color.fromARGB(255, 15, 52, 96),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          labelStyle: TextStyle(fontFamily: "Roboto Slab"),
          unselectedLabelStyle: TextStyle(fontFamily: "Roboto Slab"),
        ),
        appBarTheme: AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
          titleTextStyle: TextStyle(
            fontFamily: "Roboto Slab",
            fontSize: 20.0,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(
              color: Colors.white,
              fontFamily: "Roboto Slab",
            ),
            backgroundColor: Colors.red,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: TextStyle(
              fontFamily: "Roboto Slab",
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyText1: TextStyle(
            color: Color.fromARGB(170, 0, 0, 0),
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
            fontFamily: "Roboto Slab",
          ),
          bodyText2: TextStyle(
            color: Colors.red,
            fontSize: 15.0,
            fontWeight: FontWeight.normal,
            fontFamily: "Roboto Slab",
          ),
          headline5: TextStyle(
            color: Colors.black87,
            fontFamily: "Courgette",
          ),
          headline6: TextStyle(
            color: Colors.black87,
            fontFamily: "Courgette",
          ),
        ),
        listTileTheme: ListTileThemeData(
          textColor: Colors.black87,
          iconColor: Colors.red,
        ),
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: TextStyle(
            fontFamily: "Roboto Slab",
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color.fromARGB(255, 15, 52, 96),
          tertiary: Color.fromARGB(255, 233, 69, 96),
          background: Color.fromARGB(255, 22, 33, 62),
        ),
        cardColor: Color.fromARGB(255, 233, 69, 96),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          labelStyle: TextStyle(fontFamily: "Roboto Slab"),
          unselectedLabelStyle: TextStyle(fontFamily: "Roboto Slab"),
        ),
        appBarTheme: AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 15, 52, 96),
          titleTextStyle: TextStyle(
            fontFamily: "Roboto Slab",
            fontSize: 20.0,
          ),
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
              fontFamily: "Roboto Slab",
            ),
            backgroundColor: Color.fromARGB(255, 15, 52, 96),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: TextStyle(
              fontFamily: "Roboto Slab",
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyText1: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
            color: Colors.white70,
            fontFamily: "Roboto Slab",
          ),
          bodyText2: TextStyle(
            color: Color.fromARGB(255, 233, 69, 96),
            fontSize: 15.0,
            fontWeight: FontWeight.normal,
            fontFamily: "Roboto Slab",
          ),
          headline5: TextStyle(
            color: Colors.white70,
            fontFamily: "Courgette",
          ),
          headline6: TextStyle(
            color: Colors.white70,
            fontFamily: "Courgette",
          ),
        ),
        listTileTheme: ListTileThemeData(
          textColor: Colors.white,
          iconColor: Color.fromARGB(255, 233, 69, 96),
        ),
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: TextStyle(
            fontFamily: "Roboto Slab",
          ),
        ),
      ),
      home: MainPage(),
    );
  }
}
