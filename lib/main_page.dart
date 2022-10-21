import 'dart:io';

import 'package:bible_app/passage_page.dart';
import 'package:flutter/material.dart';
import "side_menu.dart";
import 'dart:convert';
import 'package:flutter/services.dart';

List oldTestament = [];
List newTestament = [];
var bookList = {};
String bookRef = "GEN";
String oldOrNew = "old";
String bookNameHu = "1 Mózes";
String language = "chapters_hu";
int chapter = 1;
List totalChapter = [];
int verse = 1;

String appBarTitle = "Könyvek";
late TabController tabController;
late Function updateTitle;
late var bibleJson;

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  final scrollDirection = Axis.vertical;

  JumpOneTab() {
    tabController.index += 1;
  }

  // Fetch content from the json file
  Future<void> bookListJson() async {
    final String response = await rootBundle.loadString('data/book_list.json');
    final data = await json.decode(response);

    for (var i = 0; i < 39; i++) {
      oldTestament.add(data[i]);
      bookList[data[i][2]] = {"refName": data[i][0], "testament": "old", "fullName": data[i][3]};
    }
    for (var i = 39; i < 66; i++) {
      newTestament.add(data[i]);
      bookList[data[i][2]] = {"refName": data[i][0], "testament": "new", "fullName": data[i][3]};
    }

    setState(() {
      oldTestament;
      newTestament;
    });
  }

  Future<void> bibleJsonGet() async {
    final String res = await rootBundle.loadString('data/bible_hu_en.json');
    bibleJson = await json.decode(res);
  }

  restoreData() {
    oldTestament = [];
    newTestament = [];
    bookRef = "GEN";
    oldOrNew = "old";
    bookNameHu = "1 Mózes";
    language = "chapters_hu";
    chapter = 1;
    totalChapter = [];
    verse = 1;
    appBarTitle = "Könyvek";
  }

  Future chooseBookOld(index) async {
    await showDialog(
      context: context,
      builder: (context) {
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.of(context).pop();
        });
        return AbsorbPointer(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
    tabController.index = 1;
    oldOrNew = "old";
    print(oldTestament[index][0]);
    bookRef = oldTestament[index][0];
    bookNameHu = oldTestament[index][3];
    chapter = 1;
    verse = 1;
    totalChapter = [];
    for (var i = 1; i <= oldTestament[index][1]; i++) {
      totalChapter.add(i);
    }

    print(totalChapter.length);
    setState(() {
      appBarTitle = "$bookNameHu $chapter";
    });
  }

  Future chooseBookNew(index) async {
    await showDialog(
      context: context,
      builder: (context) {
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.of(context).pop();
        });
        return AbsorbPointer(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
    tabController.index = 1;
    oldOrNew = "new";
    print(newTestament[index][3]);
    bookRef = newTestament[index][0];
    bookNameHu = newTestament[index][3];
    chapter = 1;
    verse = 1;
    totalChapter = [];
    for (var i = 1; i <= newTestament[index][1]; i++) {
      totalChapter.add(i);
    }

    print(totalChapter.length);
    setState(() {
      appBarTitle = "$bookNameHu $chapter";
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    restoreData();

    bibleJsonGet();

    // We need a TabController to control the selected tab programmatically
    tabController = TabController(
      vsync: this,
      length: 3,
      animationDuration: Duration(
        milliseconds: 1000,
      ),
    );
    bookListJson();
    for (var i = 1; i <= 50; i++) {
      totalChapter.add(i);
    }
    setState(() {
      appBarTitle = "$bookNameHu $chapter";
      totalChapter;
    });
    updateTitle = () {
      setState(() {
        appBarTitle;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: Theme.of(context).colorScheme.background,
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            title: Text(
              appBarTitle,
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
            ),
            bottom: TabBar(
              indicatorColor: Theme.of(context).colorScheme.tertiary,
              controller: tabController,
              tabs: [
                Tab(text: "Könyv"),
                Tab(text: "Fejezet"),
                Tab(text: "Vers"),
              ],
            ),
          ),
          drawer: SideMenu(),
          body: TabBarView(
            controller: tabController,
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
                                    key: PageStorageKey("oldTestament"),
                                    scrollDirection: scrollDirection,
                                    itemCount: oldTestament.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          left: 10.0,
                                          right: 10.0,
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.all(13.0),
                                            backgroundColor: bookNameHu == oldTestament[index][3]
                                                ? Theme.of(context).cardColor
                                                : null,
                                          ),
                                          key: ValueKey(oldTestament[index][0]),
                                          onPressed: () {
                                            chooseBookOld(index);
                                          },
                                          child: Text(
                                            oldTestament[index][3],
                                            style: TextStyle(
                                              color: Theme.of(context).appBarTheme.foregroundColor,
                                            ),
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
                                    key: PageStorageKey("newTestament"),
                                    scrollDirection: scrollDirection,
                                    itemCount: newTestament.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.all(13.0),
                                            backgroundColor: bookNameHu == newTestament[index][3]
                                                ? Theme.of(context).cardColor
                                                : null,
                                          ),
                                          key: ValueKey(newTestament[index][0]),
                                          onPressed: () {
                                            chooseBookNew(index);
                                          },
                                          child: Text(
                                            newTestament[index][3],
                                            style: TextStyle(
                                              color: Theme.of(context).appBarTheme.foregroundColor,
                                            ),
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ChapterList(),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Column(
                  children: [
                    Expanded(
                      child: VerseList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
  Future chooseChapter(i) async {
    await showDialog(
      context: context,
      builder: (context) {
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.of(context).pop();
        });
        return AbsorbPointer(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
    tabController.index = 2;
    chapter = i;

    appBarTitle = "$bookNameHu $chapter";
    print(appBarTitle);
    updateTitle();

    print("Chapter $i is selected");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        children: [
          for (var i in totalChapter)
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: SizedBox(
                height: 50,
                width: 60,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: chapter == i ? Theme.of(context).cardColor : null,
                  ),
                  onPressed: () {
                    chooseChapter(i);
                  },
                  child: Text(
                    "$i",
                    style: TextStyle(
                      fontSize: 25,
                      color: chapter == i ? Colors.white : null,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class VerseList extends StatefulWidget {
  const VerseList({
    Key? key,
  }) : super(key: key);

  @override
  State<VerseList> createState() => _VerseListState();
}

class _VerseListState extends State<VerseList> {
  Future chooseVerse(i) async {
    await showDialog(
      context: context,
      builder: (context) {
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.of(context).pop();
        });
        return AbsorbPointer(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );

    print(bibleJson[oldOrNew][bookRef][language]["$chapter"].last);

    verse = i;
    print(verse);
    // print(bibleJson[oldOrNew][bookRef][language]["$chapter"][0]);
    print("Verse $i was clicked!");
    updateTitle();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PassagePage(
          appBarTitle: appBarTitle,
          chapter: "$chapter",
          bible: bibleJson,
          oldOrNew: oldOrNew,
          bookRef: bookRef,
          language: language,
          chapterSum: totalChapter.length,
          verse: verse,
          verseSum: verseSum,
          bookList: bookList,
        ),
      ),
    );
  }

  int verseSum = int.parse(bibleJson[oldOrNew][bookRef][language]["$chapter"].last["num"]);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        children: [
          for (var i = 1; i <= verseSum; i++)
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: SizedBox(
                height: 50,
                width: 60,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: verse == i ? Theme.of(context).cardColor : null,
                  ),
                  onPressed: () {
                    chooseVerse(i);
                  },
                  child: Text(
                    "$i",
                    style: TextStyle(
                      fontSize: 25,
                      color: verse == i ? Colors.white : null,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
