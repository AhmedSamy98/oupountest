/// نموذج بيانات الفرع
class BranchModel {
  final LocalizedText name;
  final LocalizedText description;
  final LocalizedText address;
  final String contactNumber;
  final int cityId;
  final List<double> latLong;

  BranchModel({
    required this.name,
    required this.description,
    required this.address,
    required this.contactNumber,
    required this.cityId,
    required this.latLong,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
      'description': description.toJson(),
      'address': address.toJson(),
      'contact_number': contactNumber,
      'city_id': cityId,
      'lat_long': latLong,
    };
  }
}

/// نموذج طلب إنشاء فرع جديد
class CreateBranchRequest {
  final String phoneNumber;
  final BranchModel branch;

  CreateBranchRequest({
    required this.phoneNumber,
    required this.branch,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'branch': branch.toJson(),
    };
  }
}

/// نموذج مدينة
class CityModel {
  final int cityId;
  final String cityAr;
  final String cityEn;

  CityModel({
    required this.cityId,
    required this.cityAr,
    required this.cityEn,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      cityId: json['city_id'],
      cityAr: json['city_ar'],
      cityEn: json['city_en'],
    );
  }
}

/// نص مزدوج اللغة (عربي وإنجليزي)
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
}
