import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oupountest/core/widgets/empty_state_widget.dart';
import 'package:oupountest/core/widgets/error_state_widget.dart';
import 'package:oupountest/core/widgets/loading_widget.dart';
import 'package:oupountest/features/orders/domain/models/order_model.dart';
import 'package:oupountest/features/orders/logic/order_cubit.dart';
import 'package:oupountest/features/orders/presentation/pages/order_detail_page.dart';
import 'package:oupountest/features/orders/presentation/widgets/order_filter_dialog.dart';
import 'package:oupountest/features/orders/presentation/widgets/order_list_item.dart';

class OrderListPage extends StatefulWidget {
  static const String route = '/orders';

  const OrderListPage({Key? key}) : super(key: key);

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  // متغيرات الفلترة
  String? _selectedStatus;
  String? _selectedBranchId;
  bool _isScanned = false;
  
  // للتحكم في التمرير
  final ScrollController _scrollController = ScrollController();
  int _currentSkip = 0;
  final int _limit = 100;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    
    // تحميل الطلبات الأولية
    _loadOrders();
    
    // // إعداد مستمع للتمرير
    // _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  // // مستمع التمرير لتحميل المزيد من البيانات
  // void _scrollListener() {
  //   if (_scrollController.position.extentAfter < 200 &&
  //       !_isLoadingMore &&
  //       _hasMoreData) {
  //     _loadMoreOrders();
  //   }
  // }

  // تحميل الطلبات الأولية
  Future<void> _loadOrders() async {
    _currentSkip = 0;
    _hasMoreData = true;
    
    context.read<OrderCubit>().getOrders(
      skip: _currentSkip,
      limit: _limit,
      branchId: _selectedBranchId,
      isScanned: _isScanned ? true : null,
      status: _selectedStatus,
    );
  }

  // // تحميل المزيد من الطلبات
  // Future<void> _loadMoreOrders() async {
  //   if (_isLoadingMore) return;
  //
  //   setState(() {
  //     _isLoadingMore = true;
  //   });
  //
  //   _currentSkip += _limit;
  //
  //   try {
  //     final cubit = context.read<OrderCubit>();
  //
  //     // حالة التحميل الحالية
  //     final currentState = cubit.state;
  //     List<OrderModel> existingOrders = [];
  //
  //     if (currentState is OrdersLoaded) {
  //       existingOrders = currentState.orders;
  //     }
  //
  //     // تحميل الصفحة التالية
  //     await cubit.getOrders(
  //       skip: _currentSkip,
  //       limit: _limit,
  //       branchId: _selectedBranchId,
  //       isScanned: _isScanned ? true : null,
  //       status: _selectedStatus,
  //     );
  //
  //     // الحالة بعد التحميل
  //     final newState = cubit.state;
  //
  //     if (newState is OrdersLoaded) {
  //       // إذا لم يتم إرجاع طلبات جديدة، فقد وصلنا للنهاية
  //       if (newState.orders.length <= existingOrders.length || newState.orders.isEmpty) {
  //         setState(() {
  //           _hasMoreData = false;
  //         });
  //       }
  //     }
  //   } finally {
  //     setState(() {
  //       _isLoadingMore = false;
  //     });
  //   }
  // }
  //
  // فتح حوار الفلترة
  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => OrderFilterDialog(
        initialStatus: _selectedStatus,
        initialBranchId: _selectedBranchId,
        initialIsScanned: _isScanned,
        onApply: (status, branchId, isScanned) {
          setState(() {
            _selectedStatus = status;
            _selectedBranchId = branchId;
            _isScanned = isScanned;
          });
          _loadOrders();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات'),
        actions: [
          // زر الفلترة
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_selectedStatus != null || _selectedBranchId != null || _isScanned)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _openFilterDialog,
          ),
          // زر التحديث
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading && _currentSkip == 0) {
              return const LoadingWidget();
            }
            
            if (state is OrderError && _currentSkip == 0) {
              return ErrorStateWidget(
                message: state.message,
                onRetry: _loadOrders,
              );
            }
            
            if (state is OrdersLoaded) {
              final orders = state.orders;
              
              if (orders.isEmpty && _currentSkip == 0) {
                return const EmptyStateWidget(
                  icon: Icons.receipt_long,
                  title: 'لا توجد طلبات',
                  message: 'لم يتم العثور على أي طلبات تطابق المعايير المحددة',
                );
              }
              
              return ListView.builder(
                controller: _scrollController,
                itemCount: orders.length + (_hasMoreData ? 1 : 0),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  // إظهار مؤشر التحميل في نهاية القائمة
                  if (index == orders.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        // child: CircularProgressIndicator(),
                        child: SizedBox(),
                      ),
                    );
                  }
                  
                  final order = orders[index];
                  return OrderListItem(
                    order: order,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailPage(order: order),
                      ),
                    ),
                  );
                },
              );
            }
            
            // حالة التحميل الأولي
            return const LoadingWidget();
          },
        ),
      ),
    );
  }
}
