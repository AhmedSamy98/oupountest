/// جميع نقاط النهاية في مكان واحد مع توابع للمسارات الديناميكية.
class Endpoints {  
  // Admin
  static const String createOffer     = 'admin/create_offer';
  static const String getBusinesses   = 'admin/get_businesses';
  static const String registerBusiness = 'admin/register_business';
  static const String createBranch    = 'admin/create_branch';
  
  // Offers
  static const String offers          = 'offers/';
  static String offersById(String id) => 'offers/$id';
  static String offerImages(String id) => 'offers/$id/images';
  static String offerImagesUpload(String id) => 'offers/$id/upload_images';
  static String offerImageById(String offerId, String imageId) => 'offers/$offerId/images/$imageId';

  // Services & Portal
  static const String servicesActivity = 'services/business-activities/';
  static const String portal           = 'portal/';

  /// مساعدة لبناء Pagination شائعة.
  static Map<String, dynamic> pagination({int skip = 0, int limit = 25}) =>
      {'skip': skip, 'limit': limit};

  /// مساعدة لاختيار اللغة.
  static Map<String, dynamic> lang(String code) => {'language': code};
}