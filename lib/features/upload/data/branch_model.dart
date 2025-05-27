class BranchModel {
  final String id;
  final String nameAr;
  final String nameEn;

  BranchModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['branch_id'] as String,
      nameAr: json['name']['ar'] as String,
      nameEn: json['name']['en'] as String,
    );
  }
}
