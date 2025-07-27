import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:wallpaper_app/controller/dependency_injection.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:wallpaper_app/views/home/main_tab_view.dart';
import 'package:wallpaper_app/views/screens/quiz_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wallpaper_app/services/enhanced_category_service.dart';
import 'package:wallpaper_app/services/gemini_ai_service.dart';
import 'package:wallpaper_app/services/settings_service.dart';
import 'firebase_options.dart';

late final bool isLoggedIn;
void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await GetStorage.init();
    Get.put(AuthenticationRepository());

    // Initialize SettingsService early
    Get.put(SettingsService());

    final box = GetStorage();
    isLoggedIn = box.read('isLoggedIn') == true;
    DependencyInjection.init();

    await EnhancedCategoryService.initializeEnhancedCategories();

    try {
      Get.put(GeminiAIService());
    } catch (e) {
      debugPrint('Warning: GeminiAI service initialization failed: $e');
    }

    runApp(const MyApp());
  } catch (e) {
    debugPrint('App initialization error: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'App Initialization Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Restart app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = Get.find<SettingsService>();

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Updated to iPhone X dimensions
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() => GetMaterialApp(
              themeMode: ThemeMode.light,
              theme: ThemeData(
                useMaterial3: true,
                primarySwatch: Colors.blue,
                brightness: Brightness.light,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.indigo,
                  brightness: Brightness.light,
                ),
                textTheme: Theme.of(context).textTheme.apply(
                      fontSizeFactor: settingsService.fontSizeScale,
                    ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
              debugShowCheckedModeBanner: false,
              defaultTransition: Transition.leftToRightWithFade,
              transitionDuration: Duration(
                milliseconds: settingsService.animationsEnabled ? 500 : 200,
              ),
              builder: (context, widget) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      (MediaQuery.of(context).textScaleFactor *
                              settingsService.fontSizeScale)
                          .clamp(0.8, 1.5),
                    ),
                  ),
                  child: widget!,
                );
              },
              home: const SplashScreen(),
            ));
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(
        const Duration(milliseconds: 2400)); // Wait for animation to complete
    if (mounted) {
      Get.off(
        () => isLoggedIn ? const MainTabView() : const QuizSplashScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 400.w,
          height: 400.h,
          child: Lottie.asset(
            'assets/animation.json',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
