import 'dart:convert';
import 'dart:isolate';
import 'package:bible_app/main_page.dart';
import 'package:bible_app/passage_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "side_menu.dart";
import 'package:string_similarity/string_similarity.dart';
import 'extension/string_extension.dart';

String searchText = '';
var bibleListHu;
var bibleListEn;
List resultList = [];
List typingMatchList = [];
String searchLanguage = "hun";
var bookRefList = {};
int previousMillisec = 0;
bool circularProgressShown = false;

class RequiredArgs {
  late final SendPort sendPort;
  late String text;
  late var importedBible;

  RequiredArgs(this.text, this.importedBible, this.sendPort);
}

// Search for exact match
searchExactMatch(RequiredArgs requiredArgs) {
  String _currentVerse;
  var _currentVerseMap = {};
  String _currentVerseLower;
  int _totalMatch = 0;
  List _matchList = [];
  final SendPort sendPort = requiredArgs.sendPort;
  final text = requiredArgs.text.replaceAll(",", "").replaceAll("  ", " ");
  final importedBible = requiredArgs.importedBible;

  for (var element in importedBible) {
    _currentVerse = element["text"].split("&")[0];
    _currentVerseLower = _currentVerse.replaceAll(",", "").toLowerCase();
    if (_currentVerseLower.contains(text.toLowerCase())) {
      _totalMatch++;
      _currentVerseMap = {
        "testament": element["testament"],
        "book": element["book"],
        "language": element["language"],
        "chapter": element["chapter"],
        "verse": element["verse"],
        "text": _currentVerse.capitalizeFirstElement()
      };
      _matchList.add(_currentVerseMap);
    }
  }

  sendPort.send(_matchList);
}

// Search for similar match
searchSimilarMatch(RequiredArgs requiredArgs) {
  final SendPort sendPort = requiredArgs.sendPort;
  String givenText = requiredArgs.text.toLowerCase();
  List indexSimilarity = [];
  int index = 0;
  List resultListPre = [];

  rankingSearch(list) {
    for (var element in list) {
      var similarity = givenText.similarityTo(element["text"].toLowerCase());
      indexSimilarity.add(SimilarityIndex(index, similarity));
      index++;
    }

    indexSimilarity.sort((a, b) => b.similarity.compareTo(a.similarity));

    // List top 10 result
    for (var i = 0; i < 10; i++) {
      resultListPre.add(list[indexSimilarity[i].index]);
    }

    List resultListFinal = [];
    for (var element in resultListPre) {
      String text = element["text"].split("&")[0];
      text = text.capitalizeFirstElement();
      resultListFinal.add({
        "testament": "${element["testament"]}",
        "book": "${element["book"]}",
        "language": "${element["language"]}",
        "chapter": element["chapter"],
        "verse": "${element["verse"]}",
        "text": text
      });
    }

    List indexSimilarity2 = [];
    index = 0;
    List notSelectedIndex = [];

    for (var element in resultListFinal) {
      var similarity = givenText.similarityTo(element["text"].toLowerCase());

      if (similarity >= 0.30) {
        indexSimilarity2.add(SimilarityIndex(index, similarity));
      } else {
        notSelectedIndex.add(index);
      }
      index++;
    }

    indexSimilarity2.sort((a, b) => b.similarity.compareTo(a.similarity));

    List resultList = [];
    for (var element in indexSimilarity2) {
      resultList.add(resultListFinal[element.index]);
    }
    for (var element in notSelectedIndex) {
      resultList.add(resultListFinal[element]);
    }

    sendPort.send(resultList);
  }

  rankingSearch(requiredArgs.importedBible);
}

class SimilarityIndex {
  int index;
  double similarity;

  SimilarityIndex(this.index, this.similarity);

