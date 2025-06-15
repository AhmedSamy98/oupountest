import 'package:oupountest/features/orders/domain/models/order_model.dart';

abstract class OrderRepository {
  /// استرجاع جميع الطلبات مع إمكانية التصفية
  Future<List<OrderModel>> getOrders({
    int? skip,
    int? limit,
    String? branchId,
    bool? isScanned,
    bool? groupOrders,
    bool? getBusinessDetails,
    String? status,
  });
  
  /// استرجاع مراجعة طلب معين
  Future<Map<String, dynamic>> getOrderReview(String orderId);
  
  /// إنشاء طلب جديد
  Future<Map<String, dynamic>> createOrder({
    required String offerId,
    required String branchId,
    required String optionId,
    required String phoneNumber,
    required String currency,
    bool isGift = false,
    String? giftRecipientPhone,
    String? notes,
  });
  
  /// إضافة مراجعة لطلب
  Future<Map<String, dynamic>> createReview({
    required String orderId,
    required String review,
    required String rating,
  });
}
