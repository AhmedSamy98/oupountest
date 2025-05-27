import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oupountest/core/api/dio_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/city_model.dart';
import '../data/business_activity_model.dart';

//
//  ── States ────────────────────────────────────────────────────────────────────
//
abstract class UploadState {}
class UploadInitial extends UploadState {}
class UploadLoading extends UploadState {}
class UploadSuccess extends UploadState {}
class UploadError extends UploadState {
  final String message;
  UploadError(this.message);
}

// City States
class CitiesLoading extends UploadState {}
class CitiesLoaded extends UploadState {
  final List<CityModel> cities;
  CitiesLoaded(this.cities);
}
class CitiesError extends UploadState {
  final String message;
  CitiesError(this.message);
}

// Business Activity States
class BusinessActivitiesLoading extends UploadState {}
class BusinessActivitiesLoaded extends UploadState {
  final List<BusinessActivityModel> businessActivities;
  final List<CategoryModel> allCategories;
  BusinessActivitiesLoaded(this.businessActivities, this.allCategories);
}
class BusinessActivitiesError extends UploadState {
  final String message;
  BusinessActivitiesError(this.message);
}

//
//  ── Cubit ─────────────────────────────────────────────────────────────────────
//
class UploadOfferCubit extends Cubit<UploadState> {
  UploadOfferCubit() : super(UploadInitial());
  Future<bool> upload(Map<String, dynamic> body) async {
    emit(UploadLoading());
    print('► POST‑Body:\n${jsonEncode(body)}');

    try {
      final token = dotenv.env['TOKEN'] ?? '';
      final res = await DioClient.dio.post(
        '/admin/create_offer',
        queryParameters: {'language': 'ar'},
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('► POST‑Response: ${res.data}');
      
      // Check if the response status code is successful (200-299)
      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
        // Check if the response data indicates success (some APIs return success: true)
        final responseData = res.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error') && responseData['error'] == true) {
            final message = responseData['message'] ?? 'فشل إنشاء العرض.';
            emit(UploadError(message.toString()));
            return false;
          }
        }
        
        // If we got here, the upload was successful
        emit(UploadSuccess());
        return true;
      } else {
        // The status code indicates an error
        final errorMessage = res.data is Map<String, dynamic> && res.data.containsKey('message') 
            ? res.data['message'] 
            : 'فشل إنشاء العرض.';
        emit(UploadError(errorMessage.toString()));
        return false;
      }
    } catch (e) {
      print('► POST‑Error: $e');
      emit(UploadError('خطأ أثناء الرفع: $e'));
      return false;
    }
  }

  Future<List<CityModel>> fetchCities() async {
    emit(CitiesLoading());
    try {
      final response = await Dio().get('https://oupoun-test-272677622251.me-central1.run.app/api/v2/portal/');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final List<CityModel> cities = data.map((json) => CityModel.fromJson(json)).toList();
        emit(CitiesLoaded(cities));
        return cities;
      } else {
        emit(CitiesError('فشل تحميل المدن'));
        return [];
      }
    } catch (e) {
      print('► GET-Cities-Error: $e');
      emit(CitiesError('خطأ أثناء تحميل المدن: $e'));
      return [];
    }
  }

  Future<List<BusinessActivityModel>> fetchBusinessActivities() async {
    emit(BusinessActivitiesLoading());
    try {
      final response = await Dio().get('https://oupoun-test-272677622251.me-central1.run.app/api/v2/services/business-activities/');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final List<BusinessActivityModel> businessActivities = data
            .map((json) => BusinessActivityModel.fromJson(json))
            .toList();
        
        // استخراج جميع الفئات من جميع الأنشطة التجارية
        final List<CategoryModel> allCategories = [];
        
        for (var activity in businessActivities) {
          allCategories.addAll(activity.categories);
        }
        
        emit(BusinessActivitiesLoaded(businessActivities, allCategories));
        return businessActivities;
      } else {
        emit(BusinessActivitiesError('فشل تحميل الأنشطة التجارية'));
        return [];
      }
    } catch (e) {
      print('► GET-BusinessActivities-Error: $e');
      emit(BusinessActivitiesError('خطأ أثناء تحميل الأنشطة التجارية: $e'));
      return [];
    }
  }
}
