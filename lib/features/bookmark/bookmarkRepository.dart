import 'package:flutterquiz/features/bookmark/bookmarkException.dart';
import 'package:flutterquiz/features/bookmark/bookmarkLocalDataSource.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRemoteDataSource.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';

class BookmarkRepository {
  static final BookmarkRepository _bookmarkRepository = BookmarkRepository._internal();
  late BookmarkRemoteDataSource _bookmarkRemoteDataSource;
  late BookmarkLocalDataSource _bookmarkLocalDataSource;

  factory BookmarkRepository() {
    _bookmarkRepository._bookmarkRemoteDataSource = BookmarkRemoteDataSource();
    _bookmarkRepository._bookmarkLocalDataSource = BookmarkLocalDataSource();
    return _bookmarkRepository;
  }

  BookmarkRepository._internal();

  //to get bookmark questions
  Future<List<Question>> getBookmark(String? userId) async {
    try {
      List result = await _bookmarkRemoteDataSource.getBookmark(userId);

      return result.map((question) => Question.fromJson(Map.from(question))).toList();
    } catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    }
  }

  //to update bookmark status (add(1) or remove(0))
  Future<void> updateBookmark(String userId, String questionId, String status) async {
    try {
      await _bookmarkRemoteDataSource.updateBookmark(userId, questionId, status);
    } catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    }
  }

  //get submitted answer for given question index which is store in hive box
  Future<List<String>> getSubmittedAnswerOfBookmarkedQuestions(List<Question> questions) async {
    return _bookmarkLocalDataSource.getAnswerOfBookmarkedQuestion(questions.map((e) => e.id).toList());
  }

  //remove bookmark answer from hive box
  Future<void> removeBookmarkedAnswer(String? questionId) async {
    _bookmarkLocalDataSource.removeBookmarkedAnswer(questionId);
  }

  //set submitted answer id for given question index
  Future<void> setAnswerForBookmarkedQuestion(String questionId, String submittedAnswerId) async {
    _bookmarkLocalDataSource.setAnswerForBookmarkedQuestion(submittedAnswerId, questionId);
  }
}
