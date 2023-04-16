import 'package:flutter/material.dart';
import 'package:my_2048/src/components/score_box.dart';
import 'package:my_2048/src/game_board.dart';
import 'package:my_2048/src/game_logic.dart';
import 'package:my_2048/src/game_settings.dart';

class GameScreen extends StatefulWidget {
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller =
      AnimationController(vsync: this, duration: Duration(seconds: 1));
  GameBoard gameBoard = GameBoard();
  GameSettings gameSettings = GameSettings();
  late GameLogic gameLogic;

  @override
  void initState() {
    super.initState();
    gameLogic = GameLogic(controller, gameBoard, gameSettings);
    gameBoard.show();

    // controller =
    //     AnimationController(vsync: this, duration: Duration(seconds: 1));
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          gameBoard.flat_grid().forEach((e) => e.resetAnimation());

        });
      }
    });

    gameBoard.flat_grid().forEach((e) => e.resetAnimation());
// controller.forward();
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
              color: Colors.grey[700],
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
                        color: Colors.grey[600],
                        child: Center(
                            child: Text(
                          e.animatedValue.value.toString(),
                          style: TextStyle(
                              color: e.value <= 4
                                  ? Colors.grey[400]
                                  : Colors.white,
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ScoreBox("Top Score :", 100),
                ScoreBox("Current Score :", gameSettings.currentScore),
                ScoreBox("Top Value", gameSettings.topValue),
              ],
            ),
            Container(
                margin: EdgeInsets.only(top: 40),
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
                    child: Stack(
                      children: stackItems,
                    ))),
          ],
        ));
  }

  void executeSwipe(List<List<Tile>> grid) {
    grid.forEach((e) => gameLogic.mergeTiles(e));
    gameSettings.setTopValue(gameBoard.topValue);
    gameBoard.addNewNumber(1);
    controller.forward(from: 0);
  }
}
