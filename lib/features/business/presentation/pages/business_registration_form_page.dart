import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/business_model.dart';
import '../../logic/business_registration_cubit.dart';
import '../../logic/business_registration_state.dart';
import '../widgets/form_widgets.dart';

class BusinessRegistrationFormPage extends StatefulWidget {
  static const route = '/business/register';
  
  final String phoneNumber;
  final String email;

  const BusinessRegistrationFormPage({
    super.key,
    required this.phoneNumber,
    required this.email,
  });

  @override
  State<BusinessRegistrationFormPage> createState() =>
      _BusinessRegistrationFormPageState();
}

class _BusinessRegistrationFormPageState
    extends State<BusinessRegistrationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameArController = TextEditingController();
  final _businessNameEnController = TextEditingController();
  final _crNumberController = TextEditingController();
  final _vatNumberController = TextEditingController();
  final _bioArController = TextEditingController();
  final _bioEnController = TextEditingController();
  final _cancellationArController = TextEditingController();
  final _cancellationEnController = TextEditingController();
  
  // مفتاح خاص للتحديث القسري للواجهة عند الحاجة
  final GlobalKey<State> _categoryKey = GlobalKey<State>();
  final GlobalKey<State> _serviceKey = GlobalKey<State>();
  
  late BusinessRegistrationCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<BusinessRegistrationCubit>();
    _loadBusinessActivities();
  }

  Future<void> _loadBusinessActivities() async {
    await _cubit.loadBusinessActivities();
  }

  @override
  void dispose() {
    _businessNameArController.dispose();
    _businessNameEnController.dispose();
    _crNumberController.dispose();
    _vatNumberController.dispose();
    _bioArController.dispose();
    _bioEnController.dispose();
    _cancellationArController.dispose();
    _cancellationEnController.dispose();
    super.dispose();
  }

  // تبديل حالة الفئة مع تحديث الواجهة مباشرة
  void _toggleCategory(String categoryId) {
    _cubit.toggleCategory(categoryId);
    // تحديث قسم الفئات بشكل قسري
    setState(() {});
  }

  // تبديل حالة الخدمة مع تحديث الواجهة مباشرة
  void _toggleService(String serviceId) {
    _cubit.toggleService(serviceId);
    // تحديث قسم الخدمات بشكل قسري
    setState(() {});
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Check if business activity is selected
      if (_cubit.selectedActivity == null) {
        _showErrorSnackBar('الرجاء اختيار نشاط تجاري');
        return;
      }
      
      // Check if at least one category is selected
      if (_cubit.selectedCategories.isEmpty) {
        _showErrorSnackBar('الرجاء اختيار فئة واحدة على الأقل');
        return;
      }
      
      // Check if at least one service is selected
      if (_cubit.selectedServices.isEmpty) {
        _showErrorSnackBar('الرجاء اختيار خدمة واحدة على الأقل');
        return;
      }

      // Create the request
      final request = RegisterBusinessRequest(
        phoneNumber: widget.phoneNumber,
        email: widget.email,
        business: BusinessModel(
          businessName: BusinessName(
            ar: _businessNameArController.text,
            en: _businessNameEnController.text,
          ),
          crNumber: _crNumberController.text,
          vatNumber: _vatNumberController.text,
          businessActivity: _cubit.selectedActivity!.id,
          offeredCategory: _cubit.selectedCategories,
          offeredServices: _cubit.selectedServices,
          bio: LocalizedText(
            ar: _bioArController.text,
            en: _bioEnController.text,
          ),
          cancellationPolicy: LocalizedText(
            ar: _cancellationArController.text,
            en: _cancellationEnController.text,
          ),
        ),
      );

      // Submit the registration
      _cubit.registerBusiness(request);
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
        title: const Text('تسجيل نشاط تجاري'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<BusinessRegistrationCubit, BusinessRegistrationState>(
        listener: (context, state) {
          if (state is BusinessRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back to home after success
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is BusinessRegistrationFailure) {
            _showErrorSnackBar(state.error);
          } else if (state is BusinessActivitySelected) {
            // تحديث كل أقسام الواجهة عند تغيير النشاط التجاري
            setState(() {
              print('Updating UI after BusinessActivitySelected state change');
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is BusinessRegistrationLoading;

          return LoadingOverlay(
            isLoading: isLoading,
            loadingText: 'جاري تسجيل النشاط التجاري...',
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
                                      Icons.business,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'تسجيل نشاط تجاري جديد',
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
                          _buildBusinessNameSection(),
                          _buildCrAndVatSection(),
                          _buildBusinessActivitySection(),
                          _buildCategoriesSection(),
                          _buildServicesSection(),
                          _buildBioSection(),
                          _buildCancellationPolicySection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  // Fixed submit button at the bottom
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
                        'تسجيل النشاط التجاري',
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

  Widget _buildBusinessNameSection() {
    return SectionCard(
      title: 'اسم النشاط التجاري',
      children: [
        LocalizedInputField(
          arController: _businessNameArController,
          enController: _businessNameEnController,
          arLabel: 'الاسم بالعربية',
          enLabel: 'الاسم بالإنجليزية',
          arValidator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال الاسم بالعربية';
            }
            return null;
          },
          enValidator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال الاسم بالإنجليزية';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildCrAndVatSection() {
    return SectionCard(
      title: 'معلومات السجل التجاري',
      children: [
        TextFormField(
          controller: _crNumberController,
          decoration: const InputDecoration(
            labelText: 'رقم السجل التجاري',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.star, size: 12, color: Colors.red),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال رقم السجل التجاري';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _vatNumberController,
          decoration: const InputDecoration(
            labelText: 'رقم ضريبة القيمة المضافة',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.star, size: 12, color: Colors.red),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال رقم ضريبة القيمة المضافة';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildBusinessActivitySection() {
    return BlocBuilder<BusinessRegistrationCubit, BusinessRegistrationState>(
      builder: (context, state) {
        if (state is BusinessActivitiesLoading) {
          return const SectionCard(
            title: 'نشاط العمل',
            children: [
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 8),
              Center(child: Text('جاري تحميل أنشطة العمل...')),
            ],
          );
        }
        
        if (state is BusinessActivitiesError) {
          return SectionCard(
            title: 'نشاط العمل',
            children: [
              Center(child: Icon(Icons.error, color: Colors.red, size: 40)),
              SizedBox(height: 8),
              Center(child: Text(state.error, style: TextStyle(color: Colors.red))),
              SizedBox(height: 8),
              Center(
                child: ElevatedButton(
                  onPressed: () => _loadBusinessActivities(),
                  child: const Text('إعادة المحاولة'),
                ),
              ),
            ],
          );
        }

        final activities = _cubit.businessActivities;
        final selectedActivity = _cubit.selectedActivity;
        
        print('Business Activities for dropdown: ${activities.length}');

        return SectionCard(
          title: 'نشاط العمل',
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'اختر نشاط العمل',
                suffixIcon: Icon(Icons.star, size: 12, color: Colors.red),
                hintText: 'اختر نشاط العمل من القائمة',
              ),
              value: selectedActivity?.id,
              items: activities.isEmpty
                ? [const DropdownMenuItem(value: '', child: Text('لا توجد أنشطة متاحة'))]
                : activities.map((activity) {
                    return DropdownMenuItem(
                      value: activity.id,
                      child: Text('${activity.nameAr} - ${activity.nameEn}'),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _cubit.setSelectedBusinessActivity(value);
                  // تحديث جميع أقسام الصفحة
                  setState(() {});
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء اختيار نشاط العمل';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildCategoriesSection() {
    return StatefulBuilder(
      key: _categoryKey,
      builder: (context, setCategoryState) {
        final selectedActivity = _cubit.selectedActivity;
        final selectedCategories = _cubit.selectedCategories;
        final hasActivityBeenSelected = _cubit.hasActivityBeenSelected;
        
        print('Building categories section, selected categories: ${selectedCategories.length}');

        // إظهار محتوى توضيحي إذا لم يكن هناك نشاط تجاري محدد
        if (selectedActivity == null || !hasActivityBeenSelected) {
          return SectionCard(
            title: 'الفئات',
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'يرجى اختيار نشاط تجاري أولاً لعرض الفئات المتاحة',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),
            ],
          );
        }

        print('Rendering categories for activity: ${selectedActivity.nameAr}');
        print('Categories available: ${selectedActivity.categories.length}');

        return SectionCard(
          title: 'الفئات - ${selectedActivity.nameAr}',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            if (selectedActivity.categories.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'لا توجد فئات متاحة لهذا النشاط التجاري',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              )
            else
              ...selectedActivity.categories.map((category) {
                final isSelected = selectedCategories.contains(category.id);
                
                return Card(
                  elevation: 0,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      print('Category tapped: ${category.categoryAr}');
                      // استخدام الدالة الوسيطة للتبديل وتحديث الواجهة
                      _toggleCategory(category.id);
                      setCategoryState(() {}); // تحديث القائمة محلياً
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Checkbox explicitly separate from the title for better touch response
                          Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              print('Category checkbox changed: ${category.categoryAr}');
                              // استخدام الدالة الوسيطة للتبديل وتحديث الواجهة
                              _toggleCategory(category.id);
                              setCategoryState(() {}); // تحديث القائمة محلياً
                            },
                          ),
                          const SizedBox(width: 8),
                          if (category.icon.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Icon(Icons.category, 
                                color: isSelected ? Theme.of(context).colorScheme.primary : null),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.categoryAr,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  category.categoryEn,
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            if (selectedCategories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'الفئات المختارة: ${selectedCategories.length}', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildServicesSection() {
    return StatefulBuilder(
      key: _serviceKey,
      builder: (context, setServiceState) {
        final availableServices = _cubit.getAvailableServices();
        final selectedServices = _cubit.selectedServices;
        final selectedCategories = _cubit.selectedCategories;

        print('Building services section, selected services: ${selectedServices.length}');
        print('Available services count: ${availableServices.length}');
        print('Selected categories count: ${selectedCategories.length}');

        // For any state, if no categories are selected, show the prompt
        if (selectedCategories.isEmpty) {
          return SectionCard(
            title: 'الخدمات المقدمة',
            padding: const EdgeInsets.all(16),
            children: const [
              Center(
                child: Text(
                  'يرجى اختيار فئة واحدة على الأقل أولاً', 
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),
            ],
          );
        }

        if (availableServices.isEmpty) {
          return SectionCard(
            title: 'الخدمات المقدمة',
            padding: const EdgeInsets.all(16),
            children: const [
              Center(
                child: Text(
                  'لا توجد خدمات متاحة للفئات المختارة', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
            ],
          );
        }
        
        return SectionCard(
          title: 'الخدمات المقدمة',
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Text('اختر الخدمات التي ترغب في تقديمها:', style: TextStyle(fontStyle: FontStyle.italic)),
                  const Spacer(),
                  Text(
                    'الفئات المختارة: ${selectedCategories.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: availableServices.length,
              itemBuilder: (context, index) {
                final service = availableServices[index];
                final isSelected = selectedServices.contains(service.id);
                
                return Card(
                  elevation: 0,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  child: InkWell(
                    onTap: () {
                      print('Service tapped: ${service.serviceAr}');
                      // استخدام الدالة الوسيطة للتبديل وتحديث الواجهة
                      _toggleService(service.id);
                      setServiceState(() {}); // تحديث القائمة محلياً
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              print('Service checkbox changed: ${service.serviceAr}');
                              // استخدام الدالة الوسيطة للتبديل وتحديث الواجهة
                              _toggleService(service.id);
                              setServiceState(() {}); // تحديث القائمة محلياً
                            },
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  service.serviceAr,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  service.serviceEn,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (selectedServices.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              Text(
                'الخدمات المختارة: ${selectedServices.length}', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
  
  Widget _buildBioSection() {
    return SectionCard(
      title: 'نبذة تعريفية',
      children: [
        LocalizedInputField(
          arController: _bioArController,
          enController: _bioEnController,
          arLabel: 'النبذة بالعربية',
          enLabel: 'النبذة بالإنجليزية',
          maxLines: 3,
        ),
      ],
    );
  }
  
  Widget _buildCancellationPolicySection() {
    return SectionCard(
      title: 'سياسة الإلغاء',
      children: [
        LocalizedInputField(
          arController: _cancellationArController,
          enController: _cancellationEnController,
          arLabel: 'سياسة الإلغاء بالعربية',
          enLabel: 'سياسة الإلغاء بالإنجليزية',
          maxLines: 3,
        ),
      ],
    );
  }
}
