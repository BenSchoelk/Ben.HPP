import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/exam/examRepository.dart';
import 'package:flutterquiz/features/exam/models/examResult.dart';

abstract class CompletedExamsState {}

class CompletedExamsInitial extends CompletedExamsState {}

class CompletedExamsFetchInProgress extends CompletedExamsState {}

class CompletedExamsFetchSuccess extends CompletedExamsState {
  final List<ExamResult> completedExams;

  CompletedExamsFetchSuccess(this.completedExams);
}

class CompletedExamsFetchFailure extends CompletedExamsState {
  final String errorMessage;

  CompletedExamsFetchFailure(this.errorMessage);
}

class CompletedExamsCubit extends Cubit<CompletedExamsState> {
  final ExamRepository _examRepository;

  CompletedExamsCubit(this._examRepository) : super(CompletedExamsInitial());

  void getCompletedExams({required String userId, required String languageId}) async {
    try {
      //

      emit(CompletedExamsFetchSuccess(await _examRepository.getCompletedExams(userId: userId, languageId: languageId)));
    } catch (e) {
      emit(CompletedExamsFetchFailure(e.toString()));
    }
  }
}
