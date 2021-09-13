import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/features/bookmark/bookmarkException.dart';
import 'package:flutterquiz/utils/apiBodyParameterLabels.dart';
import 'package:flutterquiz/utils/apiUtils.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';

import 'package:http/http.dart' as http;

class BookmarkRemoteDataSource {
  Future<List<dynamic>> getBookmark(String? userId) async {
    try {
      //body of post request
      final body = {accessValueKey: accessValue, userIdKey: userId};

      final response = await http.post(Uri.parse(getBookmarkUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw BookmarkException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw BookmarkException(errorMessageCode: noInternetCode);
    } on BookmarkException catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    } catch (e) {
      throw BookmarkException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<dynamic> updateBookmark(String userId, String questionId, String status) async {
    try {
      print(questionId);
      //body of post request
      final body = {accessValueKey: accessValue, userIdKey: userId, statusKey: status, questionIdKey: questionId};
      final response = await http.post(Uri.parse(updateBookmarkUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw BookmarkException(errorMessageCode: responseJson['message']);
      }
      print(responseJson);
      return responseJson['data'];
    } on SocketException catch (_) {
      throw BookmarkException(errorMessageCode: noInternetCode);
    } on BookmarkException catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    } catch (e) {
      throw BookmarkException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
