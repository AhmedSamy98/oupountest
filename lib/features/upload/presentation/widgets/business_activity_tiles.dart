import 'package:flutter/material.dart';
import '../../data/business_activity_model.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onSelected,
  });

  final CategoryModel category;
  final bool isSelected;
  final Function(CategoryModel) onSelected;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text('${category.categoryAr} / ${category.categoryEn}'),
      value: category.id,
      groupValue: isSelected ? category.id : null,
      onChanged: (_) => onSelected(category),
    );
  }
}

class ServiceTile extends StatelessWidget {
  const ServiceTile({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onSelected,
  });

  final ServiceModel service;
  final bool isSelected;
  final Function(ServiceModel, bool) onSelected;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text('${service.serviceAr} / ${service.serviceEn}'),
      value: isSelected,
      onChanged: (value) => onSelected(service, value ?? false),
    );
  }
}
