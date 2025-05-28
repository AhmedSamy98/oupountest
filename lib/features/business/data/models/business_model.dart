class BusinessModel {
  final String? id;
  final BusinessName businessName;
  final String crNumber;
  final String vatNumber;
  final String businessActivity;
  final List<String> offeredCategory;
  final List<String> offeredServices;
  final LocalizedText bio;
  final LocalizedText cancellationPolicy;

  BusinessModel({
    this.id,
    required this.businessName,
    required this.crNumber,
    required this.vatNumber,
    required this.businessActivity,
    required this.offeredCategory,
    required this.offeredServices,
    required this.bio,
    required this.cancellationPolicy,
  });

  Map<String, dynamic> toJson() {
    return {
      'business_name': businessName.toJson(),
      'cr_number': crNumber,
      'vat_number': vatNumber,
      'business_activity': businessActivity,
      'offered_category': offeredCategory,
      'offered_services': offeredServices,
      'bio': bio.toJson(),
      'cancellation_policy': cancellationPolicy.toJson(),
    };
  }

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['_id'],
      businessName: BusinessName.fromJson(json['business_name']),
      crNumber: json['cr_number'] ?? '',
      vatNumber: json['vat_number'] ?? '',
      businessActivity: json['business_activity'] ?? '',
      offeredCategory: List<String>.from(json['offered_category'] ?? []),
      offeredServices: List<String>.from(json['offered_services'] ?? []),
      bio: LocalizedText.fromJson(json['bio']),
      cancellationPolicy: LocalizedText.fromJson(json['cancellation_policy']),
    );
  }
}

class BusinessName {
  final String ar;
  final String en;

  BusinessName({
    required this.ar,
    required this.en,
  });

  Map<String, dynamic> toJson() {
    return {
      'ar': ar,
      'en': en,
    };
  }

  factory BusinessName.fromJson(Map<String, dynamic> json) {
    return BusinessName(
      ar: json['ar'] ?? '',
      en: json['en'] ?? '',
    );
  }
}

class LocalizedText {
  final String ar;
  final String en;

  LocalizedText({
    required this.ar,
    required this.en,
  });

  Map<String, dynamic> toJson() {
    return {
      'ar': ar,
      'en': en,
    };
  }

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      ar: json['ar'] ?? '',
      en: json['en'] ?? '',
    );
  }
}

class RegisterBusinessRequest {
  final String phoneNumber;
  final String email;
  final BusinessModel business;

  RegisterBusinessRequest({
    required this.phoneNumber,
    required this.email,
    required this.business,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'email': email,
      'business': business.toJson(),
    };
  }
}
