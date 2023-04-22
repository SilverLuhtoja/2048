import 'package:flutter/material.dart';
import 'package:my_2048/src/screens/game_screen.dart';

import '../models/game_state.dart';
import '../utils/filer.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late GameState gameState;

  ButtonStyle checkIfSelected(int selectedValue, int targetValue) {
    if (selectedValue == targetValue) {
      return const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll<Color>(Colors.green));
    }
    return const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll<Color>(Colors.grey));
  }

  void initTopScore() =>
      readFile().then((value) => gameState.setTopScore(value));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gameState = GameState(4);
    initTopScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 40),
              width: MediaQuery.of(context).size.width * 0.8,
              child: gridSizeContainer("Select GridSize"),
            ),
            FilledButton(
              onPressed: () {
                // GameState gameState = GameState(selectedGridSize);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          GameScreen(gameState: gameState)),
                );
              },
              child: const Text("Lets Play!"),
            ),
          ],
        ),
      ),
    );
  }

  Column gridSizeContainer(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$text : ", style: TextStyle(fontSize: 30)),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            gridSizeButton(4),
            gridSizeButton(5),
            gridSizeButton(6),
          ],
        ),
      ],
    );
  }

  FilledButton gridSizeButton(int value) {
    return FilledButton(
        onPressed: () => setState(() => gameState.gridSize = value),
        style: checkIfSelected(gameState.gridSize, value),
        child: Text("$value x $value"));
  }
}
