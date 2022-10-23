import 'package:bible_app/passage_page.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import "side_menu.dart";
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

List oldTestament = [];
List newTestament = [];
var bookList = {};
var bookListIndex = {};
String bookRef = "GEN";
String oldOrNew = "old";
String bookNameHu = "1 Mózes";
String language = "chapters_hu";
int chapter = 1;
int chapterSum = 50;
List totalChapter = [];
int verse = 1;

String appBarTitle = "Könyvek";
late TabController tabController;
late Function updateTitle;
late var bibleJson;

var lastRead;

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  final scrollDirection = Axis.vertical;

  late AutoScrollController itemControllerOld;
  late AutoScrollController itemControllerNew;

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
      bookListIndex[data[i][0]] = {"index": i};
    }
    for (var i = 39; i < 66; i++) {
      newTestament.add(data[i]);
      bookList[data[i][2]] = {"refName": data[i][0], "testament": "new", "fullName": data[i][3]};
      bookListIndex[data[i][0]] = {"index": i};
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
    chapterSum = 50;
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

  Future getLastRead() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();

    String checkBook = prefs.getString('book') ?? bookRef;
    String checkBookNameHu = prefs.getString('bookNameHu') ?? bookNameHu;
    String checkOldNew = prefs.getString('oldNew') ?? oldOrNew;
    String checkLanguage = prefs.getString('language') ?? language;
    int checkChapter = prefs.getInt('chapter') ?? chapter;
    int checkChapterSum = prefs.getInt('chapterSum') ?? chapterSum;
    print(
        "Last read book: $checkOldNew, $checkBook, $checkLanguage, $checkChapter, $checkBookNameHu, $checkChapterSum");

    setState(() {
      bookRef = checkBook;
      oldOrNew = checkOldNew;
      language = language;
      chapter = checkChapter;
      bookNameHu = checkBookNameHu;
      chapterSum = checkChapterSum;
      appBarTitle = "$bookNameHu $chapter";
    });
  }

  // Future fontMultiplier() async {
  //   // Obtain shared preferences.
  //   final prefs = await SharedPreferences.getInstance();

  //   setState(() {
  //     fontSize = prefs.getDouble('multiplier') ?? 1.0;
  //   });
  //   print("Color multiplier: $fontSize");
  // }

  Future scrollToIndex(bookRef) async {
    print(bookListIndex[bookRef]);
    print("old or new? $oldOrNew");

    int position = bookListIndex[bookRef]["index"];

    if (oldOrNew == "old") {
      await itemControllerOld.scrollToIndex(
        position,
        preferPosition: AutoScrollPosition.middle,
      );
    } else {
      position -= 39;
      await itemControllerNew.scrollToIndex(
        position,
        preferPosition: AutoScrollPosition.middle,
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    restoreData();
    getLastRead().then((value) {
      totalChapter = [];
      print("chapter sum: $chapterSum");
      print("total chapter length: ${totalChapter.length}");
      for (var i = 1; i <= chapterSum; i++) {
        totalChapter.add(i);
      }
      print("total chapter length: ${totalChapter.length}");
      setState(() {
        appBarTitle = "$bookNameHu $chapter";
        totalChapter;
      });
      updateTitle = () {
        setState(() {
          appBarTitle;
        });
      };
    });

    bibleJsonGet();

    // We need a TabController to control the selected tab programmatically
    tabController = TabController(
      vsync: this,
      length: 3,
      animationDuration: Duration(
        milliseconds: 1000,
      ),
    );

    itemControllerOld = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    itemControllerNew = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);

    bookListJson().then((value) => {scrollToIndex(bookRef)});
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appBarTitle,
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ),
                IconButton(
                  onPressed: () {
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
                          bookList: bookList,
                          bookNameHu: bookNameHu,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.keyboard_double_arrow_right,
                    size: 30.0,
                  ),
                ),
              ],
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
                                    controller: itemControllerOld,
                                    itemBuilder: (context, index) {
                                      return AutoScrollTag(
                                        key: ValueKey(index),
                                        controller: itemControllerOld,
                                        index: index,
                                        child: Container(
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
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(),
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
                                    controller: itemControllerNew,
                                    itemCount: newTestament.length,
                                    itemBuilder: (context, index) {
                                      return AutoScrollTag(
                                        key: ValueKey(index),
                                        controller: itemControllerNew,
                                        index: index,
                                        child: Container(
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
  late int verseSum;
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
    print("########################### last element #####################");
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
          bookList: bookList,
          bookNameHu: bookNameHu,
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("old or new: $oldOrNew, bookref: $bookRef, language: $language, chapter: $chapter");
    verseSum = int.parse(bibleJson[oldOrNew][bookRef][language]["$chapter"].last["num"]);
  }

  @override
  Widget build(BuildContext context) {
    print("Length");
    print("old or new: $oldOrNew, bookref: $bookRef, language: $language, chapter: $chapter");

    print(bibleJson[oldOrNew][bookRef][language]["$chapter"].length);
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
