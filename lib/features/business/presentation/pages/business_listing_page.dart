import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:oupountest/features/business/data/models/business_listing_model.dart';

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
  }  Widget _buildBusinessCard(BuildContext context, dynamic businessItem) {
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

    final businessName = business['business_name'] as Map<String, dynamic>?;
    final businessNameAr = businessName?['ar'] ?? 'غير متاح';
    final businessNameEn = businessName?['en'] ?? 'Not available';

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
              businessNameAr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              businessNameEn,
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
            'Contact: $phoneNumber | ${email.isEmpty ? 'N/A' : email}',
            style: const TextStyle(fontSize: 13),
          ),
        ),        children: [
          _buildInfoSection(
            title: 'معلومات الشركة | Business Information',
            children: [
              _buildInfoItem(
                'رقم السجل التجاري | CR Number',
                business['cr_number'] ?? 'N/A',
              ),
              _buildInfoItem(
                'رقم ضريبة القيمة المضافة | VAT Number',
                business['vat_number'] ?? 'N/A',
              ),
              _buildInfoItem(
                'النشاط التجاري | Business Activity',
                business['business_activity'] != null
                    ? '${_getActivityName(business['business_activity'], arabic: true)} / ${_getActivityName(business['business_activity'], arabic: false)}'
                    : 'N/A',
              ),
            ],
          ),
          _buildInfoSection(
            title: 'الفئات المقدمة | Offered Categories',
            children: business['offered_category'] != null && (business['offered_category'] as List).isNotEmpty
                ? (business['offered_category'] as List)
                    .map(
                      (id) => _buildInfoItem(
                        'الفئة | Category',
                        '${_getCategoryName(id, arabic: true)} / ${_getCategoryName(id, arabic: false)}',
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
            children: business['offered_services'] != null && (business['offered_services'] as List).isNotEmpty
                ? (business['offered_services'] as List)
                    .map(
                      (id) => _buildInfoItem(
                        'الخدمة | Service',
                        '${_getServiceName(id, arabic: true)} / ${_getServiceName(id, arabic: false)}',
                      ),
                    )
                    .toList()
                : [
                    _buildInfoItem(
                      'الخدمة | Service',
                      'لا توجد خدمات | No services',
                    ),
                  ],
          ),          if (business['bio'] != null)
            _buildInfoSection(
              title: 'نبذة عن الشركة | Business Bio',
              children: [
                _buildInfoItem(
                  'عربي | Arabic',
                  (business['bio'] as Map<String, dynamic>)['ar'] ?? 'N/A',
                ),
                _buildInfoItem(
                  'English | إنجليزي',
                  (business['bio'] as Map<String, dynamic>)['en'] ?? 'N/A',
                ),
              ],
            ),
          if (business['cancellation_policy'] != null)
            _buildInfoSection(
              title: 'سياسة الإلغاء | Cancellation Policy',
              children: [
                _buildInfoItem(
                  'عربي | Arabic',
                  (business['cancellation_policy'] as Map<String, dynamic>)['ar'] ?? 'N/A',
                ),
                _buildInfoItem(
                  'English | إنجليزي',
                  (business['cancellation_policy'] as Map<String, dynamic>)['en'] ?? 'N/A',
                ),
              ],
            ),          _buildInfoSection(
            title: 'الفروع | Branches (${(business['branches'] as List?)?.length ?? 0})',
            children: business['branches'] != null && (business['branches'] as List).isNotEmpty
                ? (business['branches'] as List)
                    .map<Widget>(
                      (branch) => _buildBranchItem(branch as Map<String, dynamic>),
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
            title: 'الموظفين | Staff (${(business['staff'] as List?)?.length ?? 0})',
            children: business['staff'] != null && (business['staff'] as List).isNotEmpty
                ? (business['staff'] as List)
                    .map(
                      (staff) => _buildInfoItem(
                        'الموظف | Staff',
                        staff.toString(),
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
          if (business['added_by'] != null)
            _buildInfoSection(
              title: 'معلومات إضافية | Additional Info',
              children: [
                _buildInfoItem(
                  'أضيف بواسطة | Added By',
                  business['added_by'].toString(),
                ),
              ],
            ),
        ],
      ),
    );
  }
  Widget _buildBranchItem(Map<String, dynamic> branch) {
    final name = branch['name'] as Map<String, dynamic>?;
    final address = branch['address'] as Map<String, dynamic>?;
    final contactNumber = branch['contact_number'] as String?;
    final isActive = branch['is_active'] as bool? ?? false;
    final createdAt = branch['created_at'] as String?;

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
          if (name != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name['ar'] ?? 'غير متاح',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    name['en'] ?? 'Not available',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          if (address != null)
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
                          address['ar'] ?? 'غير متاح',
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          address['en'] ?? 'Not available',
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
          if (contactNumber != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    contactNumber,
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
              if (createdAt != null)
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
  String _getActivityName(dynamic id, {bool arabic = true}) {
    if (id == null) return 'N/A';
    
    for (final activity in _activities) {
      if (activity['id'] == id) {
        return arabic ? activity['name_ar'] ?? 'N/A' : activity['name_en'] ?? 'N/A';
      }
    }
    return 'N/A';
  }

  String _getCategoryName(dynamic id, {bool arabic = true}) {
    if (id == null) return 'N/A';
    
    for (final activity in _activities) {
      if (activity['categories'] == null) continue;
      
      for (final category in activity['categories']) {
        if (category['id'] == id) {
          return arabic ? category['category_ar'] ?? 'N/A' : category['category_en'] ?? 'N/A';
        }
      }
    }
    return id.toString();
  }

  String _getServiceName(dynamic id, {bool arabic = true}) {
    if (id == null) return 'N/A';
    
    for (final activity in _activities) {
      if (activity['categories'] == null) continue;
      
      for (final category in activity['categories']) {
        if (category['services'] == null) continue;
        
        for (final service in category['services']) {
          if (service['id'] == id) {
            return arabic ? service['service_ar'] ?? 'N/A' : service['service_en'] ?? 'N/A';
          }
        }
      }
    }
    return id.toString();
  }
}
