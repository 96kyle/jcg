import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:excel/excel.dart' as excels;
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory/complete_memory_page.dart';
import 'package:memory/word_db.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  bool isProgress = false;

  bool defaultFront = true;

  int selectedChapter = 0;

  bool isSort = false;

  final pageController = PageController(
    viewportFraction: 1,
    initialPage: 0,
  );

  final carouselController = CarouselController();

  final cardController = FlipCardController();

  List<List<WordModel>> wordList = [
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    []
  ];

  void getMemberExcel() async {
    isProgress = true;

    for (int i = 0; i < wordList.length; i++) {
      wordList[i].clear();
    }

    ByteData data = await rootBundle.load('assets/gisa.xlsx');
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = excels.Excel.decodeBytes(bytes);

    final sheet = excel['Sheet1'];

    int chapter = 0;

    List<int> completeWordSeqList = await WordDB.instance.selectWordSeq();

    for (int i = 1; i <= sheet.maxRows; i++) {
      if (sheet.cell(excels.CellIndex.indexByString("A$i")).value.toString() ==
          '다음') {
        chapter++;
        continue;
      }

      if (completeWordSeqList.contains(i)) {
        continue;
      }

      wordList[chapter].add(WordModel(
          wordSeq: i,
          chapter: chapter + 1,
          question: sheet
              .cell(excels.CellIndex.indexByString("B$i"))
              .value
              .toString(),
          answer: sheet
              .cell(excels.CellIndex.indexByString("A$i"))
              .value
              .toString()));
    }
    if (!isSort) {
      wordSuffle();
      isSort = true;
    } else {
      isSort = false;
    }
    setState(() {});
    isProgress = false;
  }

  void wordSuffle() {
    for (int i = 0; i < wordList.length; i++) {
      wordList[i].shuffle();
    }
    setState(() {});
  }

  void completeWord(WordModel wordModel) async {
    int result = await WordDB.instance.insertWord(wordModel);

    if (result == -1) {
      return;
    } else {
      wordList[wordModel.chapter - 1]
          .removeWhere((e) => e.wordSeq == wordModel.wordSeq);

      setState(() {});
    }
  }

  @override
  void initState() {
    getMemberExcel();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('단어암기(${isSort ? "셔플" : "정렬"})'),
        actions: [
          GestureDetector(
            onTap: () async {
              getMemberExcel();
              setState(() {});
            },
            child: const Text(
              '정렬/셔플',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () async {
              isProgress = true;
              defaultFront = !defaultFront;
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 100));
              isProgress = false;
              setState(() {});
            },
            child: const Text(
              '질문 정답 바꾸기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 30,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                ...List.generate(
                  12,
                  (index) => GestureDetector(
                    onTap: () async {
                      setState(() {
                        isProgress = true;
                        selectedChapter = index;
                      });

                      if (wordList[selectedChapter].isNotEmpty) {
                        // pageController.jumpTo(0);
                        carouselController.jumpToPage(0);
                      }
                      await Future.delayed(const Duration(milliseconds: 100));
                      setState(() {
                        isProgress = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Colors.blue,
                      ),
                      child: Text('${index + 1}단원'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 60,
          ),
          Text(
            '학습해야 할 ${selectedChapter + 1}단원 단어 개수 ${wordList[selectedChapter].length}개',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          isProgress
              ? Container()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 300,
                      child: CarouselSlider(
                        carouselController: carouselController,
                        items: [
                          ...List.generate(
                            wordList[selectedChapter].length,
                            (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FlipCard(
                                controller: cardController,
                                direction: FlipDirection.HORIZONTAL,
                                side: defaultFront
                                    ? CardSide.FRONT
                                    : CardSide.BACK,
                                speed: 200,
                                flipOnTouch: true,
                                onFlip: () {},
                                alignment: Alignment.bottomLeft,
                                fill: Fill.fillFront,
                                front: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0)),
                                    border: Border.all(
                                      color: Colors.black,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${index + 1}. ${wordList[selectedChapter][index].question}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ElevatedButton(
                                        onPressed: () => completeWord(
                                          wordList[selectedChapter][index],
                                        ),
                                        child: const Text('학습 완료'),
                                      ),
                                    ],
                                  ),
                                ),
                                back: Container(
                                  padding: const EdgeInsets.all(30),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0)),
                                    border: Border.all(
                                      color: Colors.black,
                                    ),
                                  ),
                                  child: Text(
                                    '${index + 1}. ${wordList[selectedChapter][index].answer}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                        options: CarouselOptions(
                            enableInfiniteScroll: false,
                            height: 300,
                            viewportFraction: .9),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size.fromHeight(50),
                        ),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CompleteMemoryPage(),
                            ),
                          );

                          getMemberExcel();
                        },
                        child: const Text('학습 완료한 단어'),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class WordModel {
  final int wordSeq;
  final int chapter;
  final String question;
  final String answer;

  WordModel({
    required this.wordSeq,
    required this.chapter,
    required this.question,
    required this.answer,
  });

  static WordModel fromJson(Map<String, dynamic> json) => WordModel(
        wordSeq: json['wordSeq'] as int,
        chapter: json['chapter'] as int,
        question: json['question'] as String,
        answer: json['answer'] as String,
      );

  Map<String, Object> toJson() => {
        'wordSeq': wordSeq,
        'chapter': chapter,
        'question': question,
        'answer': answer,
      };
}
