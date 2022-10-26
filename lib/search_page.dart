import 'dart:convert';
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
  List resultList = [];
  String searchLanguage = "hun";

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

    List indexSimilarity = [];
    int index = 0;
    resultList = [];

    print("Start looping");

    rankingSearch(list) {
      for (var element in list) {
        var similarity = searchText.toLowerCase().similarityTo(element["text"].toLowerCase());
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
        resultList.add(list[indexSimilarity[i].index]);
      }
    }

    if (searchLanguage == "hun") {
      rankingSearch(bibleListHu);
    } else {
      rankingSearch(bibleListEn);
    }

    setState(() {
      resultList;
    });

    for (var element in resultList) {
      String text = element["text"].split("&")[0];
      text = text.capitalizeFirstForCopy();
      print("${element["book"]} ${element["chapter"]}:${element["verse"]}, $text");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bibleListGet();
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
                    hintText: searchLanguage == "hun" ? "Keresés" : "Search",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: textController.clear,
                    )),
                onChanged: (text) {
                  setState(() {
                    searchText = text;
                    print(searchText);
                  });
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
                                  String text = resultList[index]["text"].split("&")[0];
                                  text = text.capitalizeFirstForCopy();

                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "${resultList[index]["book"]} ${resultList[index]["chapter"]}:${resultList[index]["verse"]}, $text"),
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
