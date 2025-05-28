import 'dart:convert';
import 'business_model.dart';

class BusinessListingResponse {
  final int statusCode;
  final String message;
  final List<BusinessItem> businesses;

  BusinessListingResponse({
    required this.statusCode,
    required this.message,
    required this.businesses,
  });

  factory BusinessListingResponse.fromJson(Map<String, dynamic> json) {
    return BusinessListingResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      businesses: (json['businesses'] as List<dynamic>?)
              ?.map((e) => BusinessItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class BusinessItem {
  final String phoneNumber;
  final String? email;
  final BusinessDetails? business;

  BusinessItem({
    required this.phoneNumber,
    this.email,
    this.business,
  });

  factory BusinessItem.fromJson(Map<String, dynamic> json) {
    return BusinessItem(
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'],
      business: json['business'] != null
          ? BusinessDetails.fromJson(json['business'])
          : null,
    );
  }
}

class BusinessDetails {
  final BusinessName? businessName;
  final String? crNumber;
  final String? vatNumber;
  final String? businessActivityId;
  final List<String> offeredCategoryIds;
  final List<String> offeredServiceIds;
  final LocalizedText? bio;
  final LocalizedText? cancellationPolicy;
  final List<Branch> branches;
  final List<String> staff;
  final String? addedBy;

  BusinessDetails({
    this.businessName,
    this.crNumber,
    this.vatNumber,
    this.businessActivityId,
    required this.offeredCategoryIds,
    required this.offeredServiceIds,
    this.bio,
    this.cancellationPolicy,
    required this.branches,
    required this.staff,
    this.addedBy,
  });

  factory BusinessDetails.fromJson(Map<String, dynamic> json) {
    return BusinessDetails(
      businessName: json['business_name'] != null
          ? BusinessName.fromJson(json['business_name'])
          : null,
      crNumber: json['cr_number'],
      vatNumber: json['vat_number'],
      businessActivityId: json['business_activity'],
      offeredCategoryIds: (json['offered_category'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      offeredServiceIds: (json['offered_services'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      bio: json['bio'] != null ? LocalizedText.fromJson(json['bio']) : null,
      cancellationPolicy: json['cancellation_policy'] != null
          ? LocalizedText.fromJson(json['cancellation_policy'])
          : null,
      branches: (json['branches'] as List<dynamic>?)
              ?.map((e) => Branch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      staff:
          (json['staff'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      addedBy: json['added_by'],
    );
  }
}

class Branch {
  final String? createdAt;
  final String? updatedAt;
  final String branchId;
  final BusinessName? name;
  final LocalizedText? description;
  final LocalizedText? address;
  final String? contactNumber;
  final int? cityId;
  final List<double>? latLong;
  final String? addedBy;
  final bool isActive;

  Branch({
    this.createdAt,
    this.updatedAt,
    required this.branchId,
    this.name,
    this.description,
    this.address,
    this.contactNumber,
    this.cityId,
    this.latLong,
    this.addedBy,
    required this.isActive,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      branchId: json['branch_id'] ?? '',
      name: json['name'] != null ? BusinessName.fromJson(json['name']) : null,
      description: json['description'] != null
          ? LocalizedText.fromJson(json['description'])
          : null,
      address: json['address'] != null
          ? LocalizedText.fromJson(json['address'])
          : null,
      contactNumber: json['contact_number'],
      cityId: json['city_id'],
      latLong: json['lat_long'] != null
          ? (json['lat_long'] as List).cast<double>()
          : null,
      addedBy: json['added_by'],
      isActive: json['is_active'] ?? false,
    );
  }
}
