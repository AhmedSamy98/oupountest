import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/offer_cubit.dart';
import '../../logic/offer_state.dart';
import '../widgets/offer_table.dart';

class OfferListPage extends StatelessWidget {
  const OfferListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OfferCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('جميع العروض')),
      body: FutureBuilder<OfferState>(
        future: cubit.load().then((_) => cubit.state),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData && snapshot.data is OfferLoaded) {
            return OfferTable((snapshot.data as OfferLoaded).list);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
