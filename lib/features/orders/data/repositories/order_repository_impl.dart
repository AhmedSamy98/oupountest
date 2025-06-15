import 'package:dio/dio.dart';
import 'package:oupountest/core/api/dio_client.dart';
import 'package:oupountest/core/utils/app_logger.dart';
import 'package:oupountest/features/orders/domain/models/order_model.dart';
import 'package:oupountest/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final String _baseUrl = 'orders';
  
  @override
  Future<List<OrderModel>> getOrders({
    int? skip,
    int? limit,
    String? branchId,
    bool? isScanned,
    bool? groupOrders,
    bool? getBusinessDetails,
    String? status,
  }) async {
    try {
      // إنشاء المعلمات الاختيارية
      final Map<String, dynamic> queryParameters = {};
      
      if (skip != null) queryParameters['skip'] = skip;
      if (limit != null) queryParameters['limit'] = limit;
      if (branchId != null) queryParameters['branch_id'] = branchId;
      if (isScanned != null) queryParameters['is_scanned'] = isScanned;
      if (groupOrders != null) queryParameters['group_orders'] = groupOrders;
      if (getBusinessDetails != null) queryParameters['get_business_details'] = getBusinessDetails;
      if (status != null) queryParameters['status'] = status;
      
      // إرسال الطلب
      final response = await DioClient.dio.get(
        '/$_baseUrl/',
        queryParameters: queryParameters,
      );
      
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => OrderModel.fromJson(item))
            .toList();
      } else {
        throw Exception('تعذر استرجاع الطلبات');
      }
    } catch (e) {
      log.e('خطأ في استرجاع الطلبات: $e');
      
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('غير مصرح: رمز التوكن غير صالح');
        } else if (e.response?.statusCode == 403) {
          throw Exception('غير مسموح: المستخدم لا يملك الصلاحيات اللازمة');
        } else if (e.response?.statusCode == 404) {
          throw Exception('لم يتم العثور على بيانات');
        } else {
          throw Exception('خطأ في الخادم: ${e.message}');
        }
      }
      
      throw Exception('فشل في الاتصال: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getOrderReview(String orderId) async {
    try {
      final response = await DioClient.dio.get(
        '/$_baseUrl/reviews',
        queryParameters: {'order_id': orderId},
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('تعذر استرجاع مراجعة الطلب');
      }
    } catch (e) {
      log.e('خطأ في استرجاع مراجعة الطلب: $e');
      
      if (e is DioException && e.response?.statusCode == 403) {
        throw Exception('المستخدم لا يملك الصلاحيات اللازمة');
      }
      
      throw Exception('فشل في استرجاع مراجعة الطلب: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> createOrder({
    required String offerId,
    required String branchId,
    required String optionId,
    required String phoneNumber,
    required String currency,
    bool isGift = false,
    String? giftRecipientPhone,
    String? notes,
  }) async {
    try {
      final data = {
        'offer_id': offerId,
        'branch_id': branchId,
        'option_id': optionId,
        'phone_number': phoneNumber,
        'currency': currency,
        'is_gift': isGift,
        if (giftRecipientPhone != null) 'gift_recipient_phone': giftRecipientPhone,
        if (notes != null) 'notes': notes,
      };
      
      final response = await DioClient.dio.post('/$_baseUrl/', data: data);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('تعذر إنشاء الطلب');
      }
    } catch (e) {
      log.e('خطأ في إنشاء الطلب: $e');
      throw Exception('فشل في إنشاء الطلب: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> createReview({
    required String orderId,
    required String review,
    required String rating,
  }) async {
    try {
      final data = {
        'order_id': orderId,
        'review': review,
        'rating': rating,
      };
      
      final response = await DioClient.dio.post('/$_baseUrl/reviews', data: data);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('تعذر إنشاء المراجعة');
      }
    } catch (e) {
      log.e('خطأ في إنشاء المراجعة: $e');
      throw Exception('فشل في إنشاء المراجعة: $e');
    }
  }
}
