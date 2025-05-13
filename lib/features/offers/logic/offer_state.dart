import 'package:oupountest/features/offers/data/models/offer_model.dart';

class OfferState {}

class OfferLoading extends OfferState {}

class OfferLoaded extends OfferState {
  final List<OfferModel> list;
  OfferLoaded(this.list);
}

class OfferError extends OfferState {
  final String msg;
  OfferError(this.msg);
}

class OfferDeleted extends OfferState {}
