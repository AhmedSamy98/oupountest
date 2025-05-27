import 'package:dio/dio.dart';
import '../utils/app_logger.dart';

/// يحاول الطلب مرّة أخرى تلقائيًا عند بعض الأخطاء (مثل Timeout) بحدٍ أقصى 3 مرات.
class RetryInterceptor extends Interceptor {
  final int maxAttempts;
  RetryInterceptor({this.maxAttempts = 3});

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final attempt = (req.extra['retry_attempt'] ?? 0) + 1;

    final shouldRetry = err.type == DioExceptionType.connectionTimeout ||
                        err.type == DioExceptionType.receiveTimeout ||
                        err.type == DioExceptionType.connectionError;

    if (shouldRetry && attempt <= maxAttempts) {
      log.w('Retry #$attempt → ${req.method} ${req.path}');
      req.extra['retry_attempt'] = attempt;
      try {
        final response = await err.requestOptions
            .copyWith(data: req.data)
            .toDio()
            .fetch(req);
        return handler.resolve(response);
      } catch (e) {
        // المحاولة التالية
      }
    }
    super.onError(err, handler);
  }
}

/// امتداد بسيط لتحويل Options إلى Dio جديد مع نفس الإعدادات.
extension _CopyToDio on RequestOptions {
  Dio toDio() => Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: headers,
        responseType: responseType,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
      ));
}
