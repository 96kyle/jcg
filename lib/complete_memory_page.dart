import 'package:carousel_slider/carousel_slider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:memory/memory_page.dart';
import 'package:memory/word_db.dart';

class CompleteMemoryPage extends StatefulWidget {
  const CompleteMemoryPage({super.key});

  @override
  State<CompleteMemoryPage> createState() => _CompleteMemoryPageState();
}

class _CompleteMemoryPageState extends State<CompleteMemoryPage> {
  bool isProgress = false;

  bool defaultFront = true;

  int selectedChapter = 0;

  final carouselController = CarouselController();

  List<List<WordModel>> completeWordList = [
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

  @override
  void initState() {
    super.initState();
    getCompleteWord();
  }

  void getCompleteWord() async {
    List<WordModel> list = await WordDB.instance.selectWord();

    for (int i = 0; i < list.length; i++) {
      completeWordList[list[i].chapter - 1].add(list[i]);
    }

    setState(() {});
  }

  void completeWord(WordModel wordModel) async {
    int result = await WordDB.instance.deleteWord(wordModel.wordSeq);

    if (result == -1) {
      return;
    } else {
      completeWordList[wordModel.chapter - 1]
          .removeWhere((e) => e.wordSeq == wordModel.wordSeq);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 완료한 단어'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...List.generate(
                  12,
                  (index) => GestureDetector(
                    onTap: () async {
                      setState(() {
                        isProgress = true;
                        selectedChapter = index;
                      });

                      if (completeWordList[selectedChapter].isNotEmpty) {
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
            '학습 완료한 ${selectedChapter + 1}단원 단어 개수 ${completeWordList[selectedChapter].length}개',
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
                            completeWordList[selectedChapter].length,
                            (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FlipCard(
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
                                          '${index + 1}. ${completeWordList[selectedChapter][index].question}',
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
                                          completeWordList[selectedChapter]
                                              [index],
                                        ),
                                        child: const Text('다시 외우기'),
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${index + 1}. ${completeWordList[selectedChapter][index].answer}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ElevatedButton(
                                        onPressed: () => completeWord(
                                          completeWordList[selectedChapter]
                                              [index],
                                        ),
                                        child: const Text('다시 외우기'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                        options: CarouselOptions(
                            height: 300,
                            enableInfiniteScroll: false,
                            viewportFraction: .9),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
