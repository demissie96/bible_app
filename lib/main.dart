import 'package:flutter/material.dart';
import 'main_page.dart';

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
        cardColor: Colors.white,
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.white,
          labelStyle: TextStyle(fontFamily: "Roboto Slab"),
          unselectedLabelStyle: TextStyle(fontFamily: "Roboto Slab"),
        ),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
          titleTextStyle: TextStyle(
            fontFamily: "Roboto Slab",
            fontSize: 20.0,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black87,
            textStyle: const TextStyle(
              color: Colors.white,
              fontFamily: "Roboto Slab",
            ),
            backgroundColor: Colors.red,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(
              fontFamily: "Roboto Slab",
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyText1: TextStyle(
            color: Colors.black87,
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
            fontFamily: "Roboto Slab",
          ),
        ),
        listTileTheme: const ListTileThemeData(
          textColor: Colors.black87,
          iconColor: Colors.red,
        ),
        snackBarTheme: const SnackBarThemeData(
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
        cardColor: const Color.fromARGB(255, 233, 69, 96),
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.white,
          labelStyle: TextStyle(fontFamily: "Roboto Slab"),
          unselectedLabelStyle: TextStyle(fontFamily: "Roboto Slab"),
        ),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 15, 52, 96),
          titleTextStyle: TextStyle(
            fontFamily: "Roboto Slab",
            fontSize: 20.0,
          ),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color.fromARGB(255, 22, 33, 62),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 22, 33, 62),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 15, 52, 96),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              color: Colors.white,
              fontFamily: "Roboto Slab",
            ),
            backgroundColor: const Color.fromARGB(255, 15, 52, 96),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(
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
            fontFamily: "Roboto Slab",
          ),
        ),
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          iconColor: Color.fromARGB(255, 233, 69, 96),
        ),
        snackBarTheme: const SnackBarThemeData(
          contentTextStyle: TextStyle(
            fontFamily: "Roboto Slab",
          ),
        ),
      ),
      home: MainPage(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
