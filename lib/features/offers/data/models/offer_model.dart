class OfferModel {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String businessId;
  final String categoryId;
  final List<int> cityIds;
  final List<String> branchIds;
  final Map<String, String> title;
  final Map<String, String> description;
  final List<String> images;
  final List<Option> options;
  final Map<String, String> highlights;
  final Map<String, String> termsAndConditions;
  final Map<String, String> aboutOffer;
  final bool requireBooking;
  final String? phoneNumber;
  final bool isActive;
  final Map<String, String> optionDescription;
  final Map<String, String> cancellationPolicy;
  final String startDate;
  final String endDate;
  final int? validUntil;
  final String? validUnit;
  final String offerLabel;
  final int maxNoOrders;
  
  // Computed properties for the table display
  num get price => options.isNotEmpty ? options.first.regularPrice : 0;
  num get coupon => options.isNotEmpty ? options.first.oupounPrice : 0;
  String get descriptionAr => description['ar'] ?? '';
  String get descriptionEn => description['en'] ?? '';

  const OfferModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.businessId,
    required this.categoryId,
    required this.cityIds,
    required this.branchIds,
    required this.title,
    required this.description,
    required this.images,
    required this.options,
    required this.highlights,
    required this.termsAndConditions,
    required this.aboutOffer,
    required this.requireBooking,
    this.phoneNumber,
    required this.isActive,
    required this.optionDescription,
    required this.cancellationPolicy,
    required this.startDate,
    required this.endDate,
    this.validUntil,
    this.validUnit,
    required this.offerLabel,
    required this.maxNoOrders,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final optionsList = (json['options'] as List)
        .map((optionJson) => Option.fromJson(optionJson))
        .toList();

    return OfferModel(
      id: json['_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      businessId: json['business_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      cityIds: List<int>.from(json['city_id'] ?? []),
      branchIds: List<String>.from(json['branch_id'] ?? []),
      title: Map<String, String>.from(json['offer_title']),
      description: Map<String, String>.from(json['description']),
      images: List<String>.from(json['image'] ?? []),
      options: optionsList,
      highlights: _mapFromJson(json['hilghlights']),
      termsAndConditions: _mapFromJson(json['terms_and_conditions']),
      aboutOffer: _mapFromJson(json['about_offer']),
      requireBooking: json['require_booking'] ?? false,
      phoneNumber: json['phone_number_4booking'],
      isActive: json['is_active'] ?? true,
      optionDescription: _mapFromJson(json['option_description']),
      cancellationPolicy: _mapFromJson(json['cancellation_policy']),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      validUntil: json['valid_until'],
      validUnit: json['valid_unit'],
      offerLabel: json['offer_label'] ?? 'all',
      maxNoOrders: json['max_no_orders'] ?? 0,
    );
  }
  
  // Helper method to convert JSON maps to String maps safely
  static Map<String, String> _mapFromJson(dynamic json) {
    if (json == null) return {'ar': '', 'en': ''};
    if (json is Map) {
      return Map<String, String>.from(json.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')));
    }
    return {'ar': '', 'en': ''};
  }
}

class Option {
  final String serviceId;
  final String optionId;
  final Map<String, String> optionTitle;
  final num regularPrice;
  final num oupounPrice;
  final num discountRate;

  String get titleAr => optionTitle['ar'] ?? '';
  String get titleEn => optionTitle['en'] ?? '';

  Option({
    required this.serviceId,
    required this.optionId,
    required this.optionTitle,
    required this.regularPrice,
    required this.oupounPrice,
    required this.discountRate,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      serviceId: json['service_id'] ?? '',
      optionId: json['option_id'] ?? '',
      optionTitle: Map<String, String>.from(json['option_title'] ?? {'ar': '', 'en': ''}),
      regularPrice: json['regular_price'] ?? 0,
      oupounPrice: json['oupoun_price'] ?? 0,
      discountRate: json['discount_rate'] ?? 0.0,
    );
  }
}
