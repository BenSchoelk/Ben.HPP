import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/category.dart';
import '../quizRepository.dart';

@immutable
abstract class QuizCategoryState {}

class QuizCategoryInitial extends QuizCategoryState {}

class QuizCategoryProgress extends QuizCategoryState {}

class QuizCategorySuccess extends QuizCategoryState {
  final List<Category> categories;
  QuizCategorySuccess(this.categories);
}

class QuizCategoryFailure extends QuizCategoryState {
  final String errorMessage;
  QuizCategoryFailure(this.errorMessage);
}

class QuizCategoryCubit extends Cubit<QuizCategoryState> {
  final QuizRepository _quizRepository;
  QuizCategoryCubit(this._quizRepository) : super(QuizCategoryInitial());

  void getQuizCategory(String languageId,String id) async {
    emit(QuizCategoryProgress());
    _quizRepository
        .getCategory(languageId,id)
        .then(
          (val) => emit(QuizCategorySuccess(val)),
        )
        .catchError((e) {
      emit(QuizCategoryFailure(e.toString()));
    });
  }
}
