import 'package:flutter/material.dart';
import "side_menu.dart";

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Keresés'),
      ),
      drawer: SideMenu(),
      body: Center(),
    );
  }
}
