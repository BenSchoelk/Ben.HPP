import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/features/exam/examException.dart';
import 'package:flutterquiz/utils/apiBodyParameterLabels.dart';
import 'package:flutterquiz/utils/apiUtils.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';

import 'package:http/http.dart' as http;

class ExamRemoteDataSource {
  Future<List<dynamic>> getExams({required String userId, required String languageId, required String type}) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        languageIdKey: languageId,
        typeKey: type // 1 for today , 2 for completed
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }
      final response = await http.post(Uri.parse(getExamModuleUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ExamException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw ExamException(errorMessageCode: noInternetCode);
    } on ExamException catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    } catch (e) {
      throw ExamException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<List<dynamic>> getQuestionForExam({required String examModuleId}) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        examModuleIdKey: examModuleId,
      };

      final response = await http.post(Uri.parse(getExamModuleQuestionsUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ExamException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ExamException(errorMessageCode: noInternetCode);
    } on ExamException catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    } catch (e) {
      throw ExamException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<dynamic> updateExamStatusToInExam({
    required String examModuleId,
    required String userId,
  }) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        examModuleIdKey: examModuleId,
        userIdKey: userId,
      };

      final response = await http.post(Uri.parse(setExamModuleResultUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ExamException(errorMessageCode: responseJson['message'].toString() == "103" ? alreadyInExamCode : responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ExamException(errorMessageCode: noInternetCode);
    } on ExamException catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    } catch (e) {
      throw ExamException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<dynamic> submitExamResult({required String examModuleId, required String userId, required String totalDuration, required List<Map<String, String>> statistics}) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        examModuleIdKey: examModuleId,
        userIdKey: userId,
        statisticsKey: statistics,
        totalDurationKey: totalDuration,
      };

      final response = await http.post(Uri.parse(setExamModuleResultUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ExamException(errorMessageCode: responseJson['message'].toString() == "103" ? alreadyInExamCode : responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ExamException(errorMessageCode: noInternetCode);
    } on ExamException catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    } catch (e) {
      throw ExamException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
