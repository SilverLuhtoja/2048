import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_2048/src/components/score_box.dart';
import 'package:my_2048/src/constants.dart';
import 'package:my_2048/src/models/game_board.dart';
import 'package:my_2048/src/models/game_logic.dart';
import 'package:my_2048/src/utils/filer.dart';

import '../models/game_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.gameState});

  final GameState gameState;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  final Duration animationSpeed = const Duration(milliseconds: 200);
  late GameBoard gameBoard;
  late GameState gameState;
  late AnimationController controller;
  late GameLogic gameLogic;
  bool isGameOver = false;
  bool canMakeMove = true;

  @override
  void initState() {
    super.initState();

    gameState = widget.gameState;
    controller = AnimationController(vsync: this, duration: animationSpeed);
    gameBoard = GameBoard(gameState.gridSize);
    gameLogic = GameLogic(controller, gameBoard, gameState);

    gameState.setTopValue(gameBoard.topValue);
    gameBoard.flat_grid().forEach((e) => e.resetAnimation());
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          gameBoard.flat_grid().forEach((e) => e.resetAnimation());
        });
      }
    });
  }

  double setTileFontSize(int tileValue, int gridSize) {
    bool isLengthOfFour = tileValue >= 1000;
    switch (gridSize) {
      case 6:
        return isLengthOfFour ? 16 : 20;
      case 5:
        return isLengthOfFour ? 20 : 25;
    }
    return isLengthOfFour ? 25 : 35;
  }

  void slowSwipeDown() async {
    setState(() => canMakeMove = false);
    await Future.delayed(animationSpeed);
    setState(() => canMakeMove = true);
  }

  void setNewTopScore() {
    if (gameState.isCurrentScoreBiggerThanTopScore()) {
      gameState.setTopScore(gameState.currentScore);
      writeFile(gameState);
    }
  }

  void executeSwipe(List<List<Tile>> grid) {
    slowSwipeDown();
    grid.forEach((e) => gameLogic.moveAndMergeTiles(e));
    gameState.setTopValue(gameBoard.topValue);
    setNewTopScore();
    controller.forward(from: 0);
    gameBoard.addNewNumber();
    if (gameLogic.isGameOver()) setState(() => isGameOver = true);
  }

  @override
  Widget build(BuildContext context) {
    double gridRowsSize = MediaQuery.of(context).size.width - 16.0 * 2;
    double tileSize = (gridRowsSize - 4.0 * 2) / gameState.gridSize;
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
                              fontSize: setTileFontSize(
                                  e.animatedValue.value, gameState.gridSize),
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
            headerSection(),
            scoreSection(),
            SizedBox(
                width: gridRowsSize,
                height: gridRowsSize,
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    double dy = details.velocity.pixelsPerSecond.dy;
                    if (dy < 250 && gameLogic.canSwipeUp() && canMakeMove) {
                      // UP
                      executeSwipe(gameBoard.gridColumns);
                    }
                    if (dy > -250 && gameLogic.canSwipeDown() && canMakeMove) {
                      // DOWN
                      executeSwipe(gameBoard.gridColumnsReversed);
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    double dx = details.velocity.pixelsPerSecond.dx;
                    if (dx < 1000 && gameLogic.canSwipeLeft() && canMakeMove) {
                      // LEFT
                      executeSwipe(gameBoard.grid);
                    }
                    if (dx > -1000 &&
                        gameLogic.canSwipeRight() &&
                        canMakeMove) {
                      // RIGHT
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
                      child: isGameOver
                          ? gameOverSection()
                          : Stack(children: stackItems)),
                )),
          ],
        ));
  }

  Widget gameOverSection() {
    return gameState.topValue == 2048
        ? const Center(
            child: Text("Congratulations!\nYou won nothing\nBut lost time",
                style: TextStyle(fontSize: 30)),
          )
        : const Center(
            child: Text(
                "--GameOver--\nNo moves left\nStop trying !\nGo enjoy Sun :D",
                style: TextStyle(fontSize: 30)),
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
          ScoreBox("Top Score :", gameState.topScore),
          ScoreBox("Current Score :", gameState.currentScore),
          ScoreBox("Top Value :", gameState.topValue),
        ],
      ),
    );
  }

  Row headerSection() {
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
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => super.widget));
              },
              style:
                  FilledButton.styleFrom(backgroundColor: tileBackgroundColor),
              child: const Text("New Game"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style:
                  FilledButton.styleFrom(backgroundColor: tileBackgroundColor),
              child: const Text("Back to Main Menu"),
            ),
          ],
        )
      ],
    );
  }
}
