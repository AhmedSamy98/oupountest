import 'dart:io';
import 'dart:js' as js;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/models/offer_model.dart';
import '../../logic/offer_cubit.dart';
import '../../logic/offer_state.dart';

class OfferTable extends StatefulWidget {
  final List<OfferModel> offers;

  const OfferTable(this.offers, {super.key});

  @override
  State<OfferTable> createState() => _OfferTableState();
}

class _OfferTableState extends State<OfferTable> {
  String? _deletingOfferId;
  bool _isLoading = false;
  String? _uploadingOfferId;
  double _uploadProgress = 0.0;

  Widget _buildImageCell(BuildContext context, OfferModel offer) {
    final hasImages = offer.images.isNotEmpty;
    final backgroundColor = hasImages ? Colors.green : Colors.red;
    final iconData = hasImages ? Icons.image : Icons.add_photo_alternate;

    return InkWell(
      onTap: () {
        if (hasImages) {
          _showImagesDialog(context, offer);
        } else {
          _showImageUploadDialog(context, offer);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                iconData,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            if (hasImages)
              Text(
                offer.images.length.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DataTable2(
          columns: const [
            DataColumn(label: Text('العنوان')),
            DataColumn(label: Text('السعر')),
            DataColumn(label: Text('سعر القسيمة')),
            DataColumn(label: Text('الوصف')),
            DataColumn(label: Text('ا��هاتف')),
            DataColumn(label: Text('الصور')),
            DataColumn(label: Text('معلومات')),
            DataColumn(label: Text('حذف')),
          ],
          rows: widget.offers.map<DataRow>((OfferModel offer) {
            return DataRow(cells: [
              DataCell(Text(offer.title['ar'] ?? '')),
              DataCell(Text(offer.price.toString())),
              DataCell(Text(offer.coupon.toString())),
              DataCell(Text(offer.descriptionAr)),
              DataCell(Text(offer.phoneNumber ?? '')),
              DataCell(
                _buildImageCell(context, offer),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.blue),
                  tooltip: 'عرض المعلومات الكاملة',
                  onPressed: () => _showOfferDetails(context, offer),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => _confirmDelete(context, offer),
                ),
              ),
            ]);
          }).toList(),
        ),
        
        // Loading overlay when deleting
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
                    child: Text(
                      _deletingOfferId != null ? 'جاري حذف العرض...' : 'جاري التحميل...',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Show dialog to upload images for an offer
  Future<void> _showImageUploadDialog(BuildContext context, OfferModel offer) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('رفع صور للعرض'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('إضافة صور للعرض: ${offer.title['ar']}'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('اختيار صور'),
                onPressed: () => _pickAndUploadFiles(context, offer),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _showImagesDialog(BuildContext context, OfferModel offer) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'صور العرض (${offer.images.length})',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_photo_alternate),
                          tooltip: 'إضافة المزيد من الصور',
                          onPressed: () {
                            Navigator.pop(context);
                            _showImageUploadDialog(context, offer);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                FutureBuilder<List<String>>(
                  future: context.read<OfferCubit>().getOfferImageUrls(offer.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'خطأ في تحميل الصور: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('لا توجد صور متاحة'),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final imageUrl = _getFullImageUrl(snapshot.data![index]);
                            final String imageId = index < offer.images.length ? offer.images[index] : '';

                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    (loadingProgress.expectedTotalBytes ?? 1)
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Text('خطأ في تحميل الصورة'),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () => _confirmDeleteImage(context, offer, imageId),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Convert relative image paths to full URLs
  String _getFullImageUrl(String path) {
    if (path.startsWith('http')) {
      return path;
    }

    // If the path is relative, add the base URL
    return 'https://oupoun-test-272677622251.me-central1.run.app$path';
  }

  // Pick and upload files (for web or mobile)
  Future<void> _pickAndUploadFiles(BuildContext context, OfferModel offer) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        allowCompression: true,
      );

      if (result != null && result.files.isNotEmpty) {
        Navigator.pop(context); // Close the dialog

        // Show upload progress dialog
        _showUploadProgressDialog(context, offer);

        if (kIsWeb) {
          // Handle web uploads
          await context.read<OfferCubit>().uploadWebImages(offer.id, result.files);
        } else {
          // Handle mobile uploads (has File objects with paths)
          List<File> files = result.paths.map((path) => File(path!)).toList();
          await context.read<OfferCubit>().uploadImages(offer.id, files);
        }

        if (!mounted) return;
        
        // Close the progress dialog and show success message
        Navigator.pop(context);
        _showResultMessage('تم رفع الصور بنجاح', Colors.green, Icons.check_circle);
      }
    } catch (e) {
      if (!mounted) return;

      // If dialog is still open, close it
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      _showResultMessage('فشل في رفع الصور: $e', Colors.red, Icons.error);
    }
  }
  
  // Show upload progress dialog
  void _showUploadProgressDialog(BuildContext context, OfferModel offer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BlocConsumer<OfferCubit, OfferState>(
          listener: (context, state) {
            if (state is OfferImageUploaded) {
              // Close progress dialog
              Navigator.pop(context);

              // إعادة تحميل الصفحة بالكامل بعد مهلة قصيرة للسماح بإكمال العمليات
              Future.delayed(const Duration(milliseconds: 300), () {
                if (kIsWeb) {
                  // استخدام JavaScript لإعادة تحميل الصفحة في بيئة الويب
                  // يتم تنفيذه فقط في بيئة الويب
                  js.context.callMethod('eval', ['window.location.reload();']);
                } else {
                  // في بيئة الموبايل نقوم بإعادة تحميل البيانات
                  context.read<OfferCubit>().load();

                  // عرض رسالة نجاح العملية
                  _showResultMessage(
                    'تم رفع الصور بنجاح وتحديث البيانات',
                    Colors.green,
                    Icons.check_circle,
                  );
                }
              });
            } else if (state is OfferImageError) {
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            double progress = 0.0;
            
            if (state is OfferImageUploading && state.offerId == offer.id) {
              progress = state.progress;
            }
            
            return AlertDialog(
              title: const Text('جاري رفع الصور'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 16),
                  Text('${(progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // Confirm deleting an image
  Future<void> _confirmDeleteImage(BuildContext context, OfferModel offer, String imageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد حذف الصورة'),
        content: const Text('هل تريد حذف هذه الصورة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<OfferCubit>().deleteImage(offer.id, imageId);
        
        if (!mounted) return;
        
        // Close the images dialog
        Navigator.pop(context);
        
        // Show success message
        _showResultMessage(
          'تم حذف الصورة بنجاح',
          Colors.green,
          Icons.check_circle,
        );
      } catch (e) {
        if (!mounted) return;
        
        // Show error message
        _showResultMessage(
          'فشل في حذف الصورة: $e',
          Colors.red,
          Icons.error,
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, OfferModel offer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف العرض: ${offer.title['ar']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteOffer(offer.id);
    }
  }

  Future<void> _deleteOffer(String offerId) async {
    setState(() {
      _deletingOfferId = offerId;
      _isLoading = true;
    });

    try {
      await context.read<OfferCubit>().delete(offerId);

      if (!mounted) return;

      // Show success message
      _showResultMessage(
        'تم حذف العرض بنجاح',
        Colors.green,
        Icons.check_circle,
      );
    } catch (e) {
      if (!mounted) return;

      // Show error message
      _showResultMessage(
        'فشل في حذف العرض: $e',
        Colors.red,
        Icons.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _deletingOfferId = null;
        });
      }
    }
  }

  void _showOfferDetails(BuildContext context, OfferModel offer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'معلومات العرض',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(
                          title: 'معلومات أساسية',
                          items: [
                            InfoItem('المعرف', offer.id),
                            InfoItem('تاريخ الإنشاء', offer.createdAt),
                            InfoItem('تاريخ التحديث', offer.updatedAt),
                            InfoItem('معرف العمل', offer.businessId),
                            InfoItem('معرف الفئة', offer.categoryId),
                            InfoItem('معرف المدن', offer.cityIds.join(', ')),
                            InfoItem('معرف الفروع', offer.branchIds.join(', ')),
                          ],
                        ),
                        _buildInfoSection(
                          title: 'تفاصيل العرض',
                          items: [
                            InfoItem('العنوان (عربي)', offer.title['ar'] ?? ''),
                            InfoItem('العنوان (إنجليزي)', offer.title['en'] ?? ''),
                            InfoItem('الوصف (عربي)', offer.description['ar'] ?? ''),
                            InfoItem('الوصف (إنجليزي)', offer.description['en'] ?? ''),
                            InfoItem('النقاط البارزة (عربي)', offer.highlights['ar'] ?? ''),
                            InfoItem('النقاط البارزة (إنجليزي)', offer.highlights['en'] ?? ''),
                            InfoItem('الشروط والأحكام (عربي)', offer.termsAndConditions['ar'] ?? ''),
                            InfoItem('الشروط والأحكام (إنجليزي)', offer.termsAndConditions['en'] ?? ''),
                            InfoItem('حول العرض (عربي)', offer.aboutOffer['ar'] ?? ''),
                            InfoItem('حول العرض (إنجليزي)', offer.aboutOffer['en'] ?? ''),
                            InfoItem('وصف الخيار (عربي)', offer.optionDescription['ar'] ?? ''),
                            InfoItem('وصف الخيار (إنجليزي)', offer.optionDescription['en'] ?? ''),
                            InfoItem('سياسة الإلغاء (عربي)', offer.cancellationPolicy['ar'] ?? ''),
                            InfoItem('سياسة الإلغاء (إنجليزي)', offer.cancellationPolicy['en'] ?? ''),
                          ],
                        ),
                        _buildInfoSection(
                          title: 'خيارات الحجز والتواريخ',
                          items: [
                            InfoItem('يتطلب الحجز', offer.requireBooking ? 'نعم' : 'لا'),
                            InfoItem('رقم الهاتف للحجز', offer.phoneNumber ?? 'غير متاح'),
                            InfoItem('تاريخ البدء', offer.startDate),
                            InfoItem('تاريخ الانتهاء', offer.endDate),
                            InfoItem('صالح حتى', offer.validUntil?.toString() ?? 'غير محدد'),
                            InfoItem('وحدة الصلاحية', offer.validUnit ?? 'غير محدد'),
                            InfoItem('تصنيف العرض', _getOfferLabelText(offer.offerLabel)),
                            InfoItem('الحد الأقصى للطلبات', offer.maxNoOrders.toString()),
                            InfoItem('نشط', offer.isActive ? 'نعم' : 'لا'),
                          ],
                        ),
                        _buildInfoSection(
                          title: 'الصور',
                          items: [
                            InfoItem('عدد الصور', offer.images.length.toString()),
                          ],
                          actions: [
                            TextButton.icon(
                              icon: Icon(
                                offer.images.isNotEmpty ? Icons.image : Icons.add_photo_alternate, 
                                color: offer.images.isNotEmpty ? Colors.green : Colors.red
                              ),
                              label: Text(offer.images.isNotEmpty ? 'عرض الصور' : 'إضافة صور'),
                              onPressed: () {
                                Navigator.pop(context);
                                if (offer.images.isNotEmpty) {
                                  _showImagesDialog(context, offer);
                                } else {
                                  _showImageUploadDialog(context, offer);
                                }
                              },
                            ),
                          ],
                        ),
                        _buildInfoSection(
                          title: 'الخيارات',
                          isExpandable: true,
                          content: Column(
                            children: offer.options.map((option) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('معرف الخيار: ${option.optionId}', 
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('معرف الخدمة: ${option.serviceId}'),
                                      Text('العنوان (عربي): ${option.optionTitle['ar']}'),
                                      Text('العنوان (إنجليزي): ${option.optionTitle['en']}'),
                                      Text('السعر العادي: ${option.regularPrice}'),
                                      Text('سعر أوبون: ${option.oupounPrice}'),
                                      Text('نسبة الخصم: ${(option.discountRate * 100).toStringAsFixed(1)}%'),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getOfferLabelText(String label) {
    switch (label) {
      case 'all':
        return 'الجميع';
      case 'exclusive':
        return 'حصري';
      case 'limited':
        return 'محدود';
      default:
        return 'غير محدد';
    }
  }

  // Show snackbar message for feedback
  void _showResultMessage(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Build info section widget
  Widget _buildInfoSection({
    required String title,
    List<InfoItem>? items,
    Widget? content,
    bool isExpandable = false,
    List<Widget>? actions,
  }) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: !isExpandable,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content ?? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items!.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            '${item.label}:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.value,
                            style: const TextStyle(
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (actions != null && actions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Item model for info section
class InfoItem {
  final String label;
  final String value;

  InfoItem(this.label, this.value);
}
