import 'package:flutter/material.dart';

import '../../logic/branch_fetch_cubit.dart';
import '../../data/branch_model.dart';
import 'offer_form_page.dart';

class PhoneNumberPage extends StatefulWidget {
  static const route = '/upload-phone';

  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final _controller = TextEditingController();
  final _cubit = BranchFetchCubit();

  @override
  void dispose() {
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _handleFetch() async {
    final phone = _controller.text.trim();
    if (phone.isEmpty) return;

    final List<BranchModel> branches = await _cubit.fetch(phone);

    if (branches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا تملك صلاحيات لإضافة عرض.')),
      );
      return;
    }

    // الانتقال لصفحة الفورم مع تمرير الفروع ورقم الهاتف
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OfferFormPage(
            phoneNumber: phone,
            branches: branches,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رقم مدير التسجيل')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleFetch,
              child: const Text('تحقق من الصلاحيات'),
            ),
          ],
        ),
      ),
    );
  }
}
