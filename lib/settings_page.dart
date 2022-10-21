import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "side_menu.dart";

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double fontSize = 1.0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.background,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text('Beállítások'),
        ),
        drawer: SideMenu(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Betűméret",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  RadioListTile(
                    activeColor: Theme.of(context).colorScheme.tertiary,
                    title: Text(
                      "Kicsi",
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 20 * 0.8),
                    ),
                    value: 0.8,
                    groupValue: fontSize,
                    onChanged: (value) {
                      setState(() {
                        fontSize = value as double;
                      });
                    },
                  ),
                  RadioListTile(
                    activeColor: Theme.of(context).colorScheme.tertiary,
                    title: Text(
                      "Közepes",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    value: 1.0,
                    groupValue: fontSize,
                    onChanged: (value) {
                      setState(() {
                        fontSize = value as double;
                      });
                    },
                  ),
                  RadioListTile(
                    activeColor: Theme.of(context).colorScheme.tertiary,
                    title: Text(
                      "Nagy",
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 20 * 1.2),
                    ),
                    value: 1.2,
                    groupValue: fontSize,
                    onChanged: (value) {
                      setState(() {
                        fontSize = value as double;
                      });
                    },
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Theme.of(context).colorScheme.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: "16 ",
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 15 * fontSize),
                        ),
                        TextSpan(
                          text:
                              "Mert úgy szerette Isten e világot, hogy az ő egyszülött Fiát adta, hogy valaki hiszen őbenne, el ne vesszen, hanem örök élete legyen.",
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 20 * fontSize),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
