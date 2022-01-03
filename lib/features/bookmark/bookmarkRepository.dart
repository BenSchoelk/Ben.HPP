import 'package:flutterquiz/features/bookmark/bookmarkException.dart';
import 'package:flutterquiz/features/bookmark/bookmarkLocalDataSource.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRemoteDataSource.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';

class BookmarkRepository {
  static final BookmarkRepository _bookmarkRepository =
      BookmarkRepository._internal();
  late BookmarkRemoteDataSource _bookmarkRemoteDataSource;
  late BookmarkLocalDataSource _bookmarkLocalDataSource;

  factory BookmarkRepository() {
    _bookmarkRepository._bookmarkRemoteDataSource = BookmarkRemoteDataSource();
    _bookmarkRepository._bookmarkLocalDataSource = BookmarkLocalDataSource();
    return _bookmarkRepository;
  }

  BookmarkRepository._internal();

  //to get bookmark questions
  Future<List> getBookmark(String userId, String type) async {
    try {
      List result = await _bookmarkRemoteDataSource.getBookmark(userId, type);
      if (type == "3") {
        return result
            .map((question) =>
                GuessTheWordQuestion.fromBookmarkJson(Map.from(question)))
            .toList();
      }
      return result
          .map((question) => Question.fromBookmarkJson(Map.from(question)))
          .toList();
    } catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    }
  }

  //to update bookmark status (add(1) or remove(0))
  Future<void> updateBookmark(
      String userId, String questionId, String status, String type) async {
    try {
      await _bookmarkRemoteDataSource.updateBookmark(
          userId, questionId, status, type);
    } catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    }
  }

  //get submitted answer for given question index which is store in hive box
  Future<List<String>> getSubmittedAnswerOfBookmarkedQuestions(
      List<String> questionIds) async {
    return await _bookmarkLocalDataSource
        .getAnswerOfBookmarkedQuestion(questionIds);
  }

  //get submitted answer for given question index which is store in hive box
  Future<List<String>> getSubmittedAnswerOfGuessTheWordBookmarkedQuestions(
      List<String> questionIds) async {
    return _bookmarkLocalDataSource
        .getAnswerOfGuessTheWordBookmarkedQuestion(questionIds);
  }

  //remove bookmark answer from hive box
  Future<void> removeBookmarkedAnswer(String? questionId) async {
    _bookmarkLocalDataSource.removeBookmarkedAnswer(questionId);
  }

  //remove bookmark answer from hive box
  Future<void> removeGuessTheWordBookmarkedAnswer(String questionId) async {
    _bookmarkLocalDataSource.removeGuessTheWordBookmarkedAnswer(questionId);
  }

  //set submitted answer id for given question index
  Future<void> setAnswerForBookmarkedQuestion(
      String questionId, String submittedAnswerId) async {
    _bookmarkLocalDataSource.setAnswerForBookmarkedQuestion(
        submittedAnswerId, questionId);
  }

  //set submitted answer id for given question index
  Future<void> setAnswerForGuessTheWordBookmarkedQuestion(
      String questionId, String submittedAnswer) async {
    _bookmarkLocalDataSource.setAnswerForGuessTheWordBookmarkedQuestion(
        submittedAnswer, questionId);
  }
}
