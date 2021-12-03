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

      emit(ExamFetchSuccess(exam: exam, questions: questions));
    } catch (e) {
      emit(ExamFetchFailure(e.toString()));
    }
  }
}
