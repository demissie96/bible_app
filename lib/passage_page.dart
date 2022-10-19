import 'dart:io';

import 'package:bible_app/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import "side_menu.dart";
import 'extension/string_extension.dart';

class PassagePage extends StatefulWidget {
  String appBarTitle;
  String chapter;
  int chapterSum;
  var bible;
  int verse;
  int verseSum;

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
    required this.verseSum,
  });

  @override
  State<PassagePage> createState() => _PassagePageState();
}

class _PassagePageState extends State<PassagePage> {
  // To list out subtitles from the AutoScroll list.
  int indexMinus = 0;
  final scrollDirection = Axis.vertical;
  late AutoScrollController itemController;

  _onPageViewChange(int page) {
    print("Current Page: " + page.toString());
    widget.chapter = (page + 1).toString();
    setState(() {
      widget.appBarTitle =
          "${widget.bible[widget.oldOrNew][widget.bookRef]["short_hu"]} ${widget.chapter}";
    });
    widget.verse = 1;
  }

  Future scroolToIndex() async {
    if (widget.verse > 1) {
      await itemController.scrollToIndex(
        widget.verse,
        preferPosition: AutoScrollPosition.middle,
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scroolToIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    var bibleCurrentHu =
        widget.bible[widget.oldOrNew][widget.bookRef]["chapters_hu"];
    var bibleCurrentEn =
        widget.bible[widget.oldOrNew][widget.bookRef]["chapters_eng"];
    print("chapter sum is ====> ${widget.chapterSum}");
    print("bibleCurrent is ====> $bibleCurrentHu");

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
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            title: Text(widget.appBarTitle),
          ),
          drawer: SideMenu(),
          body: PageView(
              controller: PageController(
                initialPage: int.parse(widget.chapter) - 1,
                keepPage: true,
              ),
              onPageChanged: _onPageViewChange,
              children: [
                for (int chap = 1; chap <= widget.chapterSum; chap++)
                  if (bibleCurrentHu["$chap"].length >
                      bibleCurrentEn["$chap"].length) ...[
                    ListView.builder(
                      // To remember scroll position
                      key: PageStorageKey(chap.toString()),
                      itemCount: bibleCurrentHu["$chap"].length,
                      scrollDirection: scrollDirection,
                      controller: itemController,
                      itemBuilder: (context, index) {
                        // Chapter titles
                        if (bibleCurrentHu["$chap"][index]["num"] == "Title") {
                          if ('$chap. fejezet' !=
                              '${bibleCurrentHu["$chap"][index]["text_hu"]}') {
                            return Column(
                              children: [
                                Visibility(
                                  visible:
                                      language == "chapters_hu" ? true : false,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '$chap. fejezet\n${bibleCurrentHu["$chap"][index]["text_hu"]}',
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      language == "chapters_hu" ? false : true,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Chapter $chap',
                                      style:
                                          Theme.of(context).textTheme.headline5,
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
                                  visible:
                                      language == "chapters_hu" ? true : false,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '$chap. fejezet',
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      language == "chapters_hu" ? false : true,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Chapter $chap',
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        } else if (bibleCurrentHu["$chap"][index]["num"] ==
                            "Subtitle") {
                          indexMinus++;
                          // Subtitle and english verse
                          return Column(
                            crossAxisAlignment: language == "chapters_hu"
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              // Hungarian part
                              Visibility(
                                visible:
                                    language == "chapters_hu" ? true : false,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    bibleCurrentHu["$chap"][index]["text_hu"],
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              if (index <= bibleCurrentEn["$chap"].length)
                                Visibility(
                                  visible:
                                      language == "chapters_hu" ? false : true,
                                  // English part
                                  child: GestureDetector(
                                    onDoubleTap: () async {
                                      // Copy selected text to clipboard
                                      await Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              "${bibleCurrentEn["$chap"][index - 1]["text_en"]}"
                                                  .capitalizeFirstForCopy(),
                                        ),
                                      ).then((_) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
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
                                      padding: const EdgeInsets.all(0.0),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30.0,
                                                right: 30.0,
                                                top: 8.0,
                                                bottom: 8.0),
                                            child: RichText(
                                              text: TextSpan(children: [
                                                TextSpan(
                                                  text:
                                                      "${bibleCurrentEn["$chap"][index - 1]["num"]}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2,
                                                ),
                                                TextSpan(
                                                  text:
                                                      "${bibleCurrentEn["$chap"][index - 1]["text_en"]}"
                                                          .capitalizeFirst(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1,
                                                ),
                                              ]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        } else {
                          // Only verses

                          return AutoScrollTag(
                            key: ValueKey(int.parse(
                                    bibleCurrentHu["$chap"][index]["num"]) -
                                indexMinus),
                            controller: itemController,
                            index: index - indexMinus,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hungarian part
                                Visibility(
                                  visible:
                                      language == "chapters_hu" ? true : false,
                                  child: GestureDetector(
                                    onDoubleTap: () async {
                                      // Copy selected text to clipboard
                                      await Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              "${bibleCurrentHu["$chap"][index]["text_hu"]}"
                                                  .capitalizeFirstForCopy(),
                                        ),
                                      ).then((_) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
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
                                      padding: const EdgeInsets.all(0.0),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30.0,
                                                right: 30.0,
                                                top: 8.0,
                                                bottom: 8.0),
                                            child: RichText(
                                              text: TextSpan(children: [
                                                TextSpan(
                                                  text:
                                                      "${bibleCurrentHu["$chap"][index]["num"]}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2,
                                                ),
                                                TextSpan(
                                                  text:
                                                      "${bibleCurrentHu["$chap"][index]["text_hu"]}"
                                                          .capitalizeFirst(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1,
                                                ),
                                              ]),
                                            ),
                                          ),
                                          if (bibleCurrentHu["$chap"][index]
                                                  ["ref"] !=
                                              null)
                                            Positioned(
                                              right: 0.0,
                                              bottom: 0.0,
                                              child: SizedBox(
                                                width: 38,
                                                height: 38,
                                                child: IconButton(
                                                  onPressed: () {
                                                    print(
                                                        "${bibleCurrentHu["$chap"][index]["ref"]}");
                                                  },
                                                  icon: Icon(
                                                    Icons.library_books,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .tertiary,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (index <= bibleCurrentEn["$chap"].length)
                                  // English part
                                  Visibility(
                                    visible: language == "chapters_hu"
                                        ? false
                                        : true,
                                    child: GestureDetector(
                                      onDoubleTap: () async {
                                        // Copy selected text to clipboard
                                        await Clipboard.setData(
                                          ClipboardData(
                                            text:
                                                "${bibleCurrentEn["$chap"][index - 1]["text_en"]}"
                                                    .capitalizeFirstForCopy(),
                                          ),
                                        ).then((_) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
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
                                        padding: const EdgeInsets.all(0.0),
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0,
                                                  right: 30.0,
                                                  top: 8.0,
                                                  bottom: 8.0),
                                              child: RichText(
                                                text: TextSpan(children: [
                                                  if ("${bibleCurrentEn["$chap"][index - 1]["num"]}" ==
                                                      "0")
                                                    TextSpan(
                                                      text:
                                                          "${bibleCurrentEn["$chap"][index - 1]["text_en"]}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline6,
                                                    ),
                                                  if ("${bibleCurrentEn["$chap"][index - 1]["num"]}" !=
                                                      "0")
                                                    TextSpan(
                                                      text:
                                                          "${bibleCurrentEn["$chap"][index - 1]["num"]}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2,
                                                    ),
                                                  if ("${bibleCurrentEn["$chap"][index - 1]["num"]}" !=
                                                      "0")
                                                    TextSpan(
                                                      text:
                                                          "${bibleCurrentEn["$chap"][index - 1]["text_en"]}"
                                                              .capitalizeFirst(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                    ),
                                                ]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                if (index == bibleCurrentHu["$chap"].length - 1)
                                  SizedBox(
                                    height: 75.0,
                                  ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ] else ...[
                    ListView.builder(
                      // To remember scroll position
                      key: PageStorageKey(chap.toString()),
                      itemCount: bibleCurrentEn["$chap"].length,
                      scrollDirection: scrollDirection,
                      controller: itemController,
                      itemBuilder: (context, index) {
                        // Title part
                        if (index < bibleCurrentHu["$chap"].length &&
                            bibleCurrentHu["$chap"][index]["num"] == "Title") {
                          if ('$chap. fejezet' !=
                              '${bibleCurrentHu["$chap"][index]["text_hu"]}') {
                            return Column(
                              children: [
                                Visibility(
                                  visible:
                                      language == "chapters_hu" ? true : false,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '$chap. fejezet\n${bibleCurrentHu["$chap"][index]["text_hu"]}',
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      language == "chapters_hu" ? false : true,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Chapter $chap',
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                                // Verse comes
                                Visibility(
                                  visible:
                                      language == "chapters_hu" ? false : true,
                                  // English part
                                  child: GestureDetector(
                                    onDoubleTap: () async {
                                      // Copy selected text to clipboard
                                      await Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              "${bibleCurrentEn["$chap"][index]["text_en"]}"
                                                  .capitalizeFirstForCopy(),
                                        ),
                                      ).then((_) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            content: Text(
                                              "${widget.appBarTitle}:${bibleCurrentEn["$chap"][index]["num"]} - Másolva (🇺🇸)",
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
                                      padding: const EdgeInsets.all(0.0),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30.0,
                                                right: 30.0,
                                                top: 8.0,
                                                bottom: 8.0),
                                            child: RichText(
                                              text: TextSpan(children: [
                                                if ("${bibleCurrentEn["$chap"][index]["num"]}" ==
                                                    "0") ...[
                                                  TextSpan(
                                                    text:
                                                        "${bibleCurrentEn["$chap"][index]["text_en"]}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6,
                                                  ),
                                                ] else ...[
                                                  TextSpan(
                                                    text:
                                                        "${bibleCurrentEn["$chap"][index]["num"]}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        "${bibleCurrentEn["$chap"][index]["text_en"]}"
                                                            .capitalizeFirst(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                  ),
                                                ]
                                              ]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            //  Title part if there is no title
                            return Column(
                              children: [
                                Visibility(
                                  visible:
                                      language == "chapters_hu" ? true : false,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '$chap. fejezet',
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      language == "chapters_hu" ? false : true,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Chapter $chap',
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        } else if (index < bibleCurrentHu["$chap"].length &&
                            bibleCurrentHu["$chap"][index]["num"] ==
                                "Subtitle") {
                          // Subtitle part
                          indexMinus++;
                          return Column(
                            crossAxisAlignment: language == "chapters_hu"
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              if (index <= bibleCurrentHu["$chap"].length)
                                Visibility(
                                  visible:
                                      language == "chapters_hu" ? true : false,
                                  // Hungarian part
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      bibleCurrentHu["$chap"][index]["text_hu"],
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              Visibility(
                                visible:
                                    language == "chapters_hu" ? false : true,
                                // English part
                                child: GestureDetector(
                                  onDoubleTap: () async {
                                    // Copy selected text to clipboard
                                    await Clipboard.setData(
                                      ClipboardData(
                                        text:
                                            "${bibleCurrentEn["$chap"][index - 1]["text_en"]}"
                                                .capitalizeFirstForCopy(),
                                      ),
                                    ).then((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
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
                                    padding: const EdgeInsets.all(0.0),
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30.0,
                                              right: 30.0,
                                              top: 8.0,
                                              bottom: 8.0),
                                          child: RichText(
                                            text: TextSpan(children: [
                                              TextSpan(
                                                text:
                                                    "${bibleCurrentEn["$chap"][index - 1]["num"]}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                              ),
                                              TextSpan(
                                                text:
                                                    "${bibleCurrentEn["$chap"][index - 1]["text_en"]}"
                                                        .capitalizeFirst(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                            ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Only verse
                          return AutoScrollTag(
                            key: ValueKey(int.parse(
                                bibleCurrentEn["$chap"][index]["num"])),
                            controller: itemController,
                            index: index,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index < bibleCurrentHu["$chap"].length)
                                  Visibility(
                                    visible: language == "chapters_hu"
                                        ? true
                                        : false,
                                    // Hungarian part
                                    child: GestureDetector(
                                      onDoubleTap: () async {
                                        // Copy selected text to clipboard
                                        await Clipboard.setData(
                                          ClipboardData(
                                            text:
                                                "${bibleCurrentHu["$chap"][index]["text_hu"]}"
                                                    .capitalizeFirstForCopy(),
                                          ),
                                        ).then((_) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
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
                                        padding: const EdgeInsets.all(0.0),
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0,
                                                  right: 30.0,
                                                  top: 8.0,
                                                  bottom: 8.0),
                                              child: RichText(
                                                text: TextSpan(children: [
                                                  TextSpan(
                                                    text:
                                                        "${bibleCurrentHu["$chap"][index]["num"]}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        "${bibleCurrentHu["$chap"][index]["text_hu"]}"
                                                            .capitalizeFirst(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                  ),
                                                ]),
                                              ),
                                            ),
                                            if (bibleCurrentHu["$chap"][index]
                                                    ["ref"] !=
                                                null)
                                              Positioned(
                                                right: 0.0,
                                                bottom: 0.0,
                                                child: SizedBox(
                                                  width: 38,
                                                  height: 38,
                                                  child: IconButton(
                                                    onPressed: () {
                                                      print(
                                                          "${bibleCurrentHu["$chap"][index]["ref"]}");
                                                    },
                                                    icon: Icon(
                                                      Icons.library_books,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .tertiary,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                Visibility(
                                  visible:
                                      language == "chapters_hu" ? false : true,
                                  // English part
                                  child: GestureDetector(
                                    onDoubleTap: () async {
                                      // Copy selected text to clipboard
                                      await Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              "${bibleCurrentEn["$chap"][index]["text_en"]}"
                                                  .capitalizeFirstForCopy(),
                                        ),
                                      ).then((_) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            content: Text(
                                              "${widget.appBarTitle}:${bibleCurrentEn["$chap"][index]["num"]} - Másolva (🇺🇸)",
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
                                      padding: const EdgeInsets.all(0.0),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30.0,
                                                right: 30.0,
                                                top: 8.0,
                                                bottom: 8.0),
                                            child: RichText(
                                              text: TextSpan(children: [
                                                if ("${bibleCurrentEn["$chap"][index]["num"]}" ==
                                                    "0") ...[
                                                  TextSpan(
                                                    text:
                                                        "${bibleCurrentEn["$chap"][index]["text_en"]}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6,
                                                  ),
                                                ] else ...[
                                                  TextSpan(
                                                    text:
                                                        "${bibleCurrentEn["$chap"][index]["num"]}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        "${bibleCurrentEn["$chap"][index]["text_en"]}"
                                                            .capitalizeFirst(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                  ),
                                                ]
                                              ]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (index == bibleCurrentEn["$chap"].length - 1)
                                  SizedBox(
                                    height: 75.0,
                                  ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
              ]),
          floatingActionButton: FloatingActionButton(
            backgroundColor:
                Theme.of(context).floatingActionButtonTheme.backgroundColor,
            child: Text(
              language == "chapters_hu" ? "🇺🇲" : "🇭🇺",
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
            },
          ),
        ),
      ),
    );
  }
}
