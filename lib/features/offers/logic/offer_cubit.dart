import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/endpoints.dart';
import 'offer_state.dart';
import '../data/models/offer_model.dart';

class OfferCubit extends Cubit<OfferState> {
  OfferCubit() : super(OfferLoading());

  Future<void> load() async {
    emit(OfferLoading());
    try {
      final res = await DioClient.dio.get(Endpoints.offers);
      final list = (res.data as List).map((e) => OfferModel.fromJson(e)).toList();
      emit(OfferLoaded(list));
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }

  Future<void> delete(String id) async {
    try {
      await DioClient.dio.delete('${Endpoints.offers}$id');
      await load();
      emit(OfferDeleted());
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }
}
