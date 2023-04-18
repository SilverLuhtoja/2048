import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_2048/src/game_board.dart';
import 'package:my_2048/src/game_logic.dart';
@GenerateNiceMocks([MockSpec<GameSettings>()])
import 'package:my_2048/src/game_settings.dart';

import 'game_logic_test.mocks.dart';
import 'test_helpers.dart';

void main() {
  group('GameLogic.canSwipe - is user able to swipe', () {
    final testCases = [
      [0, 0, 4, 0, true],
      [0, 2, 2, 0, true],
      [2, 2, 0, 4, true],
      [2, 2, 4, 4, true],
      [2, 4, 8, 0, false],
      [2, 4, 8, 4, false],
      [4, 0, 0, 0, false],
      [4, 2, 0, 0, false],
    ];

    testCases.forEach((testCase) {
      List<Object> givenList = testCase.sublist(0, 4);
      dynamic expectedResult = testCase[4];
      bool result = GameLogic.isSwipeable(tileListOfIntValues(givenList));
      String testName = 'when given $givenList then it returns $expectedResult';
      test(testName, () => expect(result, expectedResult));
    });
  });

  group('GameLogic.isGameOver - is game over', () {
    AnimationController controller = AnimationControllerMock();
    var mockGameSetting = MockGameSettings();
    var mockGameBoard = MockGameBoard();
    var logic = GameLogic(controller, mockGameBoard, mockGameSetting);
    const winCase = 2048;
    final noMovesCase = [
      [2, 4, 8, 4],
      [4, 16, 4, 2],
      [32, 64, 32, 4],
      [2, 4, 2, 8]
    ];

    test('when currentScore == 2048, it returns true', () {
      when(mockGameSetting.currentScore).thenReturn(winCase);
      expect(logic.isGameOver(), true);
    });

    test('when currentScore != 2048, it returns false', () {
      when(mockGameSetting.currentScore).thenReturn(0);
      expect(logic.isGameOver(), false);
    });
  });

  // TODO: NEED TO MOCK AnimationController to pass this or separate animations
  // group('GameLogic.mergeTiles() - tests to check if they merge correctly', () {
  //   final testCases = [
  //     [[0, 2, 2, 0], [4, 0, 0, 0]],
  //     [[0, 2, 4, 0], [2, 4, 0, 0]],
  //     [[2, 4, 0, 0], [2, 4, 0, 0]],
  //     [[2, 0, 4, 0], [2, 4, 0, 0]],
  //     [[4, 2, 2, 8], [4, 4, 8, 0]],
  //     [[2, 4, 2, 2], [2, 4, 4, 0]],
  //     [[2, 0, 0, 2], [4, 0, 0, 0]],
  //   ];
  //
  //   testCases.forEach((testCase) {
  //     List<Tile> givenList = tileListOfIntValues(testCase[0]);
  //     List<int?> expectedResult = intListOfTileValues(
  //         tileListOfIntValues(testCase[1]));
  //     List<int?> result = intListOfTileValues(GameLogic.mergeTiles(givenList,_));
  //     String testName = 'when given $givenList then it return $expectedResult';
  //     test(testName, () =>  expect(result, expectedResult));
  //   });
  // });
}

List<Tile> tileListOfIntValues(List<Object> list) {
  return List.generate(list.length, (i) => Tile(0, i, list[i] as int));
}

List<int?> intListOfTileValues(List<Tile> list) {
  return list.map((e) => e.value).toList();
}
