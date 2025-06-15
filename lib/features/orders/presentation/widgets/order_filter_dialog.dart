import 'package:flutter/material.dart';

class OrderFilterDialog extends StatefulWidget {
  final String? initialStatus;
  final String? initialBranchId;
  final bool initialIsScanned;
  final Function(String?, String?, bool) onApply;

  const OrderFilterDialog({
    Key? key,
    this.initialStatus,
    this.initialBranchId,
    this.initialIsScanned = false,
    required this.onApply,
  }) : super(key: key);

  @override
  State<OrderFilterDialog> createState() => _OrderFilterDialogState();
}

class _OrderFilterDialogState extends State<OrderFilterDialog> {
  late String? _selectedStatus;
  late String? _branchId;
  late bool _isScanned;
  late final TextEditingController _branchController;

  // حالات الطلبات المتاحة
  final List<Map<String, String>> _statusOptions = [
    {'value': 'pending', 'label': 'قيد الانتظار'},
    {'value': 'in_progress', 'label': 'قيد التنفيذ'},
    {'value': 'approved', 'label': 'معتمد'},
    {'value': 'completed', 'label': 'مكتمل'},
    {'value': 'cancelled', 'label': 'ملغي'},
    {'value': 'expired', 'label': 'منتهي الصلاحية'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _branchId = widget.initialBranchId;
    _isScanned = widget.initialIsScanned;
    _branchController = TextEditingController(text: _branchId);
  }

  @override
  void dispose() {
    _branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.filter_list, size: 24),
          const SizedBox(width: 8),
          const Text('تصفية الطلبات'),
          const Spacer(),
          // زر إعادة التعيين
          TextButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('إعادة تعيين'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _branchId = null;
                _isScanned = false;
                _branchController.clear();
              });
            },
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حالة الطلب
            const Text(
              'حالة الطلب',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statusOptions.map((status) {
                final isSelected = status['value'] == _selectedStatus;
                return FilterChip(
                  label: Text(status['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status['value'] : null;
                    });
                  },
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // معرف الفرع
            const Text(
              'معرف الفرع',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _branchController,
              decoration: InputDecoration(
                hintText: 'أدخل معرف الفرع',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                _branchId = value.isEmpty ? null : value;
              },
            ),
            
            const SizedBox(height: 16),
            
            // مسح الطلب
            SwitchListTile(
              title: const Text('تم المسح فقط'),
              subtitle: const Text('عرض الطلبات التي تم مسحها'),
              value: _isScanned,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _isScanned = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('إلغاء'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('تطبيق'),
          onPressed: () => widget.onApply(
            _selectedStatus,
            _branchId,
            _isScanned,
          ),
        ),
      ],
    );
  }
}
