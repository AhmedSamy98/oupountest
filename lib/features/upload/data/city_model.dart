class CityModel {
  final int id;
  final String nameAr;
  final String nameEn;

  CityModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['city_id'],
      nameAr: json['city_ar'],
      nameEn: json['city_en'],
    );
  }
}
