import 'dart:math';

import 'package:flutter/animation.dart';

class GameBoard {
  late List<List<Tile>> grid;
  late int gridSize;

  GameBoard(this.gridSize) {
    grid = _generate_grid();
  }

  void show() {
    String allList = "";
    for (int i = 0; i < grid.length; i++) {
      allList += "${grid[i].map((e) {
        return e.value;
      }).toList()}\n";
    }
    print(allList);
  }

  Iterable<Tile> flat_grid() => grid.expand((e) => e);

  List<List<Tile>> get gridColumns =>
      // List.generate(4, (x) => List.generate(4, (y) => grid[y][x]));
      List.generate(gridSize, (x) => List.generate(gridSize, (y) => grid[y][x]));

  List<List<Tile>> get gridColumnsReversed =>
      gridColumns.map((e) => e.reversed.toList()).toList();

  List<List<Tile>> get gridReversed =>
      grid.map((e) => e.reversed.toList()).toList();

  List<List<Tile>> _generate_grid() {
    // return List.generate(4, (y) => List.generate(4, (x) => Tile(x, y, 0)));
    Random random = new Random();
    // List<List<Tile>> generatedList =  List.generate(4, (y) => List.generate(4, (x) => Tile(x, y, 0)));
    List<List<Tile>> generatedList =  List.generate(gridSize, (y) => List.generate(gridSize, (x) => Tile(x, y, 0)));
    List<Tile> expandedList = generatedList.expand((e) => e).toList();
    int numbersToAdd  = random.nextInt(2) + 3;

    expandedList.shuffle();
    for (int i = 0 ; i < numbersToAdd; i++){
      expandedList[i].value = random.nextInt(2) > 0 ? 2 : 4;
    }

    return generatedList;
  }

  void addNewNumber() {
    List<Tile> allZeroedTiles = flat_grid().where((e) => e.value == 0).toList();
    allZeroedTiles.shuffle();
    allZeroedTiles[0].value = 2;
  }

  int get topValue {
    List<Tile> list = flat_grid().toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list.first.value;
  }

}

class Tile {
  final int x;
  final int y;
  int value;

  late Animation<double> animatedX;

  late Animation<double> animatedY;

  late Animation<int> animatedValue;

  Tile(this.x, this.y, this.value) {
    resetAnimation();
  }

  Tile.empty({this.x = -1, this.y = -1, this.value = -1});

  void resetAnimation() {
    animatedX = AlwaysStoppedAnimation(this.x.toDouble());
    animatedY = AlwaysStoppedAnimation(this.y.toDouble());
    animatedValue = AlwaysStoppedAnimation(this.value);
  }

  void moveTo(Animation<double> parent, int toX, int toY) {
    animatedX = Tween<double>(begin: this.x.toDouble(), end: toX.toDouble())
        .animate(CurvedAnimation(parent: parent, curve: const Interval(0, .5)));
    animatedY = Tween<double>(begin: this.y.toDouble(), end: toY.toDouble())
        .animate(CurvedAnimation(parent: parent, curve: const Interval(0, .5)));
  }

  void changeTileValue(Animation<double> parent, int newValue) {
    animatedValue = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(value), weight: .01),
      TweenSequenceItem(tween: ConstantTween(newValue), weight: .99),
    ]).animate(CurvedAnimation(parent: parent, curve: const Interval(.5, 1.0)));
  }
}
