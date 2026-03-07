import 'package:bytebox/features/home/admin/admin_home.dart';
import 'package:bytebox/features/home/presentation/home_page_new.dart';
import 'package:bytebox/features/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCYS0i2NaYtWXFjD5IohVHoREygxIMU8NU",
      appId: "1:685282199422:ios:a95ad3f60314f2be5cd52",
      messagingSenderId: "685282199422",
      projectId: "bytebox-96b6a",
      databaseURL: "https://bytebox-96b6a-default-rtdb.firebaseio.com",
    ),
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'RefurbLaptops',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.accent,
              background: Colors.white,
            ),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme.apply(
                    bodyColor: AppColors.textPrimary,
                    displayColor: AppColors.textPrimary,
                  ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                textStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ),
          home: child,
        );
      },
      child: const AdminHomePage(),
    );
  }
}
