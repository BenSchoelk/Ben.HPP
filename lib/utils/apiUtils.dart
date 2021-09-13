import 'package:flutterquiz/utils/constants.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class ApiUtils {
  static Map<String, String> getHeaders() => {
        "Authorization": 'Bearer ' + _getJwtToken(),
      };

  static String _getJwtToken() {
    final claimSet = new JwtClaim(issuer: 'Quiz', subject: 'Quiz Authentication', maxAge: const Duration(minutes: 5), issuedAt: DateTime.now().toUtc());
    String token = issueJwtHS256(claimSet, jwtKey);
    return token;
  }
}
