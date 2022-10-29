import 'dart:convert';

import 'package:bible_app/main_page.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import "side_menu.dart";
import 'extension/string_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PassagePage extends StatefulWidget {
  String appBarTitle;
  String chapter;
  int chapterSum;
  var bible;
  int verse;

  var bookList;
  String bookNameHu;

  String oldOrNew;
  String bookRef;
  String language;
  PassagePage({
    required this.appBarTitle,
    required this.bible,
    required this.chapter,
    required this.bookRef,
    required this.language,
    required this.oldOrNew,
    required this.chapterSum,
    required this.verse,
    required this.bookList,
    required this.bookNameHu,
  });

  @override
  State<PassagePage> createState() => _PassagePageState();
}

class _PassagePageState extends State<PassagePage> {
  // To list out subtitles from the AutoScroll list.
  int indexMinusHu = 0;
  int indexMinusEn = 0;

  final scrollDirection = Axis.vertical;
  late AutoScrollController itemController;
  late PageController pageController;

  // Bookmark
  List bookmarkList = [];
  // Book list
  var bookListPassage = {};

  Future saveLastRead({book, oldNew, language, chapter, bookNameHu, chapterSum}) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('book', book);
    await prefs.setString('bookNameHu', bookNameHu);
    await prefs.setString('oldNew', oldNew);
    await prefs.setString('language', language);
    await prefs.setInt('chapter', chapter);
    await prefs.setInt('chapterSum', chapterSum);

