import 'package:equatable/equatable.dart';

import '../data/models/branch_model.dart';

/// حالات إدارة الفروع
abstract class BranchState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class BranchInitial extends BranchState {}

/// حالة جاري التحميل
class BranchLoading extends BranchState {}

/// حالة نجاح إنشاء الفرع
class BranchCreateSuccess extends BranchState {
  final String message;

  BranchCreateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// حالة فشل إنشاء الفرع
class BranchCreateFailure extends BranchState {
  final String error;

  BranchCreateFailure(this.error);

  @override
  List<Object?> get props => [error];
}

/// حالة تحميل المدن
class CitiesLoading extends BranchState {}

/// حالة اكتمال تحميل المدن
class CitiesLoaded extends BranchState {
  final List<CityModel> cities;

  CitiesLoaded(this.cities);

  @override
  List<Object?> get props => [cities];
}

/// حالة خطأ في تحميل المدن
class CitiesError extends BranchState {
  final String error;

  CitiesError(this.error);

  @override
  List<Object?> get props => [error];
}
