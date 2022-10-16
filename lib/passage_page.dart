import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
        preferPosition: AutoScrollPosition.begin,
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
    var bibleCurrent =
        widget.bible[widget.oldOrNew][widget.bookRef][widget.language];
    print("chapter sum is ====> ${widget.chapterSum}");
    print("bibleCurrent is ====> $bibleCurrent");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
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
              ListView.builder(
                  // To remember scroll position
                  key: PageStorageKey(chap.toString()),
                  itemCount: bibleCurrent["$chap"].length,
                  scrollDirection: scrollDirection,
                  controller: itemController,
                  itemBuilder: (context, index) {
                    if (bibleCurrent["$chap"][index]["num"] == "Title") {
                      if ('$chap. fejezet' !=
                          '${bibleCurrent["$chap"][index]["text_hu"]}') {
                        return AutoScrollTag(
                          key: ValueKey(index),
                          controller: itemController,
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '$chap. fejezet\n${bibleCurrent["$chap"][index]["text_hu"]}',
                              style: Theme.of(context).textTheme.headline5,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else {
                        return AutoScrollTag(
                          key: ValueKey(index),
                          controller: itemController,
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '$chap. fejezet',
                              style: Theme.of(context).textTheme.headline5,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                    } else if (bibleCurrent["$chap"][index]["num"] ==
                        "Subtitle") {
                      return AutoScrollTag(
                        key: ValueKey(index),
                        controller: itemController,
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            bibleCurrent["$chap"][index]["text_hu"],
                            style: Theme.of(context).textTheme.headline5,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    } else {
                      return AutoScrollTag(
                        key: ValueKey(index),
                        controller: itemController,
                        index: index,
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
                                          "${bibleCurrent["$chap"][index]["num"]}",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 15,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          "${bibleCurrent["$chap"][index]["text_hu"]}"
                                              .capitalizeFirst(),
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ]),
                                ),
                              ),
                              if (bibleCurrent["$chap"][index]["ref"] != null)
                                Positioned(
                                  right: 0.0,
                                  bottom: 0.0,
                                  child: SizedBox(
                                    width: 38,
                                    height: 38,
                                    child: IconButton(
                                      onPressed: () {
                                        print(
                                            "${bibleCurrent["$chap"][index]["ref"]}");
                                      },
                                      icon: Icon(
                                        Icons.library_books,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      );
                    }
                  }),
          ]),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     scroolToIndex();
      //   },
      // ),
    );
  }
}
