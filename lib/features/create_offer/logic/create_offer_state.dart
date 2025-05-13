class CreateOfferState {}

class CreateOfferInitial extends CreateOfferState {}
class CreateOfferLoading extends CreateOfferState {}
class CreateOfferSuccess extends CreateOfferState {}
class CreateOfferError extends CreateOfferState {
  final String msg;
  CreateOfferError(this.msg);
}
