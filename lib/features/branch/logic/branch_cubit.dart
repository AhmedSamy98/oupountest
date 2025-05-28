import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/dio_client.dart';
import '../../../core/api/endpoints.dart';
import '../data/models/branch_model.dart';
import 'branch_state.dart';

/// كيوبت إدارة الفروع
class BranchCubit extends Cubit<BranchState> {
  List<CityModel> _cities = [];
  
  /// الحصول على المدن
  List<CityModel> get cities => _cities;

  BranchCubit() : super(BranchInitial());

  /// تحميل المدن
  Future<void> loadCities() async {
    emit(CitiesLoading());
    try {
      print('Loading cities from API...');
      
      final fullUrl = DioClient.dio.options.baseUrl + Endpoints.portal;
      print('Full API URL: $fullUrl');
      
      final response = await DioClient.dio.get(Endpoints.portal);
      print('API response received. Status code: ${response.statusCode}');
      
      // طباعة بيانات الاستجابة من API للتحقق
      print('Raw API Response: ${response.data}');
      
      final data = response.data as List;
      print('Cities count: ${data.length}');
      
      _cities = data
          .map((city) => CityModel.fromJson(city))
          .toList();
          
      print('Cities loaded: ${_cities.length}');
      
      emit(CitiesLoaded(_cities));
    } catch (e) {
      print('Error loading cities: $e');
      emit(CitiesError('فشل في تحميل المدن: $e'));
    }
  }

  /// إنشاء فرع جديد
  Future<void> createBranch(CreateBranchRequest request) async {
    emit(BranchLoading());
    try {
      print('Creating branch with data: ${request.toJson()}');
      
      final response = await DioClient.dio.post(
        Endpoints.createBranch,
        data: request.toJson(),
      );
      
      print('Branch created successfully. Response: ${response.data}');
      
      emit(BranchCreateSuccess('تم إنشاء الفرع بنجاح'));
    } catch (e) {
      String errorMessage = 'فشل إنشاء الفرع';
      if (e is DioException && e.response != null) {
        errorMessage += ': ${e.response?.data ?? e.message}';
      } else {
        errorMessage += ': ${e.toString()}';
      }
      print('Error creating branch: $errorMessage');
      emit(BranchCreateFailure(errorMessage));
    }
  }

  /// إعادة تعيين الحالة
  void reset() {
    emit(BranchInitial());
  }
}
