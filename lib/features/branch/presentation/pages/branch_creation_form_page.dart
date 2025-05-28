import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/branch_model.dart';
import '../../logic/branch_cubit.dart';
import '../../logic/branch_state.dart';
import '../widgets/form_widgets.dart';
import '../widgets/location_picker.dart';

class BranchCreationFormPage extends StatefulWidget {
  static const route = '/branch/create';
  
  final String phoneNumber;

  const BranchCreationFormPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<BranchCreationFormPage> createState() => _BranchCreationFormPageState();
}

class _BranchCreationFormPageState extends State<BranchCreationFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // مراقبي حقول الإدخال
  final _branchNameArController = TextEditingController();
  final _branchNameEnController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _descriptionEnController = TextEditingController();
  final _addressArController = TextEditingController();
  final _addressEnController = TextEditingController();
  final _contactNumberController = TextEditingController();
  
  // الإحداثيات والمدينة المختارة
  List<double>? _selectedLocation;
  int? _selectedCityId;
  
  late BranchCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<BranchCubit>();
    _loadCities();
  }

  Future<void> _loadCities() async {
    await _cubit.loadCities();
  }

  @override
  void dispose() {
    _branchNameArController.dispose();
    _branchNameEnController.dispose();
    _descriptionArController.dispose();
    _descriptionEnController.dispose();
    _addressArController.dispose();
    _addressEnController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // التحقق من اختيار مدينة
      if (_selectedCityId == null) {
        _showErrorSnackBar('الرجاء اختيار المدينة');
        return;
      }
      
      // التحقق من تحديد الموقع الجغرافي
      if (_selectedLocation == null || _selectedLocation!.length != 2) {
        _showErrorSnackBar('الرجاء تحديد الموقع الجغرافي');
        return;
      }

      // إنشاء طلب إنشاء الفرع
      final request = CreateBranchRequest(
        phoneNumber: widget.phoneNumber,
        branch: BranchModel(
          name: LocalizedText(
            ar: _branchNameArController.text,
            en: _branchNameEnController.text,
          ),
          description: LocalizedText(
            ar: _descriptionArController.text,
            en: _descriptionEnController.text,
          ),
          address: LocalizedText(
            ar: _addressArController.text,
            en: _addressEnController.text,
          ),
          contactNumber: _contactNumberController.text,
          cityId: _selectedCityId!,
          latLong: _selectedLocation!,
        ),
      );

      // إرسال الطلب
      _cubit.createBranch(request);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء فرع جديد'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<BranchCubit, BranchState>(
        listener: (context, state) {
          if (state is BranchCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // الانتقال إلى الصفحة الرئيسية بعد النجاح
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is BranchCreateFailure) {
            _showErrorSnackBar(state.error);
          } 
        },
        builder: (context, state) {
          final isLoading = state is BranchLoading;
          final cities = _cubit.cities;

          return LoadingOverlay(
            isLoading: isLoading,
            loadingText: 'جاري إنشاء الفرع...',
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionCard(
                            title: '',
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    child: Icon(
                                      Icons.store,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'إنشاء فرع جديد',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'الرجاء تعبئة النموذج التالي بالمعلومات المطلوبة',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildBranchNameSection(),
                          _buildDescriptionSection(),
                          _buildAddressSection(),
                          _buildContactSection(),
                          _buildCitySelectionSection(cities),
                          _buildLocationSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  // زر الإرسال الثابت في الأسفل
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                      child: const Text(
                        'إنشاء الفرع',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBranchNameSection() {
    return SectionCard(
      title: 'اسم الفرع',
      children: [
        LocalizedInputField(
          arController: _branchNameArController,
          enController: _branchNameEnController,
          arLabel: 'الاسم بالعربية',
          enLabel: 'الاسم بالإنجليزية',
          arValidator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال اسم الفرع بالعربية';
            }
            return null;
          },
          enValidator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال اسم الفرع بالإنجليزية';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildDescriptionSection() {
    return SectionCard(
      title: 'وصف الفرع',
      children: [
        LocalizedInputField(
          arController: _descriptionArController,
          enController: _descriptionEnController,
          arLabel: 'الوصف بالعربية',
          enLabel: 'الوصف بالإنجليزية',
          maxLines: 3,
          arValidator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال وصف الفرع بالعربية';
            }
            return null;
          },
          enValidator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال وصف الفرع بالإنجليزية';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return SectionCard(
      title: 'العنوان',
      children: [
        LocalizedInputField(
          arController: _addressArController,
          enController: _addressEnController,
          arLabel: 'العنوان بالعربية',
          enLabel: 'العنوان بالإنجليزية',
          maxLines: 2,
          arValidator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال عنوان الفرع بالعربية';
            }
            return null;
          },
          enValidator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال عنوان الفرع بالإنجليزية';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return SectionCard(
      title: 'رقم التواصل',
      children: [
        TextFormField(
          controller: _contactNumberController,
          decoration: const InputDecoration(
            labelText: 'رقم التواصل',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
            suffixIcon: Icon(Icons.star, size: 12, color: Colors.red),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال رقم التواصل';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCitySelectionSection(List<CityModel> cities) {
    return SectionCard(
      title: 'المدينة',
      children: [
        if (cities.isEmpty)
          Column(
            children: [
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Center(child: Text('جاري تحميل المدن...')),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _loadCities,
                  child: const Text('إعادة المحاولة'),
                ),
              ),
            ],
          )
        else
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'اختر المدينة',
              suffixIcon: Icon(Icons.star, size: 12, color: Colors.red),
              hintText: 'اختر المدينة من القائمة',
            ),
            value: _selectedCityId,
            items: cities.map((city) {
              return DropdownMenuItem(
                value: city.cityId,
                child: Text('${city.cityAr} - ${city.cityEn}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCityId = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'الرجاء اختيار المدينة';
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return SectionCard(
      title: 'موقع الفرع',
      children: [
        LocationPicker(
          initialLocation: _selectedLocation,
          onLocationSelected: (location) {
            setState(() {
              _selectedLocation = location;
            });
          },
        ),
      ],
    );
  }
}
