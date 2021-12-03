import 'package:flutterquiz/features/exam/examException.dart';
import 'package:flutterquiz/features/exam/examRemoteDataSource.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';

class ExamRepository {
  static final ExamRepository _examRepository = ExamRepository._internal();
  late ExamRemoteDataSource _examRemoteDataSource;

  factory ExamRepository() {
    _examRepository._examRemoteDataSource = ExamRemoteDataSource();
    return _examRepository;
  }

  ExamRepository._internal();

  Future<List<Exam>> getExams({required String userId, required String languageId}) async {
    try {
      final result = await _examRemoteDataSource.getExams(userId: userId, languageId: languageId);
      return result.map((e) => Exam.fromJson(e)).toList();
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
}
