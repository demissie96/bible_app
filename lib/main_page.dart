import 'package:flutter/material.dart';
import "side_menu.dart";
import 'dart:convert';
import 'package:flutter/services.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  // We need a TabController to control the selected tab programmatically
  late final _tabController = TabController(length: 3, vsync: this);

  List _oldTestament = [];
  List _newTestament = [];
  String _bookRef = "GEN";
  String _bookNameHu = "1 Mózes";
  String _language = "chapters_hu";
  int _chapter = 1;
  int _verse = 1;
  String _appBarTitle = "Könyvek";

  // Fetch content from the json file
  Future<void> readJson() async {
    final String response = await rootBundle.loadString('data/book_list.json');
    final data = await json.decode(response);
    for (var i = 0; i < 39; i++) {
      _oldTestament.add(data[i]);
    }
    for (var i = 39; i < 66; i++) {
      _newTestament.add(data[i]);
    }

    setState(() {
      _oldTestament;
      _newTestament;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_appBarTitle),
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
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        // Display the data loaded from sample.json
                        _oldTestament.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                  itemCount: _oldTestament.length,
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
                                        key: ValueKey(_oldTestament[index][0]),
                                        onPressed: () {
                                          print(_oldTestament[index][0]);
                                          _bookRef = _oldTestament[index][0];
                                          _bookNameHu = _oldTestament[index][3];
                                          setState(() {
                                            _appBarTitle = _bookNameHu;
                                          });
                                          _tabController.index = 1;
                                        },
                                        child: Text(
                                          _oldTestament[index][3],
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
                        _newTestament.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                  itemCount: _newTestament.length,
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
                                        key: ValueKey(_newTestament[index][0]),
                                        onPressed: () {
                                          print(_newTestament[index][0]);
                                          _bookRef = _newTestament[index][0];
                                          _bookNameHu = _newTestament[index][3];
                                          setState(() {
                                            _appBarTitle = _bookNameHu;
                                          });
                                          _tabController.index = 1;
                                        },
                                        child: Text(_newTestament[index][3]),
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
            Text("Hello Chapters"),
            Text("Hello Verses"),
          ],
        ),
      ),
    );
  }
}
