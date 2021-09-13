import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';

@immutable
abstract class BookmarkState {}

class BookmarkInitial extends BookmarkState {}

class BookmarkFetchInProgress extends BookmarkState {}

class BookmarkFetchSuccess extends BookmarkState {
  //bookmarked questions
  final List<Question> questions;
  //submitted answer id for questions we can get submitted answer id for given quesiton
  //by comparing index of these two lists
  final List<String> submittedAnswerIds;
  BookmarkFetchSuccess(this.questions, this.submittedAnswerIds);
}

class BookmarkFetchFailure extends BookmarkState {
  final String errorMessageCode;
  BookmarkFetchFailure(this.errorMessageCode);
}

class BookmarkCubit extends Cubit<BookmarkState> {
  final BookmarkRepository _bookmarkRepository;
  BookmarkCubit(this._bookmarkRepository) : super(BookmarkInitial());

  void getBookmark(String? userId) async {
    emit(BookmarkFetchInProgress());

    try {
      List<Question> questions = await _bookmarkRepository.getBookmark(userId);
      print(questions.length);
      //coming from local database (hive)
      List<String> submittedAnswerIds = await _bookmarkRepository.getSubmittedAnswerOfBookmarkedQuestions(questions);

      emit(BookmarkFetchSuccess(questions, submittedAnswerIds));
    } catch (e) {
      print(e.toString());
      emit(BookmarkFetchFailure(e.toString()));
    }
  }

  bool hasQuestionBookmarked(String? questionId) {
    if (state is BookmarkFetchSuccess) {
      final questions = (state as BookmarkFetchSuccess).questions;
      return questions.indexWhere((element) => element.id == questionId) != -1;
    }
    return false;
  }

  void addBookmarkQuestion(Question question) {
    print("Added question id ${question.id} and answer id is ${question.submittedAnswerId}");
    if (state is BookmarkFetchSuccess) {
      final currentState = (state as BookmarkFetchSuccess);
      //set submitted answer for given index initially submitted answer will be empty
      _bookmarkRepository.setAnswerForBookmarkedQuestion(question.id!, question.submittedAnswerId);
      emit(BookmarkFetchSuccess(
        List.from(currentState.questions)..insert(0, question.updateQuestionWithAnswer(submittedAnswerId: "")),
        List.from(currentState.submittedAnswerIds)..insert(0, question.submittedAnswerId),
      ));
    }
  }

  //we need to update submitted answer for given queston index
  //this will be call after user has given answer for question and question has been bookmarked
  void updateSubmittedAnswerId(Question question) {
    if (state is BookmarkFetchSuccess) {
      final currentState = (state as BookmarkFetchSuccess);
      print("Submitted AnswerId : ${question.submittedAnswerId}");
      _bookmarkRepository.setAnswerForBookmarkedQuestion(question.id!, question.submittedAnswerId);
      List<String> updatedSubmittedAnswerIds = List.from(currentState.submittedAnswerIds);
      updatedSubmittedAnswerIds[currentState.questions.indexWhere((element) => element.id == question.id)] = question.submittedAnswerId;
      emit(BookmarkFetchSuccess(
        List.from(currentState.questions),
        updatedSubmittedAnswerIds,
      ));
    }
  }

  //remove bookmark question and respective submitted answer
  void removeBookmarkQuestion(String? questionId) {
    if (state is BookmarkFetchSuccess) {
      final currentState = (state as BookmarkFetchSuccess);
      List<Question> updatedQuestions = List.from(currentState.questions);
      List<String> submittedAnswerIds = List.from(currentState.submittedAnswerIds);

      int index = updatedQuestions.indexWhere((element) => element.id == questionId);
      updatedQuestions.removeAt(index);
      submittedAnswerIds.removeAt(index);
      _bookmarkRepository.removeBookmarkedAnswer(questionId);
      emit(BookmarkFetchSuccess(
        updatedQuestions,
        submittedAnswerIds,
      ));
    }
  }

  List<Question> questions() {
    if (state is BookmarkFetchSuccess) {
      return (state as BookmarkFetchSuccess).questions;
    }
    return [];
  }

  //to get submitted answer title for given quesiton
  String getSubmittedAnswerForQuestion(String? questionId) {
    if (state is BookmarkFetchSuccess) {
      final currentState = (state as BookmarkFetchSuccess);
      //current question
      int index = currentState.questions.indexWhere((element) => element.id == questionId);
      if (currentState.submittedAnswerIds[index].isEmpty || currentState.submittedAnswerIds[index] == "-1" || currentState.submittedAnswerIds[index] == "0") {
        return "Un-attempted";
      }

      Question question = currentState.questions[index];

      int submittedAnswerOptionIndex = question.answerOptions!.indexWhere((element) => element.id == currentState.submittedAnswerIds[index]);

      return question.answerOptions![submittedAnswerOptionIndex].title!;
    }
    return "";
  }
}
