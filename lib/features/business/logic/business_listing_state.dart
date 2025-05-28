part of 'business_listing_cubit.dart';

abstract class BusinessListingState extends Equatable {
  const BusinessListingState();

  @override
  List<Object?> get props => [];
}

class BusinessListingInitial extends BusinessListingState {
  const BusinessListingInitial();
}

class BusinessListingLoading extends BusinessListingState {
  const BusinessListingLoading();
}

class BusinessListingLoaded extends BusinessListingState {
  final List<BusinessItem> businesses;
  final List<BusinessActivity> activities;

  const BusinessListingLoaded({
    required this.businesses,
    required this.activities,
  });

  @override
  List<Object?> get props => [businesses, activities];
}

class BusinessListingError extends BusinessListingState {
  final String message;

  const BusinessListingError({required this.message});

  @override
  List<Object?> get props => [message];
}
