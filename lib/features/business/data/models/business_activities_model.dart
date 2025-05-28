class BusinessActivitiesResponse {
  final List<BusinessActivity> activities;

  BusinessActivitiesResponse({
    required this.activities,
  });

  factory BusinessActivitiesResponse.fromJson(List<dynamic> json) {
    return BusinessActivitiesResponse(
      activities: json
          .map((e) => BusinessActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BusinessActivity {
  final String id;
  final String nameEn;
  final String nameAr;
  final List<BusinessCategory> categories;

  BusinessActivity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.categories,
  });

  factory BusinessActivity.fromJson(Map<String, dynamic> json) {
    return BusinessActivity(
      id: json['id'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => BusinessCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class BusinessCategory {
  final String id;
  final String? icon;
  final String categoryEn;
  final String categoryAr;
  final List<BusinessService> services;

  BusinessCategory({
    required this.id,
    this.icon,
    required this.categoryEn,
    required this.categoryAr,
    required this.services,
  });

  factory BusinessCategory.fromJson(Map<String, dynamic> json) {
    return BusinessCategory(
      id: json['id'] ?? '',
      icon: json['icon'],
      categoryEn: json['category_en'] ?? '',
      categoryAr: json['category_ar'] ?? '',
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => BusinessService.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class BusinessService {
  final String id;
  final String serviceEn;
  final String serviceAr;

  BusinessService({
    required this.id,
    required this.serviceEn,
    required this.serviceAr,
  });

  factory BusinessService.fromJson(Map<String, dynamic> json) {
    return BusinessService(
      id: json['id'] ?? '',
      serviceEn: json['service_en'] ?? '',
      serviceAr: json['service_ar'] ?? '',
    );
  }
}
