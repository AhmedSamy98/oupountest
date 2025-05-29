import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oupountest/features/branch/logic/branch_cubit.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/upload/presentation/pages/phone_number_page.dart';
import 'core/api/dio_client.dart';
import 'core/utils/app_logger.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/offers/presentation/pages/offer_list_page.dart';
import 'features/offers/presentation/pages/offer_delete_page.dart';
import 'features/offers/logic/offer_cubit.dart';
import 'features/business/presentation/pages/business_dashboard_page.dart';
import 'features/branch/presentation/pages/branch_phone_number_page.dart';
import 'features/business/presentation/pages/business_listing_page.dart';
import 'features/business/presentation/pages/business_phone_number_page.dart';
import 'features/branch/presentation/pages/branch_creation_form_page.dart';
import 'features/business/presentation/pages/business_registration_form_page.dart';
import 'features/business/logic/business_registration_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load();          // NEW  تحميل .env
  initLogger();                 // إعداد الـ Logger
  await DioClient.init();       // إعداد Dio
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OfferCubit()..load()),
        BlocProvider(create: (_) => BusinessRegistrationCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Oupoun Admin',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Cairo',
          colorSchemeSeed: const Color(0xff2196f3),
        ),
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: BouncingScrollWrapper.builder(context, child!),
          breakpoints: const [
            Breakpoint(start: 0,    end: 359,  name: MOBILE),
            Breakpoint(start: 360,  end: 799,  name: MOBILE),
            Breakpoint(start: 800,  end: 1199, name: TABLET),
            Breakpoint(start: 1200, end: 1919, name: DESKTOP),
            Breakpoint(start: 1920, end: double.infinity, name: '4K'),
          ],
        ),
        initialRoute: HomePage.route,
        routes: {
          HomePage.route:        (_) => const HomePage(),
          OfferListPage.route:   (_) => const OfferListPage(),
          OfferDeletePage.route: (_) => const OfferDeletePage(),

          PhoneNumberPage.route: (_) => const PhoneNumberPage(),
          BusinessDashboardPage.route: (_) => const BusinessDashboardPage(),
          BranchPhoneNumberPage.route: (_) => const BranchPhoneNumberPage(),
          BusinessListingPage.route: (_) => const BusinessListingPage(),
          BusinessPhoneNumberPage.route: (_) => const BusinessPhoneNumberPage(),
          BranchCreationFormPage.route: (_) => BlocProvider(
            create: (_) => BranchCubit(),
            child: const BranchCreationFormPage(phoneNumber: ''),
          ),
          BusinessRegistrationFormPage.route: (_) =>
          const BusinessRegistrationFormPage(phoneNumber: '', email: ''),
        },
      ),
    );
  }
}
