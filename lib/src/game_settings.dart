class GameSettings {
  int _topValue = 2;
  int _currentScore = 0;
  late int _topScore;

  GameSettings() {
    this._topScore = getTopScore();
  }

  // TODO: have to save somewhere those high scores
  int getTopScore() {
    return 100;
  }

  get topValue => _topValue;

  get currentScore => _currentScore;

  get topScore => _topScore;

  void setTopValue(int value) => _topValue = value;

  void setCurrentScore(int value) => _currentScore = value;

  void setTopScore(int value) => _topScore = value;

// void setTopValue(int topValue) {}
}
