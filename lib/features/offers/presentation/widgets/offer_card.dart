import 'package:flutter/material.dart';
import '../../data/models/offer_model.dart';

class OfferCard extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback onDelete;

  const OfferCard({super.key, required this.offer, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_offer),
        title: Text(offer.title['ar'] ?? ''),
        subtitle: Text('السعر: ${offer.coupon}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_forever),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
