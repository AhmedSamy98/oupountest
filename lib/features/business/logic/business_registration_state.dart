import 'package:equatable/equatable.dart';

import '../data/models/business_activity_model.dart';

abstract class BusinessRegistrationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BusinessRegistrationInitial extends BusinessRegistrationState {}

class BusinessRegistrationLoading extends BusinessRegistrationState {}

class BusinessRegistrationSuccess extends BusinessRegistrationState {
  final String message;

  BusinessRegistrationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BusinessRegistrationFailure extends BusinessRegistrationState {
  final String error;

  BusinessRegistrationFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// Business Activity States
class BusinessActivitiesLoading extends BusinessRegistrationState {}

class BusinessActivitiesLoaded extends BusinessRegistrationState {
  final List<BusinessActivityModel> activities;

  BusinessActivitiesLoaded(this.activities);

  @override
  List<Object?> get props => [activities];
}

class BusinessActivitiesError extends BusinessRegistrationState {
  final String error;

  BusinessActivitiesError(this.error);

  @override
  List<Object?> get props => [error];
}

class BusinessActivitySelected extends BusinessRegistrationState {
  final BusinessActivityModel activity;

  BusinessActivitySelected(this.activity);

  @override
  List<Object?> get props => [activity];
}
