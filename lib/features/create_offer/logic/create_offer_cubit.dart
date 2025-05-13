import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/endpoints.dart';
import 'create_offer_state.dart';

class CreateOfferCubit extends Cubit<CreateOfferState> {
  CreateOfferCubit() : super(CreateOfferInitial());

  Future<void> create(Map<String, dynamic> body) async {
    emit(CreateOfferLoading());
    try {
      await DioClient.dio.post(Endpoints.createOffer, data: body, queryParameters: {'language': 'ar'});
      emit(CreateOfferSuccess());
    } catch (e) {
      emit(CreateOfferError(e.toString()));
    }
  }
}
