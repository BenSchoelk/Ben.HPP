import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/features/statistic/statisticException.dart';
import 'package:flutterquiz/utils/apiBodyParameterLabels.dart';
import 'package:flutterquiz/utils/apiUtils.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';

import 'package:http/http.dart' as http;

class StatisticRemoteDataSource {
  /*
  {
        "id": "2",
        userIdKey: "11",
        "questions_answered": "1",
        correctAnswersKey: "1",
        "strong_category": "News",
        "ratio1": "100",
        "weak_category": "0",
        "ratio2": "0",
        "best_position": "0",
        "date_created": "2021-06-25 15:48:20",
        "name": "RAHUL HIRANI",
        profileKey: "https://lh3.googleusercontent.com/a/AATXAJyzUAfJwUFTV3yE6tM9KdevDnX2rcM8vm3GKHFz=s96-c"
    }
  
   */

  Future<dynamic> getStatistic(String userId) async {
    try {
      //body of post request
      final body = {accessValueKey: accessValue, userIdKey: userId};

      final response = await http.post(Uri.parse(getStatisticUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print("response of statistic $responseJson");

      if (responseJson['error']) {
        throw StatisticException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw StatisticException(errorMessageCode: noInternetCode);
    } on StatisticException catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    } catch (e) {
      throw StatisticException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  /*
  user_id:10
	questions_answered:100
	correct_answers:10
	category_id:1 //(id of category which user played) 
	ratio:50 // (In percenatge)
   */

  Future<dynamic> updateStatistic({String? userId, String? answeredQuestion, String? correctAnswers, String? winPercentage, String? categoryId}) async {
    try {
      print(categoryId);
      //body of post request
      final body = {accessValueKey: accessValue, userIdKey: userId, "questions_answered": answeredQuestion, correctAnswersKey: correctAnswers, "category_id": categoryId, "ratio": winPercentage};
      final response = await http.post(Uri.parse(updateStatisticUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw StatisticException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw StatisticException(errorMessageCode: noInternetCode);
    } on StatisticException catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    } catch (e) {
      throw StatisticException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
