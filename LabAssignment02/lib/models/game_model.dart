class GameModel {
  final int? id;
  final String attemptsList; // store all guesses
  final int totalAttempts;
  final String result; // WIN / LOSE
  final int score;
  final String time;

  GameModel({
    this.id,
    required this.attemptsList,
    required this.totalAttempts,
    required this.result,
    required this.score,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attemptsList': attemptsList,
      'totalAttempts': totalAttempts,
      'result': result,
      'score': score,
      'time': time,
    };
  }

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'],
      attemptsList: map['attemptsList'],
      totalAttempts: map['totalAttempts'],
      result: map['result'],
      score: map['score'],
      time: map['time'],
    );
  }
}