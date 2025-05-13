import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oupountest/features/create_offer/presentation/pages/create_offer_page.dart';
import 'package:oupountest/features/offers/presentation/pages/offer_delete_page.dart';
import 'package:oupountest/features/offers/presentation/pages/offer_list_page.dart';
import 'core/api/dio_client.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/create_offer/logic/create_offer_cubit.dart';
import 'features/offers/logic/offer_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DioClient.init();  // تهيئة Dio
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CreateOfferCubit()),
        BlocProvider(create: (_) => OfferCubit()..load()), // تحميل مبدئي
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Oupoun Admin',
        theme: ThemeData(useMaterial3: true, fontFamily: 'Cairo'),
        initialRoute: '/',
        routes: {
          '/': (_) => const HomePage(),
          '/create': (_) => const CreateOfferPage(),
          '/list':   (_) => const OfferListPage(),
          '/delete': (_) => const OfferDeletePage(),
        },
      ),
    );
  }
}
