import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/offer_cubit.dart';
import '../../logic/offer_state.dart';
import '../widgets/offer_card.dart';

class OfferDeletePage extends StatelessWidget {
  const OfferDeletePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OfferCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('حذف العروض')),
      body: FutureBuilder<OfferState>(
        future: cubit.load().then((_) => cubit.state),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData && snapshot.data is OfferLoaded) {
            return ListView.builder(
              itemCount: (snapshot.data as OfferLoaded).list.length,
              itemBuilder: (context, index) {
                final offer = (snapshot.data as OfferLoaded).list[index];
                return OfferCard(
                  offer: offer,
                  onDelete: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('تأكيد الحذف'),
                        content: Text('هل تريد حذف العرض: ${offer.title['ar']}؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: const Text('إلغاء'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('حذف'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) await cubit.delete(offer.id);
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
