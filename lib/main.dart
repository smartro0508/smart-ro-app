import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'routes/router.dart';
import 'theme/app_colors.dart';
import 'service/auth_service.dart';
import 'controller/auth_cubit.dart';
import 'service/customer_service.dart';
import 'controller/customer_cubit.dart';
import 'service/setting_service.dart';
import 'controller/setting_cubit.dart';
import 'service/invoice_service.dart';
import 'controller/invoice_cubit.dart';
import 'service/product_service.dart';
import 'controller/product_cubit.dart';
import 'service/service_service.dart';
import 'controller/service_cubit.dart';
import 'service/bank_service.dart';
import 'controller/bank_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('authBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(AuthService())),
        BlocProvider(create: (context) => CustomerCubit(CustomerService())),
        BlocProvider(create: (context) => SettingCubit(SettingService())),
        BlocProvider(create: (context) => InvoiceCubit(InvoiceService())),
        BlocProvider(create: (context) => ProductCubit(ProductService())),
        BlocProvider(create: (context) => ServiceCubit(ServiceService())),
        BlocProvider(create: (context) => BankCubit(BankService())),
      ],
      child: MaterialApp.router(
        title: 'Smart RO App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.primaryLight,
            surface: AppColors.surface,
            error: AppColors.error,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.primaryDark,
            elevation: 0,
            scrolledUnderElevation: 2,
            shadowColor: Colors.black.withOpacity(0.05),
            centerTitle: false,
            shape: const Border(
              bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            ),
            titleTextStyle: GoogleFonts.poppins(
              color: AppColors.primaryDark,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
            iconTheme: const IconThemeData(color: AppColors.primaryDark),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .apply(
                bodyColor: AppColors.textPrimary,
                displayColor: AppColors.textPrimary,
              ),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
