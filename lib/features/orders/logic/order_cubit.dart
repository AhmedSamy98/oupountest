import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oupountest/core/utils/app_logger.dart';
import 'package:oupountest/features/orders/domain/models/order_model.dart';
import 'package:oupountest/features/orders/domain/repositories/order_repository.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository;
  
  OrderCubit(this._repository) : super(OrderInitial());
  
  Future<void> getOrders({
    int? skip,
    int? limit,
    String? branchId,
    bool? isScanned,
    bool? groupOrders,
    bool? getBusinessDetails,
    String? status,
  }) async {
    try {
      emit(OrderLoading());
      
      final orders = await _repository.getOrders(
        skip: skip,
        limit: limit,
        branchId: branchId,
        isScanned: isScanned,
        groupOrders: groupOrders,
        getBusinessDetails: getBusinessDetails,
        status: status,
      );
      
      emit(OrdersLoaded(orders));
    } catch (e) {
      log.e('فشل في تحميل الطلبات: $e');
      emit(OrderError('فشل في تحميل الطلبات: ${e.toString()}'));
    }
  }
  
  Future<void> getOrderReview(String orderId) async {
    try {
      emit(OrderReviewLoading());
      
      final review = await _repository.getOrderReview(orderId);
      
      emit(OrderReviewLoaded(review));
    } catch (e) {
      log.e('فشل في تحميل المراجعة: $e');
      emit(OrderError('فشل في تحميل المراجعة: ${e.toString()}'));
    }
  }
  
  Future<void> createOrder({
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
      emit(OrderCreating());
      
      final result = await _repository.createOrder(
        offerId: offerId,
        branchId: branchId,
        optionId: optionId,
        phoneNumber: phoneNumber,
        currency: currency,
        isGift: isGift,
        giftRecipientPhone: giftRecipientPhone,
        notes: notes,
      );
      
      emit(OrderCreated(result));
    } catch (e) {
      log.e('فشل في إنشاء الطلب: $e');
      emit(OrderError('فشل في إنشاء الطلب: ${e.toString()}'));
    }
  }
  
  Future<void> createReview({
    required String orderId,
    required String review,
    required String rating,
  }) async {
    try {
      emit(OrderReviewCreating());
      
      final result = await _repository.createReview(
        orderId: orderId,
        review: review,
        rating: rating,
      );
      
      emit(OrderReviewCreated(result));
    } catch (e) {
      log.e('فشل في إنشاء المراجعة: $e');
      emit(OrderError('فشل في إنشاء المراجعة: ${e.toString()}'));
    }
  }
}
