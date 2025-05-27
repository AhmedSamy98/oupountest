import 'package:flutter/material.dart';
import 'dart:async'; // Add StreamSubscription import

import '../../data/branch_model.dart';
import '../../data/city_model.dart';
import '../../data/business_activity_model.dart';
import '../../logic/upload_offer_cubit.dart';
import '../widgets/branch_toggle_tile.dart';
import '../widgets/city_toggle_tile.dart';
import '../widgets/business_activity_tiles.dart';

class OfferFormPage extends StatefulWidget {
  const OfferFormPage({
    super.key,
    required this.phoneNumber,
    required this.branches,
  });

  final String phoneNumber;
  final List<BranchModel> branches;

  @override
  State<OfferFormPage> createState() => _OfferFormPageState();
}

class _OfferFormPageState extends State<OfferFormPage> {
  // اختيار الفروع
  final Set<String> _selectedBranchIds = {};
    // اختيار المدن
  final Set<int> _selectedCityIds = {};
  List<CityModel> _cities = [];
  bool _isLoadingCities = true;  // أنشطة الأعمال والفئات والخدمات
  List<BusinessActivityModel> _businessActivities = [];
  List<CategoryModel> _allCategories = [];
  bool _isLoadingBusinessActivities = true;
  CategoryModel? _selectedCategory;
  Set<String> _selectedServiceIds = {}; // تخزين معرفات الخدمات المختارة
  List<Map<String, dynamic>> _serviceOptions = []; // تخزين خيارات الخدمات مع بياناتها
  bool _isLoading = false; // متغير لتتبع حالة التحميل

  // حقول إدخال بيانات الخيار
  final TextEditingController _optionTitleArController = TextEditingController();
  final TextEditingController _optionTitleEnController = TextEditingController();
  final TextEditingController _regularPriceController = TextEditingController();
  final TextEditingController _oupounPriceController = TextEditingController();

  // 14 حقل إدخال (7×2)
  final _controllers = List.generate(14, (_) => TextEditingController());
  final _cubit = UploadOfferCubit();
  StreamSubscription? _cubitSubscription;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _validUntilController = TextEditingController();
  String _validUnit = 'months';  // لانتقاء months أو year
  String _offerLabel = 'all';    // لاختيار all, men, women
  bool _requireBooking = true;
  final TextEditingController _phoneNumber4BookingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadCities();
    _loadBusinessActivities();
    
    // Listen to cubit state changes
    _cubitSubscription = _cubit.stream.listen((state) {
      if (state is UploadSuccess) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('تم بنجاح'),
                content: const Text('تم إنشاء العرض بنجاح!'),
                backgroundColor: Colors.white,
                icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
                actions: <Widget>[
                  TextButton(
                    child: const Text('موافق'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Return to the home page after user acknowledges
                      // Navigator.of(context).popUntil(ModalRoute.withName('/'));
                    },
                  ),
                ],
              );
            },
          );
        }
      } else if (state is UploadError) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          // Show error dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('خطأ'),
                content: Text(state.message),
                backgroundColor: Colors.white,
                icon: const Icon(Icons.error, color: Colors.red, size: 64),
                actions: <Widget>[
                  TextButton(
                    child: const Text('موافق'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    });
  }

  Future<void> _loadCities() async {
    setState(() {
      _isLoadingCities = true;
    });
    
    try {
      final cities = await _cubit.fetchCities();
      setState(() {
        _cities = cities;
        _isLoadingCities = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCities = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل المدن: $e')),
        );
      }
    }
  }

  Future<void> _loadBusinessActivities() async {
    setState(() {
      _isLoadingBusinessActivities = true;
    });
    
    try {
      final businessActivities = await _cubit.fetchBusinessActivities();
      setState(() {
        _businessActivities = businessActivities;
        
        // استخراج جميع الفئات من جميع الأنشطة التجارية
        _allCategories = [];
        for (var activity in businessActivities) {
          _allCategories.addAll(activity.categories);
        }
        
        _isLoadingBusinessActivities = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBusinessActivities = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل الأنشطة التجارية: $e')),
        );
      }
    }
  }  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    
    // التخلص من وحدات التحكم لخيارات الخدمات
    for (final option in _serviceOptions) {
      final controllers = option['controllers'] as Map<String, TextEditingController>;
      controllers.values.forEach((controller) => controller.dispose());
    }
    
    _optionTitleArController.dispose();
    _optionTitleEnController.dispose();
    _regularPriceController.dispose();
    _oupounPriceController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _validUntilController.dispose();
    _phoneNumber4BookingController.dispose();
    _cubitSubscription?.cancel(); // Cancel the subscription
    _cubit.close();
    super.dispose();
  }


