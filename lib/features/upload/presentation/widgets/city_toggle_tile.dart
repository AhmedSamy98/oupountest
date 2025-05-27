import 'package:flutter/material.dart';
import '../../data/city_model.dart';

class CityToggleTile extends StatelessWidget {
  const CityToggleTile({
    super.key,
    required this.city,
    required this.checked,
    required this.onChanged,
  });

  final CityModel city;
  final bool checked;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text('${city.nameAr} / ${city.nameEn}'),
      value: checked,
      onChanged: onChanged,
    );
  }
}
