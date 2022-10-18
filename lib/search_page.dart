import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "side_menu.dart";

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.background,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text('Keresés'),
        ),
        drawer: SideMenu(),
        body: Center(),
      ),
    );
  }
}
