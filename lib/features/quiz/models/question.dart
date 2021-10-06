import 'package:flutterquiz/features/quiz/models/answerOption.dart';

class Question {
  final String? question;
  final String? id;
  final String? categoryId;
  final String? subcategoryId;
  final String? imageUrl;
  final String? level;
  final String? correctAnswerOptionId;
  final String? note;
  final String? languageId;
  final String submittedAnswerId;
  final String? questionType; //multiple option if type is 1, binary options type 2
  final List<AnswerOption>? answerOptions;
  final bool attempted;
  final String? audio;
  final String? audioType;

  Question({
    this.questionType,
    this.answerOptions,
    this.correctAnswerOptionId,
    this.id,
    this.languageId,
    this.level,
    this.note,
    this.question,
    this.categoryId,
    this.imageUrl,
    this.subcategoryId,
    this.audio,
    this.audioType,
    this.attempted = false,
    this.submittedAnswerId = "",
  });

  static Question fromJson(Map questionJson) {
    /*
    question response
    {
            "id": "254",
            "category": "2",
            "subcategory": "2",
            "language_id": "1",
            "image": "",
            "question": "Does this app IOS version available?",
            "question_type": "2",
            "optiona": "Yes - Right",
            "optionb": "No",
            "optionc": "",
            "optiond": "",
            "optione": "",
            "answer": "a",
            "level": "1",
            "note": ""
        },
    
     */

    //answer options is fix up to e and correct answer
    //identified this optionId (ex. a)
    List<String> optionIds = ["a", "b", "c", "d", "e"];
    List<AnswerOption> options = [];

    //creating answerOption model
    optionIds.forEach((optionId) {
      String optionTitle = questionJson["option$optionId"].toString();
      if (optionTitle.isNotEmpty) {
        options.add(AnswerOption(id: optionId, title: optionTitle));
      }
    });
    options.shuffle();

    return Question(
        id: questionJson['id'],
        categoryId: questionJson['category'] ?? "",
        imageUrl: questionJson['image'],
        languageId: questionJson['language_id'],
        subcategoryId: questionJson['subcategory'] ?? "",
        correctAnswerOptionId: questionJson['answer'],
        level: questionJson['level'] ?? "",
        question: questionJson['question'],
        note: questionJson['note'] ?? "",
        questionType: questionJson['question_type'] ?? "",
        audio: questionJson['audio'] ?? "",
        audioType: questionJson['audio_type'] ?? "",
        answerOptions: options);
  }

  Question updateQuestionWithAnswer({required String submittedAnswerId}) {
    return Question(
        submittedAnswerId: submittedAnswerId,
        audio: this.audio,
        audioType: this.audioType,
        answerOptions: this.answerOptions,
        attempted: submittedAnswerId.isEmpty ? false : true,
        categoryId: this.categoryId,
        correctAnswerOptionId: this.correctAnswerOptionId,
        id: this.id,
        imageUrl: this.imageUrl,
        languageId: this.languageId,
        level: this.level,
        note: this.note,
        question: this.question,
        questionType: this.questionType,
        subcategoryId: this.subcategoryId);
  }

  Question copyWith({String? submittedAnswer, bool? attempted}) {
    return Question(
        submittedAnswerId: submittedAnswer ?? this.submittedAnswerId,
        answerOptions: this.answerOptions,
        audio: this.audio,
        audioType: this.audioType,
        attempted: attempted ?? this.attempted,
        categoryId: this.categoryId,
        correctAnswerOptionId: this.correctAnswerOptionId,
        id: this.id,
        imageUrl: this.imageUrl,
        languageId: this.languageId,
        level: this.level,
        note: this.note,
        question: this.question,
        questionType: this.questionType,
        subcategoryId: this.subcategoryId);
  }
}
