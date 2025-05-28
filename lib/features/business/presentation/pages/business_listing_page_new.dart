import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/dio_client.dart';
import '../../../../core/api/endpoints.dart';

class BusinessListingPage extends StatefulWidget {
  static const String route = '/business/listing';

  const BusinessListingPage({Key? key}) : super(key: key);

  @override
  State<BusinessListingPage> createState() => _BusinessListingPageState();
}

class _BusinessListingPageState extends State<BusinessListingPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _businesses = [];
  List<dynamic> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch businesses
      final Response businessResponse = await DioClient.dio.get(
        Endpoints.getBusinesses,
      );

      // Fetch business activities to get activity names, categories and services
      final Response activitiesResponse = await DioClient.dio.get(
        Endpoints.servicesActivity,
      );

      setState(() {
        _businesses = (businessResponse.data['businesses'] as List?) ?? [];
        _activities = (activitiesResponse.data as List?) ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الأنشطة التجارية | Business Listings'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('إعادة المحاولة | Retry'),
            ),
          ],
        ),
      );
    }

    if (_businesses.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أنشطة تجارية | No businesses found',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _businesses.length,
      itemBuilder: (context, index) {
        final business = _businesses[index];
        return _buildBusinessCard(context, business);
      },
    );
  }

  Widget _buildBusinessCard(BuildContext context, dynamic businessItem) {
    final phoneNumber = businessItem['phone_number'] ?? '';
    final email = businessItem['email'] ?? '';
    final business = businessItem['business'];

    if (business == null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: ListTile(
          title: Text(
            'Phone: $phoneNumber',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Email: ${email.isEmpty ? 'N/A' : email}'),
          trailing: const Icon(Icons.business_outlined),
        ),
      );
    }

    final businessName = business['business_name'] ?? {};
    final nameAr = businessName['ar'] ?? 'غير متاح';
    final nameEn = businessName['en'] ?? 'Not available';
    
    final crNumber = business['cr_number'] ?? 'N/A';
    final vatNumber = business['vat_number'] ?? 'N/A';
    final activityId = business['business_activity'] ?? '';
    
    final categories = (business['offered_category'] as List?) ?? [];
    final services = (business['offered_services'] as List?) ?? [];
    
    final bio = business['bio'] ?? {};
    final bioAr = bio['ar'] ?? 'غير متاح';
    final bioEn = bio['en'] ?? 'Not available';
    
    final policy = business['cancellation_policy'] ?? {};
    final policyAr = policy['ar'] ?? 'غير متاح';
    final policyEn = policy['en'] ?? 'Not available';
    
    final branches = (business['branches'] as List?) ?? [];
    final staff = (business['staff'] as List?) ?? [];
    final addedBy = business['added_by'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nameAr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              nameEn,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Contact: $phoneNumber | $email',
            style: const TextStyle(fontSize: 13),
          ),
        ),
        children: [
          _buildInfoSection(
            title: 'معلومات الشركة | Business Information',
            children: [
              _buildInfoItem(
                'رقم السجل التجاري | CR Number',
                crNumber.toString(),
              ),
              _buildInfoItem(
                'رقم ضريبة القيمة المضافة | VAT Number',
                vatNumber.toString(),
              ),
              _buildInfoItem(
                'النشاط التجاري | Business Activity',
                _getActivityName(activityId),
              ),
            ],
          ),
          _buildInfoSection(
            title: 'الفئات المقدمة | Offered Categories',
            children: categories.isNotEmpty
                ? categories
                    .map<Widget>(
                      (id) => _buildInfoItem(
                        'الفئة | Category',
                        _getCategoryName(id.toString()),
                      ),
                    )
                    .toList()
                : [
                    _buildInfoItem(
                      'الفئة | Category',
                      'لا توجد فئات | No categories',
                    ),
                  ],
          ),
          _buildInfoSection(
            title: 'الخدمات المقدمة | Offered Services',
            children: services.isNotEmpty
                ? services
                    .map<Widget>(
                      (id) => _buildInfoItem(
                        'الخدمة | Service',
                        _getServiceName(id.toString()),
                      ),
                    )
                    .toList()
                : [
                    _buildInfoItem(
                      'الخدمة | Service',
                      'لا توجد خدمات | No services',
                    ),
                  ],
          ),
          _buildInfoSection(
            title: 'نبذة عن الشركة | Business Bio',
            children: [
              _buildInfoItem(
                'عربي | Arabic',
                bioAr,
              ),
              _buildInfoItem(
                'English | إنجليزي',
                bioEn,
              ),
            ],
          ),
          _buildInfoSection(
            title: 'سياسة الإلغاء | Cancellation Policy',
            children: [
              _buildInfoItem(
                'عربي | Arabic',
                policyAr,
              ),
              _buildInfoItem(
                'English | إنجليزي',
                policyEn,
              ),
            ],
          ),
          _buildInfoSection(
            title: 'الفروع | Branches (${branches.length})',
            children: branches.isNotEmpty
                ? branches
                    .map<Widget>(
                      (branch) => _buildBranchItem(branch),
                    )
                    .toList()
                : [
                    _buildInfoItem(
                      'الفروع | Branches',
                      'لا توجد فروع | No branches',
                    ),
                  ],
          ),
          _buildInfoSection(
            title: 'الموظفين | Staff (${staff.length})',
            children: staff.isNotEmpty
                ? staff
                    .map<Widget>(
                      (staffItem) => _buildInfoItem(
                        'الموظف | Staff',
                        staffItem.toString(),
                      ),
                    )
                    .toList()
                : [
                    _buildInfoItem(
                      'الموظفين | Staff',
                      'لا يوجد موظفين | No staff',
                    ),
                  ],
          ),
          _buildInfoSection(
            title: 'معلومات إضافية | Additional Info',
            children: [
              _buildInfoItem(
                'أضيف بواسطة | Added By',
                addedBy.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getActivityName(String activityId) {
    if (activityId.isEmpty) return 'غير معروف / Unknown';
    
    for (final activity in _activities) {
      if (activity['id'] == activityId) {
        return '${activity['name_ar']} / ${activity['name_en']}';
      }
    }
    
    return 'غير معروف / Unknown';
  }

  String _getCategoryName(String categoryId) {
    if (categoryId.isEmpty) return 'غير معروف / Unknown';
    
    for (final activity in _activities) {
      for (final category in (activity['categories'] as List? ?? [])) {
        if (category['id'] == categoryId) {
          return '${category['category_ar']} / ${category['category_en']}';
        }
      }
    }
    
    return 'غير معروف / Unknown';
  }

  String _getServiceName(String serviceId) {
    if (serviceId.isEmpty) return 'غير معروف / Unknown';
    
    for (final activity in _activities) {
      for (final category in (activity['categories'] as List? ?? [])) {
        for (final service in (category['services'] as List? ?? [])) {
          if (service['id'] == serviceId) {
            return '${service['service_ar']} / ${service['service_en']}';
          }
        }
      }
    }
    
    return 'غير معروف / Unknown';
  }

  Widget _buildBranchItem(dynamic branch) {
    final name = branch['name'] ?? {};
    final nameAr = name['ar'] ?? 'غير متاح';
    final nameEn = name['en'] ?? 'Not available';
    
    final address = branch['address'] ?? {};
    final addressAr = address['ar'] ?? 'غير متاح';
    final addressEn = address['en'] ?? 'Not available';
    
    final contactNumber = branch['contact_number'] ?? 'N/A';
    final isActive = branch['is_active'] ?? false;
    final createdAt = branch['created_at'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameAr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  nameEn,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addressAr,
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        addressEn,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.phone_outlined, size: 16),
                const SizedBox(width: 4),
                Text(
                  contactNumber.toString(),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: isActive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                isActive
                    ? 'نشط | Active'
                    : 'غير نشط | Inactive',
                style: TextStyle(
                  fontSize: 13,
                  color: isActive ? Colors.green : Colors.red,
                ),
              ),
              const Spacer(),
              if (createdAt.isNotEmpty)
                Text(
                  'Created: ${createdAt.length > 10 ? createdAt.substring(0, 10) : createdAt}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ),
        const Divider(),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
