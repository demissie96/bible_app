import 'dart:convert';
import 'package:bible_app/main_page.dart';
import 'package:bible_app/passage_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "side_menu.dart";
import 'package:string_similarity/string_similarity.dart';
import 'extension/string_extension.dart';

class SimilarityIndex {
  int index;
  double similarity;

  SimilarityIndex(this.index, this.similarity);

  @override
  String toString() {
    return '{ ${this.index}, ${this.similarity} }';
  }
}

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController textController = TextEditingController();
  String searchText = '';
  var bibleListHu;
  var bibleListEn;
  List resultListPre = [];
  List resultListFinal = [];
  List resultList = [];
  String searchLanguage = "hun";
  var bookRefList = {};

  Future<void> bibleListGet() async {
    final String res1 = await rootBundle.loadString('data/bible_in_list_hu.json');
    bibleListHu = await json.decode(res1);
    final String res2 = await rootBundle.loadString('data/bible_in_list_en.json');
    bibleListEn = await json.decode(res2);
  }

  Future loopThroughBible() async {
    await showDialog(
      barrierColor: Colors.black87,
      context: context,
      builder: (context) {
        Future.delayed(Duration(milliseconds: 250), () {
          Navigator.of(context).pop();
        });
        return AbsorbPointer(
          child: Center(
            child: Text(
              "Keresés...",
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                color: Colors.white,
                fontSize: 40.0,
                shadows: [
                  Shadow(
                    // offset: Offset(2.0, 2.0), //position of shadow
                    blurRadius: 30.0, //blur intensity of shadow
                    color: Colors.white.withOpacity(1.0), //color of shadow with opacity
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    searchText = searchText.toLowerCase();

    List indexSimilarity = [];
    int index = 0;
    resultListPre = [];

    print("Start looping");

    rankingSearch(list) {
      for (var element in list) {
        var similarity = searchText.similarityTo(element["text"].toLowerCase());
        // indexSimilarity.add({ "index": index, "similarity": similarity });
        indexSimilarity.add(SimilarityIndex(index, similarity));
        index++;
      }

      print(searchText);

      print("Start sorting");
      indexSimilarity.sort((a, b) => b.similarity.compareTo(a.similarity));

      print("Similarity rate: ${indexSimilarity[0].similarity}");
      print("Similarity rate: ${indexSimilarity[1].similarity}");
      print("Similarity rate: ${indexSimilarity[2].similarity}");

      // List top 10 result
      for (var i = 0; i < 10; i++) {
        resultListPre.add(list[indexSimilarity[i].index]);
      }

      print("#####################################################");
      resultListFinal = [];
      for (var element in resultListPre) {
        String text = element["text"].split("&")[0];
        text = text.capitalizeFirstForCopy();
        resultListFinal.add({
          "testament": "${element["testament"]}",
          "book": "${element["book"]}",
          "language": "${element["language"]}",
          "chapter": element["chapter"],
          "verse": "${element["verse"]}",
          "text": text
        });
      }
      // print(resultListFinal);
      print(resultListFinal.length);
      print("#####################################################");

      List indexSimilarity2 = [];
      index = 0;

      // List top 10 final result
      List notSelectedIndex = [];

      for (var element in resultListFinal) {
        var similarity = searchText.similarityTo(element["text"].toLowerCase());

        if (similarity >= 0.30) {
          indexSimilarity2.add(SimilarityIndex(index, similarity));
        } else {
          notSelectedIndex.add(index);
        }
        index++;
      }
      print("Not selected indices --> $notSelectedIndex");

      indexSimilarity2.sort((a, b) => b.similarity.compareTo(a.similarity));
      print(indexSimilarity2);
      print(indexSimilarity);

      for (var element in indexSimilarity2) {
        resultList.add(resultListFinal[element.index]);
      }
      for (var element in notSelectedIndex) {
        resultList.add(resultListFinal[element]);
      }

      setState(() {
        resultList;
      });
    }

    if (searchLanguage == "hun") {
      rankingSearch(bibleListHu);
    } else {
      rankingSearch(bibleListEn);
    }
  }

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

    setState(() {
      oldTestament;
      newTestament;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bibleListGet();
    bookListJson();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.background,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text('Keresés'),
        ),
        drawer: SideMenu(),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: textController,
                autofocus: true,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: searchLanguage == "hun" ? "Mondat keresése..." : "Search for Sentence...",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: textController.clear,
                    )),
                onChanged: (text) {
                  searchText = text;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: FloatingActionButton(
                      heroTag: "language",
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        searchLanguage == "hun" ? "🇭🇺" : "🇺🇲",
                        style: TextStyle(
                          fontSize: 35.0,
                        ),
                      ),
                      onPressed: () {
                        if (searchLanguage == "hun") {
                          searchLanguage = "eng";
                        } else {
                          searchLanguage = "hun";
                        }

                        setState(() {
                          searchLanguage;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: FloatingActionButton(
                      heroTag: "search",
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Icon(
                        Icons.manage_search_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 35.0,
                      ),
                      onPressed: () {
                        setState(() {
                          resultList = [];
                        });

                        if (searchText.length > 1) {
                          loopThroughBible();
                        }
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    resultList.isNotEmpty
                        ? Expanded(
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: resultList.length,
                                itemBuilder: (context, index) {
                                  String bookName = searchLanguage == "hun"
                                      ? bookRefList[resultList[index]["book"]]["hunName"].toString()
                                      : resultList[index]["book"];
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          print("Jump to passage");
                                          print("searchLanguage : $searchLanguage");
                                          resultListFinal.add({
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PassagePage(
                                                  appBarTitle:
                                                      "${bookRefList[resultList[index]["book"]]["fullName"]} ${resultList[index]["chapter"]}",
                                                  chapter: resultList[index]["chapter"].toString(),
                                                  bible: bibleJson,
                                                  oldOrNew:
                                                      bookRefList[resultList[index]["book"]]["testament"].toString(),
                                                  bookRef: resultList[index]["book"],
                                                  language: searchLanguage == "hun" ? "chapters_hu" : "chapters_eng",
                                                  chapterSum: bookRefList[resultList[index]["book"]]["chapterSum"],
                                                  verse: int.parse(resultList[index]["verse"]),
                                                  bookList: bookList,
                                                  bookNameHu: bookRefList[resultList[index]["book"]]["fullName"],
                                                ),
                                              ),
                                            )
                                          });
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
                          )
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
