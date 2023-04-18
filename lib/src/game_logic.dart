import 'package:flutter/animation.dart';
import 'package:my_2048/src/game_settings.dart';

import 'game_board.dart';

class GameLogic {
  late AnimationController controller;
  final GameBoard gameBoard;
  final GameSettings gameSetting;

  GameLogic(this.controller, this.gameBoard,this.gameSetting);


  bool canSwipeLeft() => gameBoard.grid.any(isSwipeable);
  bool canSwipeRight() => gameBoard.gridReversed.any(isSwipeable);
  bool canSwipeUp() => gameBoard.gridColumns.any(isSwipeable);
  bool canSwipeDown() => gameBoard.gridColumnsReversed.any(isSwipeable);
  // static bool canSwipeLeft(List<List<Tile>> grid) => grid.any(canSwipe);
  // static bool canSwipeUp(List<List<Tile>> grid) => grid.any(canSwipe);
  // static bool canSwipeRight(List<List<Tile>> grid) => grid.map((e) => e.reversed.toList()).any(canSwipe);
  // static bool canSwipeDown(List<List<Tile>> grid) => grid.map((e) => e.reversed.toList()).any(canSwipe);

  static bool isSwipeable(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i].value == 0) {
        if (tiles.skip(i + 1).any((e) => e.value != 0)) return true;
      } else {
        Tile nextNonZeroTile = tiles
            .skip(i + 1)
            .firstWhere((e) => e.value != 0, orElse: () => Tile.empty());
        if (nextNonZeroTile.value != -1 &&
            nextNonZeroTile.value == tiles[i].value) return true;
      }
    }
    return false;
  }

  // THIS DOES A LOT OF THINGS
  // TODO: try to refactor
  List<Tile> mergeTiles(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      // skip current iteration amount, it is already assigned
      Iterable<Tile> nonZeroTiles = tiles.skip(i).skipWhile((tile) => tile.value == 0);


      if (nonZeroTiles.isNotEmpty) {
        Tile firstValuedTile = nonZeroTiles.first;
        Tile nextValuedTile = nonZeroTiles
            .skip(1)
            .firstWhere((tile) => tile.value != 0, orElse: () => Tile.empty());
        // if current iteration tile is not the same as firstValuedTile
        // OR next valued tile is not null, we can move and merge tiles
        if (tiles[i] != firstValuedTile || nextValuedTile.value != -1) {
          // this value will rewrite tiles[i], no matter what was there
          int resultValue = firstValuedTile.value;
          firstValuedTile.moveTo(controller, tiles[i].x, tiles[i].y);

          if (nextValuedTile.value == firstValuedTile.value) {
            resultValue += nextValuedTile.value;
            nextValuedTile.moveTo(controller, tiles[i].x, tiles[i].y);
            nextValuedTile.changeTileValue(controller,resultValue);
            nextValuedTile.value = 0;
            firstValuedTile.changeTileValue(controller, 0);
            gameSetting.setCurrentScore(gameSetting.currentScore + resultValue);
          }
          firstValuedTile.value = 0;
          tiles[i].value = resultValue;
        }
      }
    }
    return tiles;
  }

  // TODO: Win and loose logic
  bool isGameOver(){
    if (gameSetting.currentScore == 2048) return true;
    return false;
  }
}
