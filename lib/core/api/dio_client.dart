import 'package:dio/dio.dart';

class DioClient {
  static late final Dio dio;

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://oupoun-test-272677622251.me-central1.run.app/api/v2/',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2ODExZmIwYTk5OGUwMThiN2NmMGQwOWMiLCJyb2xlIjoiYWRtaW4iLCJkZXZpY2VfaWQiOiIxMjM0IiwiZGV2aWNlX29zIjoid2ViIiwiZXhwIjoxNzQ4Njc5NTIwfQ.wq_Sll-K7zWj9QmFJkualFgtyi-XnRI6KuGW6E2cfbw',
        },
      ),
    )..interceptors.add(LogInterceptor(responseBody: true));  // To log API responses
  }
}
