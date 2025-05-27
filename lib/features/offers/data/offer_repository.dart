import '../../../core/api/dio_client.dart';
import '../../../core/api/endpoints.dart';
import 'models/offer_model.dart';

class OfferRepository {
  Future<List<OfferModel>> fetch({int skip = 0, int limit = 25}) async {
    final res = await DioClient.dio.get(
      Endpoints.offers,
      queryParameters: Endpoints.pagination(skip: skip, limit: limit),
    );
    return (res.data as List).map((e) => OfferModel.fromJson(e)).toList();
  }

  Future<void> delete(String id) =>
      DioClient.dio.delete(Endpoints.offersById(id));
}
