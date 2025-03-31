import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class FirebaseAuthTokenManager {
  static String? _cachedToken;
  static int? _tokenExpirationTime;
  static const int expirationBuffer = 60; // Refresh token 1 min before expiry

  static Future<String> getAccessToken() async {
    // Return cached token if still valid
    if (_cachedToken != null && _tokenExpirationTime != null) {
      int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (currentTime < (_tokenExpirationTime! - expirationBuffer)) {
        return _cachedToken!;
      }
    }

    const Map<String, String> serviceAccount = {
      "type": "service_account",
      "project_id": "disastermanagementapp-b5d15",
      "private_key_id": "4efc6f9befe9e159c16253bf568d2f75a934ebc6",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCi6Zkgx5qRyMNt\nu/Ii8fdK21kvGVKVDcOm6/Fml50sPK1zzAwXvVs8R/oVxgliRpxx7YAEJuUh+qSc\n5CtDfjIKeVTU/YL40vw/M8GR7DIFGCF4gfjTNplUz4bG1XesxQpYtkaNwWMnt7nW\nmJDgG5qUtwqmtRWzlYL7b/5ja2+Bg0JZ+RPw4Jhyj0NkyZigwcERD+1S48G9x7Ev\nX3ZCd0QSCUNfiXX6eoitU2WrNeySI6t8B9Qd5a79U0KO0aeqIhI5gFcU4R3r/LrU\nYDPIe7lYd07FMiiiEGz2uMO47BJ3A0D5W9xXQdZ9lvsVBi71S5FfzZZNAiENO+R6\n7Ib+3d/bAgMBAAECggEAUBuR4p6EER+piXIbtLdKpJKLni9TflvQU2o9v/bZoIEN\nwZ0abSn9jPzPqplA0ARstVDV3DTMAxNeko9X/s41CRV0c29dUcFdrC5lBr4gMoUV\nIE647hMw/pU1btxVBq21Ur3+n4Hyofsj9LP8uVaZgnsnT6ZHz5C7YaxGaNjRcdsy\nRzAxhH0/50n5TnEgtHO4gpKJYRXQaBUI0zjhjcvJZ9vRXiVa1zMEHeF8XQ4YTFDG\nZ34LlknUYfFc3EqBLMOt2SB0M7k+b8gPhbXI1FzxVhG41VGSGHluW8uYsZPUYVwJ\n0/HhJTLqa0R05cFCND08S5RC1D+Bxr0ewujvY7xbYQKBgQDXrm2hebHPBa6x8ENi\nNrNibt4FjdNsfXMl2X0kO+G9LVKFo9l/5S9REngQCpxLyk6cB3mFlPEYQ5qdCeQ6\nQz5jXpNhnVGTxjIaNvtAmbIqNf7EoLDwMk+CzQz/+SRLAJ55MGF6QKQgyOsVevZb\njfbaVQb9sUAqkVbZZtn4l7uVmQKBgQDBXeGmEE2fNQhYs194EOP1HtOMUplCD0Xv\nqjPyGxGVzInthh+1SdHrWi5ETiusfJRDpQKUuX9MvOKNW051VfI7O7pAFzCTuEXj\n8vizvdvVHMI8ZTZo1JTNtsFBxxWpVGwYYkwuRQops3kSDd3f+ZENdxglGaJMWwQH\nR+7COThhkwKBgG0Tke4wFXSVcxwaXnm1IFOPrkkwyNP9PdbOfzNr9WYvHaTokH7V\n8XAW3xF9zD2oOsk+Hn8oLCYRSohREFNG3q5yjia34SHTAlOvqrGpCSm/1PCsM8/G\nIeAMw55Q6cHktkCj7yhcuKS79+gNH7p9uXIBvl9e3QyqJDoege3vDrdBAoGAIHJV\na90ueTmX5fJrYaVL6xS6IMC3cMtJS/b+cnCyWbWRq2anKW9ypxBh1Rpc37uj0Vn9\n/eDGiKTlSxz4JF5AoEncbea2QwNXzvE1ZEvGeJMz0JiXMa4CLiatdREoBFrjLJBK\nAjWZh/fSqAHlqjChc2X5ijgr8K4RFfuvB648VLsCgYB1mveCIfpUsi2dlJ53o75N\nPd4nMCg8SBG1SoV6PVsp0i4f5gFn0W3kpGrZcY8bf886Tt0zXPJyvHKoEcUiTdc8\nnEvIkGwNuBgQ2Cs18i8TPpS7jI+Ih1oYzAKMz+sFFv/4/P/MXoCan9Nd8QXXnBpQ\n7mT8mp+FpVn20K/1ZHiC4g==\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-fbsvc@disastermanagementapp-b5d15.iam.gserviceaccount.com",
      "client_id": "114703850708754272064",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40disastermanagementapp-b5d15.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    // Create JWT payload
    final int issuedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final int expirationTime = issuedAt + 3600;

    final JWT jwt = JWT(
      {
        'iss': serviceAccount['client_email'],
        'sub': serviceAccount['client_email'],
        'aud': 'https://oauth2.googleapis.com/token',
        'iat': issuedAt,
        'exp': expirationTime,
        'scope': 'https://www.googleapis.com/auth/firebase.messaging',
      },
    );

    // Sign JWT with Firebase private key
    final String signedJwt = jwt.sign(
        RSAPrivateKey(serviceAccount['private_key']!),
        algorithm: JWTAlgorithm.RS256);

    // Request new access token
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': signedJwt,
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      _cachedToken = responseData['access_token'];
      _tokenExpirationTime = expirationTime;
      return _cachedToken!;
    } else {
      throw Exception('Failed to fetch access token: ${response.body}');
    }
  }
}

class FCMService {
  static const String fcmEndpoint =
      'https://fcm.googleapis.com/v1/projects/disastermanagementapp-b5d15/messages:send';

  Future<void> sendNotification(
      {required String topic,
      required String title,
      required String body,
      required String accessToken}) async {
    // String topic, String title, String body, String accessToken) async {
    // Define the message payload
    Map<String, dynamic> messagePayload = {
      "message": {
        "topic": topic,
        "notification": {
          "title": title,
          "body": body,
        }
      }
    };

    // Set the request headers
    Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json; charset=UTF-8'
    };

    // Send the notification
    final response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: headers,
      body: jsonEncode(messagePayload),
    );
    print(response.body);
    if (response.statusCode == 200) {
      print("✅ Notification sent successfully!");
    } else {
      print("❌ Failed to send notification: ${response.body}");
    }
  }
}

// void main() async {
//   try {
//     String token = await FirebaseAuthTokenManager.getAccessToken();
//     print('Firebase Access Token: $token');
//     FCMService fcmService = FCMService();
//     await fcmService.sendNotification(
//         topic: "volunteer",
//         title: "big flood run",
//         body: "body",
//         accessToken: token);
//     // await fcmService.sendNotification(
//     //     "news", "alphabets", "kakhagaghanga", token);
//   } catch (e) {
//     print('Error: $e');
//   }
// }
