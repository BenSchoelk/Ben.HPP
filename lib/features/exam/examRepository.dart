import 'package:flutterquiz/features/exam/examException.dart';
import 'package:flutterquiz/features/exam/examLocalDataSource.dart';
import 'package:flutterquiz/features/exam/examRemoteDataSource.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';
import 'package:flutterquiz/features/exam/models/examResult.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';

class ExamRepository {
  static final ExamRepository _examRepository = ExamRepository._internal();
  late ExamRemoteDataSource _examRemoteDataSource;
  late ExamLocalDataSource _examLocalDataSource;

  factory ExamRepository() {
    _examRepository._examRemoteDataSource = ExamRemoteDataSource();
    _examRepository._examLocalDataSource = ExamLocalDataSource();
    return _examRepository;
  }

  ExamRepository._internal();

  ExamLocalDataSource get examLocalDataSource => _examLocalDataSource;

  Future<List<Exam>> getExams({required String userId, required String languageId}) async {
    try {
      final result = await _examRemoteDataSource.getExams(userId: userId, languageId: languageId, type: "1");
      return result.map((e) => Exam.fromJson(e)).toList();
    } catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    }
  }

  Future<List<ExamResult>> getCompletedExams({required String userId, required String languageId}) async {
    try {
      final result = await _examRemoteDataSource.getExams(userId: userId, languageId: languageId, type: "2");
      return result.map((e) => ExamResult.fromJson(e)).toList();
    } catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    }
  }

  Future<List<Question>> getExamMouduleQuestions({required String examModuleId}) async {
    try {
      final result = await _examRemoteDataSource.getQuestionForExam(examModuleId: examModuleId);
      return result.map((e) => Question.fromJson(Map.from(e))).toList();
    } catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    }
  }

  Future<void> updateExamStatusToInExam({required String examModuleId, required String userId}) async {
    try {
      await _examRemoteDataSource.updateExamStatusToInExam(examModuleId: examModuleId, userId: userId);
    } catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    }
  }

  Future<void> submitExamResult({required String examModuleId, required String userId, required String totalDuration, required List<Map<String, dynamic>> statistics}) async {
    try {
      await _examRemoteDataSource.submitExamResult(examModuleId: examModuleId, userId: userId, totalDuration: totalDuration, statistics: statistics);
    } catch (e) {
      print(e.toString());
      throw ExamException(errorMessageCode: e.toString());
    }
  }

  Future<void> completePendingExams({required String userId}) async {
    //
    List<String> pendingExamIds = _examLocalDataSource.getAllExamModuleIds();
    pendingExamIds.forEach((element) {
      submitExamResult(examModuleId: element, userId: userId, totalDuration: "0", statistics: []);
    });

    //delete exams
    pendingExamIds.forEach((element) {
      _examLocalDataSource.removeExamModuleId(element);
    });
  }
}
