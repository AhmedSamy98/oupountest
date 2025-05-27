import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oupountest/core/api/dio_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../data/branch_model.dart';

//
//  ── States ────────────────────────────────────────────────────────────────────
//
abstract class BranchFetchState {}
class BranchInitial extends BranchFetchState {}
class BranchLoading extends BranchFetchState {}
class BranchLoaded extends BranchFetchState {
  final List<BranchModel> branches;
  BranchLoaded(this.branches);
}
class BranchError extends BranchFetchState {
  final String message;
  BranchError(this.message);
}

//
//  ── Cubit ─────────────────────────────────────────────────────────────────────
//
class BranchFetchCubit extends Cubit<BranchFetchState> {
  BranchFetchCubit() : super(BranchInitial());

  /// تحمــيل الفروع بناءً على رقم الهاتف.  
  /// يُعيد القائمة (فارغة إذا فشل) بحيث نستطيع استخدامها مباشرة.
  Future<List<BranchModel>> fetch(String phone) async {
    emit(BranchLoading());
    try {
      final token = dotenv.env['TOKEN'] ?? '';
      final res = await DioClient.dio.get(
        '/admin/get_businesses',
        queryParameters: {
          'phone_number': phone,
          'limit': 10,
          'skip': 0,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('► GET‑Branches response: ${res.data}');
      final businesses = res.data['businesses'] as List?;
      if (res.statusCode == 200 && businesses != null && businesses.isNotEmpty) {
        final branchesJson =
            businesses.first['business']['branches'] as List<dynamic>;
        final branches =
            branchesJson.map((e) => BranchModel.fromJson(e)).toList();
        emit(BranchLoaded(branches));
        return branches;
      } else {
        emit(BranchError('لا تملك صلاحيات لإضافة عرض.'));
        return [];
      }
    } catch (e) {
      print('► GET‑Branches error: $e');
      emit(BranchError('خطأ في الاتصال: $e'));
      return [];
    }
  }
}