  @override
  String toString() {
    return '{ $index, $similarity }';
  }
}

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController textController = TextEditingController();

  Future<void> bibleListGet() async {
    final String res1 = await rootBundle.loadString('data/bible_in_list_hu.json');
    bibleListHu = await json.decode(res1);
    final String res2 = await rootBundle.loadString('data/bible_in_list_en.json');
    bibleListEn = await json.decode(res2);
  }

// Create a book reference map
  Future<void> bookListJson() async {
    final String response = await rootBundle.loadString('data/book_list.json');
    final data = await json.decode(response);

    for (var i = 0; i < 39; i++) {
      bookRefList[data[i][0]] = {
        "hunName": data[i][2],
        "testament": "old",
        "fullName": data[i][3],
        "chapterSum": data[i][1]
      };
    }
    for (var i = 39; i < 66; i++) {
      bookRefList[data[i][0]] = {
        "hunName": data[i][2],
        "testament": "new",
        "fullName": data[i][3],
        "chapterSum": data[i][1]
      };
    }
  }

  @override
  void initState() {
    super.initState();
    bibleListGet();
    bookListJson();

    setState(() {
      resultList = [];
      typingMatchList = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
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
              const Text('Keresés'),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  height: 40.0,
                  width: 40.0,
// Change language button
                  child: FloatingActionButton(
                    heroTag: "language",
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Text(
                      searchLanguage == "hun" ? "🇭🇺" : "🇺🇲",
                      style: const TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                    onPressed: () {
                      if (searchLanguage == "hun") {
                        searchLanguage = "eng";
                      } else {
                        searchLanguage = "hun";
                      }
// Delete all result on language change
                      setState(() {
                        searchLanguage;
                        resultList = [];
                        typingMatchList = [];
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        drawer: const SideMenu(),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
// Search field
              TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: textController,
                autofocus: true,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    hintText: searchLanguage == "hun" ? "Keresés..." : "Search...",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        textController.clear();
                        setState(() {
                          typingMatchList = [];
                          resultList = [];
                          searchText = "";
                        });
                      },
                    )),
                onChanged: (text) async {
// Background search in isolate
                  if (searchText != text && text.length > 2) {
                    searchText = text;
// Prevent isolate search called too many times when backspace hold down
                    int currentMillisec = DateTime.now().millisecondsSinceEpoch;
                    if (currentMillisec > previousMillisec + 200) {
                      previousMillisec = currentMillisec;
// Creating an isolate
                      final receivePort = ReceivePort();
                      RequiredArgs requiredArgs = RequiredArgs(
                          searchText, searchLanguage == "hun" ? bibleListHu : bibleListEn, receivePort.sendPort);

                      await Isolate.spawn(searchExactMatch, requiredArgs);
// Get the result from the isolate when finished
                      receivePort.listen((response) {
// To prevent show results when backspace pressed long and emptied the text field
                        if (searchText == "") {
                          typingMatchList = [];
                        } else {
                          typingMatchList = response;
                        }
                        setState(() {
                          typingMatchList;
                          resultList = [];
                        });
                      });
                    }
                  } else if (searchText != text) {
// Delete results except if android back button is pressed
                    searchText = "";
                    typingMatchList = [];
                    setState(() {
                      searchText;
                      typingMatchList;
                      resultList = [];
                    });
                  }
                },
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
// Total results
                  SizedBox(
                    height: 80.0,
                    child: Center(
                      child: Row(
                        children: [
                          Text(
                            "Találat:",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          Visibility(
                            visible: resultList.isEmpty ? true : false,
                            child: Text(
                              " ${typingMatchList.length}",
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                    color: Theme.of(context).colorScheme.tertiary,
                                    fontSize: 30.0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
// Search button
                  Visibility(
                    visible: typingMatchList.isNotEmpty || searchText.length < 6 ? false : true,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: FloatingActionButton(
                        heroTag: "search",
                        backgroundColor: Theme.of(context).colorScheme.secondary,
// String similarity trigger
                        onPressed: circularProgressShown
                            ? null
                            : () async {
                                setState(() {
                                  resultList = [];
                                  typingMatchList = [];
                                  circularProgressShown = true;
                                });
// Start similarity search in isolate
                                final receivePort = ReceivePort();
                                RequiredArgs requiredArgs = RequiredArgs(searchText,
                                    searchLanguage == "hun" ? bibleListHu : bibleListEn, receivePort.sendPort);

                                await Isolate.spawn(searchSimilarMatch, requiredArgs);
// Get the isolate result
                                receivePort.listen((response) {
                                  setState(() {
                                    circularProgressShown = false;
                                    resultList = response;
                                  });
                                });
                              },
                        child: Icon(
                          Icons.manage_search_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 35.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: circularProgressShown ? true : false,
                      child: const CircularProgressIndicator(),
                    ),
// String similarity search result
                    resultList.isNotEmpty
                        ? Visibility(
                            visible: typingMatchList.isNotEmpty ? false : true,
                            child: Expanded(
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: resultList.length,
                                  itemBuilder: (context, index) {
                                    String bookName = searchLanguage == "hun"
                                        ? bookRefList[resultList[index]["book"]]["hunName"]
                                        : resultList[index]["book"];
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PassagePage(
                                                  appBarTitle:
                                                      "${bookRefList[resultList[index]["book"]]["fullName"]} ${resultList[index]["chapter"]}",
                                                  chapter: resultList[index]["chapter"].toString(),
                                                  bible: bibleJson,
                                                  oldOrNew: bookRefList[resultList[index]["book"]]["testament"],
                                                  bookRef: resultList[index]["book"],
                                                  language: searchLanguage == "hun" ? "chapters_hu" : "chapters_eng",
                                                  chapterSum: bookRefList[resultList[index]["book"]]["chapterSum"],
                                                  verse: int.parse(resultList[index]["verse"]),
                                                  bookList: bookList,
                                                  bookNameHu: bookRefList[resultList[index]["book"]]["fullName"],
                                                ),
                                              ),
                                            );
                                          },
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text:
                                                      "$bookName ${resultList[index]["chapter"]}:${resultList[index]["verse"]}",
                                                  style: Theme.of(context).textTheme.bodyText2,
                                                ),
                                                TextSpan(
                                                  text: " ${resultList[index]["text"]}",
                                                  style: Theme.of(context).textTheme.bodyText1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          )
                        : Container(),
// Exact matches search result
                    typingMatchList.isNotEmpty
                        ? Expanded(
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: typingMatchList.length,
                                itemBuilder: (context, index) {
                                  String bookName = searchLanguage == "hun"
                                      ? bookRefList[typingMatchList[index]["book"]]["hunName"]
                                      : typingMatchList[index]["book"];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PassagePage(
                                              appBarTitle:
                                                  "${bookRefList[typingMatchList[index]["book"]]["fullName"]} ${typingMatchList[index]["chapter"]}",
                                              chapter: typingMatchList[index]["chapter"].toString(),
                                              bible: bibleJson,
                                              oldOrNew: bookRefList[typingMatchList[index]["book"]]["testament"],
                                              bookRef: typingMatchList[index]["book"],
                                              language: searchLanguage == "hun" ? "chapters_hu" : "chapters_eng",
                                              chapterSum: bookRefList[typingMatchList[index]["book"]]["chapterSum"],
                                              verse: int.parse(typingMatchList[index]["verse"]),
                                              bookList: bookList,
                                              bookNameHu: bookRefList[typingMatchList[index]["book"]]["fullName"],
                                            ),
                                          ),
                                        );
                                      },
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  "$bookName ${typingMatchList[index]["chapter"]}:${typingMatchList[index]["verse"]}",
                                              style: Theme.of(context).textTheme.bodyText2,
                                            ),
                                            TextSpan(
                                              text: " ${typingMatchList[index]["text"]}",
                                              style: Theme.of(context).textTheme.bodyText1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }))
                        : Container(),
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
