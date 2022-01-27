import 'dart:convert';
import 'dart:io';

import 'package:hpp/features/reportQuestion/reportQuestionException.dart';
import 'package:hpp/utils/apiBodyParameterLabels.dart';
import 'package:hpp/utils/apiUtils.dart';
import 'package:hpp/utils/constants.dart';
import 'package:hpp/utils/errorMessageKeys.dart';
import 'package:http/http.dart' as http;

class ReportQuestionRemoteDataSource {
  /*
   access_key:8525
        question_id:115
        user_id:1
        message: Any reporting message
  
  
   */
  Future<dynamic> reportQuestion({required String questionId, required String message, required String userId}) async {
    try {
      Map<String, String> body = {accessValueKey: accessValue, questionIdKey: questionId, messageKey: message, userIdKey: userId};

      final response = await http.post(Uri.parse(reportQuestionUrl), body: body, headers: ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ReportQuestionException(errorMessageCode: responseJson['message']); //error
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ReportQuestionException(errorMessageCode: noInternetCode);
    } on ReportQuestionException catch (e) {
      throw ReportQuestionException(errorMessageCode: e.toString());
    } catch (e) {
      throw ReportQuestionException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
