import 'package:flutter/material.dart';
import "side_menu.dart";

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Beállítások'),
      ),
      drawer: SideMenu(),
      body: Center(),
    );
  }
}
