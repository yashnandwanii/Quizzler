import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:wallpaper_app/controller/dependency_injection.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:wallpaper_app/views/home/main_tab_view.dart';
import 'package:wallpaper_app/views/screens/quiz_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wallpaper_app/services/enhanced_category_service.dart';
import 'firebase_options.dart';

late final bool isLoggedIn;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  Get.put(AuthenticationRepository());
  final box = GetStorage();
  isLoggedIn = box.read('isLoggedIn') == true;
  DependencyInjection.init();
  
  // Initialize enhanced categories on app start
  await EnhancedCategoryService.initializeEnhancedCategories();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      child: GetMaterialApp(
        themeMode: ThemeMode.system,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        defaultTransition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 500),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splashIconSize: 400.h,
      duration: 1200,
      splash: Lottie.asset('assets/animation.json'),
      nextScreen: isLoggedIn ? const MainTabView() : const QuizSplashScreen(),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.bottomToTop,
      backgroundColor: Colors.white,
    );
  }
}