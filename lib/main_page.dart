import 'package:flutter/material.dart';
import "side_menu.dart";
import 'dart:convert';
import 'package:flutter/services.dart';

List oldTestament = [];
List newTestament = [];
String bookRef = "GEN";
String bookNameHu = "1 Mózes";
String language = "chapters_hu";
int chapter = 1;
List totalChapter = [];
int verse = 1;
String appBarTitle = "Könyvek";

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  // We need a TabController to control the selected tab programmatically
  late final _tabController = TabController(length: 3, vsync: this);

  // Fetch content from the json file
  Future<void> readJson() async {
    final String response = await rootBundle.loadString('data/book_list.json');
    final data = await json.decode(response);
    for (var i = 0; i < 39; i++) {
      oldTestament.add(data[i]);
    }
    for (var i = 39; i < 66; i++) {
      newTestament.add(data[i]);
    }

    setState(() {
      oldTestament;
      newTestament;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readJson();
    for (var i = 1; i <= 50; i++) {
      totalChapter.add(i);
    }
    setState(() {
      appBarTitle = bookNameHu;
      totalChapter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(appBarTitle),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "Könyv"),
              Tab(text: "Fejezet"),
              Tab(text: "Vers"),
            ],
          ),
        ),
        drawer: SideMenu(),
        body: TabBarView(
          controller: _tabController,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        // Display the data loaded from sample.json
                        oldTestament.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                  itemCount: oldTestament.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                      ),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                              EdgeInsets>(
                                            EdgeInsets.all(13),
                                          ),
                                        ),
                                        key: ValueKey(oldTestament[index][0]),
                                        onPressed: () {
                                          print(oldTestament[index][0]);
                                          bookRef = oldTestament[index][0];
                                          bookNameHu = oldTestament[index][3];
                                          totalChapter = [];
                                          for (var i = 1;
                                              i <= oldTestament[index][1];
                                              i++) {
                                            totalChapter.add(i);
                                          }

                                          print(totalChapter.length);
                                          setState(() {
                                            appBarTitle = bookNameHu;
                                          });
                                          _tabController.index = 1;
                                        },
                                        child: Text(
                                          oldTestament[index][3],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        // Display the data loaded from sample.json
                        newTestament.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                  itemCount: newTestament.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                              EdgeInsets>(
                                            EdgeInsets.all(13),
                                          ),
                                        ),
                                        key: ValueKey(newTestament[index][0]),
                                        onPressed: () {
                                          print(newTestament[index][0]);
                                          bookRef = newTestament[index][0];
                                          bookNameHu = newTestament[index][3];
                                          totalChapter = [];
                                          for (var i = 1;
                                              i <= newTestament[index][1];
                                              i++) {
                                            totalChapter.add(i);
                                          }

                                          print(totalChapter.length);
                                          setState(() {
                                            appBarTitle = bookNameHu;
                                          });
                                          _tabController.index = 1;
                                        },
                                        child: Text(newTestament[index][3]),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Expanded(
                    child: ChapterList(),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text("Hello Verses"),
            ),
          ],
        ),
      ),
    );
  }
}

class ChapterList extends StatefulWidget {
  const ChapterList({
    Key? key,
  }) : super(key: key);

  @override
  State<ChapterList> createState() => _ChapterListState();
}

class _ChapterListState extends State<ChapterList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: totalChapter.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 60,
                  width: 80,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
