part of 'order_cubit.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<OrderModel> orders;
  OrdersLoaded(this.orders);
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}

class OrderReviewLoading extends OrderState {}

class OrderReviewLoaded extends OrderState {
  final Map<String, dynamic> review;
  OrderReviewLoaded(this.review);
}

class OrderCreating extends OrderState {}

class OrderCreated extends OrderState {
  final Map<String, dynamic> orderData;
  OrderCreated(this.orderData);
}

class OrderReviewCreating extends OrderState {}

class OrderReviewCreated extends OrderState {
  final Map<String, dynamic> reviewData;
  OrderReviewCreated(this.reviewData);
}
