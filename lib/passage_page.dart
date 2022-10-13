import 'package:flutter/material.dart';
import "side_menu.dart";

class PassagePage extends StatelessWidget {
  final String text;
  PassagePage({required this.text});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(text),
      ),
      drawer: SideMenu(),
      body: Center(),
    );
  }
}
