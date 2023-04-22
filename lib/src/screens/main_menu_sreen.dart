import 'package:flutter/material.dart';
import 'package:my_2048/src/game_state.dart';
import 'package:my_2048/src/screens/game_screen.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int selectedGridSize = 4;

  ButtonStyle checkIfSelected(int selectedValue, int targetValue) {
    if (selectedValue == targetValue) {
      return ButtonStyle(
          backgroundColor: MaterialStatePropertyAll<Color>(Colors.green));
    }
    return ButtonStyle(
        backgroundColor: MaterialStatePropertyAll<Color>(Colors.grey));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 40),
              width: MediaQuery.of(context).size.width * 0.8,
              child: gridSizeContainer("Select GridSize"),
            ),
            FilledButton(
              onPressed: () {
                GameState gameState = GameState(selectedGridSize);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          GameScreen(gameState: gameState)),
                );
              },
              child: Text("Lets Play!"),
            ),
          ],
        ),
      ),
    );
  }

  Container formLabel(BuildContext context, String text) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: gridSizeContainer(text),
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
        onPressed: () => setState(() => selectedGridSize = value),
        style: checkIfSelected(selectedGridSize, value),
        child: Text("$value x $value"));
  }
}
