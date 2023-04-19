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
  group('GameLogic.isSwipeAble - is user able to swipe', () {
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
      bool result = GameLogic.isSwipeAble(tileListOfIntValues(givenList));
      String testName = 'when given $givenList then it returns $expectedResult';
      test(testName, () => expect(result, expectedResult));
    });
  });

  group('GameLogic.isGameOver - is game over', () {
    late AnimationControllerMock controller;
    late MockGameSettings mockGameSetting;
    late GameBoard gameBoard;
    late GameLogic logic;
    const winCase = 2048;

    setUp(() {
      controller = AnimationControllerMock();
      mockGameSetting = MockGameSettings();
      gameBoard = GameBoard();
      logic = GameLogic(controller, gameBoard, mockGameSetting);
    });

    test('when currentScore == 2048, it returns true', () {
      when(mockGameSetting.topValue).thenReturn(winCase);
      expect(logic.isGameOver(), isTrue);
    });

    test('when there is no moves left, it return true', () {
      final looseCase = [
        [2, 4, 8, 4],
        [4, 16, 4, 2],
        [32, 64, 32, 4],
        [2, 4, 2, 8]
      ];
      gameBoard.grid =
          looseCase.map((list) => tileListOfIntValues(list)).toList();
      expect(logic.isGameOver(), isTrue);
    });

    test('when there is moves left, it return false', () {
      final playableCase = [
        [2, 4, 8, 4],
        [4, 16, 4, 2],
        [32, 64, 4, 4],
        [2, 4, 2, 8]
      ];
      gameBoard.grid =
          playableCase.map((list) => tileListOfIntValues(list)).toList();
      expect(logic.isGameOver(), isFalse);
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
