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
        Future.delayed(Duration(milliseconds: 150), () {
          Navigator.of(context).pop();
        });
        return AbsorbPointer();
      },
    );

    tabController.index = 1;
    oldOrNew = "old";
    bookRef = oldTestament[index][0];
    bookNameHu = oldTestament[index][3];
    chapter = 1;
    verse = 1;
    totalChapter = [];

    for (var i = 1; i <= oldTestament[index][1]; i++) {
      totalChapter.add(i);
    }

    setState(() {
      appBarTitle = "$bookNameHu $chapter";
    });
  }

  Future chooseBookNew(index) async {
    await showDialog(
      context: context,
      builder: (context) {
        Future.delayed(Duration(milliseconds: 150), () {
          Navigator.of(context).pop();
        });
        return AbsorbPointer();
      },
    );

    tabController.index = 1;
    oldOrNew = "new";
    bookRef = newTestament[index][0];
    bookNameHu = newTestament[index][3];
    chapter = 1;
    verse = 1;
    totalChapter = [];

    for (var i = 1; i <= newTestament[index][1]; i++) {
      totalChapter.add(i);
    }

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
    // print("Last read book: $checkOldNew, $checkBook, $checkLanguage, $checkChapter, $checkBookNameHu, $checkChapterSum");

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

  Future scrollToIndex(bookRef) async {
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
    super.initState();

    restoreData();
    getLastRead().then((value) {
      totalChapter = [];

      for (var i = 1; i <= chapterSum; i++) {
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
    });

    bibleJsonGet();

    // TabController to control the selected tab programmatically
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
            titleSpacing: 0,
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
// Continue where you left off button.
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
// Tab for select book
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
// Display old testament book list
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
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                            top: 2,
                                            bottom: 2,
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
                                              maxLines: 1,
                                              softWrap: false,
                                              style: TextStyle(
                                                overflow: TextOverflow.fade,
                                                color: bookNameHu == oldTestament[index][3]
                                                    ? null
                                                    : Theme.of(context).appBarTheme.foregroundColor,
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
// Display old testament book list
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
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                            top: 2,
                                            bottom: 2,
                                          ),
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
                                              maxLines: 1,
                                              softWrap: false,
                                              style: TextStyle(
                                                overflow: TextOverflow.fade,
                                                color: bookNameHu == newTestament[index][3]
                                                    ? null
                                                    : Theme.of(context).appBarTheme.foregroundColor,
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
// Tab for listing chapters number
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
// Tab for listing verses number
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
        Future.delayed(Duration(milliseconds: 150), () {
          Navigator.of(context).pop();
        });
        return AbsorbPointer();
      },
    );
    tabController.index = 2;
    chapter = i;
    appBarTitle = "$bookNameHu $chapter";

    updateTitle();
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
                    backgroundColor: chapter == i ? Theme.of(context).colorScheme.tertiary : null,
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
        Future.delayed(Duration(milliseconds: 150), () {
          Navigator.of(context).pop();
        });
        return AbsorbPointer();
      },
    );

    verse = i;
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
    super.initState();
    verseSum = int.parse(bibleJson[oldOrNew][bookRef][language]["$chapter"].last["num"]);
  }

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
                    backgroundColor: verse == i ? Theme.of(context).colorScheme.tertiary : null,
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
