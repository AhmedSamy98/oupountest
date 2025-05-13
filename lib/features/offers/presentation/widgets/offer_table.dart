import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../data/models/offer_model.dart';

class OfferTable extends StatelessWidget {
  final List<OfferModel> offers;

  const OfferTable(this.offers, {super.key});

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      columns: const [
        DataColumn(label: Text('العنوان')),
        DataColumn(label: Text('السعر')),
        DataColumn(label: Text('سعر القسيمة')),
        DataColumn(label: Text('الوصف')),
        DataColumn(label: Text('الهاتف')),
        // DataColumn(label: Text('الصور')),
      ],
      rows: offers.map<DataRow>((OfferModel offer) {
        return DataRow(cells: [
          DataCell(Text(offer.title['ar'] ?? '')),
          DataCell(Text(offer.price.toString())),
          DataCell(Text(offer.coupon.toString())),
          DataCell(Text(offer.descriptionAr)),
          DataCell(Text(offer.phoneNumber)),
          // DataCell(
          //   offer.images.isEmpty
          //       ? const Text('No images')
          //       : Column(
          //           children: offer.images
          //               .map((image) => Image.network(image, width: 50, height: 50))
          //               .toList(),
          //         ),
          // ),
        ]);
      }).toList(),
    );
  }
}
