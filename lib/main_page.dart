import 'package:flutter/material.dart';
import "side_menu.dart";

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Könyvek'),
      ),
      drawer: SideMenu(),
      body: Center(),
    );
  }
}
