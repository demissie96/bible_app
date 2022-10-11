import 'package:flutter/material.dart';
import "side_menu.dart";

class PassagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Passage Page'),
      ),
      drawer: SideMenu(),
      body: Center(),
    );
  }
}
