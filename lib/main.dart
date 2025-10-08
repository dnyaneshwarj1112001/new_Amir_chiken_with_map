import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meatzo/screens/Mycart/cubit/counter_cubit_cubit.dart';
import 'package:meatzo/presentation/Global_widget/app_routes.dart';
import 'package:meatzo/presentation/Global_widget/SplashScreen.dart';
import 'package:hive_flutter/hive_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterCubitCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Meatzo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          textTheme: GoogleFonts.montserratTextTheme(),
        ),
        home: SplashScreen(),
        routes: AppRoutes.routes,
      ),
    );
  }
}

