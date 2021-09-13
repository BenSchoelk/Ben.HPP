class StatisticModel {
  final String? id;
  final String? answeredQuestions;
  final String? correctAnswers;
  final String? strongCategory;
  final String? ratio1;
  final String? ratiod2;
  final String? weakCategory;
  final String? bestPosition;

  StatisticModel({
    this.answeredQuestions,
    this.bestPosition,
    this.correctAnswers,
    this.id,
    this.ratio1,
    this.ratiod2,
    this.strongCategory,
    this.weakCategory,
  });

  static StatisticModel fromJson(Map json) {
    return StatisticModel(
        answeredQuestions: json['questions_answered'],
        bestPosition: json['best_position'],
        correctAnswers: json['correct_answers'],
        id: json['id'],
        ratio1: json['ratio1'],
        strongCategory: json['strong_category'],
        weakCategory: json['weak_category'],
        ratiod2: json['ratio2']);
  }
}
/*
{
        "id": "2",
        userIdKey: "11",
        "questions_answered": "1",
        "correct_answers": "1",
        "strong_category": "News",
        "ratio1": "100",
        "weak_category": "0",
        "ratio2": "0",
        "best_position": "0",
        "date_created": "2021-06-25 15:48:20",
        "name": "RAHUL HIRANI",
        "profile": "https://lh3.googleusercontent.com/a/AATXAJyzUAfJwUFTV3yE6tM9KdevDnX2rcM8vm3GKHFz=s96-c"
    }*/
