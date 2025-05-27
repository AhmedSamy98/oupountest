import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/offer_cubit.dart';
import '../../logic/offer_state.dart';
import '../widgets/offer_table.dart';

class OfferListPage extends StatefulWidget {
  static const route = '/list';
  const OfferListPage({super.key});

  @override
  State<OfferListPage> createState() => _OfferListPageState();
}

class _OfferListPageState extends State<OfferListPage> {
  @override
  void initState() {
    super.initState();
    context.read<OfferCubit>().load();   // طلب البيانات مرة واحدة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جميع العروض'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث القائمة',
            onPressed: () {
              context.read<OfferCubit>().load();
            },
          ),
        ],
      ),
      body: BlocConsumer<OfferCubit, OfferState>(
        listener: (context, state) {
          if (state is OfferDeleted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حذف العرض بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OfferLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل العروض...'),
                ],
              ),
            );
          }
          
          if (state is OfferError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.msg),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<OfferCubit>().load(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          
          if (state is OfferLoaded) {
            if (state.list.isEmpty) {
              return const Center(
                child: Text('لا توجد عروض متاحة'),
              );
            }
            return OfferTable(state.list);
          }
          
          if (state is OfferDeleted) {
            // Handle the next state
            final nextState = state.nextState;
            if (nextState is OfferLoaded) {
              return OfferTable(nextState.list);
            }
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}


