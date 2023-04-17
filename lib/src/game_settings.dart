class GameSettings {
  int _topValue = 2;
  int _currentScore = 0;
  late int _topScore = 0;

  GameSettings() {}

  GameSettings.fromJson(Map<String, dynamic> json) {
    _topScore = json['top_score']!;
  }

  Map<String, int> toJson() => {"top_score": _topScore};

  // TODO: have to save somewhere those high scores
  // Future<String> getTopScore() async {
  //   return await readFile();
  // }

  get topValue => _topValue;

  get currentScore => _currentScore;

  get topScore => _topScore;

  void setTopValue(int value) => _topValue = value;

  void setCurrentScore(int value) => _currentScore = value;

  // void setTopScore(int value) => _topScore = value;
  void setTopScore(int value) {
    print("Setting top score to: $value");
    _topScore = value;
  }

  bool isCurrentScoreBiggerThanTopScore() =>
      _currentScore > _topScore && currentScore != 0;
}
