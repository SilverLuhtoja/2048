import 'package:flutter/material.dart';
import 'package:my_2048/src/screens/game_screen.dart';
import 'package:my_2048/src/screens/main_menu_sreen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      // home: GameScreen(),
      home: MainMenu(),
    );
  }
}
