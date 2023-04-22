import 'dart:convert';
import 'dart:io';

import 'package:my_2048/src/utils/helpers.dart';
import 'package:path_provider/path_provider.dart';

import '../models/game_state.dart';

const String file_name = 'game_data.txt';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/$file_name').create(recursive: true);
}

Future<File> writeFile(GameState settings) async {
  // printWarning("WRITING");

  final file = await _localFile;
  return file.writeAsString(jsonEncode(settings));
}

Future<int> readFile() async {
  // printWarning("READING");

  try {
    final file = await _localFile;
    final contents = await file.readAsString();
    GameState values = GameState.fromJson(jsonDecode(contents));

    return values.topScore;
  } catch (e) {
    initFileData();
    printError(e.toString());
    printError("ERROR: Can not return $file_name content");
    return 0;
  }
}

void initFileData() {
  GameState gamestate = GameState();
  gamestate.setTopScore(0);
  writeFile(gamestate);
  readFile();
}
