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

class OfferDeleted extends OfferState {
  final String deletedOfferId;
  final OfferState nextState;
  
  OfferDeleted(this.deletedOfferId, this.nextState);
}

// Image upload states
class OfferImageUploading extends OfferState {
  final String offerId;
  final double progress;
  
  OfferImageUploading(this.offerId, this.progress);
}

class OfferImageUploaded extends OfferState {
  final String offerId;
  final List<String> imageIds;
  final OfferState nextState;
  
  OfferImageUploaded(this.offerId, this.imageIds, this.nextState);
}

class OfferImageError extends OfferState {
  final String offerId;
  final String message;
  final OfferState nextState;
  
  OfferImageError(this.offerId, this.message, this.nextState);
}
