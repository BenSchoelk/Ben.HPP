import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/exam/examRepository.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';

abstract class ExamState {}

class ExamInitial extends ExamState {}

class ExamFetchInProgress extends ExamState {}

class ExamFetchFailure extends ExamState {
  final String errorMessage;

  ExamFetchFailure(this.errorMessage);
}

class ExamFetchSuccess extends ExamState {
  final List<Question> questions;
  final Exam exam;

  ExamFetchSuccess({required this.exam, required this.questions});
}

class ExamCubit extends Cubit<ExamState> {
  final ExamRepository _examRepository;

  ExamCubit(this._examRepository) : super(ExamInitial());

  void updateState(ExamState newState) {
    emit(newState);
  }

  void startExam({required Exam exam, required String userId}) async {
    //
    try {
      //fetch question

      List<Question> questions = await _examRepository.getExamMouduleQuestions(examModuleId: exam.id);

      //check if user can give exam or not
      //if user is in exam then it will throw 103 error means fill all data
      await _examRepository.updateExamStatusToInExam(examModuleId: exam.id, userId: userId);
      await _examRepository.examLocalDataSource.addExamModuleId(exam.id);
      emit(ExamFetchSuccess(exam: exam, questions: questions));
    } catch (e) {
      emit(ExamFetchFailure(e.toString()));
    }
  }

  List<Question> getQuestions() {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess).questions;
    }
    return [];
  }

  Exam getExam() {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess).exam;
    }
    return Exam.fromJson({});
  }

  void submitResult({required String userId, required String totalDuration}) {
    if (state is ExamFetchSuccess) {
      //TODO : submit result
      _examRepository.submitExamResult(examModuleId: (state as ExamFetchSuccess).exam.id, userId: userId, totalDuration: totalDuration, statistics: []);
    }
  }

  void completePendingExams({required String userId}) {
    _examRepository.completePendingExams(userId: userId);
  }
}
