import 'package:bible_app/main_page.dart';
import 'package:bible_app/search_page.dart';
import 'package:bible_app/settings_page.dart';
import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: const EdgeInsets.only(bottom: 12.0),
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('images/side_menu.jpg'),
              fit: BoxFit.cover,
            )),
            child: Center(
              child: Text(
                'Szent Biblia',
                style: TextStyle(
                  shadows: [
                    Shadow(
                      // offset: Offset(2.0, 2.0), //position of shadow
                      blurRadius: 40.0, //blur intensity of shadow
                      color: Colors.white.withOpacity(1.0), //color of shadow with opacity
                    ),
                  ],
                  color: Colors.white,
                  fontSize: 40,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 40.0, right: 40.0),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            child: TextButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    Future.delayed(Duration(milliseconds: 150), () {
                      Navigator.of(context).pop();
                    });
                    return AbsorbPointer();
                  },
                );
                Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
              },
              child: const ListTile(
                leading: Icon(
                  Icons.search,
                ),
                title: Text('Keresés'),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 40.0, right: 40.0),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            child: TextButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    Future.delayed(Duration(milliseconds: 150), () {
                      Navigator.of(context).pop();
                    });
                    return AbsorbPointer();
                  },
                );
                Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
              },
              child: const ListTile(
                leading: Icon(
                  Icons.menu_book_outlined,
                ),
                title: Text('Könyvek'),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 40.0, right: 40.0),
            decoration: const BoxDecoration(),
            child: TextButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    Future.delayed(Duration(milliseconds: 150), () {
                      Navigator.of(context).pop();
                    });
                    return AbsorbPointer();
                  },
                );
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
              },
              child: const ListTile(
                leading: Icon(
                  Icons.settings,
                ),
                title: Text('Beállítások'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
