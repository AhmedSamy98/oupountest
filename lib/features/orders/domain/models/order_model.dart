import 'package:flutter/material.dart';

class OrderModel {
  final String id;
  final String clientId;
  final String businessId;
  final String phoneNumber;
  final Map<String, dynamic> offerId;
  final List<String> branchId;
  final String orderStatus;
  final String paymentStatus;
  final String purchaseDate;
  final String? validUntil;
  final num amount;
  final String? qrCode;
  final Map<String, dynamic> optionDetail;
  final Map<String, dynamic>? businessDetails;
  final Map<String, dynamic>? branchDetails;
  final String notes;

  OrderModel({
    required this.id,
    required this.clientId,
    required this.businessId,
    required this.phoneNumber,
    required this.offerId,
    required this.branchId,
    required this.orderStatus,
    required this.paymentStatus,
    required this.purchaseDate,
    this.validUntil,
    required this.amount,
    this.qrCode,
    required this.optionDetail,
    this.businessDetails,
    this.branchDetails,
    required this.notes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      businessId: json['business_id'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      offerId: json['offer_id'] is Map<String, dynamic> ? json['offer_id'] : <String, dynamic>{},
      branchId: json['branch_id'] != null ? List<String>.from(json['branch_id']) : [],
      orderStatus: json['order_status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      purchaseDate: json['purchase_date'] ?? '',
      validUntil: json['valid_until'],
      amount: json['amount'] ?? 0,
      qrCode: json['qr_code'],
      optionDetail: json['option_detail'] is Map<String, dynamic> ? json['option_detail'] : <String, dynamic>{},
      businessDetails: json['business_details'] is Map<String, dynamic> ? json['business_details'] : null,
      branchDetails: json['branch_details'] is Map<String, dynamic> ? json['branch_details'] : null,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'business_id': businessId,
      'phone_number': phoneNumber,
      'offer_id': offerId,
      'branch_id': branchId,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      'purchase_date': purchaseDate,
      'valid_until': validUntil,
      'amount': amount,
      'qr_code': qrCode,
      'option_detail': optionDetail,
      'business_details': businessDetails,
      'branch_details': branchDetails,
      'notes': notes,
    };
  }

  String get offerTitle {
    try {
      return offerId['offer_title']['ar'] ?? offerId['offer_title']['en'] ?? 'غير متوفر';
    } catch (e) {
      return 'غير متوفر';
    }
  }

  String get optionTitle {
    try {
      return optionDetail['option_title']['ar'] ?? 
             optionDetail['option_title']['en'] ?? 
             'غير متوفر';
    } catch (e) {
      return 'غير متوفر';
    }
  }

  String get statusDisplayName {
    switch (orderStatus) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'approved':
        return 'معتمد';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      case 'expired':
        return 'منتهي الصلاحية';
      default:
        return orderStatus;
    }
  }
  
  // دالة تساعد في الحصول على لون الحالة
  Color getStatusColor() {
    switch (orderStatus) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
