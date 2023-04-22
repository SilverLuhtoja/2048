import 'package:flutter/animation.dart';

import 'game_board.dart';
import 'game_state.dart';

class GameLogic {
  late AnimationController controller;
  final GameBoard gameBoard;
  final GameState gameSetting;

  GameLogic(this.controller, this.gameBoard, this.gameSetting);

  bool canSwipeLeft() => gameBoard.grid.any(isSwipeAble);

  bool canSwipeRight() => gameBoard.gridReversed.any(isSwipeAble);

  bool canSwipeUp() => gameBoard.gridColumns.any(isSwipeAble);

  bool canSwipeDown() => gameBoard.gridColumnsReversed.any(isSwipeAble);

  static bool isSwipeAble(List<Tile> tiles) {
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

  List<Tile> moveAndMergeTiles(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      // skip current iteration amount, it is already assigned
      Iterable<Tile> nonZeroTiles =
          tiles.skip(i).skipWhile((tile) => tile.value == 0);

      if (nonZeroTiles.isNotEmpty) {
        Tile firstValuedTile = nonZeroTiles.first;
        Tile nextValuedTile = nonZeroTiles
            .skip(1)
            .firstWhere((tile) => tile.value != 0, orElse: () => Tile.empty());

        // if current iteration tile is not the same as firstValuedTile
        // OR next valued tile is not null, we can merge tiles
        if (tiles[i] != firstValuedTile || nextValuedTile.value != -1) {
          // this value will rewrite tiles[i], no matter what was there
          int resultValue = firstValuedTile.value;

          firstValuedTile.moveTo(controller, tiles[i].x, tiles[i].y);
          if (nextValuedTile.value == firstValuedTile.value) {
            resultValue += nextValuedTile.value;
            nextValuedTile.moveTo(controller, tiles[i].x, tiles[i].y);
            nextValuedTile.changeTileValue(controller, resultValue);
            firstValuedTile.changeTileValue(controller, 0);
            nextValuedTile.value = 0;
            gameSetting.setCurrentScore(gameSetting.currentScore + resultValue);
          }
          firstValuedTile.value = 0;
          tiles[i].value = resultValue;
        }
      }
    }
    return tiles;
  }

  bool isGameOver() {
    Iterable<Tile> zeroValueList =
        gameBoard.flat_grid().where((e) => e.value == 0);
    if (gameSetting.topValue == 2048) return true;

    // still some moves left
    if (zeroValueList.isNotEmpty) {
      return false;
    }

    if (zeroValueList.isEmpty) {
      if (canSwipeLeft()) return false;
      if (canSwipeRight()) return false;
      if (canSwipeUp()) return false;
      if (canSwipeDown()) return false;
    }

    return true;
  }
}
