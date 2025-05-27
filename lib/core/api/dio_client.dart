// import 'package:dio/dio.dart';

// class DioClient {
//   static late final Dio dio;

//   static Future<void> init() async {
//     dio = Dio(
//       BaseOptions(
//         baseUrl: 'https://oupoun-test-272677622251.me-central1.run.app/api/v2/',
//         connectTimeout: const Duration(seconds: 15),
//         receiveTimeout: const Duration(seconds: 20),
//         responseType: ResponseType.json,
//         headers: {
//           'accept': 'application/json',
//           'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2ODExZmIwYTk5OGUwMThiN2NmMGQwOWMiLCJyb2xlIjoiYWRtaW4iLCJkZXZpY2VfaWQiOiIxMjM0IiwiZGV2aWNlX29zIjoid2ViIiwiZXhwIjoxNzQ4Njc5NTIwfQ.wq_Sll-K7zWj9QmFJkualFgtyi-XnRI6KuGW6E2cfbw',
//         },
//       ),
//     )..interceptors.add(LogInterceptor(responseBody: true));  // To log API responses
//   }
// }

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../utils/constants.dart';
import '../utils/app_logger.dart';
import '../network/error.dart';
import '../network/retry_interceptor.dart';

class DioClient {
  DioClient._();
  static final DioClient _i = DioClient._();
  static Dio get dio => _i._dio;
  late Dio _dio;

  static Future<void> init({String? token}) => _i._init(token: token);

  Future<void> _init({String? token}) async {
    _dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: kConnectTimeout,
        receiveTimeout: kReceiveTimeout,
        headers: {
          'accept': 'application/json',
          if ((token ?? kDefaultToken).isNotEmpty)
            'Authorization': 'Bearer ${token ?? kDefaultToken}',
        },
      ),
    )
      ..interceptors.add(RetryInterceptor())
      ..interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          compact: true,
          logPrint: (o) => log.d(o),
        ),
      )
      ..interceptors.add(_ErrorMapper());
  }
}

/// يحوّل أخطاء Dio إلى Failure ويطبعها.
class _ErrorMapper extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Failure failure;
    if (err.type == DioExceptionType.badResponse) {
      failure = ServerFailure(
          '${err.response?.statusCode ?? ''} • ${err.response?.data}');
    } else if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout) {
      failure = const NetworkFailure('تحقّق من الاتصال بالإنترنت');
    } else {
      failure = UnknownFailure(err.message ?? 'خطأ غير معروف');    }
    log.e(failure);
    handler.next(err);
  }
}