    String checkBook = prefs.getString('book')!;
    String checkOldNew = prefs.getString('oldNew')!;
    String checkLanguage = prefs.getString('language')!;
    int checkChapter = prefs.getInt('chapter')!;
    int checkChapterSum = prefs.getInt('chapterSum')!;
    String checkBookNameHu = prefs.getString('bookNameHu')!;
    //print("Book was added: $checkOldNew, $checkBook, $checkLanguage, $checkChapter, $checkBookNameHu, $checkChapterSum");
  }

  Future addBookmark({bookmark}) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();

    List<String> checkBookmark = prefs.getStringList('bookmark') ?? [];
    checkBookmark.add(bookmark);

    await prefs.setStringList('bookmark', checkBookmark);
    setState(() {
      bookmarkList = checkBookmark;
    });

    //print(bookmarkList);
  }

  Future deleteBookmark({bookmark}) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();

    if (bookmark.length == 0) {
      await prefs.remove('bookmark');
    } else {
      await prefs.setStringList('bookmark', bookmark);
    }

    setState(() {
      bookmarkList = bookmark;
    });

    //print(bookmarkList);
  }

  Future getBookmark() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();

    List<String> checkBookmark = prefs.getStringList('bookmark') ?? [];
    setState(() {
      bookmarkList = checkBookmark;
    });
    //print(bookmarkList);
  }

  _onPageViewChange(int page) {
    //print("Current Page: " + page.toString());
    widget.chapter = (page + 1).toString();
    setState(() {
      widget.appBarTitle = "${widget.bible[widget.oldOrNew][widget.bookRef]["short_hu"]} ${widget.chapter}";
    });
    widget.verse = 1;
    fontMultiplier();
    saveLastRead(
        book: widget.bookRef,
        oldNew: widget.oldOrNew,
        language: "chapters_hu",
        chapter: int.parse(widget.chapter),
        bookNameHu: widget.bookNameHu,
        chapterSum: widget.chapterSum);
  }

  Future scroolToIndex() async {
    //print("Widgete.verse = ${widget.verse}");
    if (widget.verse > 1) {
      await itemController
          .scrollToIndex(
            widget.verse,
            preferPosition: AutoScrollPosition.middle,
          )
          .then((value) => widget.verse = 1); // Fix language change jumping weirdly bug
    }
  }

  double multiplier = 1.0;
  Future fontMultiplier() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      multiplier = prefs.getDouble('multiplier') ?? 1.0;
    });
    //print("Color multiplier in passage: $multiplier");
  }

  Future<void> bookListJson() async {
    final String response = await rootBundle.loadString('data/book_list.json');
    final data = await json.decode(response);

    for (var i = 0; i < 39; i++) {
      bookListPassage[data[i][3]] = {
        "refName": data[i][0],
        "testament": "old",
        "shortName": data[i][2],
        "length": data[i][1]
      };
    }
    for (var i = 39; i < 66; i++) {
      bookListPassage[data[i][3]] = {
        "refName": data[i][0],
        "testament": "new",
        "shortName": data[i][2],
        "length": data[i][1]
      };
    }
  }

  @override
  void initState() {
    super.initState();
    fontMultiplier();
    bookListJson();

    getBookmark();

    setState(() {
      language = widget.language;
      //print("language: $language, widget.language: ${widget.language}");
    });
    saveLastRead(
        book: widget.bookRef,
        oldNew: widget.oldOrNew,
        language: "chapters_hu",
        chapter: int.parse(widget.chapter),
        bookNameHu: widget.bookNameHu,
        chapterSum: widget.chapterSum);
    pageController = PageController(
      initialPage: int.parse(widget.chapter) - 1,
      keepPage: true,
    );
    itemController = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // scroolToIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    var bibleCurrentHu = widget.bible[widget.oldOrNew][widget.bookRef]["chapters_hu"];
    var bibleCurrentEn = widget.bible[widget.oldOrNew][widget.bookRef]["chapters_eng"];
    // //print("chapter sum is ====> ${widget.chapterSum}");
    // //print("bibleCurrent is ====> $bibleCurrentHu");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scroolToIndex();
    });

    return WillPopScope(
      onWillPop: () async {
        // For controlling system back button action
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => MainPage()));
        return true;
      },
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
                Row(
                  children: [
                    Text(
                      widget.appBarTitle,
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                    GestureDetector(
                      onTap: () {
                        //print("Total chapters number: ${widget.chapterSum}");

                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Theme.of(context).colorScheme.background,
                                title: Text(
                                  "Fejezetek",
                                  style: Theme.of(context).textTheme.headline5?.copyWith(fontSize: 24 * multiplier),
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      for (var i = 1; i <= widget.chapterSum; i++)
                                        TextButton(
                                          style: Theme.of(context).textButtonTheme.style,
                                          onPressed: () {
                                            //print("$i was clicked");

                                            pageController.animateToPage(i - 1,
                                                duration: Duration(milliseconds: 500), curve: Curves.ease);
                                            Navigator.pop(context);
                                          },
                                          child: Text("$i. fejezet",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5
                                                  ?.copyWith(fontSize: 24 * multiplier)),
                                        )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: bookmarkList.length > 0 ? true : false,
                  child: GestureDetector(
                    onTap: () {
                      //print("Bookmark clicked");
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Theme.of(context).colorScheme.background,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    bookmarkList.length > 1 ? "Könyvjelzők" : "Könyvjelző",
                                    style: Theme.of(context).textTheme.headline5?.copyWith(fontSize: 24),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      deleteBookmark(bookmark: []);
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(
                                      Icons.delete_forever,
                                      size: 30,
                                      color: Theme.of(context).colorScheme.tertiary,
                                    ),
                                  ),
                                ],
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (var i = 0; i < bookmarkList.length; i++)
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Stack(
                                            children: [
                                              SizedBox(
                                                width: 150,
                                                child: TextButton(
                                                  style: Theme.of(context).textButtonTheme.style,
                                                  onPressed: () {
                                                    //print("${bookmarkList[i]} was clicked");

                                                    List splitListBookmark = bookmarkList[i].split(" ");

                                                    List chapAndVerseBookmark =
                                                        splitListBookmark.last.toString().split(":");
                                                    late String bookBookmark;
                                                    if (splitListBookmark.length > 2) {
                                                      bookBookmark = splitListBookmark[0] + " " + splitListBookmark[1];
                                                    } else {
                                                      bookBookmark = splitListBookmark[0];
                                                    }

                                                    String verseBookmark = chapAndVerseBookmark[1];
                                                    String chapterBookmark = chapAndVerseBookmark[0];
                                                    //print("bookBookmark: $bookBookmark");

                                                    String testamentBookmark =
                                                        bookListPassage[bookBookmark]["testament"];

                                                    //print("testament: $testamentBookmark, book: $bookBookmark, chapter: $chapterBookmark, verse: $verseBookmark");
// Jump to passage
                                                    // Navigator.pop(context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => PassagePage(
                                                          appBarTitle: "$bookBookmark $chapterBookmark",
                                                          chapter: chapterBookmark,
                                                          bible: widget.bible,
                                                          oldOrNew: testamentBookmark,
                                                          bookRef: bookListPassage[bookBookmark]["refName"],
                                                          language: "chapters_hu",
                                                          chapterSum: bookListPassage[bookBookmark]["length"],
                                                          verse: int.parse(verseBookmark),
                                                          bookList: widget.bookList,
                                                          bookNameHu: bookBookmark,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    bookmarkList[i],
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                                          fontSize: 20,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            child: Icon(
                                              Icons.close,
                                              color: Theme.of(context).colorScheme.tertiary,
                                              size: 30,
                                            ),
                                            onTap: () {
                                              //print("Delete: ${bookmarkList[i]}");
                                              bookmarkList.remove(bookmarkList[i]);
                                              deleteBookmark(bookmark: bookmarkList);
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      )
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.bookmark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          drawer: SideMenu(),
          body: PageView(controller: pageController, onPageChanged: _onPageViewChange, children: [
            // Book length
            for (int chap = 1; chap <= widget.chapterSum; chap++)
              // Hungarian based ListView
              ListView.builder(
                // To remember scroll position
                key: PageStorageKey(chap.toString()),
                itemCount: bibleCurrentHu["$chap"].length + 30, // Chapter length
                scrollDirection: scrollDirection,
                controller: itemController,
                itemBuilder: (context, index) {
                  // Chapter titles
                  if (index == 0) {
                    indexMinusHu = 0;
                    //print("Index minus Hun at zero ---> $indexMinusHu");
                    if ("${bibleCurrentEn["$chap"][0]["num"]}" == "0") {
                      indexMinusEn = 1;
                    }
                    if ('$chap. fejezet' != '${bibleCurrentHu["$chap"][index]["text_hu"]}') {
                      return Column(
                        children: [
                          Visibility(
                            visible: language == "chapters_hu" ? true : false,
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                              child: Text(
                                '$chap. fejezet\n${bibleCurrentHu["$chap"][index]["text_hu"]}',
                                style: Theme.of(context).textTheme.headline5?.copyWith(fontSize: 24 * multiplier),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: language == "chapters_hu" ? false : true,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Chapter $chap',
                                style: Theme.of(context).textTheme.headline5?.copyWith(fontSize: 24 * multiplier),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Chapter title if chapter has no title
                      return Column(
                        children: [
                          Visibility(
                            visible: language == "chapters_hu" ? true : false,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                '$chap. fejezet',
                                style: Theme.of(context).textTheme.headline5?.copyWith(fontSize: 24 * multiplier),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: language == "chapters_hu" ? false : true,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Chapter $chap',
                                style: Theme.of(context).textTheme.headline5?.copyWith(fontSize: 24 * multiplier),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  } else if (index < bibleCurrentHu["$chap"].length &&
                      bibleCurrentHu["$chap"][index]["num"] == "Subtitle") {
                    //print("Index minus Hun Before ---> $indexMinusHu");
                    indexMinusHu++; // For AutoScrollTag proper indexing
                    //print("Index minus Hun After increment---> $indexMinusHu");
                    // Hungarian subtitle
                    return Column(
                      crossAxisAlignment:
                          language == "chapters_hu" ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: language == "chapters_hu" ? true : false,
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                            child: Text(
                              bibleCurrentHu["$chap"][index]["text_hu"],
                              style: Theme.of(context).textTheme.headline5?.copyWith(fontSize: 24 * multiplier),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        if (index <= bibleCurrentEn["$chap"].length)
                          // English verse
                          Visibility(
                            visible: language == "chapters_hu" ? false : true,
                            child: AutoScrollTag(
                              key: ValueKey(index - indexMinusEn),
                              controller: itemController,
                              index: index - indexMinusEn,
                              child: GestureDetector(
                                onDoubleTap: () async {
                                  // Copy selected text to clipboard
                                  await Clipboard.setData(
                                    ClipboardData(
                                      text: "${bibleCurrentEn["$chap"][index - 1]["text_en"]}".capitalizeFirstForCopy(),
                                    ),
                                  ).then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                                        content: Text(
                                          "${widget.appBarTitle}:${bibleCurrentEn["$chap"][index - 1]["num"]} - Másolva (🇺🇸)",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(0.0),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 8.0, bottom: 8.0),
                                        child: RichText(
                                          text: TextSpan(children: [
                                            if ("${bibleCurrentEn["$chap"][index - 1]["num"]}" == "0")
                                              TextSpan(
                                                text: "${bibleCurrentEn["$chap"][index - 1]["text_en"]}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    ?.copyWith(fontSize: 20 * multiplier),
                                              ),
                                            if ("${bibleCurrentEn["$chap"][index - 1]["num"]}" != "0")
                                              TextSpan(
                                                text: "${bibleCurrentEn["$chap"][index - 1]["num"]}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    ?.copyWith(fontSize: 15 * multiplier),
                                              ),
                                            if ("${bibleCurrentEn["$chap"][index - 1]["num"]}" != "0")
                                              TextSpan(
                                                text: "${bibleCurrentEn["$chap"][index - 1]["text_en"]}"
                                                    .capitalizeFirst(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    ?.copyWith(fontSize: 20 * multiplier),
                                              ),
                                          ]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  } else {
                    // Only verses

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index < bibleCurrentHu["$chap"].length)
                          // Hungarian part
                          Visibility(
                            visible: language == "chapters_hu" ? true : false,
                            child: AutoScrollTag(
                              key: ValueKey(index - indexMinusHu),
                              controller: itemController,
                              index: index - indexMinusHu,
                              child: GestureDetector(
                                onDoubleTap: () async {
                                  // Copy selected text to clipboard
                                  await Clipboard.setData(
                                    ClipboardData(
                                      text: "${bibleCurrentHu["$chap"][index]["text_hu"]}".capitalizeFirstForCopy(),
                                    ),
                                  ).then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                                        content: Text(
                                          "${widget.appBarTitle}:${bibleCurrentHu["$chap"][index]["num"]} - Másolva (🇭🇺)",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(0.0),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 8.0, bottom: 8.0),
                                        child: RichText(
                                          text: TextSpan(children: [
                                            TextSpan(
                                              text: "${bibleCurrentHu["$chap"][index]["num"]}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  ?.copyWith(fontSize: 15 * multiplier),
                                            ),
                                            TextSpan(
                                              text: "${bibleCurrentHu["$chap"][index]["text_hu"]}".capitalizeFirst(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  ?.copyWith(fontSize: 20 * multiplier),
                                            ),
                                          ]),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 14.0),
                                          child: IconButton(
                                            onPressed: () {
                                              String bookmarkRefText =
                                                  "$bookNameHu $chap:${bibleCurrentHu["$chap"][index]["num"]}";

                                              if (bookmarkList.contains(bookmarkRefText)) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                                                    content: Text(
                                                      "${bookmarkRefText} - Mentve",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15.0,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                addBookmark(bookmark: bookmarkRefText).then((_) => {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                                                          content: Text(
                                                            "${bookmarkRefText} - Mentve",
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15.0,
                                                            ),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ),
                                                    });
                                              }
                                              //print(bookmarkRefText);
                                            },
                                            icon: Icon(
                                              Icons.star,
                                              color: Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (bibleCurrentHu["$chap"][index]["ref"] != null)
                                        hungarianReferences(bibleCurrentHu, chap, index, context)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (index <= bibleCurrentEn["$chap"].length)
                          // English part
                          Visibility(
                            visible: language == "chapters_hu" ? false : true,
                            child: AutoScrollTag(
                              key: ValueKey(index - indexMinusEn),
                              controller: itemController,
                              index: index - indexMinusEn,
                              child: GestureDetector(
                                onDoubleTap: () async {
                                  // Copy selected text to clipboard
                                  await Clipboard.setData(
                                    ClipboardData(
                                      text: "${bibleCurrentEn["$chap"][index - 1]["text_en"]}".capitalizeFirstForCopy(),
                                    ),
                                  ).then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                                        content: Text(
                                          "${widget.appBarTitle}:${bibleCurrentEn["$chap"][index - 1]["num"]} - Másolva (🇺🇸)",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(0.0),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 8.0, bottom: 8.0),
                                        child: RichText(
                                          text: TextSpan(children: [
                                            if ("${bibleCurrentEn["$chap"][index - 1]["num"]}" == "0")
                                              TextSpan(
                                                text: "${bibleCurrentEn["$chap"][index - 1]["text_en"]}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    ?.copyWith(fontSize: 20 * multiplier),
                                              ),
                                            if ("${bibleCurrentEn["$chap"][index - 1]["num"]}" != "0")
                                              TextSpan(
                                                text: "${bibleCurrentEn["$chap"][index - 1]["num"]}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    ?.copyWith(fontSize: 15 * multiplier),
                                              ),
                                            if ("${bibleCurrentEn["$chap"][index - 1]["num"]}" != "0")
                                              TextSpan(
                                                text: "${bibleCurrentEn["$chap"][index - 1]["text_en"]}"
                                                    .capitalizeFirst(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    ?.copyWith(fontSize: 20 * multiplier),
                                              ),
                                          ]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (index == bibleCurrentHu["$chap"].length + 29)
                          // At the end of the page to prevent floating button to hide content
                          SizedBox(
                            height: 75.0,
                          ),
                      ],
                    );
                  }
                },
              ),
          ]),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
            child: Text(
              language == "chapters_hu" ? "🇭🇺" : "🇺🇸",
              style: TextStyle(fontSize: 35.0),
            ),
            onPressed: () {
              setState(() {
                if (language == "chapters_hu") {
                  language = "chapters_eng";
                } else {
                  language = "chapters_hu";
                }
              });
              saveLastRead(
                  book: widget.bookRef,
                  oldNew: widget.oldOrNew,
                  language: "chapters_hu",
                  chapter: int.parse(widget.chapter),
                  bookNameHu: widget.bookNameHu,
                  chapterSum: widget.chapterSum);
            },
          ),
        ),
      ),
    );
  }

  // Hungarian references with their functions
  Positioned hungarianReferences(bibleCurrentHu, int chap, int index, BuildContext context) {
    return Positioned(
      right: 0.0,
      bottom: 0.0,
      child: SizedBox(
        width: 38,
        height: 38,
        child: IconButton(
          onPressed: () {
            //print("${bibleCurrentHu["$chap"][index]["ref"]}");
            showDialog(
                context: context,
                builder: (context) {
                  List refList = bibleCurrentHu["$chap"][index]["ref"];
                  return AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    title: Text(
                      bibleCurrentHu["$chap"][index]["ref"].length > 1 ? "Hivatkozások" : "Hivatkozás",
                      style: Theme.of(context).textTheme.headline5?.copyWith(fontSize: 24),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var element in refList)
                            SizedBox(
                              height: 35.0,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(0.0),
                                ),
                                onPressed: () {
// Print preview of the references #############################
                                  Navigator.pop(context);
                                  List prepareRef = element.split(" ");
                                  List prepareRef1 = prepareRef[1].split(",");
                                  String refBook = prepareRef[0];
                                  String refChapter = prepareRef1[0];
                                  String prepareVerse = prepareRef1[1];
                                  List verseList = [];
                                  if (prepareVerse.contains(".")) {
                                    List verseList1 = prepareRef1[1].split(".");
                                    List verseList2 = [];
                                    for (var element in verseList1) {
                                      if (element.contains("-")) {
                                        // Example (1Sám 1,2-5.19)
                                        verseList2 = element.split("-");
                                        List verseList3 = [];
                                        for (var i = int.parse(verseList2[0]); i <= int.parse(verseList2[1]); i++) {
                                          verseList3.add(i.toString());
                                        }
                                        for (var element in verseList3) {
                                          verseList.add(element);
                                        }
                                      } else {
                                        verseList.add(element);
                                      }
                                    }
                                  } else if (prepareVerse.contains("-")) {
                                    List verseList2 = prepareRef1[1].split("-");
                                    List verseList3 = [];
                                    for (var i = int.parse(verseList2[0]); i <= int.parse(verseList2[1]); i++) {
                                      verseList3.add(i.toString());
                                    }
                                    verseList = verseList3;
                                  } else {
                                    verseList.add(prepareVerse);
                                  }

                                  String refOldOrNew = bookList[refBook]["testament"];
                                  String refBookName = bookList[refBook]["refName"];
                                  String refBookNameFull = bookList[refBook]["fullName"];
                                  // //print(bookList);

                                  //print("Book: $refBookName");
                                  //print("Testament: $refOldOrNew");
                                  //print("Chapter: $refChapter");
                                  //print("Verses: $verseList");

                                  // //print(widget.bible[refOldOrNew][refBookName]
                                  //     ["chapters_hu"][refChapter]);

                                  int refBookLength = widget.bible[refOldOrNew][refBookName]["chapters_hu"].length;

                                  List refWholeChapter =
                                      widget.bible[refOldOrNew][refBookName]["chapters_hu"][refChapter];
                                  List finalVersList = [];
                                  for (var element in refWholeChapter) {
                                    if (verseList.contains(element["num"])) {
                                      String verseCapitalized = element["text_hu"];
                                      finalVersList.add(
                                          {"num": element["num"], "verse": verseCapitalized.capitalizeFirstForCopy()});
                                    }
                                  }
                                  //print(finalVersList);
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Theme.of(context).colorScheme.background,
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "$refBookNameFull $refChapter",
                                                style: Theme.of(context).textTheme.headline5?.copyWith(fontSize: 24),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
// Jump from ref to Passage ###############################################
                                                //print("Continue");

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PassagePage(
                                                      appBarTitle: "$refBookNameFull $refChapter",
                                                      chapter: refChapter,
                                                      bible: widget.bible,
                                                      oldOrNew: refOldOrNew,
                                                      bookRef: refBookName,
                                                      language: "chapters_hu",
                                                      chapterSum: refBookLength,
                                                      verse: int.parse(verseList[0]),
                                                      bookList: widget.bookList,
                                                      bookNameHu: refBookNameFull,
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                Icons.arrow_circle_right_outlined,
                                                color: Theme.of(context).colorScheme.tertiary,
                                                size: 30.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              for (element in finalVersList)
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: 8.0),
                                                  child: RichText(
                                                    text: TextSpan(children: [
                                                      TextSpan(
                                                        text: "${element["num"]} ",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2
                                                            ?.copyWith(fontSize: 15 * multiplier),
                                                      ),
                                                      TextSpan(
                                                        text: "${element["verse"]}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1
                                                            ?.copyWith(fontSize: 20 * multiplier),
                                                      ),
                                                    ]),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Icon(Icons.arrow_drop_down),
                                    Text(
                                      "$element 🔻",
                                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                });
          },
          icon: Icon(
            Icons.library_books,
            color: Theme.of(context).colorScheme.tertiary,
            size: 20,
          ),
        ),
      ),
    );
  }
}
