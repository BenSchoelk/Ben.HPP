import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';

import 'package:flutterquiz/utils/uiUtils.dart';

@immutable
abstract class GuessTheWordBookmarkState {}

class GuessTheWordBookmarkInitial extends GuessTheWordBookmarkState {}

class GuessTheWordBookmarkFetchInProgress extends GuessTheWordBookmarkState {}

class GuessTheWordBookmarkFetchSuccess extends GuessTheWordBookmarkState {
  //bookmarked questions
  final List<GuessTheWordQuestion> questions;
  //submitted answer id for questions we can get submitted answer id for given quesiton
  //by comparing index of these two lists
  final List<String> submittedAnswers;
  GuessTheWordBookmarkFetchSuccess(this.questions, this.submittedAnswers);
}

class GuessTheWordBookmarkFetchFailure extends GuessTheWordBookmarkState {
  final String errorMessageCode;
  GuessTheWordBookmarkFetchFailure(this.errorMessageCode);
}

class GuessTheWordBookmarkCubit extends Cubit<GuessTheWordBookmarkState> {
  final BookmarkRepository _bookmarkRepository;
  GuessTheWordBookmarkCubit(this._bookmarkRepository)
      : super(GuessTheWordBookmarkInitial());

  void getBookmark(String userId) async {
    emit(GuessTheWordBookmarkFetchInProgress());

    try {
      List<GuessTheWordQuestion> questions =
          await _bookmarkRepository.getBookmark(userId, "3")
              as List<GuessTheWordQuestion>; //type 3 is for guess the word

      //coming from local database (hive)
      List<String> submittedAnswers = await _bookmarkRepository
          .getSubmittedAnswerOfGuessTheWordBookmarkedQuestions(
              questions.map((e) => e.id).toList());

      print("Guess the word book mark fetch success");

      emit(GuessTheWordBookmarkFetchSuccess(questions, submittedAnswers));
    } catch (e) {
      print(e.toString());
      emit(GuessTheWordBookmarkFetchFailure(e.toString()));
    }
  }

  bool hasQuestionBookmarked(String? questionId) {
    if (state is GuessTheWordBookmarkFetchSuccess) {
      final questions = (state as GuessTheWordBookmarkFetchSuccess).questions;
      return questions.indexWhere((element) => element.id == questionId) != -1;
    }
    return false;
  }

  void addBookmarkQuestion(GuessTheWordQuestion question) {
    print(
        "Guess the word bookmark question answer : ${UiUtils.buildGuessTheWordQuestionAnswer(question.submittedAnswer)}");

    if (state is GuessTheWordBookmarkFetchSuccess) {
      final currentState = (state as GuessTheWordBookmarkFetchSuccess);
      //set submitted answer for given index initially submitted answer will be empty
      _bookmarkRepository.setAnswerForGuessTheWordBookmarkedQuestion(
        question.id,
        UiUtils.buildGuessTheWordQuestionAnswer(question.submittedAnswer),
      );

      emit(GuessTheWordBookmarkFetchSuccess(
        List.from(currentState.questions)..insert(0, question),
        List.from(currentState.submittedAnswers)
          ..insert(
              0,
              UiUtils.buildGuessTheWordQuestionAnswer(
                  question.submittedAnswer)),
      ));
    }
  }

  //we need to update submitted answer for given queston index
  //this will be call after user has given answer for question and question has been bookmarked
  void updateSubmittedAnswer(
      {required String questionId, required String submittedAnswer}) {
    if (state is GuessTheWordBookmarkFetchSuccess) {
      final currentState = (state as GuessTheWordBookmarkFetchSuccess);

      //update the answer
      _bookmarkRepository.setAnswerForGuessTheWordBookmarkedQuestion(
          questionId, submittedAnswer);

      //update state
      List<String> updatedSubmittedAnswers =
          List.from(currentState.submittedAnswers);
      updatedSubmittedAnswers[currentState.questions
          .indexWhere((element) => element.id == questionId)] = submittedAnswer;
      emit(GuessTheWordBookmarkFetchSuccess(
        List.from(currentState.questions),
        updatedSubmittedAnswers,
      ));
    }
  }

  //remove bookmark question and respective submitted answer
  void removeBookmarkQuestion(String questionId) {
    if (state is GuessTheWordBookmarkFetchSuccess) {
      final currentState = (state as GuessTheWordBookmarkFetchSuccess);
      List<GuessTheWordQuestion> updatedQuestions =
          List.from(currentState.questions);
      List<String> submittedAnswerIds =
          List.from(currentState.submittedAnswers);

      int index =
          updatedQuestions.indexWhere((element) => element.id == questionId);
      updatedQuestions.removeAt(index);
      submittedAnswerIds.removeAt(index);
      _bookmarkRepository.removeGuessTheWordBookmarkedAnswer(questionId);
      emit(GuessTheWordBookmarkFetchSuccess(
        updatedQuestions,
        submittedAnswerIds,
      ));
    }
  }

  List<GuessTheWordQuestion> questions() {
    if (state is GuessTheWordBookmarkFetchSuccess) {
      return (state as GuessTheWordBookmarkFetchSuccess).questions;
    }
    return [];
  }

  //to get submitted answer title for given quesiton
  String getSubmittedAnswerForQuestion(String questionId) {
    if (state is GuessTheWordBookmarkFetchSuccess) {
      final currentState = (state as GuessTheWordBookmarkFetchSuccess);
      //current question
      int index = currentState.questions
          .indexWhere((element) => element.id == questionId);
      if (currentState.submittedAnswers[index].isEmpty) {
        return "Un-attempted";
      }

      return currentState.submittedAnswers[index];
    }
    return "";
  }

  void updateState(GuessTheWordBookmarkState updatedState) {
    emit(updatedState);
  }
}
