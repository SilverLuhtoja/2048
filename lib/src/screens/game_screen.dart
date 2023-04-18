import 'package:flutter/material.dart';
import 'package:my_2048/src/components/score_box.dart';
import 'package:my_2048/src/constants.dart';
import 'package:my_2048/src/game_board.dart';
import 'package:my_2048/src/game_logic.dart';
import 'package:my_2048/src/game_settings.dart';
import 'package:my_2048/src/utils/filer.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200));
  GameBoard gameBoard = GameBoard();
  GameSettings gameSettings = GameSettings();
  late GameLogic gameLogic;

  bool isAbleToPlay = false;

  void updateTopScore() =>
      readFile().then((value) => gameSettings.setTopScore(value));

  void setNewTopScore() {
    if (gameSettings.isCurrentScoreBiggerThanTopScore()) {
      gameSettings.setTopScore(gameSettings.currentScore);
      writeFile(gameSettings);
    }
  }

  @override
  void initState() {
    super.initState();
    gameLogic = GameLogic(controller, gameBoard, gameSettings);
    gameBoard.show();
    updateTopScore();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          gameBoard.flat_grid().forEach((e) => e.resetAnimation());
        });
      }
    });

    gameBoard.flat_grid().forEach((e) => e.resetAnimation());
  }

  void executeSwipe(List<List<Tile>> grid) {
    grid.forEach((e) => gameLogic.mergeTiles(e));
    gameSettings.setTopValue(gameBoard.topValue);
    setNewTopScore();
    gameBoard.addNewNumber(1);
    controller.forward(from: 0);
    //TODO: check gameEnd
  }

  @override
  Widget build(BuildContext context) {
    double gridRowsSize = MediaQuery.of(context).size.width - 16.0 * 2;
    double tileSize = (gridRowsSize - 4.0 * 2) / 4;
    List<Widget> stackItems = [];

    stackItems.addAll(gameBoard.flat_grid().map((e) => Positioned(
          top: e.x * tileSize,
          left: e.y * tileSize,
          width: tileSize,
          height: tileSize,
          child: Center(
            child: Container(
              width: tileSize - 4.0 * 2,
              height: tileSize - 4.0 * 2,
              color: tileBackgroundColor,
            ),
          ),
        )));

    stackItems.addAll(gameBoard.flat_grid().map((e) => AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) =>
              e.animatedValue.value == 0
                  ? Container()
                  : Positioned(
                      left: e.animatedX.value * tileSize,
                      top: e.animatedY.value * tileSize,
                      width: tileSize,
                      height: tileSize,
                      child: Center(
                          child: Container(
                        width: (tileSize - 4.0 * 2) - 16,
                        height: (tileSize - 4.0 * 2) - 16,
                        color: numTileColor[e.animatedValue.value],
                        child: Center(
                            child: Text(
                          e.animatedValue.value.toString(),
                          style: TextStyle(
                              color: e.value <= 4 ? valueColor : Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.bold),
                        )),
                      )),
                    ),
        )));

    return Scaffold(
        appBar: AppBar(
          title: Text("2048"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buttonSection(),
            scoreSection(),
            Container(
                width: gridRowsSize,
                height: gridRowsSize,
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    double dy = details.velocity.pixelsPerSecond.dy;
                    if (dy < 100 && gameLogic.canSwipeUp()) {
                      // print("Swiping up");
                      executeSwipe(gameBoard.gridColumns);
                    }
                    if (dy > -100 && gameLogic.canSwipeDown()) {
                      // print("Swiping down");
                      executeSwipe(gameBoard.gridColumnsReversed);
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    double dx = details.velocity.pixelsPerSecond.dx;
                    if (dx < 1000 && gameLogic.canSwipeLeft()) {
                      // print("Swiping left");
                      executeSwipe(gameBoard.grid);
                    }
                    if (dx > -1000 && gameLogic.canSwipeRight()) {
                      // print("Swiping right");
                      executeSwipe(gameBoard.gridReversed);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: tileBackgroundColor, width: 4),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 5,
                              blurRadius: 5)
                        ]),
                    child: isAbleToPlay
                        ? Stack(children: stackItems)
                        : gameoverSection(),
                  ),
                )),
          ],
        ));
  }

  Widget gameoverSection() {
    return gameSettings.topValue == 2048
        ? Center(child: Container(child: Text("Congratzzzzz,\n YOu Won")))
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("No moves left"),
              TextButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                      foregroundColor: tileBackgroundColor),
                  child: Text("Go Again")),
            ],
          );
  }

  Container scoreSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: const BoxDecoration(color: tileBackgroundColor, boxShadow: [
        BoxShadow(color: Colors.black26, spreadRadius: 20, blurRadius: 10),
        BoxShadow(
            color: Colors.white, spreadRadius: 1, blurStyle: BlurStyle.outer),
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ScoreBox("Top Score :", gameSettings.topScore),
          ScoreBox("Current Score :", gameSettings.currentScore),
          ScoreBox("Top Value :", gameSettings.topValue),
        ],
      ),
    );
  }

  Row buttonSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Text("2048",
            style: TextStyle(fontSize: 60, shadows: [
              Shadow(
                  color: Colors.black45,
                  blurRadius: 10,
                  offset: Offset(8.0, 10.0))
            ])),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                    backgroundColor: tileBackgroundColor),
                child: const Text("New Game")),
            FilledButton(
                onPressed: null,
                style: FilledButton.styleFrom(
                    backgroundColor: tileBackgroundColor),
                child: const Text("Back to Main Menu")),
          ],
        )
      ],
    );
  }
}
