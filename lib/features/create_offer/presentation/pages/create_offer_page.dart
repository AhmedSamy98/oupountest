import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../offers/logic/offer_cubit.dart';
import '../../logic/create_offer_cubit.dart';
import '../../logic/create_offer_state.dart';
import '../widgets/multi_lang_field.dart';

class CreateOfferPage extends StatefulWidget {
  const CreateOfferPage({super.key});

  @override
  State<CreateOfferPage> createState() => _CreateOfferPageState();
}

class _CreateOfferPageState extends State<CreateOfferPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleAr = TextEditingController();
  final _titleEn = TextEditingController();
  final _descAr  = TextEditingController();
  final _descEn  = TextEditingController();
  final _regPrice = TextEditingController();
  final _couponPrice = TextEditingController();

  @override
  void dispose() {
    _titleAr.dispose();
    _titleEn.dispose();
    _descAr.dispose();
    _descEn.dispose();
    _regPrice.dispose();
    _couponPrice.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildBody() {
    return {
      "category_id": "5eb7cf5a86d9755df3a6c593",
      "branch_id": [],
      "offer_title": {"ar": _titleAr.text, "en": _titleEn.text},
      "description": {"ar": _descAr.text, "en": _descEn.text},
      "city_id": [0],
      "options": [
        {
          "service_id": "5eb7cf5a86d9755df3a6c593",
          "option_title": {"ar": _titleAr.text, "en": _titleEn.text},
          "regular_price": num.tryParse(_regPrice.text) ?? 0,
          "oupoun_price": num.tryParse(_couponPrice.text) ?? 0,
        }
      ],
      "hilghlights": {"ar": "", "en": ""},
      "terms_and_conditions": {"ar": "", "en": ""},
      "about_offer": {"ar": "", "en": ""},
      "require_booking": true,
      "phone_number_4booking": "",
      "option_description": {"ar": "", "en": ""},
      "cancellation_policy": {"ar": "", "en": ""},
      "start_date": DateTime.now().toIso8601String().split('T').first,
      "end_date": DateTime.now().toIso8601String().split('T').first,
      "valid_until": 0,
      "valid_unit": "months",
      "offer_label": "all",
      "max_no_orders": 0,
      "amenities": [],
      "phone_number": ""
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة عرض')),
      body: BlocConsumer<CreateOfferCubit, CreateOfferState>(
        listener: (context, state) {
          if (state is CreateOfferSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم الحفظ بنجاح')),
            );
            context.read<OfferCubit>().load();
            Navigator.pop(context);
          } else if (state is CreateOfferError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.msg)),
            );
          }
        },
        builder: (context, state) {
          final loading = state is CreateOfferLoading;
          return AbsorbPointer(
            absorbing: loading,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    MultiLangField(label: 'العنوان', ar: _titleAr, en: _titleEn),
                    const SizedBox(height: 16),
                    MultiLangField(label: 'الوصف', ar: _descAr, en: _descEn),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _regPrice,
                            decoration: const InputDecoration(labelText: 'السعر الأصلي'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _couponPrice,
                            decoration: const InputDecoration(labelText: 'سعر القسيمة'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<CreateOfferCubit>().create(_buildBody());
                        }
                      },
                      icon: loading
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.save),
                      label: const Text('حفظ'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
