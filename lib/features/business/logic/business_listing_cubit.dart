import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:oupountest/features/business/data/models/business_activities_model.dart';
import 'package:oupountest/features/business/data/models/business_listing_model.dart';

import '../../../../core/api/dio_client.dart';
import '../../../../core/api/endpoints.dart';

part 'business_listing_state.dart';

class BusinessListingCubit extends Cubit<BusinessListingState> {
  final Dio _dio;

  BusinessListingCubit({required Dio dioClient})
      : _dio = dioClient,
        super(const BusinessListingInitial());
  Future<void> loadBusinesses() async {
    emit(const BusinessListingLoading());

    try {
      // Fetch businesses
      final businessResponse = await _dio.get(
        Endpoints.getBusinesses,
      );

      final businessesData = BusinessListingResponse.fromJson(businessResponse.data);

      // Fetch business activities to get activity names, categories and services
      final activitiesResponse = await _dio.get(
        Endpoints.servicesActivity,
      );

      final activitiesData = BusinessActivitiesResponse.fromJson(
          activitiesResponse.data as List<dynamic>);

      emit(BusinessListingLoaded(
        businesses: businessesData.businesses,
        activities: activitiesData.activities,
      ));
    } catch (e) {
      emit(BusinessListingError(message: e.toString()));
    }
  }

  // Helper methods to find activity, category or service names from their IDs
  String getActivityName(String activityId, {bool arabic = true}) {
    if (state is! BusinessListingLoaded) return '';

    final loadedState = state as BusinessListingLoaded;
    final activity = loadedState.activities
        .firstWhere((a) => a.id == activityId, orElse: () {
      return BusinessActivity(
        id: '',
        nameEn: 'Unknown',
        nameAr: 'غير معروف',
        categories: [],
      );
    });

    return arabic ? activity.nameAr : activity.nameEn;
  }

  String getCategoryName(String categoryId, {bool arabic = true}) {
    if (state is! BusinessListingLoaded) return '';

    final loadedState = state as BusinessListingLoaded;
    
    for (final activity in loadedState.activities) {
      final category = activity.categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () {
          return BusinessCategory(
            id: '',
            categoryEn: '',
            categoryAr: '',
            services: [],
          );
        },
      );
      
      if (category.id.isNotEmpty) {
        return arabic ? category.categoryAr : category.categoryEn;
      }
    }
    
    return arabic ? 'غير معروف' : 'Unknown';
  }

  String getServiceName(String serviceId, {bool arabic = true}) {
    if (state is! BusinessListingLoaded) return '';

    final loadedState = state as BusinessListingLoaded;
    
    for (final activity in loadedState.activities) {
      for (final category in activity.categories) {
        final service = category.services.firstWhere(
          (s) => s.id == serviceId,
          orElse: () {
            return BusinessService(
              id: '',
              serviceEn: '',
              serviceAr: '',
            );
          },
        );
        
        if (service.id.isNotEmpty) {
          return arabic ? service.serviceAr : service.serviceEn;
        }
      }
    }
    
    return arabic ? 'غير معروف' : 'Unknown';
  }
}
