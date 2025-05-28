import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// واجهة لاختيار الموقع الجغرافي
class LocationPicker extends StatelessWidget {
  final List<double>? initialLocation;
  final Function(List<double>) onLocationSelected;

  const LocationPicker({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    // التحقق من المنصة وتقديم الواجهة المناسبة
    if (kIsWeb) {
      // واجهة الويب
      return _WebLocationPicker(
        initialLocation: initialLocation,
        onLocationSelected: onLocationSelected,
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      // واجهة الموبايل
      return _MobileLocationPicker(
        initialLocation: initialLocation,
        onLocationSelected: onLocationSelected,
      );
    } else {
      // واجهة افتراضية لباقي المنصات
      return _DefaultLocationPicker(
        initialLocation: initialLocation,
        onLocationSelected: onLocationSelected,
      );
    }
  }
}

/// واجهة اختيار الموقع للويب
class _WebLocationPicker extends StatefulWidget {
  final List<double>? initialLocation;
  final Function(List<double>) onLocationSelected;

  const _WebLocationPicker({
    required this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<_WebLocationPicker> createState() => _WebLocationPickerState();
}

class _WebLocationPickerState extends State<_WebLocationPicker> {
  double? _latitude;
  double? _longitude;
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null && widget.initialLocation!.length == 2) {
      _latitude = widget.initialLocation![0];
      _longitude = widget.initialLocation![1];
      _latController.text = _latitude.toString();
      _lngController.text = _longitude.toString();
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _updateCoordinates() {
    if (_latitude != null && _longitude != null) {
      widget.onLocationSelected([_latitude!, _longitude!]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أدخل إحداثيات الموقع (خط العرض وخط الطول)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _latController,
                decoration: const InputDecoration(
                  labelText: 'خط العرض (Latitude)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    _latitude = double.tryParse(value);
                    if (_latitude != null && _longitude != null) {
                      _updateCoordinates();
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lngController,
                decoration: const InputDecoration(
                  labelText: 'خط الطول (Longitude)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    _longitude = double.tryParse(value);
                    if (_latitude != null && _longitude != null) {
                      _updateCoordinates();
                    }
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'نصائح: يمكنك البحث عن الموقع في خرائط جوجل والحصول على الإحداثيات منها',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        if (_latitude != null && _longitude != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              'تم تحديد الموقع: $_latitude, $_longitude',
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ],
    );
  }
}

/// واجهة اختيار الموقع للموبايل
class _MobileLocationPicker extends StatefulWidget {
  final List<double>? initialLocation;
  final Function(List<double>) onLocationSelected;

  const _MobileLocationPicker({
    required this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<_MobileLocationPicker> createState() => _MobileLocationPickerState();
}

class _MobileLocationPickerState extends State<_MobileLocationPicker> {
  double? _latitude;
  double? _longitude;
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null && widget.initialLocation!.length == 2) {
      _latitude = widget.initialLocation![0];
      _longitude = widget.initialLocation![1];
      _latController.text = _latitude.toString();
      _lngController.text = _longitude.toString();
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _updateCoordinates() {
    if (_latitude != null && _longitude != null) {
      widget.onLocationSelected([_latitude!, _longitude!]);
    }
  }

  void _getCurrentLocation() {
    // في التطبيق الحقيقي، سيتم هنا استخدام حزمة geolocator أو location
    // للحصول على الموقع الحالي. لكن هنا نضع قيم افتراضية للتوضيح فقط.
    setState(() {
      _latitude = 24.7136;  // افتراضي للرياض
      _longitude = 46.6753;
      _latController.text = _latitude.toString();
      _lngController.text = _longitude.toString();
      _updateCoordinates();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ملاحظة: هذه وظيفة تجريبية. سيتم استخدام GPS في التطبيق الحقيقي'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تحديد موقع الفرع',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.my_location),
          label: const Text('استخدام موقعي الحالي'),
          onPressed: _getCurrentLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text('أو أدخل الإحداثيات يدويًا:'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _latController,
                decoration: const InputDecoration(
                  labelText: 'خط العرض (Latitude)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    _latitude = double.tryParse(value);
                    if (_latitude != null && _longitude != null) {
                      _updateCoordinates();
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lngController,
                decoration: const InputDecoration(
                  labelText: 'خط الطول (Longitude)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    _longitude = double.tryParse(value);
                    if (_latitude != null && _longitude != null) {
                      _updateCoordinates();
                    }
                  });
                },
              ),
            ),
          ],
        ),
        if (_latitude != null && _longitude != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              'تم تحديد الموقع: $_latitude, $_longitude',
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ],
    );
  }
}

/// واجهة اختيار الموقع الافتراضية للمنصات الأخرى
class _DefaultLocationPicker extends StatefulWidget {
  final List<double>? initialLocation;
  final Function(List<double>) onLocationSelected;

  const _DefaultLocationPicker({
    required this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<_DefaultLocationPicker> createState() => _DefaultLocationPickerState();
}

class _DefaultLocationPickerState extends State<_DefaultLocationPicker> {
  double? _latitude;
  double? _longitude;
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null && widget.initialLocation!.length == 2) {
      _latitude = widget.initialLocation![0];
      _longitude = widget.initialLocation![1];
      _latController.text = _latitude.toString();
      _lngController.text = _longitude.toString();
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _updateCoordinates() {
    if (_latitude != null && _longitude != null) {
      widget.onLocationSelected([_latitude!, _longitude!]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أدخل إحداثيات الموقع (خط العرض وخط الطول)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _latController,
                decoration: const InputDecoration(
                  labelText: 'خط العرض (Latitude)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    _latitude = double.tryParse(value);
                    if (_latitude != null && _longitude != null) {
                      _updateCoordinates();
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lngController,
                decoration: const InputDecoration(
                  labelText: 'خط الطول (Longitude)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    _longitude = double.tryParse(value);
                    if (_latitude != null && _longitude != null) {
                      _updateCoordinates();
                    }
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'ملاحظة: يمكنك البحث عن الموقع في خرائط جوجل والحصول على الإحداثيات منها',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        if (_latitude != null && _longitude != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              'تم تحديد الموقع: $_latitude, $_longitude',
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ],
    );
  }
}