// تابع إرسال البيانات
  Future<void> _submit() async {
    if (_selectedBranchIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر فرعًا واحدًا على الأقل')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار فئة')),
      );
      return;
    }

    if (!_validateOptionsData()) {
      return;
    }

    // تحقق مما إذا تم اختيار require_booking
    String? phoneNumberForBooking;
    if (_requireBooking) {
      phoneNumberForBooking = _phoneNumber4BookingController.text;
    }    
    
    // إعداد قائمة خيارات الخدمات
    final options = _serviceOptions.map((option) {
      final controllers = option['controllers'] as Map<String, TextEditingController>;
      return {
        'service_id': option['service_id'],
        'option_title': {
          'ar': controllers['option_title_ar']!.text,
          'en': controllers['option_title_en']!.text,
        },
        'regular_price': double.parse(controllers['regular_price']!.text),
        'oupoun_price': double.parse(controllers['oupoun_price']!.text),
      };
    }).toList();
    
    // بناء الجسم النهائي حسب الحقول الجديدة
    final body = {
      'branch_id': _selectedBranchIds.toList(),
      'phone_number': widget.phoneNumber,
      'offer_title': {
        'ar': _controllers[0].text,
        'en': _controllers[1].text,
      },
      'description': {
        'ar': _controllers[2].text,
        'en': _controllers[3].text,
      },
      'hilghlights': {
        'ar': _controllers[4].text,
        'en': _controllers[5].text,
      },
      'terms_and_conditions': {
        'ar': _controllers[6].text,
        'en': _controllers[7].text,
      },
      'about_offer': {
        'ar': _controllers[8].text,
        'en': _controllers[9].text,
      },
      'option_description': {
        'ar': _controllers[10].text,
        'en': _controllers[11].text,
      },
      'cancellation_policy': {
        'ar': _controllers[12].text,
        'en': _controllers[13].text,
      },
      // الحقول الجديدة
      'start_date': _startDateController.text,
      'end_date': _endDateController.text,
      'valid_until': int.tryParse(_validUntilController.text) ?? 0,
      'valid_unit': _validUnit,
      'offer_label': _offerLabel,
      'max_no_orders': 0,  // تأكد من أن هذا الرقم يتم تحديده كما هو مطلوب
      'require_booking': _requireBooking,
      if (_requireBooking) 'phone_number_4booking': phoneNumberForBooking,
      // إضافة المدن المختارة
      'city_id': _selectedCityIds.toList(),
      // إضافة الفئة والخدمة المختارة
      'category_id': _selectedCategory!.id,
      'options': options,
    };    // عرض مؤشر التحميل
    setState(() {
      _isLoading = true;
    });
    
    // Submit the form data to the cubit
    // The listener in initState will handle the response and show appropriate dialogs
    try {
      await _cubit.upload(body);
    } catch (e) {
      // Handle any exceptions that might occur before reaching the cubit
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  // عنصر حقليْ الإدخال (ar/en) تحت عنوان القسم
  Widget _pair(String title, int indexAr, int indexEn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        TextField(
          controller: _controllers[indexAr],
          decoration: const InputDecoration(labelText: 'ar', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _controllers[indexEn],
          decoration: const InputDecoration(labelText: 'en', border: OutlineInputBorder()),
        ),
      ],
    );
  }
  // طريقة لمعالجة اختيار فئة
  void _handleCategorySelection(CategoryModel category) {
    setState(() {
      _selectedCategory = category;
      _selectedServiceIds.clear(); // إعادة تعيين الخدمات المحددة عند تغيير الفئة
      _serviceOptions.clear(); // إعادة تعيين خيارات الخدمات
    });
  }

  // طريقة لمعالجة اختيار خدمة
  void _handleServiceSelection(ServiceModel service, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedServiceIds.add(service.id);
        // إضافة خيار فارغ للخدمة المختارة
        if (!_serviceOptions.any((option) => option['service_id'] == service.id)) {
          _serviceOptions.add({
            'service_id': service.id,
            'service_ar': service.serviceAr,
            'service_en': service.serviceEn,
            'controllers': {
              'option_title_ar': TextEditingController(),
              'option_title_en': TextEditingController(),
              'regular_price': TextEditingController(),
              'oupoun_price': TextEditingController(),
            }
          });
        }
      } else {
        _selectedServiceIds.remove(service.id);
        // إزالة الخيار للخدمة التي تم إلغاء تحديدها
        _serviceOptions.removeWhere((option) => option['service_id'] == service.id);
      }
    });
  }

  // طريقة للتحقق من صحة بيانات الخيارات
  bool _validateOptionsData() {
    if (_selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار خدمة واحدة على الأقل')),
      );
      return false;
    }
    
    for (final option in _serviceOptions) {
      final controllers = option['controllers'] as Map<String, TextEditingController>;
      final optionTitleAr = controllers['option_title_ar']!.text;
      final optionTitleEn = controllers['option_title_en']!.text;
      final regularPrice = controllers['regular_price']!.text;
      final oupounPrice = controllers['oupoun_price']!.text;
      
      if (optionTitleAr.isEmpty || optionTitleEn.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يرجى إدخال عنوان الخيار لـ ${option['service_ar']} بالعربية والإنجليزية')),
        );
        return false;
      }
      
      if (regularPrice.isEmpty || oupounPrice.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يرجى إدخال السعر العادي وسعر أوبون لـ ${option['service_ar']}')),
        );
        return false;
      }
      
      if (double.tryParse(regularPrice) == null || double.tryParse(oupounPrice) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يرجى إدخال أرقام صحيحة للأسعار لـ ${option['service_ar']}')),
        );
        return false;
      }
    }
    
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء عرض جديد')),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // رقم الهاتف (غير قابل للتعديل)
              TextField(
                readOnly: true,
                controller: TextEditingController(text: widget.phoneNumber),
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // توجّل ليست لاختيار الفروع
              const Text('Branches', style: TextStyle(fontWeight: FontWeight.bold)),
              ...widget.branches.map(
                (b) => BranchToggleTile(
                  branch: b,
                  checked: _selectedBranchIds.contains(b.id),
                  onChanged: (v) => setState(() {
                    v == true ? _selectedBranchIds.add(b.id) : _selectedBranchIds.remove(b.id);
                  }),
                ),
              ),
              const Divider(height: 32),

              // الحقول الـ 14
              _pair('Offer title', 0, 1),
              _pair('Description', 2, 3),
              _pair('Highlights', 4, 5),
              _pair('Terms & Conditions', 6, 7),
              _pair('About Offer', 8, 9),
              _pair('Option Description', 10, 11),
              _pair('Cancellation Policy', 12, 13),

              const SizedBox(height: 16),

              _buildDateField('Start Date', _startDateController),
              const SizedBox(height: 16),
              _buildDateField('End Date', _endDateController),
              const SizedBox(height: 16),
              _buildTextField('Valid Until', _validUntilController),
              const SizedBox(height: 16),

              // توجّل ليست (Valid Unit)
              DropdownButton<String>(
                value: _validUnit,
                onChanged: (value) {
                  setState(() {
                    _validUnit = value!;
                  });
                },
                items: ['months', 'years'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // توجّل ليست (Offer Label)
              DropdownButton<String>(
                value: _offerLabel,
                onChanged: (value) {
                  setState(() {
                    _offerLabel = value!;
                  });
                },
                items: ['all', 'men', 'women'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // حقل require_booking
              SwitchListTile(
                title: const Text('Require Booking'),
                value: _requireBooking,
                onChanged: (bool value) {
                  setState(() {
                    _requireBooking = value;
                  });
                },
              ),
              const SizedBox(height: 16),              // حقل phone_number_4booking
              if (_requireBooking)
                _buildTextField('Phone Number for Booking', _phoneNumber4BookingController),
                
              const SizedBox(height: 24),
                // قسم اختيار المدن
              const Text('Cities', style: TextStyle(fontWeight: FontWeight.bold)),
              if (_isLoadingCities)
                const Center(child: CircularProgressIndicator())
              else if (_cities.isEmpty)
                const Text('لا توجد مدن متاحة')
              else
                ..._cities.map(
                  (city) => CityToggleTile(
                    city: city,
                    checked: _selectedCityIds.contains(city.id),
                    onChanged: (v) => setState(() {
                      v == true ? _selectedCityIds.add(city.id) : _selectedCityIds.remove(city.id);
                    }),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // قسم اختيار الفئات والخدمات
              const Text('Business Categories', style: TextStyle(fontWeight: FontWeight.bold)),
              if (_isLoadingBusinessActivities)
                const Center(child: CircularProgressIndicator())
              else if (_allCategories.isEmpty)
                const Text('لا توجد فئات متاحة')
              else
                ..._allCategories.map(
                  (category) => CategoryTile(
                    category: category,
                    isSelected: _selectedCategory?.id == category.id,
                    onSelected: _handleCategorySelection,
                  ),
                ),
              
              const SizedBox(height: 16),              // عرض الخدمات المتاحة للفئة المختارة
              if (_selectedCategory != null) ...[
                const Text('Services', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._selectedCategory!.services.map(
                  (service) => ServiceTile(
                    service: service,
                    isSelected: _selectedServiceIds.contains(service.id),
                    onSelected: _handleServiceSelection,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // عرض حقول إدخال البيانات لكل خدمة محددة
                if (_selectedServiceIds.isNotEmpty) ...[
                  for (final option in _serviceOptions) 
                    _buildServiceOptionFields(option),                ],
              ],
              const SizedBox(height: 24),
              
              // Submit button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit, // Disable during loading
                icon: const Icon(Icons.cloud_upload),
                label: const Text('رفع العرض'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),],
              ),
            ),
          ),
          
          // Full-screen loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 5.0,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'جاري رفع العرض...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

    // بناء حقل النص
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  // بناء حقل التاريخ مع استخدام DatePicker وتنسيق التاريخ ليكون بهذا الشكل yyyy-MM-dd
  Widget _buildDateField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      onTap: () async {
        final DateTime? date = await showDatePicker(
          context: context,
          initialDate: controller.text.isNotEmpty
              ? DateTime.tryParse(controller.text) ?? DateTime.now()
              : DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          // تنسيق التاريخ ليكون بهذا الشكل yyyy-MM-dd
          final String formattedDate =
              "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          controller.text = formattedDate;
        }
      },
      keyboardType: TextInputType.datetime,
    );
  }

  // بناء حقول إدخال بيانات الخدمة
  Widget _buildServiceOptionFields(Map<String, dynamic> option) {
    final controllers = option['controllers'] as Map<String, TextEditingController>;
    final serviceAr = option['service_ar'];
    final serviceEn = option['service_en'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Option Details - $serviceAr / $serviceEn',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          
          // حقل عنوان الخيار بالعربية
          TextField(
            controller: controllers['option_title_ar']!,
            decoration: const InputDecoration(
              labelText: 'Option Title (Arabic)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          
          // حقل عنوان الخيار بالإنجليزية
          TextField(
            controller: controllers['option_title_en']!,
            decoration: const InputDecoration(
              labelText: 'Option Title (English)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          
          // حقل السعر العادي
          TextField(
            controller: controllers['regular_price']!,
            decoration: const InputDecoration(
              labelText: 'Regular Price',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          
          // حقل سعر أوبون
          TextField(
            controller: controllers['oupoun_price']!,
            decoration: const InputDecoration(
              labelText: 'Oupoun Price',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}