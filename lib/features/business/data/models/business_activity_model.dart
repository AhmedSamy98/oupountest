class BusinessActivityModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final List<CategoryModel> categories;

  BusinessActivityModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.categories,
  });

  factory BusinessActivityModel.fromJson(Map<String, dynamic> json) {
    return BusinessActivityModel(
      id: json['id'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      categories: (json['categories'] as List?)
              ?.map((e) => CategoryModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CategoryModel {
  final String id;
  final String icon;
  final String categoryEn;
  final String categoryAr;
  final List<ServiceModel> services;

  CategoryModel({
    required this.id,
    required this.icon,
    required this.categoryEn,
    required this.categoryAr,
    required this.services,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      icon: json['icon'] ?? '',
      categoryEn: json['category_en'] ?? '',
      categoryAr: json['category_ar'] ?? '',
      services: (json['services'] as List?)
              ?.map((e) => ServiceModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ServiceModel {
  final String id;
  final String serviceEn;
  final String serviceAr;

  ServiceModel({
    required this.id,
    required this.serviceEn,
    required this.serviceAr,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      serviceEn: json['service_en'] ?? '',
      serviceAr: json['service_ar'] ?? '',
    );
  }
}
