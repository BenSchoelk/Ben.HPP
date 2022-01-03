import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';

@immutable
abstract class AudioQuestionBookMarkState {}

class AudioQuestionBookmarkInitial extends AudioQuestionBookMarkState {}

class AudioQuestionBookmarkFetchInProgress extends AudioQuestionBookMarkState {}

class AudioQuestionBookmarkFetchSuccess extends AudioQuestionBookMarkState {
  //bookmarked questions
  final List<Question> questions;
  //submitted answer id for questions we can get submitted answer id for given quesiton
  //by comparing index of these two lists
  final List<String> submittedAnswerIds;
  AudioQuestionBookmarkFetchSuccess(this.questions, this.submittedAnswerIds);
}

class AudioQuestionBookmarkFetchFailure extends AudioQuestionBookMarkState {
  final String errorMessageCode;
  AudioQuestionBookmarkFetchFailure(this.errorMessageCode);
}

class AudioQuestionBookmarkCubit extends Cubit<AudioQuestionBookMarkState> {
  final BookmarkRepository _bookmarkRepository;
  AudioQuestionBookmarkCubit(this._bookmarkRepository)
      : super(AudioQuestionBookmarkInitial());

  void getBookmark(String userId) async {
    emit(AudioQuestionBookmarkFetchInProgress());

    try {
      List<Question> questions = await _bookmarkRepository.getBookmark(
          userId, "4") as List<Question>; //type 4 is for audio questions

      //coming from local database (hive)
      List<String> submittedAnswerIds = await _bookmarkRepository
          .getSubmittedAnswerOfAudioBookmarkedQuestions(
              questions.map((e) => e.id!).toList());

      emit(AudioQuestionBookmarkFetchSuccess(questions, submittedAnswerIds));
    } catch (e) {
      emit(AudioQuestionBookmarkFetchFailure(e.toString()));
    }
  }

  bool hasQuestionBookmarked(String? questionId) {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final questions = (state as AudioQuestionBookmarkFetchSuccess).questions;
      return questions.indexWhere((element) => element.id == questionId) != -1;
    }
    return false;
  }

  void addBookmarkQuestion(Question question) {
    print(
        "Added question id ${question.id} and answer id is ${question.submittedAnswerId}");
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final currentState = (state as AudioQuestionBookmarkFetchSuccess);
      //set submitted answer for given index initially submitted answer will be empty
      _bookmarkRepository.setAnswerForAudioBookmarkedQuestion(
          question.id!, question.submittedAnswerId);
      emit(AudioQuestionBookmarkFetchSuccess(
        List.from(currentState.questions)
          ..insert(0, question.updateQuestionWithAnswer(submittedAnswerId: "")),
        List.from(currentState.submittedAnswerIds)
          ..insert(0, question.submittedAnswerId),
      ));
    }
  }

  //we need to update submitted answer for given queston index
  //this will be call after user has given answer for question and question has been bookmarked
  void updateSubmittedAnswerId(Question question) {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final currentState = (state as AudioQuestionBookmarkFetchSuccess);
      print("Submitted AnswerId : ${question.submittedAnswerId}");
      _bookmarkRepository.setAnswerForAudioBookmarkedQuestion(
          question.id!, question.submittedAnswerId);
      List<String> updatedSubmittedAnswerIds =
          List.from(currentState.submittedAnswerIds);
      updatedSubmittedAnswerIds[currentState.questions
              .indexWhere((element) => element.id == question.id)] =
          question.submittedAnswerId;
      emit(AudioQuestionBookmarkFetchSuccess(
        List.from(currentState.questions),
        updatedSubmittedAnswerIds,
      ));
    }
  }

  //remove bookmark question and respective submitted answer
  void removeBookmarkQuestion(String? questionId) {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final currentState = (state as AudioQuestionBookmarkFetchSuccess);
      List<Question> updatedQuestions = List.from(currentState.questions);
      List<String> submittedAnswerIds =
          List.from(currentState.submittedAnswerIds);

      int index =
          updatedQuestions.indexWhere((element) => element.id == questionId);
      updatedQuestions.removeAt(index);
      submittedAnswerIds.removeAt(index);
      _bookmarkRepository.removeAudioBookmarkedAnswer(questionId);
      emit(AudioQuestionBookmarkFetchSuccess(
        updatedQuestions,
        submittedAnswerIds,
      ));
    }
  }

  List<Question> questions() {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      return (state as AudioQuestionBookmarkFetchSuccess).questions;
    }
    return [];
  }

  //to get submitted answer title for given quesiton
  String getSubmittedAnswerForQuestion(String? questionId) {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final currentState = (state as AudioQuestionBookmarkFetchSuccess);
      //current question
      int index = currentState.questions
          .indexWhere((element) => element.id == questionId);
      if (currentState.submittedAnswerIds[index].isEmpty ||
          currentState.submittedAnswerIds[index] == "-1" ||
          currentState.submittedAnswerIds[index] == "0") {
        return "Un-attempted";
      }

      Question question = currentState.questions[index];

      int submittedAnswerOptionIndex = question.answerOptions!.indexWhere(
          (element) => element.id == currentState.submittedAnswerIds[index]);

      return question.answerOptions![submittedAnswerOptionIndex].title!;
    }
    return "";
  }

  void updateState(AudioQuestionBookMarkState updatedState) {
    emit(updatedState);
  }
}
