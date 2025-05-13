class OfferModel {
  final String id;
  final Map<String, String> title;
  final num price;
  final num coupon;
  final String descriptionAr;
  final String descriptionEn;
  final List<String> images;
  final List<Option> options;
  final String phoneNumber;

  const OfferModel({
    required this.id,
    required this.title,
    required this.price,
    required this.coupon,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.images,
    required this.options,
    required this.phoneNumber,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final optionsList = (json['options'] as List)
        .map((optionJson) => Option.fromJson(optionJson))
        .toList();

    return OfferModel(
      id: json['_id'],
      title: Map<String, String>.from(json['offer_title']),
      price: optionsList.first.regularPrice,
      coupon: optionsList.first.oupounPrice,
      descriptionAr: json['description']['ar'] ?? '',
      descriptionEn: json['description']['en'] ?? '',
      images: List<String>.from(json['image'] ?? []),
      options: optionsList,
      phoneNumber: json['phone_number_4booking'] ?? '',
    );
  }
}

class Option {
  final String serviceId;
  final String titleAr;
  final String titleEn;
  final num regularPrice;
  final num oupounPrice;

  Option({
    required this.serviceId,
    required this.titleAr,
    required this.titleEn,
    required this.regularPrice,
    required this.oupounPrice,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      serviceId: json['service_id'],
      titleAr: json['option_title']['ar'] ?? '',
      titleEn: json['option_title']['en'] ?? '',
      regularPrice: json['regular_price'] ?? 0,
      oupounPrice: json['oupoun_price'] ?? 0,
    );
  }
}
