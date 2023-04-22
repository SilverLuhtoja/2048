class GameState {
  int _topValue = 2;
  int _currentScore = 0;
  late int _topScore = 0;
  late int gridSize;

  GameState([this.gridSize = 4]);

  GameState.fromJson(Map<String, dynamic> json) {
    _topScore = json['top_score']!;
  }

  Map<String, int> toJson() => {"top_score": _topScore};

  get topValue => _topValue;

  get currentScore => _currentScore;

  get topScore => _topScore;

  void setTopValue(int value) => _topValue = value;

  void setCurrentScore(int value) => _currentScore = value;

  void setTopScore(int value) => _topScore = value;

  bool isCurrentScoreBiggerThanTopScore() =>
      _currentScore > _topScore && currentScore != 0;
}
