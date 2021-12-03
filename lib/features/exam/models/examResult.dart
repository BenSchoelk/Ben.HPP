class ExamResult {
  ExamResult({
    required this.id,
    required this.languageId,
    required this.title,
    required this.date,
    required this.examKey,
    required this.duration,
    required this.status,
    required this.totalDuration,
    required this.statistics,
  });
  late final String id;
  late final String languageId;
  late final String title;
  late final String date;
  late final String examKey;
  late final String duration;
  late final String status;
  late final String totalDuration;
  late final List<Statistics> statistics;

  ExamResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    languageId = json['language_id'];
    title = json['title'];
    date = json['date'];
    examKey = json['exam_key'];
    duration = json['duration'];
    status = json['status'];
    totalDuration = json['total_duration'];
    statistics = List.from(json['statistics'] ?? []).map((e) => Statistics.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['language_id'] = languageId;
    _data['title'] = title;
    _data['date'] = date;
    _data['exam_key'] = examKey;
    _data['duration'] = duration;
    _data['status'] = status;
    _data['total_duration'] = totalDuration;
    _data['statistics'] = statistics.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Statistics {
  Statistics({
    required this.mark,
    required this.correctAnswer,
    required this.incorrect,
  });
  late final String mark;
  late final String correctAnswer;
  late final String incorrect;

  Statistics.fromJson(Map<String, dynamic> json) {
    mark = json['mark'];
    correctAnswer = json['correct_answer'];
    incorrect = json['incorrect'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['mark'] = mark;
    _data['correct_answer'] = correctAnswer;
    _data['incorrect'] = incorrect;
    return _data;
  }
}
