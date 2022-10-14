import 'package:flutter/material.dart';
import "side_menu.dart";

class PassagePage extends StatelessWidget {
  final String appBarTitle;
  final String chapter;
  final List bible;
  PassagePage(
      {required this.appBarTitle, required this.bible, required this.chapter});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(appBarTitle),
      ),
      drawer: SideMenu(),
      body: ListView.builder(
          itemCount: bible.length,
          itemBuilder: (context, index) {
            if (bible[index]["num"] == "Title") {
              if ('$chapter. fejezet' != '${bible[index]["text_hu"]}') {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$chapter. fejezet\n${bible[index]["text_hu"]}',
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$chapter. fejezet',
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                );
              }
            } else if (bible[index]["num"] == "Subtitle") {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  bible[index]["text_hu"],
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              if (bible[index]["ref"] != null) {
                print("Ref is working");
                print(bible[index]["ref"]);
              } else {
                print(bible[index]["ref"]);
              }
              return Padding(
                padding: const EdgeInsets.all(0.0),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 30.0, right: 35.0, top: 8.0, bottom: 8.0),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "${bible[index]["num"]}",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: " ${bible[index]["text_hu"]}",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ]),
                      ),
                    ),
                    if (bible[index]["ref"] != null)
                      Positioned(
                        right: 0.0,
                        bottom: 0.0,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            onPressed: () {
                              print("${bible[index]["ref"]}");
                            },
                            icon: Icon(
                              Icons.link,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              );
            }
          }),
    );
  }
}
